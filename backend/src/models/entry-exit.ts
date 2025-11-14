import { t } from "elysia";
import { BaseSchema } from "./base-model";
import { EmployeeResponseSchema } from "./employee";
import { VehiclePreviewSchema } from "./vehicle";

// ===== TIPOS DE ACCESO =====
export const ACCESS_STATUS = {
  ENTERED: "entered",
  EXITED: "exited",
  CANCELLED: "cancelled"
} as const;

// ===== ESQUEMA PRINCIPAL DE ACCESO =====
export const EntryExitSchema = t.Composite([
  BaseSchema,
  t.Object({
    // Campos específicos para accesos
    number: t.Integer({
      description: "Número del acceso",
      required: true,
    }),
    parkingId: t.String({
      description: "ID del estacionamiento asociado",
      required: true,
      format: "uuid",
    }),
    parking: t.Object({
      id: t.String(),
      name: t.String(),
      address: t.String(),
    }),
    employeeId: t.String({
      description: "ID del empleado que registra la entrada",
      required: true,
      format: "uuid",
    }),
    employee: EmployeeResponseSchema,
    vehicleId: t.String({
      description: "ID del vehículo asociado",
      required: true,
      format: "uuid",
    }),
    vehicle: VehiclePreviewSchema,
    spotId: t.Union([t.Null(), t.String({
      description: "ID del spot asociado",
      required: false,
      format: "uuid",
    })]),
    entryTime: t.Union([
      t.String({
        description: "Fecha y hora de entrada",
        required: true,
      }),
      t.Date({
        description: "Fecha y hora de entrada",
        required: true,
      }),
    ]),
    exitTime: t.Union([
      t.Null(),
      t.String({
        description: "Fecha y hora de salida",
        required: false,
      }),
      t.Date({
        description: "Fecha y hora de salida",
        required: false,
      }),
    ]),
    exitEmployeeId: t.Union([t.Null(), t.String({
      description: "ID del empleado que registra la salida",
      required: false,
      format: "uuid",
    })]),
    exitEmployee: t.Union([t.Null(), EmployeeResponseSchema]),
    amount: t.Numeric({
      description: "Monto a pagar",
      required: true,
    }),
    status: t.Union([
      t.Literal(ACCESS_STATUS.ENTERED),
      t.Literal(ACCESS_STATUS.EXITED),
      t.Literal(ACCESS_STATUS.CANCELLED),
    ], {
      description: "Estado del acceso",
      required: true,
    }),
    notes: t.Optional(t.String({
      description: "Notas adicionales del acceso",
      required: false,
    })),
  }),
], {
  description: "Esquema principal para la entidad EntryExit (Acceso)",
});

// ===== ESQUEMA DE CREACIÓN INTERNO =====
export const EntryExitCreateSchema = t.Pick(EntryExitSchema, [
  "id", "createdAt", "number", "parkingId", "employeeId", "vehicleId", 
  "spotId", "entryTime", "exitTime", "exitEmployeeId", "amount", "status", "notes"
], {
  description: "Esquema interno para la creación de un Acceso (incluye id y createdAt)",
});

// ===== ESQUEMA DE CREACIÓN PARA REQUESTS =====
export const EntryExitCreateRequestSchema = t.Object({
  vehiclePlate: t.String({
    description: "Placa del vehículo",
    required: true,
  }),
  vehicleType: t.Optional(t.String({
    description: "Tipo de vehículo",
    required: false,
  })),
  vehicleColor: t.Optional(t.String({
    description: "Color del vehículo",
    required: false,
  })),
  ownerName: t.Optional(t.String({
    description: "Nombre del propietario del vehículo",
    required: false,
  })),
  ownerDocument: t.Optional(t.String({
    description: "Documento del propietario del vehículo",
    required: false,
  })),
  ownerPhone: t.Optional(t.String({
    description: "Teléfono del propietario del vehículo",
    required: false,
  })),
  spotId: t.Optional(t.String({ format: "uuid" })),
  notes: t.Optional(t.String()),
}, {
  description: "Esquema para la creación de un Acceso desde el frontend",
});

// ===== ESQUEMA DE SALIDA =====
export const ExitRequestSchema = t.Object({
  exitEmployeeId: t.String({
    description: "ID del empleado que registra la salida",
    required: true,
    format: "uuid",
  }),
  amount: t.Optional(t.Numeric({
    description: "Monto a pagar",
    required: false,
  })),
  notes: t.Optional(t.String({
    description: "Notas adicionales de la salida",
    required: false,
  })),
}, {
  description: "Esquema para registrar la salida de un vehículo",
});

// ===== ESQUEMA DE ACTUALIZACIÓN =====
export const EntryExitUpdateSchema = t.Partial(t.Pick(EntryExitSchema, [
  "updatedAt", "spotId", "exitTime", "exitEmployeeId", "amount", "status", "notes"
]), {
  description: "Esquema para la actualización de un Acceso",
});

// ===== ESQUEMAS ADICIONALES =====
export const EntryExitResponseSchema = t.Pick(EntryExitSchema, [
  "id", "number", "parkingId", "employeeId", "vehicleId", 
  "spotId", "entryTime", "exitTime", "exitEmployeeId", "amount", "status", "notes"
], {
  description: "Esquema para la respuesta de un Acceso",
});

export const EntryExitForElementSchema = t.Pick(EntryExitSchema, [
  "id", "number", "employee", "vehicle", "entryTime", 
  "exitTime", "amount", "status", "notes"
]);

export const EntryExitPreviewSchema = t.Pick(EntryExitSchema, [
  "id", "number", "parking", "employee", "vehicle", 
  "entryTime", "exitTime", "amount", "status"
]);

// ===== EXPORT TYPES =====
export type EntryExit = typeof EntryExitSchema.static;
export type EntryExitCreate = typeof EntryExitCreateSchema.static;
export type EntryExitUpdate = typeof EntryExitUpdateSchema.static;
export type EntryExitResponse = typeof EntryExitResponseSchema.static;
export type EntryExitForElement = typeof EntryExitForElementSchema.static;
export type EntryExitPreview = typeof EntryExitPreviewSchema.static;
export type EntryExitCreateRequest = typeof EntryExitCreateRequestSchema.static;
export type ExitRequest = typeof ExitRequestSchema.static;

// Tipos de constantes
export type AccessStatus = typeof ACCESS_STATUS[keyof typeof ACCESS_STATUS];
