import { pool, withTransaction } from "../connection";
import { Access, AccessCreate, AccessUpdate, AccessCreateRequest, ExitRequest, FeeUpdateRequest, ACCESS_STATUS } from "../../models/access";
import { BadRequestError } from "../../utils/error";
import { getSchemaValidator } from "elysia";
import { VehicleCreateSchema } from "../../models/vehicle";
import { calculateParkingFee } from "../../utils/common";
import { randomUUID } from "crypto";
import { cashRegisterCrud } from "./cash-register";
import { movementCrud } from "./movement";
import { parkingCrud } from "./parking";
import { SPOT_SUBTYPES } from "../../models/parking";

class AccessCrud {
  /**
   * Map vehicle type string to vehicle category integer
   */
  private mapVehicleTypeToCategory(vehicleType: string): number {
    switch (vehicleType.toLowerCase()) {
      case 'bicycle':
      case 'bycicle': // in case of typo
        return SPOT_SUBTYPES.BYCICLE;
      case 'motorcycle':
        return SPOT_SUBTYPES.MOTORCYCLE;
      case 'car':
        return SPOT_SUBTYPES.CAR;
      case 'truck':
        return SPOT_SUBTYPES.TRUCK;
      default:
        return SPOT_SUBTYPES.CAR; // default to car
    }
  }

  generateNumber = async (parkingId: string): Promise<number> => {
    const result = await pool.query(`
      SELECT COALESCE(MAX("number"), 0) + 1 as next_number
      FROM t_access
      WHERE "parkingId" = $1
    `, [parkingId]);

    return result.rows[0].next_number;
  };

  /**
   * Obtener un acceso por ID
   */
  getById = async (id: string): Promise<Access | null> => {
    const accesss = await this.find({ id: id });
    if (accesss.length === 0) {
      return null;
    }
    return accesss[0];
  };

  /**
   * Buscar accesos por filtros
   */
  async find (filters: {
    id?: string;
    parkingId?: string;
    employeeId?: string;
    vehicleId?: string;
    vehiclePlate?: string;
    spotId?: string;
    status?: string;
    startDate?: string;
    endDate?: string;
    inParking?: boolean;
  } = {}): Promise<Access[]> {
    const conditions: string[] = [];
    const values: any[] = [];
    let paramIndex = 1;

    if (filters.id) {
      conditions.push(`a."id" = $${paramIndex++}`);
      values.push(filters.id);
    }

    if (filters.parkingId) {
      conditions.push(`a."parkingId" = $${paramIndex++}`);
      values.push(filters.parkingId);
    }

    if (filters.employeeId) {
      conditions.push(`a."employeeId" = $${paramIndex++}`);
      values.push(filters.employeeId);
    }

    if (filters.vehicleId) {
      conditions.push(`a."vehicleId" = $${paramIndex++}`);
      values.push(filters.vehicleId);
    }

    if (filters.vehiclePlate) {
      conditions.push(`v."plate" ILIKE $${paramIndex++}`);
      values.push(`%${filters.vehiclePlate}%`);
    }

    if (filters.spotId) {
      conditions.push(`a."spotId" = $${paramIndex++}`);
      values.push(filters.spotId);
    }

    if (filters.status) {
      conditions.push(`a."status" = $${paramIndex++}`);
      values.push(filters.status);
    }

    if (filters.startDate) {
      conditions.push(`a."entryTime" >= $${paramIndex++}`);
      values.push(filters.startDate);
    }

    if (filters.endDate) {
      conditions.push(`a."entryTime" <= $${paramIndex++}`);
      values.push(filters.endDate);
    }
    if (filters.inParking) {
      conditions.push(`a."exitTime" IS NULL`);
    }

    const whereClause = conditions.length > 0 ? `WHERE ${conditions.join(" AND ")}` : "";

    const result = await pool.query(`
      SELECT
        a.id,
        a."entryTime",
        a."exitTime",
        a."status",
        a."amount",
        a."number",
        a."notes",
        json_build_object(
          'id', a."parkingId",
          'name', p."name",
          'address', p."address"
        ) as parking,
        json_build_object(
          'id', a."employeeId",
          'name', u."name",
          'email', u."email",
          'phone', u."phone",
          'role', e."role"
        ) as employee,
        (
          case when a."exitEmployeeId" is null then null else json_build_object(
            'id', a."exitEmployeeId",
            'role', ee."role",
            'name', eu."name",
            'email', eu."email",
            'phone', eu."phone"
          ) end
        ) as "exitEmployee",
        json_build_object(
          'id', a."vehicleId",
          'plate', v."plate",
          'type', v."type",
          'color', v."color",
          'ownerName', v."ownerName",
          'ownerDocument', v."ownerDocument",
          'ownerPhone', v."ownerPhone",
          'isSubscribed', v."isSubscribed"
        ) as vehicle,
        ( 
          case when a."spotId" is null then null else json_build_object(
            'id', a."spotId",
            'name', s."name",
            'type', s."type",
            'subType', s."subType"
          ) end
        ) as spot
      FROM t_access a
      LEFT JOIN t_vehicle v ON a."vehicleId" = v.id
      LEFT JOIN t_parking p ON a."parkingId" = p.id
      LEFT JOIN t_employee e ON a."employeeId" = e.id
      LEFT JOIN t_user u ON e."userId" = u.id
      LEFT JOIN t_employee ee ON a."exitEmployeeId" = ee.id
      LEFT JOIN t_user eu ON ee."userId" = eu.id
      LEFT JOIN t_element s ON a."spotId" = s.id
      ${whereClause}
      ORDER BY a."entryTime" DESC
    `, values);

    return result.rows;
  };

