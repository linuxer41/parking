
import { t } from 'elysia';
import { ParkingSchema } from './parking';

// Esquemas JSON adicionales
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
  posX: t.Number(
    {
      description: "Coordenada X del lugar",
      required: true
    }
  ),
  posY: t.Number(
    {
      description: "Coordenada Y del lugar",
      required: true
    }
  ),
  status: t.String(
    {
      description: "Estado del lugar (libre, ocupado, etc.)",
      required: true
    }
  ),
  },
  {
    description: 'Esquema adicional: SpotSchema'
  }
);

// Modelo Principal
export const LevelSchema = t.Object(
  {
    id: t.String(
    {
      description: "Identificador único del nivel",
      required: true
    }
  ),
  name: t.String(
    {
      description: "Nombre del nivel",
      required: true
    }
  ),
  parkingId: t.String(
    {
      description: "ID del estacionamiento al que pertenece el nivel",
      required: true
    }
  ),
  parking: ParkingSchema,
  spots: t.Array(SpotSchema),
  indicators: t.Array(IndicatorSchema),
  offices: t.Array(OfficeSchema),
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
    description: 'Esquema principal para la entidad Level'
  }
);

export type Level = typeof LevelSchema.static;

// Modelo de Creación
export const LevelCreateSchema = t.Object(
  {
    name: t.String(
    {
      description: "Nombre del nivel",
      required: true
    }
  ),
  parkingId: t.String(
    {
      description: "ID del estacionamiento al que pertenece el nivel",
      required: true
    }
  ),
  },
  {
  description: 'Esquema para la creación de un Level'
  }
);

export type LevelCreate = typeof LevelCreateSchema.static;

// Modelo de Actualización
export const LevelUpdateSchema = t.Object(
  {
  name: t.String(
    {
      description: "Nombre del nivel",
      required: true
    }
  ),
  },
  {
  description: 'Esquema para la actualización de un Level'
  }
);

export type LevelUpdate = typeof LevelUpdateSchema.static;
