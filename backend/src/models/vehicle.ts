import { t } from "elysia";
import { BaseSchema } from "./base-model";

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

// Modelo Principal
export const VehicleSchema = t.Object(
  {
    // Campos base
    ...BaseSchema.properties,
    // Campos específicos
    parkingId: t.String({
      description: "ID del estacionamiento asociado",
      required: true,
    }),
    type: t.Optional(t.String({
      description: "ID del tipo de vehículo",
      required: false,
    })),
    color: t.Optional(t.String({
      description: "ID del color del vehículo",
      required: false,
    })),
    plate: t.String({
      description: "Placa del vehículo",
      required: true,
    }),
    ownerName: t.Nullable(t.String({
      description: "Nombre del propietario del vehículo",
      required: false,
    })),
    ownerDocument: t.Nullable(t.String({
      description: "Documento de identidad del propietario del vehículo",
      required: false,
    })),
    ownerPhone: t.Nullable(t.String({
      description: "Teléfono del propietario del vehículo",
      required: false,
    })),
    subscription: t.Nullable(SpotCheckSchema),
    reservation: t.Nullable(SpotCheckSchema),
    access: t.Nullable(SpotCheckSchema),
  },
  {
    description: "Esquema principal para la entidad Vehicle",
  },
);

export type Vehicle = typeof VehicleSchema.static;

// Modelo de Creación
export const VehicleCreateSchema = t.Pick(VehicleSchema, ["parkingId", "type", "color", "plate", "ownerName", "ownerDocument", "ownerPhone"], {
  description: "Esquema para la creación de un Vehicle",
});

export type VehicleCreate = typeof VehicleCreateSchema.static;

// Modelo de Actualización
export const VehicleUpdateSchema = t.Partial(t.Pick(VehicleSchema, ["type", "color", "plate", "ownerName", "ownerDocument", "ownerPhone"]), {
  description: "Esquema para la actualización de un Vehicle",
});

export type VehicleUpdate = typeof VehicleUpdateSchema.static;

// pick vehicle schema properties
export const VehiclePreviewSchema = t.Pick(VehicleSchema, ["id", "plate", "color", "type", "ownerName", "ownerDocument", "ownerPhone"]);

export type VehiclePreview = typeof VehiclePreviewSchema.static;

export const VehicleDetailsRequestSchema = t.Object({
  vehiclePlate: t.String({
    description: "Placa del vehículo",
    required: true,
  }),
  vehicleType: t.Optional(t.String({
    description: "Tipo de vehículo",
    required: true,
  })),
  vehicleColor: t.Optional(t.String({
    description: "Color del vehículo",
    required: true,
  })),
  ownerDocument:  t.Optional(t.String({
    description: "Documento del propietario del vehículo",
    required: true,
  })),
  ownerName: t.Optional(t.String({
    description: "Nombre del propietario del vehículo",
    required: true,
  })),
  ownerPhone: t.Optional(t.String({
    description: "Teléfono del propietario del vehículo",
    required: true,
  })),
});

export type VehicleDetailsRequest = typeof VehicleDetailsRequestSchema.static;

