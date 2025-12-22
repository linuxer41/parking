import { t } from "elysia";
import { BaseSchema } from "./base-model";
import { EmployeeResponseSchema } from "./employee";

// ===== ESQUEMAS DE ELEMENT =====
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
  vehicle: t.Object({
    id: t.String({ format: "uuid" }),
    plate: t.String(),
    color: t.Union([t.String(), t.Null()]),
    type: t.String(),
    ownerName: t.Union([t.String(), t.Null()]),
    ownerDocument: t.Union([t.String(), t.Null()]),
    ownerPhone: t.Union([t.String(), t.Null()]),
  }),
  employee: EmployeeResponseSchema,
  amount: t.Number({
    description: "Cantidad de la reserva",
    required: true,
  }),
});

// ===== ESQUEMA DE OCUPACIÓN UNIFICADA =====
export const ElementOccupancySchema = t.Object({
  // Prioridad: Access > Booking > Subscription
  access: t.Nullable(t.Object({
    id: t.String(),
    number: t.Number(),
    entryTime: t.Union([t.String(), t.Date()]),
    exitTime: t.Union([t.String(), t.Date(), t.Null()]),
    status: t.String(),
    amount: t.Number(),
    employee: t.Object({
      id: t.String(),
      name: t.String(),
      email: t.String(),
    }),
    vehicle: t.Object({
      id: t.String(),
      plate: t.String(),
      type: t.String(),
      color: t.Union([t.String(), t.Null()]),
    }),
  })),
  booking: t.Nullable(t.Object({
    id: t.String(),
    number: t.Number(),
    startDate: t.Union([t.String(), t.Date()]),
    endDate: t.Union([t.String(), t.Date(), t.Null()]),
    status: t.String(),
    amount: t.Number(),
    employee: t.Object({
      id: t.String(),
      name: t.String(),
      email: t.String(),
    }),
    vehicle: t.Object({
      id: t.String(),
      plate: t.String(),
      type: t.String(),
      color: t.Union([t.String(), t.Null()]),
    }),
  })),
  subscription: t.Nullable(t.Object({
    id: t.String(),
    number: t.Number(),
    startDate: t.Union([t.String(), t.Date()]),
    endDate: t.Union([t.String(), t.Date(), t.Null()]),
    status: t.String(),
    amount: t.Number(),
    period: t.String(),
    isActive: t.Boolean(),
    employee: t.Object({
      id: t.String(),
      name: t.String(),
      email: t.String(),
    }),
    vehicle: t.Object({
      id: t.String(),
      plate: t.String(),
      type: t.String(),
      color: t.Union([t.String(), t.Null()]),
    }),
  })),
  status: t.String({
    description: "Estado del elemento, (available, occupied, maintenance, reserved, subscribed)",
    required: true,
  }),
});

