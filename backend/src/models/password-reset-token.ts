import { t } from "elysia";
import { BaseSchema } from "./base-model";

// ===== ESQUEMA PRINCIPAL =====
export const PasswordResetTokenSchema = t.Composite([
  BaseSchema,
  t.Object({
    userId: t.String({
      description: "ID del usuario",
      required: true,
    }),
    token: t.String({
      description: "Token de 6 dígitos",
      required: true,
      minLength: 6,
      maxLength: 6,
    }),
    expiresAt: t.String({
      description: "Fecha de expiración del token",
      required: true,
    }),
    used: t.Boolean({
      description: "Indica si el token ya fue utilizado",
      required: true,
      default: false,
    }),
  }),
], {
  description: "Esquema principal para PasswordResetToken",
});

// ===== ESQUEMA DE CREACIÓN =====
export const PasswordResetTokenCreateSchema = t.Pick(PasswordResetTokenSchema, ["id", "createdAt", "userId", "token", "expiresAt"], {
  description: "Esquema para la creación de un PasswordResetToken",
});

// ===== ESQUEMA DE REQUEST PARA SOLICITAR RESET =====
export const PasswordResetRequestSchema = t.Object({
  email: t.String({
    format: "email",
    description: "Correo electrónico del usuario",
    required: true,
  }),
});

// ===== ESQUEMA DE REQUEST PARA RESETEAR CONTRASEÑA =====
export const PasswordResetConfirmSchema = t.Object({
  email: t.String({
    format: "email",
    description: "Correo electrónico del usuario",
    required: true,
  }),
  token: t.String({
    description: "Token de 6 dígitos",
    required: true,
    minLength: 6,
    maxLength: 6,
  }),
  newPassword: t.String({
    description: "Nueva contraseña",
    required: true,
    minLength: 8,
  }),
});

// ===== EXPORT TYPES =====
export type PasswordResetToken = typeof PasswordResetTokenSchema.static;
export type PasswordResetTokenCreate = typeof PasswordResetTokenCreateSchema.static;
export type PasswordResetRequest = typeof PasswordResetRequestSchema.static;
export type PasswordResetConfirm = typeof PasswordResetConfirmSchema.static;