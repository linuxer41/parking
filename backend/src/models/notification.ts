import { t } from "elysia";
import { BaseSchema } from "./base-model";

// ===== CONSTANTES =====
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

// ===== ESQUEMA PRINCIPAL =====
export const NotificationSchema = t.Composite([
  BaseSchema,
  t.Object({
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
      format: "uuid",
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
      format: "uuid",
    }),
    relatedEntityId: t.Optional(
      t.String({
        description:
          "ID de la entidad relacionada (access, reservation, etc.)",
        required: false,
        format: "uuid",
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
  }),
  ],
  {
    description: "Esquema principal para la entidad Notification",
  }
);

// ===== ESQUEMA DE CREACIÓN =====
export const NotificationCreateSchema = t.Pick(NotificationSchema, ["id", "createdAt", "type", "title", "message", "recipientId", "recipientType", "channel", "parkingId", "relatedEntityId", "relatedEntityType", "status", "metadata", "scheduledFor", "sentAt"], {
  description: "Esquema para la creación de una Notification",
});

// ===== ESQUEMA DE ACTUALIZACIÓN =====
export const NotificationUpdateSchema = t.Pick(NotificationSchema, ["updatedAt", "status"], {
  description: "Esquema para la actualización de una Notification",
});

// ===== ESQUEMA DE FILTRO =====
export const NotificationFilterSchema = t.Object(
  {
    recipientId: t.Optional(
      t.String({
        description: "Filtrar por ID del destinatario",
        required: false,
        format: "uuid",
      }),
    ),
    parkingId: t.Optional(
      t.String({
        description: "Filtrar por ID del estacionamiento",
        required: false,
        format: "uuid",
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

// ===== EXPORT TYPES =====
export type Notification = typeof NotificationSchema.static;
export type NotificationCreate = typeof NotificationCreateSchema.static;
export type NotificationUpdate = typeof NotificationUpdateSchema.static;
export type NotificationFilter = typeof NotificationFilterSchema.static;
