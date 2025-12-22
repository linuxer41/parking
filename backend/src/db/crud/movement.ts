import { PoolClient } from "pg";
import { getConnection, withClient } from "../connection";
import { Movement, MovementCreate, MovementUpdate, MovementCreateSchema, MovementUpdateSchema, MovementCreateRequest, MovementUpdateRequest } from "../../models/movement";
import { getSchemaValidator } from "elysia";

class MovementCrud {
  private TABLE_NAME = "t_movement";

// ===== CRUD OPERATIONS =====

/**
 * Crear un nuevo movimiento
 */
async create(input: MovementCreateRequest): Promise<Movement> {
  const validator = getSchemaValidator(MovementCreateSchema);
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
    text: `INSERT INTO ${this.TABLE_NAME} (${columns}) VALUES (${placeholders}) RETURNING *`,
    values: values,
  };
  
  return withClient(async (client) => {
    const res = await client.query<Movement>(query);
    return res.rows[0];
  });
}

/**
 * Buscar un movimiento por ID
 */
async findById(id: string): Promise<Movement | undefined> {
  const query = {
    text: `SELECT * FROM ${this.TABLE_NAME} WHERE id = $1 LIMIT 1`,
    values: [id],
  };
  
  return withClient(async (client) => {
    const res = await client.query<Movement>(query);
    return res.rows[0];
  });
}

/**
 * Buscar movimientos por criterios
 */
async find(where: Partial<Movement> = {}): Promise<Movement[]> {
  const conditions = Object.entries(where)
    .map(([key, value], i) => `"${key}" = $${i + 1}`)
    .join(" AND ");
  
  const query = {
    text: `SELECT * FROM ${this.TABLE_NAME} ${conditions ? `WHERE ${conditions}` : ""}`,
    values: Object.values(where),
  };
  
  return withClient(async (client) => {
    const res = await client.query<Movement>(query);
    return res.rows;
  });
}

/**
 * Actualizar un movimiento
 */
async update(id: string, input: MovementUpdateRequest): Promise<Movement> {
  const validator = getSchemaValidator(MovementUpdateSchema);
  const data = validator.parse(input);
  
  const setClause = Object.keys(data)
    .map((key, i) => `"${key}" = $${i + 1}`)
    .join(", ");

  const values = Object.values(data).map((value) =>
    typeof value === "object" ? JSON.stringify(value) : value,
  );
  
  const query = {
    text: `UPDATE ${this.TABLE_NAME} SET ${setClause}, "updatedAt" = NOW() WHERE id = $${Object.keys(data).length + 1} RETURNING *`,
    values: [...values, id],
  };
  
  return withClient(async (client) => {
    const res = await client.query<Movement>(query);
    
    if (!res.rows || res.rows.length === 0) {
      throw new Error(`No se encontró el movimiento con ID ${id} para actualizar`);
    }
    
    return res.rows[0];
  });
}

/**
 * Eliminar un movimiento
 */
async delete(id: string): Promise<Movement> {
  const query = {
    text: `DELETE FROM ${this.TABLE_NAME} WHERE id = $1 RETURNING *`,
    values: [id],
  };
  
  return withClient(async (client) => {
    const res = await client.query<Movement>(query);
    
    if (!res.rows || res.rows.length === 0) {
      throw new Error(`No se encontró el movimiento con ID ${id} para eliminar`);
    }
    
    return res.rows[0];
  });
}
}

export const movementCrud = new MovementCrud();
