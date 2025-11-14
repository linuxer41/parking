import { pool, withTransaction } from "../connection";
import { EntryExit, EntryExitCreate, EntryExitUpdate, EntryExitCreateRequest, ExitRequest, ACCESS_STATUS } from "../../models/entry-exit";
import { BadRequestError } from "../../utils/error";
import { getSchemaValidator } from "elysia";
import { VehicleCreateSchema } from "../../models/vehicle";
import { randomUUID } from "crypto";

// ===== FUNCIONES AUXILIARES =====

/**
 * Generar número único para un acceso
 */
const generateEntryExitNumber = async (parkingId: string): Promise<number> => {
  const result = await pool.query(`
    SELECT COALESCE(MAX("number"), 0) + 1 as next_number
    FROM t_entry_exit
    WHERE "parkingId" = $1
  `, [parkingId]);

  return result.rows[0].next_number;
};

/**
 * Obtener un acceso por ID
 */
const getEntryExitById = async (id: string): Promise<EntryExit | null> => {
  const entryExits = await findEntryExits({ id: id });
  if (entryExits.length === 0) {
    return null;
  }
  return entryExits[0];
};

/**
 * Buscar accesos por filtros
 */
const findEntryExits = async (filters: {
  id?: string;
  parkingId?: string;
  employeeId?: string;
  vehicleId?: string;
  spotId?: string;
  status?: string;
  startDate?: string;
  endDate?: string;
} = {}): Promise<EntryExit[]> => {
  const conditions: string[] = [];
  const values: any[] = [];
  let paramIndex = 1;

  if (filters.id) {
    conditions.push(`ee."id" = $${paramIndex++}`);
    values.push(filters.id);
  }

  if (filters.parkingId) {
    conditions.push(`ee."parkingId" = $${paramIndex++}`);
    values.push(filters.parkingId);
  }

  if (filters.employeeId) {
    conditions.push(`ee."employeeId" = $${paramIndex++}`);
    values.push(filters.employeeId);
  }

  if (filters.vehicleId) {
    conditions.push(`ee."vehicleId" = $${paramIndex++}`);
    values.push(filters.vehicleId);
  }

  if (filters.spotId) {
    conditions.push(`ee."spotId" = $${paramIndex++}`);
    values.push(filters.spotId);
  }

  if (filters.status) {
    conditions.push(`ee."status" = $${paramIndex++}`);
    values.push(filters.status);
  }

  if (filters.startDate) {
    conditions.push(`ee."entryTime" >= $${paramIndex++}`);
    values.push(filters.startDate);
  }

  if (filters.endDate) {
    conditions.push(`ee."entryTime" <= $${paramIndex++}`);
    values.push(filters.endDate);
  }

  const whereClause = conditions.length > 0 ? `WHERE ${conditions.join(" AND ")}` : "";

  const result = await pool.query(`
    SELECT
      ee.id,
      ee."entryTime",
      ee."exitTime",
      ee."status",
      ee."amount",
      ee."number",
      ee."notes",
      json_build_object(
        'id', ee."parkingId",
        'name', p."name"
      ) as parking,
      json_build_object(
        'id', ee."employeeId",
        'name', u."name",
        'email', u."email",
        'phone', u."phone"
      ) as employee,
      json_build_object(
        'id', ee."exitEmployeeId",
        'name', eu."name",
        'email', eu."email",
        'phone', eu."phone"
      ) as exitEmployee,
      json_build_object(
        'id', ee."vehicleId",
        'plate', v."plate",
        'type', v."type",
        'color', v."color",
        'ownerName', v."ownerName",
        'ownerDocument', v."ownerDocument",
        'ownerPhone', v."ownerPhone",
        'isSubscribed', v."isSubscribed"
      ) as vehicle
    FROM t_entry_exit ee
    LEFT JOIN t_vehicle v ON ee.vehicleId = v.id
    LEFT JOIN t_parking p ON ee.parkingId = p.id
    LEFT JOIN t_employee e ON ee.employeeId = e.id
    LEFT JOIN t_user u ON e.userId = u.id
    LEFT JOIN t_employee exit_e ON ee.exitEmployeeId = exit_e.id
    LEFT JOIN t_user eu ON exit_e.userId = eu.id
    ${whereClause}
    ORDER BY ee."entryTime" DESC
  `, values);

  return result.rows;
};

// ===== FUNCIONES PRINCIPALES =====

/**
 * Crear un nuevo acceso (entrada)
 */
