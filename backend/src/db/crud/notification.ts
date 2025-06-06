import { BaseCrud } from './base-crud';
import { 
  Notification, 
  NotificationCreate, 
  NotificationUpdate,
  NotificationFilter
} from '../../models/notification';
import { v4 as uuidv4 } from 'uuid';

class NotificationCrud extends BaseCrud<Notification, NotificationCreate, NotificationUpdate> {
  constructor() {
    super('t_notification');
  }

  async create(data: NotificationCreate): Promise<Notification> {
    const id = uuidv4();
    const notification = {
      id,
      ...data,
      status: 'pending'
    };

    const sql = `
      INSERT INTO t_notification (
        "id", "type", "title", "message", "recipientId", "recipientType", 
        "channel", "parkingId", "relatedEntityId", "relatedEntityType", 
        "status", "metadata", "scheduledFor"
      ) VALUES (
        $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13
      ) RETURNING *
    `;

    const params = [
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
      notification.scheduledFor || null
    ];

    const res = await this.query<Notification>({ sql, params });
    return res[0];
  }

  async findByRecipient(recipientId: string): Promise<Notification[]> {
    const sql = `
      SELECT * FROM t_notification
      WHERE "recipientId" = $1
      ORDER BY "createdAt" DESC
    `;

    return await this.query<Notification>({ sql, params: [recipientId] });
  }

  async findPendingNotifications(): Promise<Notification[]> {
    const sql = `
      SELECT * FROM t_notification
      WHERE "status" = 'pending'
      AND ("scheduledFor" IS NULL OR "scheduledFor" <= NOW())
      ORDER BY "createdAt" ASC
    `;

    return await this.query<Notification>({ sql });
  }

  async markAsSent(id: string): Promise<Notification> {
    const sql = `
      UPDATE t_notification
      SET "status" = 'sent', "sentAt" = NOW(), "updatedAt" = NOW()
      WHERE "id" = $1
      RETURNING *
    `;

    const res = await this.query<Notification>({ sql, params: [id] });
    return res[0];
  }

  async markAsDelivered(id: string): Promise<Notification> {
    const sql = `
      UPDATE t_notification
      SET "status" = 'delivered', "updatedAt" = NOW()
      WHERE "id" = $1
      RETURNING *
    `;

    const res = await this.query<Notification>({ sql, params: [id] });
    return res[0];
  }

  async markAsRead(id: string): Promise<Notification> {
    const sql = `
      UPDATE t_notification
      SET "status" = 'read', "updatedAt" = NOW()
      WHERE "id" = $1
      RETURNING *
    `;

    const res = await this.query<Notification>({ sql, params: [id] });
    return res[0];
  }

  async markAsFailed(id: string, error?: string): Promise<Notification> {
    const metadata = error ? { error } : {};
    
    const sql = `
      UPDATE t_notification
      SET "status" = 'failed', "updatedAt" = NOW(), "metadata" = COALESCE("metadata", '{}'::jsonb) || $2::jsonb
      WHERE "id" = $1
      RETURNING *
    `;

    const res = await this.query<Notification>({ sql, params: [id, JSON.stringify(metadata)] });
    return res[0];
  }

  async findByFilter(filter: NotificationFilter): Promise<Notification[]> {
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

    const whereClause = conditions.length > 0 ? `WHERE ${conditions.join(' AND ')}` : '';

    const sql = `
      SELECT * FROM t_notification
      ${whereClause}
      ORDER BY "createdAt" DESC
    `;

    return await this.query<Notification>({ sql, params });
  }

  async countUnreadByRecipient(recipientId: string): Promise<number> {
    const sql = `
      SELECT COUNT(*) as count FROM t_notification
      WHERE "recipientId" = $1 AND "status" NOT IN ('read', 'failed')
    `;

    const res = await this.query<{ count: number }>({ sql, params: [recipientId] });
    return parseInt(res[0].count as any);
  }
}

export const notificationCrud = new NotificationCrud(); 