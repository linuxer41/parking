import { t } from "elysia";
import { BaseSchema } from "./base-model";

// ===== ESQUEMA PRINCIPAL =====
export const UserSchema = t.Composite([
  BaseSchema,
  t.Object({
    // Campos específicos de Usuario
    name: t.String({
      description: "Nombre completo del usuario",
      required: true,
    }),
    email: t.String({
      description: "Correo electrónico del usuario",
      required: true,
    }),
    phone: t.String({
      description: "Teléfono del usuario",
      required: true,
    }),
    passwordHash: t.String({
      description: "Contraseña encriptada del usuario",
      required: true,
    }),
    avatarUrl: t.Union([t.String(), t.Null()], {
      description: "URL del logo del usuario",
      required: false,
    }),
  }),
  ],
  {
    description: "Esquema principal para la entidad User",
  }
);

// ===== ESQUEMA DE RESPUESTA =====
export const UserResponseSchema = t.Pick(UserSchema, ["id", "name", "email", "phone", "avatarUrl"], {
  description: "Esquema de respuesta para operaciones de User",
});

// ===== ESQUEMA DE CREACIÓN =====
export const UserCreateSchema = t.Pick(UserSchema, ["id", "createdAt", "name", "email", "passwordHash", "phone"], {
  description: "Esquema para la creación de un User",
});

// ===== ESQUEMA DE REQUEST DE CREACIÓN =====
export const UserCreateRequestSchema = t.Composite([
  t.Pick(UserSchema, ["name", "email", "phone"]),
  t.Object({
    password: t.String({
      description: "Contraseña del usuario",
      required: true,
      minLength: 8,
    }),
  }),
], {
  description: "Esquema de request para crear un User",
});

// ===== ESQUEMA DE ACTUALIZACIÓN =====
export const UserUpdateSchema = t.Partial(t.Pick(UserSchema, ["updatedAt", "name", "email", "phone"]), {
  description: "Esquema para la actualización de un User",
});

// ===== ESQUEMA DE REQUEST DE ACTUALIZACIÓN =====
export const UserUpdateRequestSchema = t.Partial(t.Pick(UserSchema, ["name", "email", "phone"]), {
  description: "Esquema de request para actualizar un User",
});

// ===== EXPORT TYPES =====
export type User = typeof UserSchema.static;
export type UserResponse = typeof UserResponseSchema.static;
export type UserCreate = typeof UserCreateSchema.static;
export type UserCreateRequest = typeof UserCreateRequestSchema.static;
export type UserUpdate = typeof UserUpdateSchema.static;
export type UserUpdateRequest = typeof UserUpdateRequestSchema.static;
