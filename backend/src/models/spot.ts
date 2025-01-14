
import { t } from 'elysia';
import { ParkingSchema } from './parking';
import { AreaSchema } from './area';

// Esquemas JSON adicionales
export const CoordinatesSchema = t.Object(
  {
    x0: t.Integer(
    {
      description: "Coordenada X inicial",
      required: true
    }
  ),
  y0: t.Integer(
    {
      description: "Coordenada Y inicial",
      required: true
    }
  ),
  x1: t.Integer(
    {
      description: "Coordenada X final",
      required: true
    }
  ),
  y1: t.Integer(
    {
      description: "Coordenada Y final",
      required: true
    }
  ),
  },
  {
    description: 'Esquema adicional: CoordinatesSchema'
  }
);

// Modelo Principal
export const SpotSchema = t.Object(
  {
    id: t.String(
    {
      description: "Identificador único del lugar de estacionamiento",
      required: true
    }
  ),
  name: t.String(
    {
      description: "Nombre del lugar",
      required: true
    }
  ),
  coordinates: CoordinatesSchema,
  status: t.String(
    {
      description: "Estado del lugar (libre, ocupado, etc.)",
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
  areaId: t.String(
    {
      description: "ID del área a la que pertenece el lugar",
      required: true
    }
  ),
  area: AreaSchema,
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
    description: 'Esquema principal para la entidad Spot'
  }
);

export type Spot = typeof SpotSchema.static;

// Modelo de Creación
export const SpotCreateSchema = t.Object(
  {
    name: t.String(
    {
      description: "Nombre del lugar",
      required: true
    }
  ),
  coordinates: CoordinatesSchema,
  status: t.String(
    {
      description: "Estado del lugar (libre, ocupado, etc.)",
      required: true
    }
  ),
  parkingId: t.String(
    {
      description: "ID del estacionamiento asociado",
      required: true
    }
  ),
  areaId: t.String(
    {
      description: "ID del área a la que pertenece el lugar",
      required: true
    }
  ),
  },
  {
  description: 'Esquema para la creación de un Spot'
  }
);

export type SpotCreate = typeof SpotCreateSchema.static;

// Modelo de Actualización
export const SpotUpdateSchema = t.Object(
  {
  name: t.String(
    {
      description: "Nombre del lugar",
      required: true
    }
  ),
  coordinates: CoordinatesSchema,
  status: t.String(
    {
      description: "Estado del lugar (libre, ocupado, etc.)",
      required: true
    }
  ),
  },
  {
  description: 'Esquema para la actualización de un Spot'
  }
);

export type SpotUpdate = typeof SpotUpdateSchema.static;
