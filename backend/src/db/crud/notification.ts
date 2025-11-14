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

const TABLE_NAME = "t_notification";

// ===== CRUD OPERATIONS =====

/**
 * Crear una nueva notificación
 */
export async function createNotification(input: NotificationCreate): Promise<Notification> {
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
    text: `INSERT INTO ${TABLE_NAME} (${columns}) VALUES (${placeholders}) RETURNING *`,
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
export async function findNotificationById(id: string): Promise<Notification | undefined> {
  const query = {
    text: `SELECT * FROM ${TABLE_NAME} WHERE id = $1 LIMIT 1`,
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
export async function findNotifications(where: Partial<Notification> = {}): Promise<Notification[]> {
  const conditions = Object.entries(where)
    .map(([key, value], i) => `"${key}" = $${i + 1}`)
    .join(" AND ");
  
  const query = {
    text: `SELECT * FROM ${TABLE_NAME} ${conditions ? `WHERE ${conditions}` : ""}`,
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
export async function updateNotification(id: string, input: NotificationUpdate): Promise<Notification> {
  const validator = getSchemaValidator(NotificationUpdateSchema);
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
export async function deleteNotification(id: string): Promise<Notification> {
  const query = {
    text: `DELETE FROM ${TABLE_NAME} WHERE id = $1 RETURNING *`,
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

// ===== CUSTOM METHODS =====

/**
 * Crear una notificación con UUID automático
 */
export async function createNotificationWithUUID(data: NotificationCreate): Promise<Notification> {
  const id = uuidv4();
  const notification = {
    id,
    ...data,
    status: "pending",
  };

  const query = {
    text: `
      INSERT INTO ${TABLE_NAME} (
        "id", "type", "title", "message", "recipientId", "recipientType", 
        "channel", "parkingId", "relatedEntityId", "relatedEntityType", 
        "status", "metadata", "scheduledFor"
      ) VALUES (
        $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13
      ) RETURNING *
    `,
    values: [
      notification.id,
      notification.type,
      notification.title,
      notification.message,
      notification.recipientId,
      notification.recipientType,
      notification.channel,
      notification.parkingId,
      notification.relatedEntityId || null,
      notification.relatedEntityType || null,
      notification.status,
      notification.metadata ? JSON.stringify(notification.metadata) : null,
      notification.scheduledFor || null,
    ],
  };

  return withClient(async (client) => {
    const res = await client.query<Notification>(query);
    return res.rows[0];
  });
}

/**
 * Buscar notificaciones por destinatario
 */
export async function findByRecipient(recipientId: string): Promise<Notification[]> {
  const query = {
    text: `
      SELECT * FROM ${TABLE_NAME}
      WHERE "recipientId" = $1
      ORDER BY "createdAt" DESC
    `,
    values: [recipientId],
  };

  return withClient(async (client) => {
    const res = await client.query<Notification>(query);
    return res.rows;
  });
}

/**
 * Buscar notificaciones pendientes
 */
export async function findPendingNotifications(): Promise<Notification[]> {
  const query = {
    text: `
      SELECT * FROM ${TABLE_NAME}
      WHERE "status" = 'pending'
      AND ("scheduledFor" IS NULL OR "scheduledFor" <= NOW())
      ORDER BY "createdAt" ASC
    `,
  };

  return withClient(async (client) => {
    const res = await client.query<Notification>(query);
    return res.rows;
  });
}

/**
 * Marcar notificación como enviada
 */
export async function markAsSent(id: string): Promise<Notification> {
  const query = {
    text: `
      UPDATE ${TABLE_NAME}
      SET "status" = 'sent', "sentAt" = NOW(), "updatedAt" = NOW()
      WHERE "id" = $1
      RETURNING *
    `,
    values: [id],
  };

  return withClient(async (client) => {
    const res = await client.query<Notification>(query);
    return res.rows[0];
  });
}

/**
 * Marcar notificación como entregada
 */
export async function markAsDelivered(id: string): Promise<Notification> {
  const query = {
    text: `
      UPDATE ${TABLE_NAME}
      SET "status" = 'delivered', "updatedAt" = NOW()
      WHERE "id" = $1
      RETURNING *
    `,
    values: [id],
  };

  return withClient(async (client) => {
    const res = await client.query<Notification>(query);
    return res.rows[0];
  });
}

/**
 * Marcar notificación como leída
 */
export async function markAsRead(id: string): Promise<Notification> {
  const query = {
    text: `
      UPDATE ${TABLE_NAME}
      SET "status" = 'read', "updatedAt" = NOW()
      WHERE "id" = $1
      RETURNING *
    `,
    values: [id],
  };

  return withClient(async (client) => {
    const res = await client.query<Notification>(query);
    return res.rows[0];
  });
}

/**
 * Marcar notificación como fallida
 */
export async function markAsFailed(id: string, error?: string): Promise<Notification> {
  const metadata = error ? { error } : {};

  const query = {
    text: `
      UPDATE ${TABLE_NAME}
      SET "status" = 'failed', "updatedAt" = NOW(), "metadata" = COALESCE("metadata", '{}'::jsonb) || $2::jsonb
      WHERE "id" = $1
      RETURNING *
    `,
    values: [id, JSON.stringify(metadata)],
  };

  return withClient(async (client) => {
    const res = await client.query<Notification>(query);
    return res.rows[0];
  });
}

/**
 * Buscar notificaciones por filtro
 */
export async function findByFilter(filter: NotificationFilter): Promise<Notification[]> {
  let conditions = [];
  let params = [];
  let paramIndex = 1;

  if (filter.recipientId) {
    conditions.push(`"recipientId" = $${paramIndex++}`);
    params.push(filter.recipientId);
  }

  if (filter.parkingId) {
    conditions.push(`"parkingId" = $${paramIndex++}`);
    params.push(filter.parkingId);
  }

  if (filter.type) {
    conditions.push(`"type" = $${paramIndex++}`);
    params.push(filter.type);
  }

  if (filter.status) {
    conditions.push(`"status" = $${paramIndex++}`);
    params.push(filter.status);
  }

  if (filter.startDate) {
    conditions.push(`"createdAt" >= $${paramIndex++}`);
    params.push(filter.startDate);
  }

  if (filter.endDate) {
    conditions.push(`"createdAt" <= $${paramIndex++}`);
    params.push(filter.endDate);
  }

  const whereClause =
    conditions.length > 0 ? `WHERE ${conditions.join(" AND ")}` : "";

  const query = {
    text: `
      SELECT * FROM ${TABLE_NAME}
      ${whereClause}
      ORDER BY "createdAt" DESC
    `,
    values: params,
  };

  return withClient(async (client) => {
    const res = await client.query<Notification>(query);
    return res.rows;
  });
}

/**
 * Contar notificaciones no leídas por destinatario
 */
export async function countUnreadByRecipient(recipientId: string): Promise<number> {
  const query = {
    text: `
      SELECT COUNT(*) as count FROM ${TABLE_NAME}
      WHERE "recipientId" = $1 AND "status" NOT IN ('read', 'failed')
    `,
    values: [recipientId],
  };

  return withClient(async (client) => {
    const res = await client.query<{ count: number }>(query);
    return parseInt(res.rows[0].count as any);
  });
}
