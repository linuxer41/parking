import { PoolClient } from "pg";
import { getConnection, withClient } from "../connection";
import { Vehicle, VehicleCreate, VehicleUpdate, VehicleCreateSchema, VehicleUpdateSchema, VehicleCreateRequest, VehicleUpdateRequest } from "../../models/vehicle";
import { getSchemaValidator } from "elysia";

const TABLE_NAME = "t_vehicle";

// ===== CRUD OPERATIONS =====

/**
 * Crear un nuevo vehículo
 */
export async function createVehicle(input: VehicleCreateRequest): Promise<Vehicle> {
  const validator = getSchemaValidator(VehicleCreateSchema);
  const data = validator.parse({
    ...input,
    id: crypto.randomUUID(),
    createdAt: new Date().toISOString(),
    // updatedAt: new Date().toISOString(),
  });

  const columns = Object.keys(data)
    .map((key) => `"${key}"`)
    .join(", ");

  const values = Object.values(data).map((value) =>
    typeof value === "object" ? JSON.stringify(value) : value,
  );

  const placeholders = values.map((_, i) => `$${i + 1}`).join(", ");
  
  const query = {
    text: `INSERT INTO ${TABLE_NAME} (${columns}) VALUES (${placeholders}) RETURNING *`,
    values: values,
  };
  
  return withClient(async (client) => {
    const res = await client.query<Vehicle>(query);
    return res.rows[0];
  });
}

/**
 * Buscar un vehículo por ID
 */
export async function findVehicleById(id: string): Promise<Vehicle | undefined> {
  const query = {
    text: `SELECT * FROM ${TABLE_NAME} WHERE id = $1 LIMIT 1`,
    values: [id],
  };
  
  return withClient(async (client) => {
    const res = await client.query<Vehicle>(query);
    return res.rows[0];
  });
}

/**
 * Buscar vehículos por criterios
 */
export async function findVehicles(where: Partial<Vehicle> = {}): Promise<Vehicle[]> {
  const conditions = Object.entries(where)
    .map(([key, value], i) => `"${key}" = $${i + 1}`)
    .join(" AND ");
  
  const query = {
    text: `SELECT * FROM ${TABLE_NAME} ${conditions ? `WHERE ${conditions}` : ""}`,
    values: Object.values(where),
  };
  
  return withClient(async (client) => {
    const res = await client.query<Vehicle>(query);
    return res.rows;
  });
}

/**
 * Actualizar un vehículo
 */
export async function updateVehicle(id: string, input: VehicleUpdateRequest): Promise<Vehicle> {
  const validator = getSchemaValidator(VehicleUpdateSchema);
  const data = validator.parse(input);
  
  const setClause = Object.keys(data)
    .map((key, i) => `"${key}" = $${i + 1}`)
    .join(", ");

  const values = Object.values(data).map((value) =>
    typeof value === "object" ? JSON.stringify(value) : value,
  );
  
  const query = {
    text: `UPDATE ${TABLE_NAME} SET ${setClause}, "updatedAt" = NOW() WHERE id = $${Object.keys(data).length + 1} RETURNING *`,
    values: [...values, id],
  };
  
  return withClient(async (client) => {
    const res = await client.query<Vehicle>(query);
    
    if (!res.rows || res.rows.length === 0) {
      throw new Error(`No se encontró el vehículo con ID ${id} para actualizar`);
    }
    
    return res.rows[0];
  });
}

/**
 * Eliminar un vehículo
 */
export async function deleteVehicle(id: string): Promise<Vehicle> {
  const query = {
    text: `DELETE FROM ${TABLE_NAME} WHERE id = $1 RETURNING *`,
    values: [id],
  };
  
  return withClient(async (client) => {
    const res = await client.query<Vehicle>(query);
    
    if (!res.rows || res.rows.length === 0) {
      throw new Error(`No se encontró el vehículo con ID ${id} para eliminar`);
    }
    
    return res.rows[0];
  });
}
