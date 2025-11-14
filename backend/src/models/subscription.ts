import { t } from "elysia";
import { BaseSchema } from "./base-model";
import { EmployeeResponseSchema } from "./employee";
import { VehiclePreviewSchema } from "./vehicle";

// ===== TIPOS DE SUSCRIPCIÓN =====
export const SUBSCRIPTION_STATUS = {
  ACTIVE: "active",
  SUSPENDED: "suspended",
  EXPIRED: "expired",
  CANCELLED: "cancelled",
  RENEWED: "renewed"
} as const;

export const SUBSCRIPTION_PERIOD = {
  WEEKLY: "weekly",
  MONTHLY: "monthly",
  YEARLY: "yearly"
} as const;

// ===== ESQUEMA PRINCIPAL DE SUSCRIPCIÓN =====
export const SubscriptionSchema = t.Composite([
  BaseSchema,
  t.Object({
    // Campos específicos para suscripciones
    number: t.Integer({
      description: "Número de la suscripción",
      required: true,
    }),
    parkingId: t.String({
      description: "ID del estacionamiento asociado",
      required: true,
      format: "uuid",
    }),
    parking: t.Object({
      id: t.String(),
      name: t.String(),
      address: t.String(),
    }),
    employeeId: t.String({
      description: "ID del empleado que crea la suscripción",
      required: true,
      format: "uuid",
    }),
    employee: EmployeeResponseSchema,
    vehicleId: t.String({
      description: "ID del vehículo asociado",
      required: true,
      format: "uuid",
    }),
    vehicle: VehiclePreviewSchema,
    spotId: t.Union([t.Null(), t.String({
      description: "ID del spot asociado",
      required: false,
      format: "uuid",
    })]),
    startDate: t.Union([
      t.String({
        description: "Fecha de inicio de la suscripción",
        required: true,
      }),
      t.Date({
        description: "Fecha de inicio de la suscripción",
        required: true,
      }),
    ]),
    endDate: t.Union([
      t.Null(),
      t.String({
        description: "Fecha de fin de la suscripción",
        required: false,
      }),
      t.Date({
        description: "Fecha de fin de la suscripción",
        required: false,
      }),
    ]),
    amount: t.Numeric({
      description: "Monto de la suscripción",
      required: true,
    }),
    status: t.Union([
      t.Literal(SUBSCRIPTION_STATUS.ACTIVE),
      t.Literal(SUBSCRIPTION_STATUS.SUSPENDED),
      t.Literal(SUBSCRIPTION_STATUS.EXPIRED),
      t.Literal(SUBSCRIPTION_STATUS.CANCELLED),
      t.Literal(SUBSCRIPTION_STATUS.RENEWED),
    ], {
      description: "Estado de la suscripción",
      required: true,
    }),
    period: t.Union([
      t.Literal(SUBSCRIPTION_PERIOD.WEEKLY),
      t.Literal(SUBSCRIPTION_PERIOD.MONTHLY),
      t.Literal(SUBSCRIPTION_PERIOD.YEARLY),
    ], {
      description: "Periodo de la suscripción",
      required: true,
    }),
    isActive: t.Boolean({
      description: "Indica si la suscripción está activa",
      required: true,
    }),
    parentId: t.Union([t.Null(), t.String({
      description: "ID de la suscripción padre (para renovaciones)",
      required: false,
      format: "uuid",
    })]),
    notes: t.Optional(t.String({
      description: "Notas adicionales de la suscripción",
      required: false,
    })),
  }),
], {
  description: "Esquema principal para la entidad Subscription (Suscripción)",
});

// ===== ESQUEMA DE CREACIÓN INTERNO =====
export const SubscriptionCreateSchema = t.Pick(SubscriptionSchema, [
  "id", "createdAt", "number", "parkingId", "employeeId", "vehicleId", 
  "spotId", "startDate", "endDate", "amount", "status", "period", "isActive", "parentId", "notes"
], {
  description: "Esquema interno para la creación de una Suscripción (incluye id y createdAt)",
});

