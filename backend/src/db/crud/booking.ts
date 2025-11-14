import { pool, withTransaction } from "../connection";
import { Booking, BookingCreate, BookingUpdate, BookingCreateRequest, RESERVATION_STATUS } from "../../models/booking";
import { BadRequestError } from "../../utils/error";
import { getSchemaValidator } from "elysia";
import { VehicleCreateSchema } from "../../models/vehicle";
import { randomUUID } from "crypto";

export const bookingCrud = {
  // ===== OPERACIONES BÁSICAS =====
  
  /**
   * Crear una nueva reserva
   */
  async createBooking(data: BookingCreateRequest, parkingId: string, employeeId: string): Promise<Booking> {
    const booking = await withTransaction(async (client) => {
      const { vehiclePlate, vehicleType, vehicleColor, ownerName, ownerDocument, ownerPhone, spotId, startDate, duration, notes } = data;
      
      // Buscar vehículo existente o crear uno nuevo
      const vehicleResult = await client.query<{ id: string, plate: string }>(`
        SELECT id, plate FROM t_vehicle WHERE plate = $1 AND "deletedAt" IS NULL LIMIT 1
      `, [vehiclePlate]);

      let vehicle = vehicleResult.rows[0];
      
      if (!vehicle) {
        const vehicleValidator = getSchemaValidator(VehicleCreateSchema)
        const vehicleData = vehicleValidator.parse({
          plate: vehiclePlate,
          type: vehicleType || "car",
          color: vehicleColor,
          ownerName: ownerName,
          ownerDocument: ownerDocument,
          ownerPhone: ownerPhone,
          parkingId: parkingId,
          id: randomUUID(),
          createdAt: new Date().toISOString(),
        });
        
        const newVehicle = await client.query<{ id: string, plate: string }>(`
          INSERT INTO t_vehicle (id, plate, type, color, "ownerName", "ownerDocument", "ownerPhone", "parkingId", "createdAt")
          VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
          RETURNING *
        `, [vehicleData.id, vehicleData.plate, vehicleData.type, vehicleData.color, vehicleData.ownerName, vehicleData.ownerDocument, vehicleData.ownerPhone, vehicleData.parkingId, vehicleData.createdAt]);
        vehicle = newVehicle.rows[0];
      }

      // Generar número de reserva
      const number = await this.generateBookingNumber(parkingId);

      // Calcular fecha de fin
      const startDateTime = new Date(startDate);
      const endDateTime = new Date(startDateTime.getTime() + duration * 60 * 60 * 1000); // duration en horas

      // Crear la reserva
      const bookingData = {
        id: randomUUID(),
        createdAt: new Date().toISOString(),
        number,
        parkingId,
        employeeId,
        vehicleId: vehicle.id,
        spotId: spotId || null,
        startDate: startDateTime.toISOString(),
        endDate: endDateTime.toISOString(),
        amount: 0, // Se calcula después
        status: RESERVATION_STATUS.PENDING,
        notes: notes || null,
      };

      const columns = Object.keys(bookingData)
        .map((key) => `"${key}"`)
        .join(", ");
      const values = Object.values(bookingData);
      const placeholders = values.map((_, i) => `$${i + 1}`).join(", ");
      
      const result = await client.query(`
        INSERT INTO t_booking (${columns})
        VALUES (${placeholders})
        RETURNING *
      `, values);
        
      return result.rows[0];
    });

    const result = await this.getBookingById(booking.id);
    if (!result) {
      throw new BadRequestError("Error al crear la reserva");
    }
    return result;
  },

  /**
   * Buscar reservas por filtros
   */
  async findBookings(filters: {
    id?: string;
    parkingId?: string;
    employeeId?: string;
    vehicleId?: string;
    spotId?: string;
    status?: string;
    startDate?: string;
    endDate?: string;
  } = {}): Promise<Booking[]> {
    const conditions: string[] = []; // Ya no necesitamos filtrar por type porque t_booking solo maneja reservas
    const values: any[] = [];
    let paramIndex = 1;

    if (filters.id) {
      conditions.push(`b."id" = $${paramIndex++}`);
      values.push(filters.id);
    }

    if (filters.parkingId) {
      conditions.push(`b."parkingId" = $${paramIndex++}`);
      values.push(filters.parkingId);
    }

    if (filters.employeeId) {
      conditions.push(`b."employeeId" = $${paramIndex++}`);
      values.push(filters.employeeId);
    }

    if (filters.vehicleId) {
      conditions.push(`b."vehicleId" = $${paramIndex++}`);
      values.push(filters.vehicleId);
    }

    if (filters.spotId) {
      conditions.push(`b."spotId" = $${paramIndex++}`);
      values.push(filters.spotId);
    }

    if (filters.status) {
      conditions.push(`b."status" = $${paramIndex++}`);
      values.push(filters.status);
    }

    if (filters.startDate) {
      conditions.push(`b."startDate" >= $${paramIndex++}`);
      values.push(filters.startDate);
    }

    if (filters.endDate) {
      conditions.push(`b."endDate" <= $${paramIndex++}`);
      values.push(filters.endDate);
    }

    const whereClause = conditions.length > 0 ? `WHERE ${conditions.join(" AND ")}` : "";

    const result = await pool.query(`
      SELECT 
        b.id,
        b."startDate",
        b."endDate",
        b."status",
        b."amount",
        b."number",
        b."notes",
        json_build_object(
          'id', b."parkingId",
          'name', p."name"
        ) as parking,
        json_build_object(
          'id', b."employeeId",
          'name', u."name",
          'email', u."email",
          'phone', u."phone"
        ) as employee,
        json_build_object(
          'id', b."vehicleId",
          'plate', v."plate",
          'type', v."type",
          'color', v."color",
          'ownerName', v."ownerName",
          'ownerDocument', v."ownerDocument",
          'ownerPhone', v."ownerPhone"
        ) as vehicle
      FROM t_booking b
      LEFT JOIN t_vehicle v ON b.vehicleId = v.id
      LEFT JOIN t_parking p ON b.parkingId = p.id
      LEFT JOIN t_employee e ON b.employeeId = e.id
      LEFT JOIN t_user u ON e.userId = u.id
      ${whereClause}
      ORDER BY b."startDate" DESC
    `, values);

    return result.rows;
  },

  /**
   * Obtener una reserva por ID
   */
  async getBookingById(id: string): Promise<Booking | null> {
    const bookings = await this.findBookings({ id: id });
    if (bookings.length === 0) {
      return null;
    }
    return bookings[0];
  },

  /**
   * Actualizar una reserva
   */
  async updateBooking(id: string, data: BookingUpdate): Promise<Booking | null> {
    const updates: string[] = [];
    const values: any[] = [];
    let paramIndex = 1;

    // Agregar updatedAt automáticamente
    updates.push(`"updatedAt" = $${paramIndex++}`);
    values.push(new Date().toISOString());

    Object.entries(data).forEach(([key, value]) => {
      if (value !== undefined) {
        updates.push(`"${key}" = $${paramIndex++}`);
        values.push(typeof value === "object" && value !== null ? JSON.stringify(value) : value);
      }
    });

    if (updates.length === 1) { // Solo updatedAt
      return this.getBookingById(id);
    }

    values.push(id);
    const result = await pool.query(`
      UPDATE t_booking 
      SET ${updates.join(", ")}
      WHERE "id" = $${paramIndex}
      RETURNING *
    `, values);

    return result.rows[0] || null;
  },

  /**
   * Eliminar una reserva
   */
  async deleteBooking(id: string): Promise<boolean> {
    const result = await pool.query(`
      DELETE FROM t_booking WHERE "id" = $1
    `, [id]);

    return result.rowCount ? result.rowCount > 0 : false;
  },

  // ===== OPERACIONES ESPECÍFICAS =====

  /**
   * Obtener reservas activas para un spot
   */
  async getActiveBookingsForSpot(spotId: string, date?: string): Promise<Booking[]> {
    const targetDate = date || new Date().toISOString();
    
    const result = await pool.query(`
      SELECT * FROM t_booking 
      WHERE "spotId" = $1 
        AND "status" IN ('pending', 'active')
        AND "startDate" <= $2 
        AND "endDate" >= $2
      ORDER BY "createdAt" DESC
    `, [spotId, targetDate]);

    return result.rows;
  },

  /**
   * Obtener reservas activas para un vehículo
   */
  async getActiveBookingsForVehicle(vehicleId: string): Promise<Booking[]> {
    const result = await pool.query(`
      SELECT * FROM t_booking 
      WHERE "vehicleId" = $1 
        AND "status" IN ('pending', 'active')
        AND "endDate" >= NOW()
      ORDER BY "createdAt" DESC
    `, [vehicleId]);

    return result.rows;
  },

  /**
   * Obtener estadísticas de reservas por parking
   */
  async getBookingStats(parkingId: string, startDate?: string, endDate?: string): Promise<{
    total: number;
    byStatus: { [key: string]: number };
  }> {
    const conditions = [`"parkingId" = $1`];
    const values = [parkingId];
    let paramIndex = 2;

    if (startDate) {
      conditions.push(`"createdAt" >= $${paramIndex++}`);
      values.push(startDate);
    }

    if (endDate) {
      conditions.push(`"createdAt" <= $${paramIndex++}`);
      values.push(endDate);
    }

    const whereClause = conditions.join(" AND ");

    const result = await pool.query(`
      SELECT 
        COUNT(*) as total,
        "status"
      FROM t_booking 
      WHERE ${whereClause}
      GROUP BY "status"
    `, values);

    const stats = {
      total: 0,
      byStatus: {} as { [key: string]: number }
    };

    result.rows.forEach(row => {
      stats.total += parseInt(row.total);
      stats.byStatus[row.status] = (stats.byStatus[row.status] || 0) + parseInt(row.total);
    });

    return stats;
  },

  /**
   * Generar número único para una reserva
   */
  async generateBookingNumber(parkingId: string): Promise<number> {
    const result = await pool.query(`
      SELECT COALESCE(MAX("number"), 0) + 1 as next_number
      FROM t_booking 
      WHERE "parkingId" = $1
    `, [parkingId]);

    return result.rows[0].next_number;
  },
};
