import { t } from "elysia";
import { BaseSchema } from "./base-model";
import { EmployeePreviewSchema } from "./employee";
import { ParkingPreviewSchema } from "./parking";
import { VehicleDetailsRequestSchema, VehiclePreviewSchema } from "./vehicle";
import { ElementPreviewSchema } from "./element";

// Modelo Principal
export const SubscriptionSchema = t.Object(
  {
    // Campos base
    ...BaseSchema.properties,
    // Campos específicos
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
      description: "ID del vehículo asociado",
      required: true,
    }),
    vehicle: VehiclePreviewSchema,
    spotId: t.String({
      description: "ID del spot asociado",
      required: true,
    }),
    spot: ElementPreviewSchema,
    startDate: t.Union([
      t.String({
        description: "Fecha de inicio del abono",
        required: true,
      }),
      t.Date({
        description: "Fecha de inicio del abono",
        required: true,
      }),
    ]),
    endDate: t.Union([
      t.String({
        description: "Fecha de fin del abono",
        required: true,
      }),
      t.Date({
        description: "Fecha de fin del abono",
        required: true,
      }),
    ]),
    amount: t.Numeric({
      description: "Cantidad de abono",
      required: true,
    }),
    isActive: t.Boolean({
      description: "Indica si el abono está activo",
      required: true,
    }),
  },
  {
    description: "Esquema principal para la entidad Subscription",
  },
);

export type Subscription = typeof SubscriptionSchema.static;

// Modelo de Creación
export const SubscriptionCreateSchema = t.Pick(SubscriptionSchema, ["parkingId", "employeeId", "vehicleId", "spotId", "startDate", "endDate", "amount", "isActive"], {
  description: "Esquema para la creación de un Subscription",
});

export type SubscriptionCreate = typeof SubscriptionCreateSchema.static;


// Modelo de Actualización
export const SubscriptionUpdateSchema = t.Partial(t.Pick(SubscriptionSchema, ["startDate", "endDate", "amount", "isActive"]), {
  description: "Esquema para la actualización de un Subscription",
});

export type SubscriptionUpdate = typeof SubscriptionUpdateSchema.static;

export const SubscriptionPreviewSchema = t.Pick(SubscriptionSchema, ["id", "parking", "employee", "vehicle", "startDate", "endDate", "amount"]);

export type SubscriptionPreview = typeof SubscriptionPreviewSchema.static;

export const SubscriptionForElementSchema = t.Pick(SubscriptionSchema, ["id", "employee", "vehicle", "startDate", "endDate", "amount"]);

export type SubscriptionForElement = typeof SubscriptionForElementSchema.static;

export const SubscriptionCreateRequestSchema = t.Composite([
  t.Pick(SubscriptionSchema, ["parkingId", "spotId", "startDate", "amount"]),
  VehicleDetailsRequestSchema,
  t.Object({
    spotId: t.String({
      description: "ID del spot",
      required: true,
    }),
    areaId: t.String({
      description: "ID del área",
      required: true,
    }),
    period: t.Union([
      t.Literal("weekly"),
      t.Literal("monthly"),
      t.Literal("yearly"),
    ], {
      description: "Periodo de la suscripción",
      required: true,
    }),
  }),
], {
  description: "Esquema para la creación de un Subscription desde el frontend",
});

export type SubscriptionCreateRequest = typeof SubscriptionCreateRequestSchema.static;
