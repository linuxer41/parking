import { t } from "elysia";
import { BaseSchema } from "./base-model";
import { ElementPreviewSchema } from "./element";
import { EmployeePreviewSchema } from "./employee";
import { ParkingPreviewSchema } from "./parking";
import { VehicleDetailsRequestSchema, VehiclePreviewSchema } from "./vehicle";

// Modelo Principal
export const ReservationSchema = t.Object(
  {
    // Campos base
    ...BaseSchema.properties,
    // Campos específicos
    number: t.Integer({
      description: "Número de la reserva",
      required: true,
    }),
    parkingId: t.String({
      description: "ID del estacionamiento asociado",
      required: true,
    }),
    parking: ParkingPreviewSchema,
    employeeId: t.String({
      description: "ID del empleado asociado",
      required: true,
    }),
    employee: EmployeePreviewSchema,
    vehicleId: t.String({
      description: "ID del vehículo que realiza la reserva",
      required: true,
    }),
    vehicle: VehiclePreviewSchema,
    spotId: t.String({
      description: "ID del puesto reservado",
      required: true,
    }),
    spot: ElementPreviewSchema,
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
      t.String({
        description: "Fecha y hora de fin de la reserva",
        required: true,
      }),
      t.Date({
        description: "Fecha y hora de fin de la reserva",
        required: true,
      }),
    ]),
    status: t.String({
      description: "Estado de la reserva (activa, cancelada, etc.)",
      required: true,
    }),
    amount: t.Numeric({
      description: "Monto de la reserva",
      required: true,
    }),
  },
  {
    description: "Esquema principal para la entidad Reservation",
  },
);

export type Reservation = typeof ReservationSchema.static;

// Modelo de Creación
export const ReservationCreateSchema = t.Pick(ReservationSchema, ["number", "parkingId", "employeeId", "vehicleId", "spotId", "startDate", "endDate", "status", "amount"], {
  description: "Esquema para la creación de una Reservation",
});

export type ReservationCreate = typeof ReservationCreateSchema.static;

// Modelo de Actualización
export const ReservationUpdateSchema = t.Partial(t.Pick(ReservationSchema, ["number", "employeeId", "vehicleId", "spotId", "startDate", "endDate", "status", "amount"]), {
  description: "Esquema para la actualización de una Reservation",
});

export type ReservationUpdate = typeof ReservationUpdateSchema.static;

// Modelo de Previsualización
export const ReservationPreviewSchema = t.Pick(ReservationSchema, ["id", "number", "parkingId", "employeeId", "vehicleId", "spotId", "startDate", "endDate", "status", "amount"], {
  description: "Esquema para la previsualización de una Reservation",
});

export type ReservationPreview = typeof ReservationPreviewSchema.static;

export const ReservationForElementSchema = t.Pick(ReservationSchema, ["id", "number", "employee", "vehicle", "startDate", "endDate", "amount"]);

export type ReservationForElement = typeof ReservationForElementSchema.static;

export const ReservationCreateRequestSchema = t.Composite([
  t.Pick(ReservationSchema, ["parkingId", "spotId", "startDate", "amount"]),
  VehicleDetailsRequestSchema,
  t.Object({
    areaId: t.String({
      description: "ID del área",
      required: true,
    }),
    durationHours: t.Number({
      description: "Duración de la reserva en horas",
      required: true,
    }),
  }),
], {
  description: "Esquema para la creación de una Reservation desde el frontend",
});

export type ReservationCreateRequest = typeof ReservationCreateRequestSchema.static;