  create = async (data: AccessCreateRequest, parkingId: string, employeeId: string): Promise<Access> => {
    const access = await withTransaction(async (client) => {
      const { vehiclePlate, vehicleType, vehicleColor, ownerName, ownerDocument, ownerPhone, spotId, notes } = data;

      // Buscar vehículo existente o crear uno nuevo
      const vehicleResult = await client.query<{ id: string, plate: string }>(`
        SELECT id, plate FROM t_vehicle WHERE plate = $1 AND "deletedAt" IS NULL LIMIT 1
      `, [vehiclePlate]);

      let vehicle = vehicleResult.rows[0];

      // Verificar si ya existe un acceso activo para este vehículo
      if (vehicle) {
        const existingAccessResult = await client.query(`
          SELECT id FROM t_access
          WHERE "vehicleId" = $1 AND "exitTime" IS NULL AND "status" = $2
        `, [vehicle.id, ACCESS_STATUS.VALID]);

        if (existingAccessResult.rows.length > 0) {
          throw new BadRequestError(`Ya existe un acceso activo para el vehículo con placa ${vehiclePlate}`);
        }
      }

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
          isSubscribed: false,
          id: randomUUID(),
          createdAt: new Date().toISOString(),
        });

        const newVehicle = await client.query<{ id: string, plate: string }>(`
          INSERT INTO t_vehicle (id, plate, type, color, "ownerName", "ownerDocument", "ownerPhone", "parkingId", "isSubscribed", "createdAt")
          VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
          RETURNING id
        `, [vehicleData.id, vehicleData.plate, vehicleData.type, vehicleData.color, vehicleData.ownerName, vehicleData.ownerDocument, vehicleData.ownerPhone, vehicleData.parkingId, vehicleData.isSubscribed, vehicleData.createdAt]);
        vehicle = newVehicle.rows[0];
      }

      // Generar número de acceso
      const number = await this.generateNumber(parkingId);

      // Crear el acceso
      const accessData = {
        id: randomUUID(),
        createdAt: new Date().toISOString(),
        number,
        parkingId,
        employeeId,
        vehicleId: vehicle.id,
        spotId: spotId || null,
        entryTime: new Date().toISOString(),
        exitTime: null,
        exitEmployeeId: null,
        amount: 0, // Se calcula al salir
        status: ACCESS_STATUS.VALID,
        notes: notes || null,
      };

      const columns = Object.keys(accessData)
        .map((key) => `"${key}"`)
        .join(", ");
      const values = Object.values(accessData);
      const placeholders = values.map((_, i) => `$${i + 1}`).join(", ");

      const result = await client.query(`
        INSERT INTO t_access (${columns})
        VALUES (${placeholders})
        RETURNING *
      `, values);

