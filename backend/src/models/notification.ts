import { t } from "elysia";
import { BaseSchema } from "./base-model";

// Tipos de notificaciones
export enum NotificationType {
  ACCESS = "access",
  RESERVATION = "reservation",
  SUBSCRIPTION_EXPIRY = "subscription_expiry",
  TIME_LIMIT = "time_limit",
  PAYMENT = "payment",
  SYSTEM = "system",
}

// Canales de notificación
export enum NotificationChannel {
  EMAIL = "email",
  SMS = "sms",
  PUSH = "push",
  WHATSAPP = "whatsapp",
}

// Helper para convertir enum a objeto para t.Enum
const enumToRecord = <T extends Record<string, string>>(enumObj: T) => {
  return Object.values(enumObj).reduce(
    (acc, val) => {
      acc[val] = val;
      return acc;
    },
    {} as Record<string, string>,
  );
};

// Esquema para notificaciones
export const NotificationSchema = t.Object(
  {
    // Campos base
    ...BaseSchema.properties,
    // Campos específicos
    type: t.Enum(enumToRecord(NotificationType), {
      description: "Tipo de notificación",
      required: true,
    }),
    title: t.String({
      description: "Título de la notificación",
      required: true,
    }),
    message: t.String({
      description: "Mensaje de la notificación",
      required: true,
    }),
    recipientId: t.String({
      description: "ID del destinatario (usuario, empleado, etc.)",
      required: true,
    }),
    recipientType: t.String({
      description: "Tipo de destinatario (user, employee, subscription, etc.)",
      required: true,
    }),
    channel: t.Enum(enumToRecord(NotificationChannel), {
      description: "Canal de notificación",
      required: true,
    }),
    parkingId: t.String({
      description: "ID del estacionamiento relacionado",
      required: true,
    }),
    relatedEntityId: t.Optional(
      t.String({
        description:
          "ID de la entidad relacionada (access, reservation, etc.)",
        required: false,
      }),
    ),
    relatedEntityType: t.Optional(
      t.String({
        description: "Tipo de la entidad relacionada",
        required: false,
      }),
    ),
    status: t.Enum(
      {
        pending: "pending",
        sent: "sent",
        delivered: "delivered",
        read: "read",
        failed: "failed",
      },
      {
        description: "Estado de la notificación",
        required: true,
      },
    ),
    metadata: t.Optional(
      t.Any({
        description: "Metadatos adicionales de la notificación",
        required: false,
      }),
    ),
    scheduledFor: t.Optional(
      t.Union([
        t.String({
          description: "Fecha programada para envío",
          required: false,
        }),
        t.Date({
          description: "Fecha programada para envío",
          required: false,
        }),
      ]),
    ),
    sentAt: t.Optional(
      t.Union([
        t.String({
          description: "Fecha de envío",
          required: false,
        }),
        t.Date({
          description: "Fecha de envío",
          required: false,
        }),
      ]),
    ),
  },
  {
    description: "Esquema principal para la entidad Notification",
  },
);

export type Notification = typeof NotificationSchema.static;

// Esquema para crear notificaciones
export const NotificationCreateSchema = t.Pick(NotificationSchema, ["type", "title", "message", "recipientId", "recipientType", "channel", "parkingId", "relatedEntityId", "relatedEntityType", "status", "metadata", "scheduledFor", "sentAt"], {
  description: "Esquema para la creación de una Notification",
});

export type NotificationCreate = typeof NotificationCreateSchema.static;

// Esquema para actualizar notificaciones
export const NotificationUpdateSchema = t.Pick(NotificationSchema, ["status"], {
  description: "Esquema para la actualización de una Notification",
});

export type NotificationUpdate = typeof NotificationUpdateSchema.static;

// Esquema para filtrar notificaciones
export const NotificationFilterSchema = t.Object(
  {
    recipientId: t.Optional(
      t.String({
        description: "Filtrar por ID del destinatario",
        required: false,
      }),
    ),
    parkingId: t.Optional(
      t.String({
        description: "Filtrar por ID del estacionamiento",
        required: false,
      }),
    ),
    type: t.Optional(
      t.Enum(enumToRecord(NotificationType), {
        description: "Filtrar por tipo de notificación",
        required: false,
      }),
    ),
    status: t.Optional(
      t.Enum(
        {
          pending: "pending",
          sent: "sent",
          delivered: "delivered",
          read: "read",
          failed: "failed",
        },
        {
          description: "Filtrar por estado de la notificación",
          required: false,
        },
      ),
    ),
  },
  {
    description: "Esquema para filtrar notificaciones",
  },
);

export type NotificationFilter = typeof NotificationFilterSchema.static;
