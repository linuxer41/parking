
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
  posZ: t.Number(
    {
      description: "Coordenada Z del lugar",
      required: true
    }
  ),
  rotation: t.Number(
    {
      description: "Rotación del lugar",
      required: true
    }
  ),
  scale: t.Number(
    {
      description: "Escala del lugar",
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
  spotCategory: t.Integer(
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


export const SignageSchema = t.Object(
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
  posZ: t.Number(
    {
      description: "Coordenada Z del indicador",
      required: true
    }
  ),
  scale: t.Number(
    {
      description: "Escala del indicador",
      required: true
    }
  ),
  rotation: t.Number(
    {
      description: "Rotación del indicador",
      required: true
    }
  ),
  direction: t.Number(
    {
      description: "Dirección del icono de la señal (0-360)",
      required: true
    }
  ),
  signageType: t.Integer(
    {
      description: "Tipo de indicador (entrada, salida, etc.)",
      required: true
    }
  ),
  },
  {
    description: 'Esquema adicional: SignageSchema'
  }
);

export type Signage = typeof SignageSchema.static;


export const FacilitySchema = t.Object(
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
  posZ: t.Number(
    {
      description: "Coordenada Z de la oficina",
      required: true
    }
  ),
  rotation: t.Number(
    {
      description: "Rotación de la oficina",
      required: true
    }
  ),
  scale: t.Number(
    {
      description: "Escala de la oficina",
      required: true
    }
  ),
  facilityType: t.Integer(
    {
      description: "Tipo de oficina (oficina, oficina de entrada, etc.)",
      required: true
    }
  ),
  },
  {
    description: 'Esquema adicional: FacilitySchema'
  }
);

export type Facility = typeof FacilitySchema.static;


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
  signages: t.Array(SignageSchema),
  facilities: t.Array(FacilitySchema),
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