// ===== ESQUEMA DE CREACIÓN PARA REQUESTS =====
export const SubscriptionCreateRequestSchema = t.Object({
  vehiclePlate: t.String({
    description: "Placa del vehículo",
    required: true,
  }),
  vehicleType: t.Optional(t.String({
    description: "Tipo de vehículo",
    required: false,
  })),
  vehicleColor: t.Optional(t.String({
    description: "Color del vehículo",
    required: false,
  })),
  ownerName: t.Optional(t.String({
    description: "Nombre del propietario del vehículo",
    required: false,
  })),
  ownerDocument: t.Optional(t.String({
    description: "Documento del propietario del vehículo",
    required: false,
  })),
  ownerPhone: t.Optional(t.String({
    description: "Teléfono del propietario del vehículo",
    required: false,
  })),
  spotId: t.Optional(t.String({ format: "uuid" })),
  startDate: t.String({ format: "date-time" }),
  period: t.Union([
    t.Literal(SUBSCRIPTION_PERIOD.WEEKLY),
    t.Literal(SUBSCRIPTION_PERIOD.MONTHLY),
    t.Literal(SUBSCRIPTION_PERIOD.YEARLY),
  ], {
    description: "Periodo de la suscripción",
    required: true,
  }),
  amount: t.Optional(t.Numeric({
    description: "Monto de la suscripción",
    required: false,
  })),
  notes: t.Optional(t.String()),
}, {
  description: "Esquema para la creación de una Suscripción desde el frontend",
});

// ===== ESQUEMA DE RENOVACIÓN =====
export const SubscriptionRenewalRequestSchema = t.Object({
  period: t.Union([
    t.Literal(SUBSCRIPTION_PERIOD.WEEKLY),
    t.Literal(SUBSCRIPTION_PERIOD.MONTHLY),
    t.Literal(SUBSCRIPTION_PERIOD.YEARLY),
  ], {
    description: "Periodo de la renovación",
    required: true,
  }),
  amount: t.Optional(t.Numeric({
    description: "Monto de la renovación",
    required: false,
  })),
  notes: t.Optional(t.String({
    description: "Notas adicionales de la renovación",
    required: false,
  })),
}, {
  description: "Esquema para renovar una suscripción",
});

// ===== ESQUEMA DE ACTUALIZACIÓN =====
export const SubscriptionUpdateSchema = t.Partial(t.Pick(SubscriptionSchema, [
  "updatedAt", "spotId", "endDate", "status", "amount", "isActive", "notes"
]), {
  description: "Esquema para la actualización de una Suscripción",
});

// ===== ESQUEMAS ADICIONALES =====
export const SubscriptionResponseSchema = t.Pick(SubscriptionSchema, [
  "id", "number", "parkingId", "employeeId", "vehicleId", 
  "spotId", "startDate", "endDate", "amount", "status", "period", "isActive", "parentId", "notes"
], {
  description: "Esquema para la respuesta de una Suscripción",
});

export const SubscriptionForElementSchema = t.Pick(SubscriptionSchema, [
  "id", "number", "employee", "vehicle", "startDate", 
  "endDate", "amount", "status", "period", "isActive", "notes"
]);

export const SubscriptionPreviewSchema = t.Pick(SubscriptionSchema, [
  "id", "number", "parking", "employee", "vehicle", 
  "startDate", "endDate", "amount", "status", "period", "isActive"
]);

// ===== EXPORT TYPES =====
export type Subscription = typeof SubscriptionSchema.static;
export type SubscriptionCreate = typeof SubscriptionCreateSchema.static;
export type SubscriptionUpdate = typeof SubscriptionUpdateSchema.static;
export type SubscriptionResponse = typeof SubscriptionResponseSchema.static;
export type SubscriptionForElement = typeof SubscriptionForElementSchema.static;
export type SubscriptionPreview = typeof SubscriptionPreviewSchema.static;
export type SubscriptionCreateRequest = typeof SubscriptionCreateRequestSchema.static;
export type SubscriptionRenewalRequest = typeof SubscriptionRenewalRequestSchema.static;

// Tipos de constantes
export type SubscriptionStatus = typeof SUBSCRIPTION_STATUS[keyof typeof SUBSCRIPTION_STATUS];
export type SubscriptionPeriod = typeof SUBSCRIPTION_PERIOD[keyof typeof SUBSCRIPTION_PERIOD];
