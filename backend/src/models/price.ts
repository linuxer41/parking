
import { t } from 'elysia';
import { ParkingSchema } from './parking';

// Esquemas JSON adicionales
// No hay esquemas adicionales

// Modelo Principal
export const PriceSchema = t.Object(
  {
    id: t.String(
    {
      description: "Identificador único del precio",
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
  vehicleTypeId: t.String(
    {
      description: "ID del tipo de vehículo",
      required: true
    }
  ),
  timeRangeId: t.String(
    {
      description: "ID del rango de tiempo",
      required: true
    }
  ),
  amount: t.Numeric(
    {
      description: "Monto del precio",
      required: true
    }
  ),
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
    description: 'Esquema principal para la entidad Price'
  }
);

export type Price = typeof PriceSchema.static;

// Modelo de Creación
export const PriceCreateSchema = t.Object(
  {
    parkingId: t.String(
    {
      description: "ID del estacionamiento asociado",
      required: true
    }
  ),
  vehicleTypeId: t.String(
    {
      description: "ID del tipo de vehículo",
      required: true
    }
  ),
  timeRangeId: t.String(
    {
      description: "ID del rango de tiempo",
      required: true
    }
  ),
  amount: t.Numeric(
    {
      description: "Monto del precio",
      required: true
    }
  ),
  },
  {
  description: 'Esquema para la creación de un Price'
  }
);

export type PriceCreate = typeof PriceCreateSchema.static;

// Modelo de Actualización
export const PriceUpdateSchema = t.Object(
  {
  vehicleTypeId: t.String(
    {
      description: "ID del tipo de vehículo",
      required: true
    }
  ),
  timeRangeId: t.String(
    {
      description: "ID del rango de tiempo",
      required: true
    }
  ),
  amount: t.Numeric(
    {
      description: "Monto del precio",
      required: true
    }
  ),
  },
  {
  description: 'Esquema para la actualización de un Price'
  }
);

export type PriceUpdate = typeof PriceUpdateSchema.static;