      return result.rows[0];
    });

    const result = await this.getById(access.id);
    if (!result) {
      throw new BadRequestError("Error al crear el acceso");
    }
    return result;
  };

  /**
     * Registrar salida de un vehículo
     */
    registerExit = async (id: string, exitEmployeeId: string, data: Omit<ExitRequest, 'exitEmployeeId'>): Promise<Access> => {
     const { notes } = data;

     return await withTransaction(async (client) => {
       // Get the access record to calculate the fee
       const access = await this.getById(id);
       if (!access) {
         throw new BadRequestError("Acceso no encontrado");
       }

       // Get parking rates
       const parking = await parkingCrud.findById(access.parking.id);
       if (!parking || !parking.rates) {
         throw new BadRequestError("No se encontraron tarifas para el estacionamiento");
       }

       // Map vehicle type to category
       const vehicleCategory = this.mapVehicleTypeToCategory(access.vehicle.type);

       // Calculate parking fee
       const entryTimeStr = typeof access.entryTime === 'string' ? access.entryTime : access.entryTime.toISOString();
       const calculatedAmount = calculateParkingFee(entryTimeStr, parking.rates, vehicleCategory) || 2;
       const updates: string[] = [];
       const values: any[] = [];
       let paramIndex = 1;

       updates.push(`"exitTime" = $${paramIndex++}`);
       values.push(new Date().toISOString());

       updates.push(`"exitEmployeeId" = $${paramIndex++}`);
       values.push(exitEmployeeId);

       updates.push(`"amount" = $${paramIndex++}`);
       values.push(calculatedAmount);

       if (notes !== undefined) {
         updates.push(`"notes" = $${paramIndex++}`);
         values.push(notes);
       }

       updates.push(`"status" = $${paramIndex++}`);
       values.push(ACCESS_STATUS.VALID);

       updates.push(`"updatedAt" = $${paramIndex++}`);
       values.push(new Date().toISOString());

       values.push(id);

       const result = await client.query(`
         UPDATE t_access
         SET ${updates.join(", ")}
         WHERE "id" = $${paramIndex}
         RETURNING *
       `, values);

       if (result.rows.length === 0) {
         throw new BadRequestError("Acceso no encontrado");
       }

       // Crear movimiento de caja si hay caja registradora activa y monto > 0
       if (calculatedAmount > 0) {
         const currentCashRegister = await cashRegisterCrud.getCurrentByEmployee(exitEmployeeId);
         if (currentCashRegister) {
           await movementCrud.create({
             cashRegisterId: currentCashRegister.id,
             originId: id,
             type: 'income',
             originType: 'access',
             amount: calculatedAmount,
             description: `cobro a vehiculo: ${access.vehicle.plate}`,
           });
         }
       }

       const updatedAccess = await this.getById(id);
       if (!updatedAccess) {
         throw new BadRequestError("Error al obtener el acceso actualizado");
       }
       return updatedAccess;
     });
   };

  /**
   * Actualizar un acceso
   */
  async update (id: string, data: AccessUpdate): Promise<Access | null> {
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
      return this.getById(id);
    }

    values.push(id);
    const result = await pool.query(`
      UPDATE t_access
      SET ${updates.join(", ")}
      WHERE "id" = $${paramIndex}
      RETURNING *
    `, values);

    return result.rows[0] || null;
  };

  /**
   * Eliminar un acceso
   */
  async delete  (id: string): Promise<boolean> {
    const result = await pool.query(`
      DELETE FROM t_access WHERE "id" = $1
    `, [id]);

    return result.rowCount ? result.rowCount > 0 : false;
  };


  /**
   * Obtener estadísticas de accesos por parking
   */
  async getStats(parkingId: string): Promise<{
    today: { vehiclesAttended: number; collection: number; currentVehiclesInParking: number };
    weekly: { vehiclesAttended: number; collection: number };
    monthly: { vehiclesAttended: number; collection: number };
  }> {
    const now = new Date();
    const startOfToday = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    const startOfWeek = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
    const startOfMonth = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);

    // Current vehicles in parking
    const currentResult = await pool.query(`
      SELECT COUNT(*) as currentVehiclesInParking
      FROM t_access
      WHERE "parkingId" = $1 AND "exitTime" IS NULL
    `, [parkingId]);

    // Today stats
    const todayResult = await pool.query(`
      SELECT
        COUNT(CASE WHEN "exitTime" >= $2 THEN 1 END) as vehiclesAttended,
        COALESCE(SUM(CASE WHEN "exitTime" >= $2 THEN "amount" END), 0) as collection
      FROM t_access
      WHERE "parkingId" = $1
    `, [parkingId, startOfToday.toISOString()]);

    // Weekly stats
    const weeklyResult = await pool.query(`
      SELECT
        COUNT(CASE WHEN "exitTime" >= $2 THEN 1 END) as vehiclesAttended,
        COALESCE(SUM(CASE WHEN "exitTime" >= $2 THEN "amount" END), 0) as collection
      FROM t_access
      WHERE "parkingId" = $1
    `, [parkingId, startOfWeek.toISOString()]);

    // Monthly stats
    const monthlyResult = await pool.query(`
      SELECT
        COUNT(CASE WHEN "exitTime" >= $2 THEN 1 END) as vehiclesAttended,
        COALESCE(SUM(CASE WHEN "exitTime" >= $2 THEN "amount" END), 0) as collection
      FROM t_access
      WHERE "parkingId" = $1
    `, [parkingId, startOfMonth.toISOString()]);

    return {
      today: {
        vehiclesAttended: parseInt(todayResult.rows[0].vehiclesattended || 0),
        collection: parseFloat(todayResult.rows[0].collection || 0),
        currentVehiclesInParking: parseInt(currentResult.rows[0].currentvehiclesinparking || 0)
      },
      weekly: {
        vehiclesAttended: parseInt(weeklyResult.rows[0].vehiclesattended || 0),
        collection: parseFloat(weeklyResult.rows[0].collection || 0)
      },
      monthly: {
        vehiclesAttended: parseInt(monthlyResult.rows[0].vehiclesattended || 0),
        collection: parseFloat(monthlyResult.rows[0].collection || 0)
      }
    };
  };

}

export const accessCrud = new AccessCrud();
