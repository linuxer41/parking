
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
  vehicleId: t.String(
    {
      description: "ID del vehículo que se encuentra en el lugar",
      required: false
    }
  ),
  spotType: t.Integer(
    {
      description: "Tipo de lugar (motocicleta, camión, etc.)",
      required: true
    }
  ),
  spotLevel: t.Integer(
    {
      description: "vip, normal, etc.",
      required: true
    }
  ),
  },
  {
    description: 'Esquema adicional: SpotSchema'
  }
);

export type Spot = typeof SpotSchema.static;


export const IndicatorSchema = t.Object(
  {
    id: t.String(
    {
      description: "Identificador único del indicador",
      required: true
    }
  ),
  posX: t.Number(
    {
      description: "Coordenada X del indicador",
      required: true
    }
  ),
  posY: t.Number(
    {
      description: "Coordenada Y del indicador",
      required: true
    }
  ),
  indicatorType: t.Integer(
    {
      description: "Tipo de indicador (entrada, salida, etc.)",
      required: true
    }
  ),
  },
  {
    description: 'Esquema adicional: IndicatorSchema'
  }
);

export type Indicator = typeof IndicatorSchema.static;


export const OfficeSchema = t.Object(
  {
    id: t.String(
    {
      description: "Identificador único de la oficina",
      required: true
    }
  ),
  name: t.String(
    {
      description: "Nombre de la oficina",
      required: true
    }
  ),
  posX: t.Number(
    {
      description: "Coordenada X de la oficina",
      required: true
    }
  ),
  posY: t.Number(
    {
      description: "Coordenada Y de la oficina",
      required: true
    }
  ),
  },
  {
    description: 'Esquema adicional: OfficeSchema'
  }
);

export type Office = typeof OfficeSchema.static;


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
