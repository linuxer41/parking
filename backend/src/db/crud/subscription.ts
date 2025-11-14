import { pool, withTransaction } from "../connection";
import { Subscription, SubscriptionCreate, SubscriptionUpdate, SubscriptionCreateRequest, SubscriptionRenewalRequest, SUBSCRIPTION_STATUS, SUBSCRIPTION_PERIOD } from "../../models/subscription";
import { BadRequestError } from "../../utils/error";
import { getSchemaValidator } from "elysia";
import { VehicleCreateSchema } from "../../models/vehicle";
import { randomUUID } from "crypto";

export const subscriptionCrud = {
  // ===== OPERACIONES BÁSICAS =====
  
  /**
   * Crear una nueva suscripción
   */
  async createSubscription(data: SubscriptionCreateRequest, parkingId: string, employeeId: string): Promise<Subscription> {
    const subscription = await withTransaction(async (client) => {
      const { vehiclePlate, vehicleType, vehicleColor, ownerName, ownerDocument, ownerPhone, spotId, startDate, period, amount, notes } = data;
      
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
          isSubscribed: false,
          id: randomUUID(),
          createdAt: new Date().toISOString(),
        });
        
        const newVehicle = await client.query<{ id: string, plate: string }>(`
          INSERT INTO t_vehicle (id, plate, type, color, "ownerName", "ownerDocument", "ownerPhone", "parkingId", "isSubscribed", "createdAt")
          VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
          RETURNING *
        `, [vehicleData.id, vehicleData.plate, vehicleData.type, vehicleData.color, vehicleData.ownerName, vehicleData.ownerDocument, vehicleData.ownerPhone, vehicleData.parkingId, vehicleData.isSubscribed, vehicleData.createdAt]);
        vehicle = newVehicle.rows[0];
      }

      // Generar número de suscripción
      const number = await this.generateSubscriptionNumber(parkingId);

      // Calcular fecha de fin según el periodo
      const startDateTime = new Date(startDate);
      let endDateTime: Date;
      
      switch (period) {
        case SUBSCRIPTION_PERIOD.WEEKLY:
          endDateTime = new Date(startDateTime.getTime() + 7 * 24 * 60 * 60 * 1000);
          break;
        case SUBSCRIPTION_PERIOD.MONTHLY:
          endDateTime = new Date(startDateTime.getTime() + 30 * 24 * 60 * 60 * 1000);
          break;
        case SUBSCRIPTION_PERIOD.YEARLY:
          endDateTime = new Date(startDateTime.getTime() + 365 * 24 * 60 * 60 * 1000);
          break;
        default:
          throw new BadRequestError("Periodo de suscripción no válido");
      }

      // Crear la suscripción
      const subscriptionData = {
        id: randomUUID(),
        createdAt: new Date().toISOString(),
        number,
        parkingId,
        employeeId,
        vehicleId: vehicle.id,
        spotId: spotId || null,
        startDate: startDateTime.toISOString(),
        endDate: endDateTime.toISOString(),
        amount: amount || 0,
        status: SUBSCRIPTION_STATUS.ACTIVE,
        period,
        isActive: true,
        parentId: null,
        notes: notes || null,
      };

      const columns = Object.keys(subscriptionData)
        .map((key) => `"${key}"`)
        .join(", ");
      const values = Object.values(subscriptionData);
      const placeholders = values.map((_, i) => `$${i + 1}`).join(", ");
      
      const result = await client.query(`
        INSERT INTO t_subscription (${columns})
        VALUES (${placeholders})
        RETURNING *
      `, values);
        
      return result.rows[0];
    });

    const result = await this.getSubscriptionById(subscription.id);
    if (!result) {
      throw new BadRequestError("Error al crear la suscripción");
    }
    return result;
  },

  /**
   * Renovar una suscripción
   */
  async renewSubscription(id: string, data: SubscriptionRenewalRequest): Promise<Subscription> {
    const { period, amount, notes } = data;
    
    // Obtener la suscripción actual
    const currentSubscription = await this.getSubscriptionById(id);
    if (!currentSubscription) {
      throw new BadRequestError("Suscripción no encontrada");
    }

    // Crear nueva suscripción como renovación
    const renewalData: SubscriptionCreateRequest = {
      vehiclePlate: currentSubscription.vehicle.plate,
      vehicleType: currentSubscription.vehicle.type,
      vehicleColor: currentSubscription.vehicle.color || undefined,
      ownerName: currentSubscription.vehicle.ownerName || undefined,
      ownerDocument: currentSubscription.vehicle.ownerDocument || undefined,
      ownerPhone: currentSubscription.vehicle.ownerPhone || undefined,
      spotId: currentSubscription.spotId || undefined,
      startDate: currentSubscription.endDate as string, // Comienza donde termina la anterior
      period,
      amount,
      notes,
    };

    const newSubscription = await this.createSubscription(renewalData, currentSubscription.parkingId, currentSubscription.employeeId);

    // Actualizar la suscripción anterior como renovada
    await this.updateSubscription(id, {
      status: SUBSCRIPTION_STATUS.RENEWED,
      isActive: false,
    });

    // Actualizar la nueva suscripción con el parentId
    await pool.query(`
      UPDATE t_subscription 
      SET "parentId" = $1, "updatedAt" = $2
      WHERE "id" = $3
    `, [id, new Date().toISOString(), newSubscription.id]);

    const result = await this.getSubscriptionById(newSubscription.id);
    if (!result) {
      throw new BadRequestError("Error al renovar la suscripción");
    }
    return result;
  },

  /**
   * Buscar suscripciones por filtros
   */
  async findSubscriptions(filters: {
    id?: string;
    parkingId?: string;
    employeeId?: string;
    vehicleId?: string;
    spotId?: string;
    status?: string;
    period?: string;
    isActive?: boolean;
    startDate?: string;
    endDate?: string;
  } = {}): Promise<Subscription[]> {
    const conditions: string[] = [];
    const values: any[] = [];
    let paramIndex = 1;

    if (filters.id) {
      conditions.push(`s."id" = $${paramIndex++}`);
      values.push(filters.id);
    }

    if (filters.parkingId) {
      conditions.push(`s."parkingId" = $${paramIndex++}`);
      values.push(filters.parkingId);
    }

    if (filters.employeeId) {
      conditions.push(`s."employeeId" = $${paramIndex++}`);
      values.push(filters.employeeId);
    }

    if (filters.vehicleId) {
      conditions.push(`s."vehicleId" = $${paramIndex++}`);
      values.push(filters.vehicleId);
    }

    if (filters.spotId) {
      conditions.push(`s."spotId" = $${paramIndex++}`);
      values.push(filters.spotId);
    }

    if (filters.status) {
      conditions.push(`s."status" = $${paramIndex++}`);
      values.push(filters.status);
    }

    if (filters.period) {
      conditions.push(`s."period" = $${paramIndex++}`);
      values.push(filters.period);
    }

    if (filters.isActive !== undefined) {
      conditions.push(`s."isActive" = $${paramIndex++}`);
      values.push(filters.isActive);
    }

    if (filters.startDate) {
      conditions.push(`s."startDate" >= $${paramIndex++}`);
      values.push(filters.startDate);
    }

    if (filters.endDate) {
      conditions.push(`s."endDate" <= $${paramIndex++}`);
      values.push(filters.endDate);
    }

    const whereClause = conditions.length > 0 ? `WHERE ${conditions.join(" AND ")}` : "";

    const result = await pool.query(`
      SELECT 
        s.id,
        s."startDate",
        s."endDate",
        s."status",
        s."amount",
        s."number",
        s."period",
        s."isActive",
        s."parentId",
        s."notes",
        json_build_object(
          'id', s."parkingId",
          'name', p."name"
        ) as parking,
        json_build_object(
          'id', s."employeeId",
          'name', u."name",
          'email', u."email",
          'phone', u."phone"
        ) as employee,
        json_build_object(
          'id', s."vehicleId",
          'plate', v."plate",
          'type', v."type",
          'color', v."color",
          'ownerName', v."ownerName",
          'ownerDocument', v."ownerDocument",
          'ownerPhone', v."ownerPhone",
          'isSubscribed', v."isSubscribed"
        ) as vehicle
      FROM t_subscription s
      LEFT JOIN t_vehicle v ON s.vehicleId = v.id
      LEFT JOIN t_parking p ON s.parkingId = p.id
      LEFT JOIN t_employee e ON s.employeeId = e.id
      LEFT JOIN t_user u ON e.userId = u.id
      ${whereClause}
      ORDER BY s."startDate" DESC
    `, values);

    return result.rows;
  },

  /**
   * Obtener una suscripción por ID
   */
  async getSubscriptionById(id: string): Promise<Subscription | null> {
    const subscriptions = await this.findSubscriptions({ id: id });
    if (subscriptions.length === 0) {
      return null;
    }
    return subscriptions[0];
  },

  /**
   * Actualizar una suscripción
   */
  async updateSubscription(id: string, data: SubscriptionUpdate): Promise<Subscription | null> {
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
      return this.getSubscriptionById(id);
    }

    values.push(id);
    const result = await pool.query(`
      UPDATE t_subscription 
      SET ${updates.join(", ")}
      WHERE "id" = $${paramIndex}
      RETURNING *
    `, values);

    return result.rows[0] || null;
  },

  /**
   * Eliminar una suscripción
   */
  async deleteSubscription(id: string): Promise<boolean> {
    const result = await pool.query(`
      DELETE FROM t_subscription WHERE "id" = $1
    `, [id]);

    return result.rowCount ? result.rowCount > 0 : false;
  },

  // ===== OPERACIONES ESPECÍFICAS =====

  /**
   * Obtener suscripciones activas para un spot
   */
  async getActiveSubscriptionsForSpot(spotId: string): Promise<Subscription[]> {
    const result = await pool.query(`
      SELECT * FROM t_subscription 
      WHERE "spotId" = $1 
        AND "status" = 'active'
        AND "isActive" = true
        AND "endDate" >= NOW()
      ORDER BY "startDate" DESC
    `, [spotId]);

    return result.rows;
  },

  /**
   * Obtener suscripciones activas para un vehículo
   */
  async getActiveSubscriptionsForVehicle(vehicleId: string): Promise<Subscription[]> {
    const result = await pool.query(`
      SELECT * FROM t_subscription 
      WHERE "vehicleId" = $1 
        AND "status" = 'active'
        AND "isActive" = true
        AND "endDate" >= NOW()
      ORDER BY "startDate" DESC
    `, [vehicleId]);

    return result.rows;
  },

  /**
   * Obtener suscripciones que expiran pronto
   */
  async getExpiringSubscriptions(days: number = 7): Promise<Subscription[]> {
    const expiryDate = new Date();
    expiryDate.setDate(expiryDate.getDate() + days);

    const result = await pool.query(`
      SELECT * FROM t_subscription 
      WHERE "status" = 'active'
        AND "isActive" = true
        AND "endDate" <= $1
        AND "endDate" >= NOW()
      ORDER BY "endDate" ASC
    `, [expiryDate.toISOString()]);

    return result.rows;
  },

  /**
   * Obtener estadísticas de suscripciones por parking
   */
  async getSubscriptionStats(parkingId: string, startDate?: string, endDate?: string): Promise<{
    total: number;
    active: number;
    expired: number;
    suspended: number;
    byPeriod: { [key: string]: number };
  }> {
    const conditions = [`"parkingId" = $1`];
    const values = [parkingId];
    let paramIndex = 2;

    if (startDate) {
      conditions.push(`"startDate" >= $${paramIndex++}`);
      values.push(startDate);
    }

    if (endDate) {
      conditions.push(`"startDate" <= $${paramIndex++}`);
      values.push(endDate);
    }

    const whereClause = conditions.join(" AND ");

    const result = await pool.query(`
      SELECT 
        COUNT(*) as total,
        COUNT(CASE WHEN "status" = 'active' AND "isActive" = true THEN 1 END) as active,
        COUNT(CASE WHEN "status" = 'expired' THEN 1 END) as expired,
        COUNT(CASE WHEN "status" = 'suspended' THEN 1 END) as suspended,
        "period"
      FROM t_subscription 
      WHERE ${whereClause}
      GROUP BY "period"
    `, values);

    const stats = {
      total: 0,
      active: 0,
      expired: 0,
      suspended: 0,
      byPeriod: {} as { [key: string]: number }
    };

    result.rows.forEach(row => {
      stats.total += parseInt(row.total);
      stats.active += parseInt(row.active);
      stats.expired += parseInt(row.expired);
      stats.suspended += parseInt(row.suspended);
      stats.byPeriod[row.period] = parseInt(row.total);
    });

    return stats;
  },

  /**
   * Generar número único para una suscripción
   */
  async generateSubscriptionNumber(parkingId: string): Promise<number> {
    const result = await pool.query(`
      SELECT COALESCE(MAX("number"), 0) + 1 as next_number
      FROM t_subscription 
      WHERE "parkingId" = $1
    `, [parkingId]);

    return result.rows[0].next_number;
  },
};