// ===== ESQUEMA PRINCIPAL DE ELEMENT =====
export const ElementSchema = t.Composite([
  BaseSchema,
  t.Object({
    // Campos específicos
    areaId: t.String({
      description: "ID del área a la que pertenece el elemento",
      required: true,
      format: "uuid",
    }),
    parkingId: t.String({
      description: "ID del estacionamiento al que pertenece el elemento",
      required: true,
      format: "uuid",
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
  }),
  ],
  {
    description: "Esquema principal para la entidad Element",
  }
);

// ===== ESQUEMA DE INFORMACIÓN SIMPLIFICADA DE OCUPACIÓN =====
export const ElementOccupancyInfoSchema = t.Object({
  vehiclePlate: t.String({
    description: "Placa del vehículo",
    required: true,
  }),
  ownerName: t.String({
    description: "Nombre del dueño del vehículo",
    required: true,
  }),
  ownerPhone: t.String({
    description: "Teléfono del dueño del vehículo",
    required: true,
  }),
  startDate: t.Union([t.String(), t.Date()], {
    description: "Fecha de inicio",
    required: true,
  }),
});

// ===== ESQUEMA DE RESPUESTA DE ELEMENT =====
export const ElementResponseSchema = t.Composite([
  t.Pick(ElementSchema, ["id", "name", "isActive", "type", "subType", "posX", "posY", "posZ", "rotation", "scale"]),
  t.Object({
    entry: t.Nullable(ElementOccupancyInfoSchema),
    subscription: t.Nullable(ElementOccupancyInfoSchema),
    booking: t.Nullable(ElementOccupancyInfoSchema),
  }),
], {
  description: "Esquema de respuesta para operaciones de Element",
});

// ===== ESQUEMA DE CREACIÓN DE ELEMENT =====
export const ElementCreateSchema = t.Pick(ElementSchema, ["id", "createdAt", "areaId", "parkingId", "name", "type", "subType", "posX", "posY", "posZ", "rotation", "scale"], {
  description: "Esquema para la creación de un Element",
});

// ===== ESQUEMA DE REQUEST DE CREACIÓN DE ELEMENT =====
export const ElementCreateRequestSchema = t.Pick(ElementSchema, ["areaId", "parkingId", "name", "type", "subType", "posX", "posY", "posZ", "rotation", "scale"], {
  description: "Esquema de request para crear un Element",
});

// ===== ESQUEMA DE ACTUALIZACIÓN DE ELEMENT =====
export const ElementUpdateSchema = t.Partial(t.Pick(ElementSchema, ["updatedAt", "name", "type", "subType", "posX", "posY", "posZ", "rotation", "scale", "isActive"]), {
  description: "Esquema para la actualización de un Element",
});

// ===== ESQUEMA DE REQUEST DE ACTUALIZACIÓN DE ELEMENT =====
export const ElementUpdateRequestSchema = t.Partial(t.Pick(ElementSchema, ["name", "type", "subType", "posX", "posY", "posZ", "rotation", "scale", "isActive"]), {
  description: "Esquema de request para actualizar un Element",
});


export const ElementPreviewSchema = t.Partial(t.Pick(ElementSchema, ["id", "name", "type", "subType"]), {
  description: "Esquema de request para actualizar un Element",
});

// ===== ESQUEMAS DE AREA =====
export const AreaSchema = t.Composite([
  BaseSchema,
  t.Object({
    // Campos específicos
    name: t.String({
      description: "Nombre del área",
      required: true,
    }),
    parkingId: t.String({
      description: "ID del estacionamiento al que pertenece el área",
      required: true,
      format: "uuid",
    }),
  }),
  ],
  {
    description: "Esquema principal para la entidad Area",
  }
);

// ===== ESQUEMA DE RESPUESTA DE AREA =====
export const AreaResponseSchema = t.Composite([
  t.Pick(AreaSchema, ["id", "name"]),
  t.Object({
    totalSpots: t.Integer({
      description: "Cantidad total de spots",
      required: true,
    }),
    occupiedSpots: t.Integer({
      description: "Cantidad de spots ocupados",
      required: true,
    }),
    availableSpots: t.Integer({
      description: "Cantidad de spots disponibles",
      required: true,
    }),
    elements: t.Array(ElementResponseSchema),
  }),
], {
  description: "Esquema de respuesta para operaciones de Area",
});

// ===== ESQUEMA DE CREACIÓN DE AREA =====
export const AreaCreateSchema = t.Pick(AreaSchema, ["id", "createdAt", "name", "parkingId"], {
  description: "Esquema para la creación de un Area",
});

// ===== ESQUEMA DE REQUEST DE CREACIÓN DE AREA =====
export const AreaCreateRequestSchema = t.Pick(AreaSchema, ["name", ], {
  description: "Esquema de request para crear un Area",
});

// ===== ESQUEMA DE ACTUALIZACIÓN DE AREA =====
export const AreaUpdateSchema = t.Partial(t.Pick(AreaSchema, ["updatedAt", "name"]), {
  description: "Esquema para la actualización de un Area",
});

// ===== ESQUEMA DE REQUEST DE ACTUALIZACIÓN DE AREA =====
export const AreaUpdateRequestSchema = t.Partial(t.Pick(AreaSchema, ["name"]), {
  description: "Esquema de request para actualizar un Area",
});

// Esquemas JSON adicionales
export const ParkingParamsSchema = t.Object(
  {
    currency: t.String({
      description: "Moneda del pase",
      required: true,
    }),
    timeZone: t.String({
      description: "Zona horaria del pase",
      required: true,
    }),
    decimalPlaces: t.Integer({
      description: "Decimales del pase",
      required: true,
    }),
    countryCode: t.String({
      description: "Código de país del pase",
      required: true,
    }),
    theme: t.String({
      description: "Tema del pase",
      required: true,
    }),
    slogan: t.Optional(
      t.String({
        description: "Eslogan del estacionamiento",
        required: false,
      }),
    ),
  },
  {
    description: "Esquema adicional: ParkingParamsSchema",
  },
);

export const RateSchema = t.Object(
  {
    id: t.String({
      description: "Identificador único de la tarifa",
      required: true,
    }),
    name: t.String({
      description: "Nombre de la tarifa",
      required: true,
    }),
    vehicleCategory: t.Integer({
      description: "Categoría de vehículo",
      required: true,
    }),
    tolerance: t.Integer({
      description: "Tolerancia en minutos",
      required: true,
    }),
    hourly: t.Number({
      description: "Precio por hora",
      required: true,
    }),
    daily: t.Number({
      description: "Precio por día completo (24h)",
      required: true,
    }),
    weekly: t.Number({
      description: "Precio por semana",
      required: true,
    }),
    monthly: t.Number({
      description: "Precio por mes",
      required: true,
    }),
    yearly: t.Number({
      description: "Precio por año",
      required: true,
    }),
    isActive: t.Boolean({
      description: "Indica si la tarifa está activa",
      required: true,
    }),
  },
  {
    description: "Esquema adicional: RateSchema",
  },
);

export const ParkingAditionalSelectSchema = t.Object({
  areas: t.Array(AreaResponseSchema, {
    description: "Áreas del parking",
    required: true,
  }),
  employees: t.Array(EmployeeResponseSchema, {
    description: "Empleados del parking",
    required: true,
  }),
  isOwner: t.Boolean({
    description: "Indica si el usuario es propietario",
    required: true,
  }),
  areaCount: t.Integer({
    description: "Cantidad total de áreas",
    required: true,
  }),
  }, {
    description: "Esquema adicional: ParkingAditionalSelectSchema",
  },
);

// ===== ESQUEMA PRINCIPAL DE PARKING =====
export const ParkingSchema = t.Composite([
  BaseSchema,
  t.Object({
    
    // Campos específicos
    name: t.String({
      description: "Nombre del estacionamiento",
      required: true,
    }),
    email: t.String({
      description: "Correo electrónico del estacionamiento",
      required: true,
    }),
    phone: t.Optional(
      t.String({
        description: "Número de teléfono del estacionamiento",
        required: false,
      }),
    ),
    address: t.Optional(
      t.String({
        description: "Dirección del estacionamiento",
        required: false,
      }),
    ),
    location: t.Optional(
      t.Object({
        lat: t.Optional(t.Number()),
        lng: t.Optional(t.Number()),
      }),
    ),
    logoUrl: t.Optional(
      t.Union([t.String(), t.Null()], {
        description: "URL del logo del estacionamiento",
        required: false,
      }),
    ),
    status: t.String({
      description: "Estado del estacionamiento",
      required: true,
    }),
    isOpen: t.Optional(
      t.Boolean({
        description: "Indica si el estacionamiento está abierto",
      }),
    ),
    ownerId: t.String({
      description: "ID del usuario propietario del estacionamiento",
      required: true,
      format: "uuid",
    }),
    params: ParkingParamsSchema,
    rates: t.Array(RateSchema),
    
    operationMode: t.Union([t.Literal("map"), t.Literal("list")], {
      description: "Modo de operación del parqueo: map o list",
      required: true,
      default: "map",
    }),
  })],
  {
    description: "Esquema principal para la entidad Parking",
  },
);

// ===== ESQUEMA DE RESPUESTA DE PARKING =====
export const ParkingResponseSchema = t.Composite([
  t.Pick(ParkingSchema, ["id", "name", "email", "phone", "address", "location", "logoUrl", "status", "isOpen", "params", "rates", "operationMode"]),
  t.Pick(ParkingAditionalSelectSchema, ["isOwner", "areaCount",]),
], {
  description: "Esquema de respuesta para operaciones de Parking",
});

export const ParkingDetailedResponseSchema = t.Composite([
  t.Pick(ParkingSchema, ["id", "name", "email", "phone", "address", "location", "logoUrl", "status", "isOpen", "params", "rates", "operationMode"]),
  ParkingAditionalSelectSchema,
], {
  description: "Esquema de respuesta para operaciones de Parking",
});

// ===== ESQUEMA DE CREACIÓN DE PARKING =====
export const ParkingCreateSchema = t.Pick(ParkingSchema, ["id", "createdAt", "name", "email", "phone", "address", "location", "operationMode", "logoUrl", "status", "isOpen", "ownerId", "params", "rates"], {
  description: "Esquema para la creación de un Parking",
});

// ===== ESQUEMA DE REQUEST DE CREACIÓN DE PARKING =====
export const ParkingCreateRequestSchema = t.Pick(ParkingSchema, ["name", "address", "location", "operationMode"], {
  description: "Esquema de request para crear un Parking",
});

// ===== ESQUEMA DE ACTUALIZACIÓN DE PARKING =====
export const ParkingUpdateSchema = t.Partial(t.Pick(ParkingSchema, ["updatedAt", "name", "email", "phone", "address", "location", "logoUrl", "status", "isOpen", "params", "rates", "operationMode"]), {
  description: "Esquema para la actualización de un Parking",
});

// ===== ESQUEMA DE REQUEST DE ACTUALIZACIÓN DE PARKING =====
export const ParkingUpdateRequestSchema = t.Partial(t.Pick(ParkingSchema, ["name", "email", "phone", "address", "location", "logoUrl", "status", "isOpen", "params", "rates", "operationMode"]), {
  description: "Esquema de request para actualizar un Parking",
});

// ===== ESQUEMAS ADICIONALES =====
export const ParkingPreviewSchema = t.Pick(ParkingSchema, ["id", "name", "address", "location", "logoUrl", "params"]);

export const ParkingSimpleSchema = t.Pick(ParkingSchema, ["id", "name", "address", "location", "logoUrl", "params", "rates", "status", "isOwner", "isActive", "areaCount", ], {
  description: "Esquema para la vista de un Parking",
});

// ===== CONSTANTES =====
// Tipos de elementos
export const ELEMENT_TYPES = {
  SPOT: 'spot',
  FACILITY: 'facility',
  SIGNAGE: 'signage',
} as const;

export type ElementType = typeof ELEMENT_TYPES[keyof typeof ELEMENT_TYPES];

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

// ===== EXPORT TYPES =====
// Tipos de Parking
export type ParkingParams = typeof ParkingParamsSchema.static;
export type Rate = typeof RateSchema.static;
export type Parking = typeof ParkingSchema.static;
export type ParkingResponse = typeof ParkingResponseSchema.static;
export type ParkingDetailedResponse = typeof ParkingDetailedResponseSchema.static;
export type ParkingCreate = typeof ParkingCreateSchema.static;
export type ParkingCreateRequest = typeof ParkingCreateRequestSchema.static;
export type ParkingUpdate = typeof ParkingUpdateSchema.static;
export type ParkingUpdateRequest = typeof ParkingUpdateRequestSchema.static;
export type ParkingPreview = typeof ParkingPreviewSchema.static;
export type ParkingSimple = typeof ParkingSimpleSchema.static;

// Tipos de Element
export type ElementActivity = typeof ElementActivitySchema.static;
export type ElementOccupancy = typeof ElementOccupancySchema.static;
export type ElementOccupancyInfo = typeof ElementOccupancyInfoSchema.static;
export type Element = typeof ElementSchema.static;
export type ElementResponse = typeof ElementResponseSchema.static;
export type ElementCreate = typeof ElementCreateSchema.static;
export type ElementCreateRequest = typeof ElementCreateRequestSchema.static;
export type ElementUpdate = typeof ElementUpdateSchema.static;
export type ElementUpdateRequest = typeof ElementUpdateRequestSchema.static;
export type ElementPreview = typeof ElementPreviewSchema.static;

// Tipos de Area
export type Area = typeof AreaSchema.static;
export type AreaResponse = typeof AreaResponseSchema.static;
export type AreaCreate = typeof AreaCreateSchema.static;
export type AreaCreateRequest = typeof AreaCreateRequestSchema.static;
export type AreaUpdate = typeof AreaUpdateSchema.static;
export type AreaUpdateRequest = typeof AreaUpdateRequestSchema.static;