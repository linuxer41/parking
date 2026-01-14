import { t } from "elysia";
import { UserCreateRequestSchema, UserResponseSchema } from "./user";
import { ParkingCreateRequestSchema, ParkingResponseSchema } from "./parking";
import { PasswordResetRequestSchema, PasswordResetConfirmSchema } from "./password-reset-token";

const loginBodySchema = t.Object({
  email: t.String({ format: "email" }),
  password: t.String({ minLength: 8 }),
});

const signupBodySchema = t.Object({
  name: t.String({ maxLength: 60, minLength: 1 }),
  email: t.String({ format: "email" }),
  password: t.String({ minLength: 8 }),
  phone: t.String({ minLength: 1 }),
  location: t.Optional(t.Tuple([t.Number(), t.Number()])),
});

// Esquema para el registro completo (usuario + parking)
export const RegistrationSchema = t.Object({
  user: UserCreateRequestSchema,
  parking: ParkingCreateRequestSchema,
}, {
  description: "Esquema para el registro completo de usuario y estacionamiento",
});

export const AuthResponseSchema = t.Object({
  auth: t.Object({
    token: t.String(),
    refreshToken: t.String(),
  }),
  user: UserResponseSchema,
  parkings: t.Array(ParkingResponseSchema),
}, {
  description: "Esquema para la respuesta de autenticación",
});

export type CompleteRegistration = typeof RegistrationSchema.static;
export type AuthResponse = typeof AuthResponseSchema.static;

export { loginBodySchema, signupBodySchema, PasswordResetRequestSchema, PasswordResetConfirmSchema };
