import { t } from "elysia";
import { CashRegisterSchema } from "./cash-register";
import { BaseSchema } from "./base-model";

// ===== ESQUEMA PRINCIPAL =====
export const MovementSchema = t.Composite([
  BaseSchema,
  t.Object({
    // Campos específicos
    cashRegisterId: t.String({
      description: "ID de la caja registradora asociada",
      required: true,
      format: "uuid",
    }),
    cashRegister: CashRegisterSchema,
    type: t.String({
      description: "Tipo de movimiento (ingreso, egreso)",
      required: true,
    }),
    amount: t.Numeric({
      description: "Monto del movimiento",
      required: true,
    }),
    description: t.String({
      description: "Descripción del movimiento",
      required: true,
    }),
  }),
  ],
  {
    description: "Esquema principal para la entidad Movement",
  }
);

// ===== ESQUEMA DE CREACIÓN =====
export const MovementCreateSchema = t.Pick(MovementSchema, ["id", "createdAt", "cashRegisterId", "type", "amount", "description"], {
  description: "Esquema para la creación de un Movement",
});

// ===== ESQUEMA DE ACTUALIZACIÓN =====
export const MovementUpdateSchema = t.Pick(MovementSchema, ["updatedAt", "type", "amount", "description"], {
  description: "Esquema para la actualización de un Movement",
});

// ===== ESQUEMAS DE REQUEST =====
export const MovementCreateRequestSchema = t.Pick(MovementSchema, ["cashRegisterId", "type", "amount", "description"], {
  description: "Esquema de request para la creación de un Movement",
});

export const MovementUpdateRequestSchema = t.Partial(t.Pick(MovementSchema, ["type", "amount", "description"]), {
  description: "Esquema de request para la actualización de un Movement",
});

// ===== EXPORT TYPES =====
export type Movement = typeof MovementSchema.static;
export type MovementCreate = typeof MovementCreateSchema.static;
export type MovementUpdate = typeof MovementUpdateSchema.static;
export type MovementCreateRequest = typeof MovementCreateRequestSchema.static;
export type MovementUpdateRequest = typeof MovementUpdateRequestSchema.static;
