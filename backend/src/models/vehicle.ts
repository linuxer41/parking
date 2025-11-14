import { t } from "elysia";
import { BaseSchema } from "./base-model";

// ===== ESQUEMAS ADICIONALES =====
export const SpotCheckSchema = t.Object({
  id: t.String({
    description: "ID de la suscripción",
    required: true,
  }),
  spotId: t.String({
    description: "ID del espacio de estacionamiento",
    required: true,
  }),
  spotName: t.String({
    description: "Nombre del espacio de estacionamiento",
    required: true,
  }),
  startDate: t.String({
    description: "Fecha de inicio de la suscripción",
    required: true,
  }),
  endDate: t.Nullable(t.String({
    description: "Fecha de fin de la suscripción",
    required: true,
  })),
  amount: t.Number({
    description: "Monto de la suscripción",
    required: true,
  }),
});

// ===== ESQUEMA PRINCIPAL =====
export const VehicleSchema = t.Composite([
  BaseSchema,
  t.Object({
    // Campos específicos
    parkingId: t.String({
      description: "ID del estacionamiento asociado",
      required: true,
      format: "uuid",
    }),
    type: t.String({
      description: "ID del tipo de vehículo",
      required: false,
    }),
    color: t.Optional(t.Union([t.String(), t.Null()], {
      description: "ID del color del vehículo",
      required: false,
    })),
    plate: t.String({
      description: "Placa del vehículo",
      required: true,
    }),
    ownerName: t.Optional(t.Union([t.String(), t.Null()], {
      description: "Nombre del propietario del vehículo",
      required: false,
    })),
    ownerDocument: t.Optional(t.Union([t.String(), t.Null()], {
      description: "Documento de identidad del propietario del vehículo",
      required: false,
    })),
    ownerPhone: t.Optional(t.Union([t.String(), t.Null()], {
      description: "Teléfono del propietario del vehículo",
      required: false,
    })),
    isSubscribed: t.Boolean({
      description: "Indica si el vehículo tiene una suscripción activa",
      required: true,
    }),
    // Campo para el booking activo (solo reservas)
    activeBooking: t.Nullable(t.Object({
      id: t.String(),
      number: t.Number(),
      startDate: t.Union([t.String(), t.Date()]),
      endDate: t.Union([t.String(), t.Date(), t.Null()]),
      status: t.String(),
      amount: t.Number(),
    })),
  }),
  ],
  {
    description: "Esquema principal para la entidad Vehicle",
  }
);

// ===== ESQUEMA DE RESPUESTA =====
export const VehicleResponseSchema = t.Pick(VehicleSchema, ["id", "parkingId", "type", "color", "plate", "ownerName", "ownerDocument", "ownerPhone", "isSubscribed", "activeBooking"], {
  description: "Esquema de respuesta para operaciones de Vehicle",
});

// ===== ESQUEMA DE CREACIÓN =====
export const VehicleCreateSchema = t.Pick(VehicleSchema, ["id", "createdAt", "parkingId", "type", "color", "plate", "ownerName", "ownerDocument", "ownerPhone", "isSubscribed"], {
  description: "Esquema para la creación de un Vehicle",
});

// ===== ESQUEMA DE REQUEST DE CREACIÓN =====
export const VehicleCreateRequestSchema = t.Pick(VehicleSchema, ["parkingId", "type", "color", "plate", "ownerName", "ownerDocument", "ownerPhone", "isSubscribed"], {
  description: "Esquema de request para crear un Vehicle",
});

// ===== ESQUEMA DE ACTUALIZACIÓN =====
export const VehicleUpdateSchema = t.Partial(t.Pick(VehicleSchema, ["updatedAt", "type", "color", "plate", "ownerName", "ownerDocument", "ownerPhone"]), {
  description: "Esquema para la actualización de un Vehicle",
});

// ===== ESQUEMA DE REQUEST DE ACTUALIZACIÓN =====
export const VehicleUpdateRequestSchema = t.Partial(t.Pick(VehicleSchema, ["type", "color", "plate", "ownerName", "ownerDocument", "ownerPhone"]), {
  description: "Esquema de request para actualizar un Vehicle",
});

// ===== ESQUEMAS ADICIONALES =====
export const VehiclePreviewSchema = t.Object({
  id: t.String({ format: "uuid" }),
  plate: t.String(),
  color: t.Union([t.String(), t.Null()]),
  type: t.String(),
  ownerName: t.Union([t.String(), t.Null()]),
  ownerDocument: t.Union([t.String(), t.Null()]),
  ownerPhone: t.Union([t.String(), t.Null()]),
});



// ===== EXPORT TYPES =====
export type SpotCheck = typeof SpotCheckSchema.static;
export type Vehicle = typeof VehicleSchema.static;
export type VehicleResponse = typeof VehicleResponseSchema.static;
export type VehicleCreate = typeof VehicleCreateSchema.static;
export type VehicleCreateRequest = typeof VehicleCreateRequestSchema.static;
export type VehicleUpdate = typeof VehicleUpdateSchema.static;
export type VehicleUpdateRequest = typeof VehicleUpdateRequestSchema.static;
export type VehiclePreview = typeof VehiclePreviewSchema.static;

