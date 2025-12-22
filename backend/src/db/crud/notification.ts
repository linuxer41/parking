import { PoolClient } from "pg";
import { getConnection, withClient } from "../connection";
import {
  Notification,
  NotificationCreate,
  NotificationUpdate,
  NotificationFilter,
  NotificationCreateSchema,
  NotificationUpdateSchema,
} from "../../models/notification";
import { getSchemaValidator } from "elysia";
import { v4 as uuidv4 } from "uuid";

class NotificationCrud {
  private TABLE_NAME = "t_notification";

// ===== CRUD OPERATIONS =====

/**
 * Crear una nueva notificación
 */
async create(input: NotificationCreate): Promise<Notification> {
  const validator = getSchemaValidator(NotificationCreateSchema);
  const data = validator.parse({
    ...input,
    id: uuidv4(),
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
    const res = await client.query<Notification>(query);
    return res.rows[0];
  });
}

/**
 * Buscar una notificación por ID
 */
async findById(id: string): Promise<Notification | undefined> {
  const query = {
    text: `SELECT * FROM ${this.TABLE_NAME} WHERE id = $1 LIMIT 1`,
    values: [id],
  };
  
  return withClient(async (client) => {
    const res = await client.query<Notification>(query);
    return res.rows[0];
  });
}

/**
 * Buscar notificaciones por criterios
 */
async find(where: Partial<Notification> = {}): Promise<Notification[]> {
  const conditions = Object.entries(where)
    .map(([key, value], i) => `"${key}" = $${i + 1}`)
    .join(" AND ");
  
  const query = {
    text: `SELECT * FROM ${this.TABLE_NAME} ${conditions ? `WHERE ${conditions}` : ""}`,
    values: Object.values(where),
  };
  
  return withClient(async (client) => {
    const res = await client.query<Notification>(query);
    return res.rows;
  });
}

/**
 * Actualizar una notificación
 */
async update(id: string, input: NotificationUpdate): Promise<Notification> {
  const validator = getSchemaValidator(NotificationUpdateSchema);
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
    const res = await client.query<Notification>(query);
    
    if (!res.rows || res.rows.length === 0) {
      throw new Error(`No se encontró la notificación con ID ${id} para actualizar`);
    }
    
    return res.rows[0];
  });
}

/**
 * Eliminar una notificación
 */
async delete(id: string): Promise<Notification> {
  const query = {
    text: `DELETE FROM ${this.TABLE_NAME} WHERE id = $1 RETURNING *`,
    values: [id],
  };
  
  return withClient(async (client) => {
    const res = await client.query<Notification>(query);
    
    if (!res.rows || res.rows.length === 0) {
      throw new Error(`No se encontró la notificación con ID ${id} para eliminar`);
    }
    
    return res.rows[0];
  });
}
}

export const notificationCrud = new NotificationCrud();
