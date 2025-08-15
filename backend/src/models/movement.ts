import { t } from "elysia";
import { CashRegisterSchema } from "./cash-register";
import { BaseSchema } from "./base-model";

// Modelo Principal
export const MovementSchema = t.Object(
  {
    // Campos base
    ...BaseSchema.properties,
    // Campos específicos
    cashRegisterId: t.String({
      description: "ID de la caja registradora asociada",
      required: true,
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
  },
  {
    description: "Esquema principal para la entidad Movement",
  },
);

export type Movement = typeof MovementSchema.static;

// Modelo de Creación
export const MovementCreateSchema = t.Pick(MovementSchema, ["cashRegisterId", "type", "amount", "description"], {
  description: "Esquema para la creación de un Movement",
});

export type MovementCreate = typeof MovementCreateSchema.static;

// Modelo de Actualización
export const MovementUpdateSchema = t.Pick(MovementSchema, ["type", "amount", "description"], {
  description: "Esquema para la actualización de un Movement",
});

export type MovementUpdate = typeof MovementUpdateSchema.static;