const createEntryExit = async (data: EntryExitCreateRequest, parkingId: string, employeeId: string): Promise<EntryExit> => {
  const entryExit = await withTransaction(async (client) => {
    const { vehiclePlate, vehicleType, vehicleColor, ownerName, ownerDocument, ownerPhone, spotId, notes } = data;

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
        RETURNING id
      `, [vehicleData.id, vehicleData.plate, vehicleData.type, vehicleData.color, vehicleData.ownerName, vehicleData.ownerDocument, vehicleData.ownerPhone, vehicleData.parkingId, vehicleData.isSubscribed, vehicleData.createdAt]);
      vehicle = newVehicle.rows[0];
    }

    // Generar número de acceso
    const number = await generateEntryExitNumber(parkingId);

    // Crear el acceso
    const entryExitData = {
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
      status: ACCESS_STATUS.ENTERED,
      notes: notes || null,
    };

    const columns = Object.keys(entryExitData)
      .map((key) => `"${key}"`)
      .join(", ");
    const values = Object.values(entryExitData);
    const placeholders = values.map((_, i) => `$${i + 1}`).join(", ");

    const result = await client.query(`
      INSERT INTO t_entry_exit (${columns})
      VALUES (${placeholders})
      RETURNING *
    `, values);

    return result.rows[0];
  });
  console.log({entryExit});

  const result = await getEntryExitById(entryExit.id);
  if (!result) {
    throw new BadRequestError("Error al crear el acceso");
  }
  return result;
};

/**
 * Registrar salida de un vehículo
 */
const registerExit = async (id: string, data: ExitRequest): Promise<EntryExit> => {
  const { exitEmployeeId, amount, notes } = data;

  const updates: string[] = [];
  const values: any[] = [];
  let paramIndex = 1;

  updates.push(`"exitTime" = $${paramIndex++}`);
  values.push(new Date().toISOString());

  updates.push(`"exitEmployeeId" = $${paramIndex++}`);
  values.push(exitEmployeeId);

  if (amount !== undefined) {
    updates.push(`"amount" = $${paramIndex++}`);
    values.push(amount);
  }

  if (notes !== undefined) {
    updates.push(`"notes" = $${paramIndex++}`);
    values.push(notes);
  }

  updates.push(`"status" = $${paramIndex++}`);
  values.push(ACCESS_STATUS.EXITED);

  updates.push(`"updatedAt" = $${paramIndex++}`);
  values.push(new Date().toISOString());

  values.push(id);

  const result = await pool.query(`
    UPDATE t_entry_exit
    SET ${updates.join(", ")}
    WHERE "id" = $${paramIndex}
    RETURNING *
  `, values);

  if (result.rows.length === 0) {
    throw new BadRequestError("Acceso no encontrado");
  }

  const updatedEntryExit = await getEntryExitById(id);
  if (!updatedEntryExit) {
    throw new BadRequestError("Error al obtener el acceso actualizado");
  }
  return updatedEntryExit;
};

/**
 * Actualizar un acceso
 */
const updateEntryExit = async (id: string, data: EntryExitUpdate): Promise<EntryExit | null> => {
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
    return getEntryExitById(id);
  }

  values.push(id);
  const result = await pool.query(`
    UPDATE t_entry_exit
    SET ${updates.join(", ")}
    WHERE "id" = $${paramIndex}
    RETURNING *
  `, values);

  return result.rows[0] || null;
};

/**
 * Eliminar un acceso
 */
const deleteEntryExit = async (id: string): Promise<boolean> => {
  const result = await pool.query(`
    DELETE FROM t_entry_exit WHERE "id" = $1
  `, [id]);

  return result.rowCount ? result.rowCount > 0 : false;
};

/**
 * Obtener accesos activos para un spot
 */
const getActiveEntryExitsForSpot = async (spotId: string): Promise<EntryExit[]> => {
  const result = await pool.query(`
    SELECT * FROM t_entry_exit
    WHERE "spotId" = $1
      AND "status" = 'entered'
    ORDER BY "entryTime" DESC
  `, [spotId]);

  return result.rows;
};

/**
 * Obtener accesos activos para un vehículo
 */
const getActiveEntryExitsForVehicle = async (vehicleId: string): Promise<EntryExit[]> => {
  const result = await pool.query(`
    SELECT * FROM t_entry_exit
    WHERE "vehicleId" = $1
      AND "status" = 'entered'
    ORDER BY "entryTime" DESC
  `, [vehicleId]);

  return result.rows;
};

/**
 * Obtener estadísticas de accesos por parking
 */
const getEntryExitStats = async (parkingId: string, startDate?: string, endDate?: string): Promise<{
  total: number;
  entered: number;
  exited: number;
  cancelled: number;
}> => {
  const conditions = [`"parkingId" = $1`];
  const values = [parkingId];
  let paramIndex = 2;

  if (startDate) {
    conditions.push(`"entryTime" >= $${paramIndex++}`);
    values.push(startDate);
  }

  if (endDate) {
    conditions.push(`"entryTime" <= $${paramIndex++}`);
    values.push(endDate);
  }

  const whereClause = conditions.join(" AND ");

  const result = await pool.query(`
    SELECT
      COUNT(*) as total,
      COUNT(CASE WHEN "status" = 'entered' THEN 1 END) as entered,
      COUNT(CASE WHEN "status" = 'exited' THEN 1 END) as exited,
      COUNT(CASE WHEN "status" = 'cancelled' THEN 1 END) as cancelled
    FROM t_entry_exit
    WHERE ${whereClause}
  `, values);

  const row = result.rows[0];
  return {
    total: parseInt(row.total),
    entered: parseInt(row.entered),
    exited: parseInt(row.exited),
    cancelled: parseInt(row.cancelled),
  };
};

export const entryExitCrud = {
  createEntryExit,
  registerExit,
  findEntryExits,
  getEntryExitById,
  updateEntryExit,
  deleteEntryExit,
  getActiveEntryExitsForSpot,
  getActiveEntryExitsForVehicle,
  getEntryExitStats,
  generateEntryExitNumber,
};
