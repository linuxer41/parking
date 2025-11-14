import { t } from "elysia";
import { BaseSchema } from "./base-model";
import { EmployeeResponseSchema } from "./employee";
import { VehiclePreviewSchema } from "./vehicle";
import { ParkingPreviewSchema } from "./parking";

// ===== TIPOS DE RESERVA =====
export const RESERVATION_STATUS = {
  PENDING: "pending",
  ACTIVE: "active",
  COMPLETED: "completed",
  CANCELLED: "cancelled",
  EXPIRED: "expired"
} as const;

// ===== ESQUEMA PRINCIPAL DE RESERVA =====
export const BookingSchema = t.Composite([
  BaseSchema,
  t.Object({
    // Campos específicos para reservas
    number: t.Integer({
      description: "Número de la reserva",
      required: true,
    }),
    parkingId: t.String({
      description: "ID del estacionamiento asociado",
      required: true,
      format: "uuid",
    }),
    parking: ParkingPreviewSchema,
    employeeId: t.String({
      description: "ID del empleado asociado",
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
        description: "Fecha y hora de inicio de la reserva",
        required: true,
      }),
      t.Date({
        description: "Fecha y hora de inicio de la reserva",
        required: true,
      }),
    ]),
    endDate: t.Union([
      t.Null(),
      t.String({
        description: "Fecha y hora de fin de la reserva",
        required: false,
      }),
      t.Date({
        description: "Fecha y hora de fin de la reserva",
        required: false,
      }),
    ]),
    amount: t.Numeric({
      description: "Monto de la reserva",
      required: true,
    }),
    status: t.Union([
      t.Literal(RESERVATION_STATUS.PENDING),
      t.Literal(RESERVATION_STATUS.ACTIVE),
      t.Literal(RESERVATION_STATUS.COMPLETED),
      t.Literal(RESERVATION_STATUS.CANCELLED),
      t.Literal(RESERVATION_STATUS.EXPIRED),
    ], {
      description: "Estado de la reserva",
      required: true,
    }),
    notes: t.Optional(t.String({
      description: "Notas adicionales de la reserva",
      required: false,
    })),
  }),
], {
  description: "Esquema principal para la entidad Booking (Reserva)",
});

// ===== ESQUEMA DE CREACIÓN INTERNO =====
export const BookingCreateSchema = t.Pick(BookingSchema, [
  "id", "createdAt", "number", "parkingId", "employeeId", "vehicleId", 
  "spotId", "startDate", "endDate", "amount", "status", "notes"
], {
  description: "Esquema interno para la creación de una Reserva (incluye id y createdAt)",
});

// ===== ESQUEMA DE CREACIÓN PARA REQUESTS =====
export const BookingCreateRequestSchema = t.Object({
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
  duration: t.Integer({ minimum: 1, description: "Duración en horas" }),
  notes: t.Optional(t.String()),
}, {
  description: "Esquema para la creación de una Reserva desde el frontend",
});

// ===== ESQUEMA DE ACTUALIZACIÓN =====
export const BookingUpdateSchema = t.Partial(t.Pick(BookingSchema, [
  "updatedAt", "spotId", "startDate", "endDate", "status", "amount", "notes"
]), {
  description: "Esquema para la actualización de una Reserva",
});

// ===== ESQUEMAS ADICIONALES =====
export const BookingResponseSchema = t.Pick(BookingSchema, [
  "id", "number", "parkingId", "employeeId", "vehicleId", 
  "spotId", "startDate", "endDate", "status", "amount", "notes"
], {
  description: "Esquema para la respuesta de una Reserva",
});

export const BookingForElementSchema = t.Pick(BookingSchema, [
  "id", "number", "employee", "vehicle", "startDate", 
  "endDate", "amount", "status", "notes"
]);

export const BookingPreviewSchema = t.Pick(BookingSchema, [
  "id", "number", "parking", "employee", "vehicle", 
  "startDate", "endDate", "amount", "status"
]);

// ===== EXPORT TYPES =====
export type Booking = typeof BookingSchema.static;
export type BookingCreate = typeof BookingCreateSchema.static;
export type BookingUpdate = typeof BookingUpdateSchema.static;
export type BookingResponse = typeof BookingResponseSchema.static;
export type BookingForElement = typeof BookingForElementSchema.static;
export type BookingPreview = typeof BookingPreviewSchema.static;
export type BookingCreateRequest = typeof BookingCreateRequestSchema.static;

// Tipos de constantes
export type ReservationStatus = typeof RESERVATION_STATUS[keyof typeof RESERVATION_STATUS];
