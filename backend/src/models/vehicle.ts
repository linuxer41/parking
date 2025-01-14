
import { t } from 'elysia';
import { ParkingSchema } from './parking';

// Esquemas JSON adicionales
// No hay esquemas adicionales

// Modelo Principal
export const VehicleSchema = t.Object(
  {
    id: t.String(
    {
      description: "Identificador único del vehículo",
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
  typeId: t.String(
    {
      description: "ID del tipo de vehículo",
      required: true
    }
  ),
  plate: t.String(
    {
      description: "Placa del vehículo",
      required: true
    }
  ),
  isSubscriber: t.Boolean(
    {
      description: "Indica si el vehículo es abonado",
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
    description: 'Esquema principal para la entidad Vehicle'
  }
);

export type Vehicle = typeof VehicleSchema.static;

// Modelo de Creación
export const VehicleCreateSchema = t.Object(
  {
    parkingId: t.String(
    {
      description: "ID del estacionamiento asociado",
      required: true
    }
  ),
  typeId: t.String(
    {
      description: "ID del tipo de vehículo",
      required: true
    }
  ),
  plate: t.String(
    {
      description: "Placa del vehículo",
      required: true
    }
  ),
  isSubscriber: t.Boolean(
    {
      description: "Indica si el vehículo es abonado",
      required: true
    }
  ),
  },
  {
  description: 'Esquema para la creación de un Vehicle'
  }
);

export type VehicleCreate = typeof VehicleCreateSchema.static;

// Modelo de Actualización
export const VehicleUpdateSchema = t.Object(
  {
  typeId: t.String(
    {
      description: "ID del tipo de vehículo",
      required: true
    }
  ),
  plate: t.String(
    {
      description: "Placa del vehículo",
      required: true
    }
  ),
  isSubscriber: t.Boolean(
    {
      description: "Indica si el vehículo es abonado",
      required: true
    }
  ),
  },
  {
  description: 'Esquema para la actualización de un Vehicle'
  }
);

export type VehicleUpdate = typeof VehicleUpdateSchema.static;
