
import { t } from 'elysia';
import { CompanySchema } from './company';

// Esquemas JSON adicionales
export const VehicleTypeSchema = t.Object(
  {
    id: t.Integer({
          description: "Identificador único del tipo de vehículo",
          required: true
        }),
  name: t.String({
          description: "Nombre del tipo de vehículo",
          required: true
        }),
  description: t.Optional(t.String({
          description: "Descripción del tipo de vehículo",
          required: false
        })),
  },
  {
    description: 'Esquema adicional: VehicleTypeSchema'
  }
);

export type VehicleType = typeof VehicleTypeSchema.static;


export const ParkingParamsSchema = t.Object(
  {
    currency: t.String({
          description: "Moneda del pase",
          required: true
        }),
  timeZone: t.String({
          description: "Zona horaria del pase",
          required: true
        }),
  decimalPlaces: t.Integer({
          description: "Decimales del pase",
          required: true
        }),
  theme: t.String({
          description: "Tema del pase",
          required: true
        }),
  },
  {
    description: 'Esquema adicional: ParkingParamsSchema'
  }
);

export type ParkingParams = typeof ParkingParamsSchema.static;


export const PriceSchema = t.Object(
  {
    id: t.String({
          description: "Identificador único del precio",
          required: true
        }),
  name: t.String({
          description: "Nombre del precio",
          required: true
        }),
  baseTime: t.Integer({
          description: "Tiempo base del pase",
          required: true
        }),
  tolerance: t.Integer({
          description: "Tolerancia del pase",
          required: true
        }),
  pasePrice: t.Numeric({
          description: "Precio del pase",
          required: true
        }),
  },
  {
    description: 'Esquema adicional: PriceSchema'
  }
);

export type Price = typeof PriceSchema.static;


export const SubscriptionPlanSchema = t.Object(
  {
    id: t.String({
          description: "Identificador único del plan de suscripción",
          required: true
        }),
  name: t.String({
          description: "Nombre del plan",
          required: true
        }),
  description: t.Optional(t.String({
          description: "Descripción opcional del plan",
          required: false
        })),
  price: t.Numeric({
          description: "Precio del plan",
          required: true
        }),
  duration: t.Integer({
          description: "Duración del plan en días",
          required: true
        }),
  },
  {
    description: 'Esquema adicional: SubscriptionPlanSchema'
  }
);

export type SubscriptionPlan = typeof SubscriptionPlanSchema.static;


// Modelo Principal
export const ParkingSchema = t.Object(
  {
    id: t.String({
          description: "Identificador único del estacionamiento",
          required: true
        }),
  name: t.String({
          description: "Nombre del estacionamiento",
          required: true
        }),
  companyId: t.String({
          description: "ID de la empresa a la que pertenece el estacionamiento",
          required: true
        }),
  company: t.Optional(CompanySchema),
  vehicleTypes: t.Array(VehicleTypeSchema),
  params: ParkingParamsSchema,
  prices: t.Array(PriceSchema),
  subscriptionPlans: t.Array(SubscriptionPlanSchema),
  createdAt: t.Union([
      t.String({
        description: 'Fecha de creación del registro',
        required: true
      }),
      t.Date({
        description: 'Fecha de creación del registro',
        required: true
      })
    ]),
  updatedAt: t.Union([
      t.String({
        description: 'Fecha de última actualización del registro',
        required: true
      }),
      t.Date({
        description: 'Fecha de última actualización del registro',
        required: true
      })
    ]),
  },
  {
    description: 'Esquema principal para la entidad Parking'
  }
);

export type Parking = typeof ParkingSchema.static;

// Modelo de Creación
export const ParkingCreateSchema = t.Object(
  {
    name: t.String({
          description: "Nombre del estacionamiento",
          required: true
        }),
  companyId: t.String({
          description: "ID de la empresa a la que pertenece el estacionamiento",
          required: true
        }),
  },
  {
  description: 'Esquema para la creación de un Parking'
  }
);

export type ParkingCreate = typeof ParkingCreateSchema.static;

// Modelo de Actualización
export const ParkingUpdateSchema = t.Object(
  {
  name: t.Optional(t.String({
          description: "Nombre del estacionamiento",
          required: true
        })),
  vehicleTypes: t.Optional(t.Array(VehicleTypeSchema)),
  params: t.Optional(ParkingParamsSchema),
  prices: t.Optional(t.Array(PriceSchema)),
  subscriptionPlans: t.Optional(t.Array(SubscriptionPlanSchema)),
  },
  {
  description: 'Esquema para la actualización de un Parking'
  }
);

export type ParkingUpdate = typeof ParkingUpdateSchema.static;
