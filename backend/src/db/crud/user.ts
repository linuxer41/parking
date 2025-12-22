import { PoolClient } from "pg";
import { getConnection, withClient } from "../connection";
import { User, UserCreate, UserUpdate, UserCreateSchema, UserUpdateSchema, UserCreateRequest, UserUpdateRequest } from "../../models/user";
import { getSchemaValidator } from "elysia";

class UserCrud {
  private TABLE_NAME = "t_user";

// ===== CRUD OPERATIONS =====

/**
 * Crear un nuevo usuario
 */
async create(input: UserCreateRequest): Promise<User> {
  const validator = getSchemaValidator(UserCreateSchema);
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
    const res = await client.query<User>(query);
    return res.rows[0];
  });
}

/**
 * Buscar un usuario por ID
 */
async findById(id: string): Promise<User | undefined> {
  const query = {
    text: `SELECT * FROM ${this.TABLE_NAME} WHERE id = $1 LIMIT 1`,
    values: [id],
  };
  
  return withClient(async (client) => {
    const res = await client.query<User>(query);
    return res.rows[0];
  });
}

/**
 * Buscar usuarios por criterios
 */
async find(where: Partial<User> = {}): Promise<User[]> {
  const conditions = Object.entries(where)
    .map(([key, value], i) => `"${key}" = $${i + 1}`)
    .join(" AND ");
  
  const query = {
    text: `SELECT * FROM ${this.TABLE_NAME} ${conditions ? `WHERE ${conditions}` : ""}`,
    values: Object.values(where),
  };
  
  return withClient(async (client) => {
    const res = await client.query<User>(query);
    return res.rows;
  });
}

/**
 * Actualizar un usuario
 */
async update(id: string, input: UserUpdateRequest): Promise<User> {
  const validator = getSchemaValidator(UserUpdateSchema);
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
    const res = await client.query<User>(query);
    
    if (!res.rows || res.rows.length === 0) {
      throw new Error(`No se encontró el usuario con ID ${id} para actualizar`);
    }
    
    return res.rows[0];
  });
}

/**
 * Eliminar un usuario
 */
async delete(id: string): Promise<User> {
  const query = {
    text: `DELETE FROM ${this.TABLE_NAME} WHERE id = $1 RETURNING *`,
    values: [id],
  };

  return withClient(async (client) => {
    const res = await client.query<User>(query);

    if (!res.rows || res.rows.length === 0) {
      throw new Error(`No se encontró el usuario con ID ${id} para eliminar`);
    }

    return res.rows[0];
  });
}
}

export const userCrud = new UserCrud();
