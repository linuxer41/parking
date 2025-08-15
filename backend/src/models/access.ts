import { t } from "elysia";
import { BaseSchema } from "./base-model";
import { ElementPreviewSchema } from "./element";
import { EmployeePreviewSchema } from "./employee";
import { ParkingPreviewSchema } from "./parking";
import { SubscriptionPreviewSchema } from "./subscription";
import { VehicleDetailsRequestSchema, VehiclePreviewSchema } from "./vehicle";
import { ReservationPreviewSchema } from "./reservation";
// Modelo Principal para Access
export const AccessSchema = t.Object({
  // Campos base
  ...BaseSchema.properties,
  // Campos específicos
  number: t.Integer({
    description: "Número del acceso",
    required: true,
  }),
  parkingId: t.String({
    description: "ID del estacionamiento asociado",
    required: true,
  }),
  parking: ParkingPreviewSchema,
  entryEmployeeId: t.String({
    description: "ID del empleado que registra la entrada",
    required: true,
  }),
  entryEmployee: EmployeePreviewSchema,
  exitEmployeeId: t.Nullable(
    t.String({
      description: "ID del empleado que registra la salida",
      required: false,
    })
  ),
  exitEmployee: t.Nullable(EmployeePreviewSchema),
  vehicleId: t.String({
    description: "ID del vehículo",
    required: true,
  }),
  vehicle: VehiclePreviewSchema,
  spotId: t.String({
    description: "ID del lugar de estacionamiento",
    required: true,
  }),
  spot: ElementPreviewSchema,
  entryTime: t.Union([
    t.String({
      description: "Fecha y hora de entrada",
      required: true,
    }),
    t.Date({
      description: "Fecha y hora de entrada",
      required: true,
    })
  ]),
  exitTime: t.Union([
    t.Null(),
    t.String({
        description: "Fecha y hora de salida",
        required: false,
      }),
      t.Date({
        description: "Fecha y hora de salida",
        required: false,
      }),
    ]
  ),
  amount: t.Optional(
    t.Numeric({
      description: "Monto cobrado por el estacionamiento",
      required: false,
    })
  ),
  status: t.String({
    description: "Estado del acceso: active, completed, cancelled",
    required: true,
  }),
  subscriptionId: t.Optional(t.Nullable(t.String({
    description: "ID de la suscripción",
    required: false,
  }))),
  subscription: t.Optional(t.Nullable(SubscriptionPreviewSchema)),
  reservationId: t.Optional(t.Nullable(t.String({
    description: "ID de la reserva",
    required: false,
  }))),
  reservation: t.Optional(t.Nullable(ReservationPreviewSchema)),
}, {
  description: "Esquema principal para la entidad Access",
});

export type Access = typeof AccessSchema.static;

// Modelo de Creación
export const AccessCreateSchema = t.Pick(AccessSchema, ["parkingId", "entryEmployeeId", "vehicleId", "spotId", "entryTime", "subscriptionId", "reservationId"], {
  description: "Esquema para la creación de un Access",
});

export type AccessCreate = typeof AccessCreateSchema.static;

// Modelo de Actualización
export const AccessUpdateSchema = t.Pick(AccessSchema, ["exitEmployeeId", "exitTime", "amount", "status"], {
  description: "Esquema para la actualización de un Access",
});

export type AccessUpdate = typeof AccessUpdateSchema.static;

export const AccessForElementSchema = t.Pick(AccessSchema, ["id", "entryTime", "entryEmployee",  "amount", "status"]);

export type AccessForElement = typeof AccessForElementSchema.static;

export const AccessPreviewSchema = t.Pick(AccessSchema, ["id", "entryTime", "entryEmployee", "vehicle", "amount", "status"]);

export type AccessPreview = typeof AccessPreviewSchema.static;

export const AccessCreateRequestSchema = t.Composite([
  t.Pick(AccessSchema, ["parkingId", "spotId"]),
  VehicleDetailsRequestSchema,
  t.Object({
    areaId: t.String({
      description: "ID del área",
      required: true,
    }),
  }),
], {
  description: "Esquema para la creación de un Access desde el frontend",
});

export type AccessCreateRequest = typeof AccessCreateRequestSchema.static;

