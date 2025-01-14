
import { t } from 'elysia';
import { ParkingSchema } from './parking';
import { LevelSchema } from './level';

// Esquemas JSON adicionales
// No hay esquemas adicionales

// Modelo Principal
export const AreaSchema = t.Object(
  {
    id: t.String(
    {
      description: "Identificador único del área",
      required: true
    }
  ),
  name: t.String(
    {
      description: "Nombre del área",
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
  levelId: t.String(
    {
      description: "ID del nivel al que pertenece el área",
      required: true
    }
  ),
  level: LevelSchema,
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
    description: 'Esquema principal para la entidad Area'
  }
);

export type Area = typeof AreaSchema.static;

// Modelo de Creación
export const AreaCreateSchema = t.Object(
  {
    name: t.String(
    {
      description: "Nombre del área",
      required: true
    }
  ),
  parkingId: t.String(
    {
      description: "ID del estacionamiento asociado",
      required: true
    }
  ),
  levelId: t.String(
    {
      description: "ID del nivel al que pertenece el área",
      required: true
    }
  ),
  },
  {
  description: 'Esquema para la creación de un Area'
  }
);

export type AreaCreate = typeof AreaCreateSchema.static;

// Modelo de Actualización
export const AreaUpdateSchema = t.Object(
  {
  name: t.String(
    {
      description: "Nombre del área",
      required: true
    }
  ),
  },
  {
  description: 'Esquema para la actualización de un Area'
  }
);

export type AreaUpdate = typeof AreaUpdateSchema.static;
