import { t } from "elysia";
import { UserSchema } from "./user";
import { BaseSchema } from "./base-model";
import { AreaSchema } from "./area";
import { EmployeeSchema } from "./employee";

// Esquemas JSON adicionales
export const ParkingParamsSchema = t.Object(
  {
    currency: t.String({
      description: "Moneda del pase",
      required: true,
    }),
    timeZone: t.String({
      description: "Zona horaria del pase",
      required: true,
    }),
    decimalPlaces: t.Integer({
      description: "Decimales del pase",
      required: true,
    }),
    countryCode: t.String({
      description: "Código de país del pase",
      required: true,
    }),
    theme: t.String({
      description: "Tema del pase",
      required: true,
    }),
    slogan: t.Optional(
      t.String({
        description: "Eslogan del estacionamiento",
        required: false,
      }),
    ),
  },
  {
    description: "Esquema adicional: ParkingParamsSchema",
  },
);

export type ParkingParams = typeof ParkingParamsSchema.static;

export const RateSchema = t.Object(
  {
    id: t.String({
      description: "Identificador único de la tarifa",
      required: true,
    }),
    name: t.String({
      description: "Nombre de la tarifa",
      required: true,
    }),
    vehicleCategory: t.Integer({
      description: "Categoría de vehículo",
      required: true,
    }),
    tolerance: t.Integer({
      description: "Tolerancia en minutos",
      required: true,
    }),
    hourly: t.Number({
      description: "Precio por hora",
      required: true,
    }),
    daily: t.Number({
      description: "Precio por día completo (24h)",
      required: true,
    }),
    weekly: t.Number({
      description: "Precio por semana",
      required: true,
    }),
    monthly: t.Number({
      description: "Precio por mes",
      required: true,
    }),
    yearly: t.Number({
      description: "Precio por año",
      required: true,
    }),
    isActive: t.Boolean({
      description: "Indica si la tarifa está activa",
      required: true,
    }),
  },
  {
    description: "Esquema adicional: RateSchema",
  },
);

export type Rate = typeof RateSchema.static;

// Modelo Principal
export const ParkingSchema = t.Object(
  {
    // Campos base
    ...BaseSchema.properties,
    // Campos específicos
    name: t.String({
      description: "Nombre del estacionamiento",
      required: true,
    }),
    email: t.String({
      description: "Correo electrónico del estacionamiento",
      required: true,
    }),
    phone: t.Optional(
      t.String({
        description: "Número de teléfono del estacionamiento",
        required: false,
      }),
    ),
    address: t.Optional(
      t.String({
        description: "Dirección del estacionamiento",
        required: false,
      }),
    ),
    logoUrl: t.Optional(
      t.String({
        description: "URL del logo del estacionamiento",
        required: false,
      }),
    ),
    status: t.String({
      description: "Estado del estacionamiento",
      required: true,
    }),
    ownerId: t.String({
      description: "ID del usuario propietario del estacionamiento",
      required: true,
    }),
    params: ParkingParamsSchema,
    rates: t.Array(RateSchema),
    areas: t.Array(AreaSchema),
    employees: t.Array(EmployeeSchema),
    isOwner: t.Boolean({
      description: "Indica si el usuario es propietario",
      required: true,
    }),
    isActive: t.Boolean({
      description: "Indica si el estacionamiento está activo",
      required: true,
    }),
    areaCount: t.Integer({
      description: "Cantidad total de áreas",
      required: true,
    }),
    totalSpots: t.Integer({
      description: "Cantidad total de spots",
      required: true,
    }),
    occupiedSpots: t.Integer({
      description: "Cantidad de spots ocupados",
      required: true,
    }),
    availableSpots: t.Integer({
      description: "Cantidad de spots disponibles",
      required: true,
    }),
    operationMode: t.Union([t.Literal("visual"), t.Literal("simple")], {
      description: "Modo de operación del parqueo: visual o simple",
      required: true,
      default: "visual",
    }),
    capacity: t.Number({
      description: "Capacidad máxima del parqueo",
      required: true,
      default: 0,
    }),
  },
  {
    description: "Esquema principal para la entidad Parking",
  },
);

export type Parking = typeof ParkingSchema.static;

// Modelo de Creación
export const ParkingCreateSchema = t.Pick(ParkingSchema, ["name", "email", "phone", "address", "logoUrl", "status", "ownerId", "params", "rates"], {
  description: "Esquema para la creación de un Parking",
});

export type ParkingCreate = typeof ParkingCreateSchema.static;

// Modelo de Actualización
export const ParkingUpdateSchema = t.Partial(t.Pick(ParkingSchema, ["name", "email", "phone", "address", "logoUrl", "status", "params", "rates", "operationMode", "capacity"], {
  description: "Esquema para la actualización de un Parking",
}));

export type ParkingUpdate = typeof ParkingUpdateSchema.static;

export const ParkingPreviewSchema = t.Pick(ParkingSchema, ["id", "name", "address", "logoUrl", "params"]);

export type ParkingPreview = typeof ParkingPreviewSchema.static;

export const ParkingSimpleSchema = t.Pick(ParkingSchema, ["id", "name", "address", "logoUrl", "params", "rates", "status", "isOwner", "isActive", "areaCount", "totalSpots", "occupiedSpots", "availableSpots"], {
  description: "Esquema para la vista de un Parking",
});

export type ParkingSimple = typeof ParkingSimpleSchema.static;
