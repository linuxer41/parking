import { t } from "elysia";
import { BaseSchema } from "./base-model";
import { EmployeePreviewSchema } from "./employee";
import { VehiclePreviewSchema } from "./vehicle";


export const ElementActivitySchema = t.Object({
  id: t.String({
    description: "ID del elemento",
    required: true,
  }),
  startDate: t.String({
    description: "Fecha de inicio ",
    required: true,
  }),
  endDate: t.Nullable( t.String({
    description: "Fecha de fin",
    required: false,
  })),
  vehicle: VehiclePreviewSchema,
  employee: EmployeePreviewSchema,
  amount: t.Number({
    description: "Cantidad de la reserva",
    required: true,
  }),
});

export const ElementOccupancySchema = t.Object({
  access: t.Nullable(ElementActivitySchema),
  reservation: t.Nullable(ElementActivitySchema),
  subscription: t.Nullable(ElementActivitySchema),
  status: t.String({
    description: "Estado del elemento, (available, occupied, maintenance, reserved, subscribed)",
    required: true,
  }),
});

// Modelo Principal para Element
export const ElementSchema = t.Object({
  // Campos base
  ...BaseSchema.properties,
  // Campos específicos
  areaId: t.String({
    description: "ID del área a la que pertenece el elemento",
    required: true,
  }),
  parkingId: t.String({
    description: "ID del estacionamiento al que pertenece el elemento",
    required: true,
  }),
  name: t.String({
    description: "Nombre del elemento",
    required: true,
  }),
  type: t.String({
    description: "Tipo de elemento: spot, facility, signage",
    required: true,
  }),
  subType: t.Integer({
    description: "Subtipo específico según type",
    required: true,
  }),
  posX: t.Number({
    description: "Coordenada X del elemento",
    required: true,
  }),
  posY: t.Number({
    description: "Coordenada Y del elemento",
    required: true,
  }),
  posZ: t.Number({
    description: "Coordenada Z del elemento",
    required: true,
  }),
  rotation: t.Number({
    description: "Rotación del elemento",
    required: true,
  }),
  scale: t.Number({
    description: "Escala del elemento",
    required: true,
  }),
  isActive: t.Boolean({
    description: "Indica si el elemento está activo",
    required: true,
  }),
  occupancy: ElementOccupancySchema,
}, {
  description: "Esquema principal para la entidad Element",
});

export type Element = typeof ElementSchema.static;

// Modelo de Creación
export const ElementCreateSchema = t.Pick(ElementSchema, ["areaId", "parkingId", "name", "type", "subType", "category", "posX", "posY", "posZ", "rotation", "scale", "status", "metadata"], {
  description: "Esquema para la creación de un Element",
});

export type ElementCreate = typeof ElementCreateSchema.static;

// Modelo de Actualización
export const ElementUpdateSchema = t.Pick(ElementSchema, ["name", "type", "subType", "category", "posX", "posY", "posZ", "rotation", "scale", "status", "metadata"], {
  description: "Esquema para la actualización de un Element",
});

export type ElementUpdate = typeof ElementUpdateSchema.static;


// Tipos de elementos
export const ELEMENT_TYPES = {
  SPOT: 'spot',
  FACILITY: 'facility',
  SIGNAGE: 'signage',
} as const;

export type type = typeof ELEMENT_TYPES[keyof typeof ELEMENT_TYPES];

// Subtipos para spots
export const SPOT_SUBTYPES = {
  BYCICLE: 1,
  MOTORCYCLE: 2,
  CAR: 3,
  TRUCK: 4,
} as const;

// Subtipos para facilidades
export const FACILITY_SUBTYPES = {
  OFFICE: 1,
  BATHROOM: 2,
  CAFETERIA: 3,
  ELEVATOR: 4,
  STAIRS: 5,
  INFORMATION: 6,
} as const;

// Subtipos para señalizaciones
export const SIGNAGE_SUBTYPES = {
  ENTRANCE: 1,
  EXIT: 2,
  DIRECTION: 3,
  BIDIRECTIONAL: 4,
  STOP: 5,
} as const;


// Estados de elementos
export const ELEMENT_STATUS = {
  AVAILABLE: 'available',
  OCCUPIED: 'occupied',
  MAINTENANCE: 'maintenance',
  RESERVED: 'reserved',
  SUBSCRIBED: 'subscribed',
} as const; 

export const ElementPreviewSchema = t.Pick(ElementSchema, ["id", "name", "type", "subType"]);

export type ElementPreview = typeof ElementPreviewSchema.static;

