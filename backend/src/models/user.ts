import { t } from "elysia";
import { BaseSchema } from "./base-model";

// Esquemas JSON adicionales
// No hay esquemas adicionales

// Modelo Principal con extensión directa
export const UserSchema = t.Object(
  {
    // Campos base
    ...BaseSchema.properties,
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
    password: t.String({
      description: "Contraseña encriptada del usuario",
      required: true,
    }),
  },
  {
    description: "Esquema principal para la entidad User",
  },
);

export type User = typeof UserSchema.static;

// Modelo de Creación (excluye los campos automáticos como id, createdAt, etc.)
export const UserCreateSchema = t.Pick(UserSchema, ["name", "email", "password", "phone"], {
  description: "Esquema para la creación de un User",
});

export type UserCreate = typeof UserCreateSchema.static;

// Modelo de Actualización (todos los campos son opcionales)
export const UserUpdateSchema = t.Pick(UserSchema, ["name", "email"], {
  description: "Esquema para la actualización de un User",
});


export type UserUpdate = typeof UserUpdateSchema.static;
