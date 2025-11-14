import { t } from "elysia";
import { ParkingSchema } from "./parking";
import { EmployeeSchema } from "./employee";
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
    parking: ParkingSchema,
    employeeId: t.String({
      description: "ID del empleado asociado",
      required: true,
      format: "uuid",
    }),
    employee: EmployeeSchema,
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
        required: true,
      }),
      t.Date({
        description: "Fecha de fin de la caja",
        required: true,
      }),
    ]),
    status: t.String({
      description: "Estado de la caja (activa, inactiva, etc.)",
      required: true,
    }),
  }),
  ],
  {
    description: "Esquema principal para la entidad CashRegister",
  }
);

// ===== ESQUEMA DE CREACIÓN =====
export const CashRegisterCreateSchema = t.Pick(CashRegisterSchema, ["id", "createdAt", "number", "parkingId", "employeeId", "startDate"], {
  description: "Esquema para la creación de un CashRegister",
});

// ===== ESQUEMA DE ACTUALIZACIÓN =====
export const CashRegisterUpdateSchema = t.Pick(CashRegisterSchema, ["updatedAt", "number", "employeeId", "startDate", "endDate", "status"], {
  description: "Esquema para la actualización de un CashRegister",
});

// ===== ESQUEMAS DE REQUEST =====
export const CashRegisterCreateRequestSchema = t.Pick(CashRegisterSchema, ["number", "parkingId", "employeeId", "startDate"], {
  description: "Esquema de request para la creación de un CashRegister",
});

export const CashRegisterUpdateRequestSchema = t.Partial(t.Pick(CashRegisterSchema, ["number", "employeeId", "startDate", "endDate", "status"]), {
  description: "Esquema de request para la actualización de un CashRegister",
});

// ===== EXPORT TYPES =====
export type CashRegister = typeof CashRegisterSchema.static;
export type CashRegisterCreate = typeof CashRegisterCreateSchema.static;
export type CashRegisterUpdate = typeof CashRegisterUpdateSchema.static;
export type CashRegisterCreateRequest = typeof CashRegisterCreateRequestSchema.static;
export type CashRegisterUpdateRequest = typeof CashRegisterUpdateRequestSchema.static;
