
import { t } from 'elysia';
import { ParkingSchema } from './parking';

// Esquemas JSON adicionales
// No hay esquemas adicionales

// Modelo Principal
export const SubscriptionPlanSchema = t.Object(
  {
    id: t.String(
    {
      description: "Identificador único del plan de suscripción",
      required: true
    }
  ),
  name: t.String(
    {
      description: "Nombre del plan",
      required: true
    }
  ),
  description: t.String(
    {
      description: "Descripción opcional del plan",
      required: false
    }
  ),
  price: t.Numeric(
    {
      description: "Precio del plan",
      required: true
    }
  ),
  duration: t.Integer(
    {
      description: "Duración del plan en días",
      required: true
    }
  ),
  parkingId: t.String(
    {
      description: "ID del estacionamiento asociado",
      required: true
    }
  ),
  parking: ParkingSchema,
  createdAt: t.Union([
    t.String(
      {
        description: 'Fecha de creación del registro',
        required: true
      }
    ),
    t.Date(
      {
        description: 'Fecha de creación del registro',
        required: true
      })
  ]),
  updatedAt: t.Union([
    t.String(
      {
        description: 'Fecha de última actualización del registro',
        required: true
      }
    ),
    t.Date(
      {
        description: 'Fecha de última actualización del registro',
        required: true
      })
  ]),
  },
  {
    description: 'Esquema principal para la entidad SubscriptionPlan'
  }
);

export type SubscriptionPlan = typeof SubscriptionPlanSchema.static;

// Modelo de Creación
export const SubscriptionPlanCreateSchema = t.Object(
  {
    name: t.String(
    {
      description: "Nombre del plan",
      required: true
    }
  ),
  description: t.String(
    {
      description: "Descripción opcional del plan",
      required: false
    }
  ),
  price: t.Numeric(
    {
      description: "Precio del plan",
      required: true
    }
  ),
  duration: t.Integer(
    {
      description: "Duración del plan en días",
      required: true
    }
  ),
  parkingId: t.String(
    {
      description: "ID del estacionamiento asociado",
      required: true
    }
  ),
  },
  {
  description: 'Esquema para la creación de un SubscriptionPlan'
  }
);

export type SubscriptionPlanCreate = typeof SubscriptionPlanCreateSchema.static;

// Modelo de Actualización
export const SubscriptionPlanUpdateSchema = t.Object(
  {
  name: t.String(
    {
      description: "Nombre del plan",
      required: true
    }
  ),
  description: t.String(
    {
      description: "Descripción opcional del plan",
      required: false
    }
  ),
  price: t.Numeric(
    {
      description: "Precio del plan",
      required: true
    }
  ),
  duration: t.Integer(
    {
      description: "Duración del plan en días",
      required: true
    }
  ),
  },
  {
  description: 'Esquema para la actualización de un SubscriptionPlan'
  }
);

export type SubscriptionPlanUpdate = typeof SubscriptionPlanUpdateSchema.static;
