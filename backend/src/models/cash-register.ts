import { t } from "elysia";
import { ParkingPreviewSchema, ParkingResponseSchema, ParkingSchema, ParkingSimpleSchema } from "./parking";
import { EmployeeResponseSchema, EmployeeSchema } from "./employee";
import { BaseSchema } from "./base-model";

// ===== ESQUEMA PRINCIPAL =====
export const CashRegisterSchema = t.Composite([
  BaseSchema,
  t.Object({
    // Campos específicos
    number: t.Integer({
      description: "Número de la caja",
      required: true,
    }),
    parkingId: t.String({
      description: "ID del estacionamiento asociado",
      required: true,
      format: "uuid",
    }),
    employeeId: t.String({
      description: "ID del empleado asociado",
      required: true,
      format: "uuid",
    }),
    employee: EmployeeResponseSchema,
    startDate: t.Union([
      t.String({
        description: "Fecha de inicio de la caja",
        required: true,
      }),
      t.Date({
        description: "Fecha de inicio de la caja",
        required: true,
      }),
    ]),
    endDate: t.Union([
      t.String({
        description: "Fecha de fin de la caja",
        required: false,
      }),
      t.Date({
        description: "Fecha de fin de la caja",
        required: false,
      }),
      t.Null({
        description: "Sin fecha de fin (caja abierta)",
      }),
    ]),
    initialAmount: t.Number({
      description: "Monto inicial en la caja",
      required: true,
    }),
    status: t.Union([
      t.Literal("active", { description: "Caja activa (abierta)" }),
      t.Literal("verified", { description: "Caja verificada (dueño recogió el dinero)" }),
    ], {
      description: "Estado de la caja",
      required: true,
    }),
    comment: t.Optional(t.Union([
      t.String({ description: "Comentario del empleado sobre la caja" }),
      t.Null(),
    ], {
      description: "Comentario que hace el empleado",
    })),
    observation: t.Optional(t.Union([
      t.String({ description: "Observación del administrador al verificar la caja" }),
      t.Null(),
    ], {
      description: "Observación que agrega el administrador al verificar",
    })),
  }),
], {
  description: "Esquema principal para la entidad CashRegister",
});

// ===== ESQUEMA DE CREACIÓN =====
export const CashRegisterCreateSchema = t.Pick(CashRegisterSchema, ["number", "parkingId", "employeeId", "startDate", "initialAmount", "status"], {
  description: "Esquema para la creación de un CashRegister",
});

// ===== ESQUEMA DE ACTUALIZACIÓN =====
export const CashRegisterUpdateSchema = t.Partial(t.Pick(CashRegisterSchema, ["updatedAt", "number", "employeeId", "startDate", "endDate", "status", "comment", "observation"]), {
  description: "Esquema para la actualización de un CashRegister",
});

 // ===== ESQUEMAS DE REQUEST =====
export const CashRegisterCreateRequestSchema = t.Pick(CashRegisterSchema, ["initialAmount"], {
  description: "Esquema de request para la creación de un CashRegister",
});

export const CashRegisterUpdateRequestSchema = t.Partial(t.Pick(CashRegisterSchema, ["endDate", "status"]), {
  description: "Esquema de request para la actualización de un CashRegister",
});

// ===== ESQUEMA DE RESPONSE =====
export const CashRegisterResponseSchema = t.Composite([
  t.Pick(CashRegisterSchema, ["id", "createdAt", "updatedAt", "number","employee", "startDate", "endDate", "initialAmount", "status"]),
  t.Object({
    totalAmount: t.Number({
      description: "Monto total recaudado en la caja",
      required: true,
    }),
  }),
], {
  description: "Esquema de response para CashRegister, para reportar al público",
});

// ===== EXPORT TYPES =====
export type CashRegister = typeof CashRegisterSchema.static;
export type CashRegisterCreate = typeof CashRegisterCreateSchema.static;
export type CashRegisterUpdate = typeof CashRegisterUpdateSchema.static;
export type CashRegisterCreateRequest = typeof CashRegisterCreateRequestSchema.static;
export type CashRegisterUpdateRequest = typeof CashRegisterUpdateRequestSchema.static;
export type CashRegisterResponse = typeof CashRegisterResponseSchema.static;
