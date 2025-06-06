import Elysia, { t } from "elysia";
import { db } from "../db";
import { accessPlugin } from "../plugins/access";
import { notificationService } from "../services/notification";
import { 
  NotificationSchema, 
  NotificationCreateSchema,
  NotificationFilterSchema
} from "../models/notification";

export const notificationController = new Elysia({ prefix: '/notification', tags: ['notification'], detail: { summary: 'Gestión de notificaciones', description: 'Endpoints para gestionar notificaciones del sistema.', security: [{ branchId: [], token: [] }] } })
  .use(accessPlugin)
  .use(notificationService)
  .get('/', async ({ query }) => {
    try {
      const filter = query as any;
      const notifications = await db.notification.findByFilter(filter);
      return notifications;
    } catch (error) {
      console.error('Error fetching notifications:', error);
      throw new Error('Error al obtener notificaciones');
    }
  }, {
    query: 'NotificationFilterSchema',
    detail: {
      summary: 'Obtener notificaciones',
      description: 'Obtiene las notificaciones según los filtros especificados.',
    },
    response: {
      200: t.Array(NotificationSchema),
      400: t.String(),
      500: t.String(),
    },
  })
  .post('/', async ({ body }) => {
    try {
      const notification = await db.notification.create(body);
      return notification;
    } catch (error) {
      console.error('Error creating notification:', error);
      throw new Error('Error al crear la notificación');
    }
  }, {
    body: 'NotificationCreateSchema',
    detail: {
      summary: 'Crear notificación',
      description: 'Crea una nueva notificación en el sistema.',
    },
    response: {
      200: NotificationSchema,
      400: t.String(),
      500: t.String(),
    },
  })
  .get('/recipient/:id', async ({ params }) => {
    try {
      const notifications = await db.notification.findByRecipient(params.id);
      return notifications;
    } catch (error) {
      console.error('Error fetching notifications by recipient:', error);
      throw new Error('Error al obtener notificaciones del destinatario');
    }
  }, {
    detail: {
      summary: 'Obtener notificaciones por destinatario',
      description: 'Obtiene todas las notificaciones de un destinatario específico.',
    },
    response: {
      200: t.Array(NotificationSchema),
      400: t.String(),
      500: t.String(),
    },
  })
  .get('/unread-count/:recipientId', async ({ params }) => {
    try {
      const count = await db.notification.countUnreadByRecipient(params.recipientId);
      return { count };
    } catch (error) {
      console.error('Error counting unread notifications:', error);
      throw new Error('Error al contar notificaciones no leídas');
    }
  }, {
    detail: {
      summary: 'Contar notificaciones no leídas',
      description: 'Cuenta las notificaciones no leídas de un destinatario específico.',
    },
    response: {
      200: t.Object({
        count: t.Integer({
          description: "Cantidad de notificaciones no leídas",
          required: true
        })
      }),
      400: t.String(),
      500: t.String(),
    },
  })
  .patch('/:id/mark-as-read', async ({ params }) => {
    try {
      const notification = await db.notification.markAsRead(params.id);
      return notification;
    } catch (error) {
      console.error('Error marking notification as read:', error);
      throw new Error('Error al marcar la notificación como leída');
    }
  }, {
    detail: {
      summary: 'Marcar como leída',
      description: 'Marca una notificación específica como leída.',
    },
    response: {
      200: NotificationSchema,
      400: t.String(),
      500: t.String(),
    },
  })
  .delete('/:id', async ({ params }) => {
    try {
      const notification = await db.notification.delete({ id: params.id });
      return notification;
    } catch (error) {
      console.error('Error deleting notification:', error);
      throw new Error('Error al eliminar la notificación');
    }
  }, {
    detail: {
      summary: 'Eliminar notificación',
      description: 'Elimina una notificación específica.',
    },
    response: {
      200: NotificationSchema,
      400: t.String(),
      500: t.String(),
    },
  }); 