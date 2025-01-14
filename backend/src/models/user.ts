
import { t } from 'elysia';


// Esquemas JSON adicionales
// No hay esquemas adicionales

// Modelo Principal
export const UserSchema = t.Object(
  {
    id: t.String(
    {
      description: "Identificador único del usuario",
      required: true
    }
  ),
  name: t.String(
    {
      description: "Nombre completo del usuario",
      required: true
    }
  ),
  email: t.String(
    {
      description: "Correo electrónico del usuario",
      required: true
    }
  ),
  password: t.String(
    {
      description: "Contraseña encriptada del usuario",
      required: true
    }
  ),
  createdAt: t.Union([
    t.String(
      {
        description: 'Fecha de creación del registro',
        required: true
      }
    ),
    t.Date(
      {
        description: 'Fecha de creación del registro',
        required: true
      })
  ]),
  updatedAt: t.Union([
    t.String(
      {
        description: 'Fecha de última actualización del registro',
        required: true
      }
    ),
    t.Date(
      {
        description: 'Fecha de última actualización del registro',
        required: true
      })
  ]),
  },
  {
    description: 'Esquema principal para la entidad User'
  }
);

export type User = typeof UserSchema.static;

// Modelo de Creación
export const UserCreateSchema = t.Object(
  {
    name: t.String(
    {
      description: "Nombre completo del usuario",
      required: true
    }
  ),
  email: t.String(
    {
      description: "Correo electrónico del usuario",
      required: true
    }
  ),
  password: t.String(
    {
      description: "Contraseña encriptada del usuario",
      required: true
    }
  ),
  },
  {
  description: 'Esquema para la creación de un User'
  }
);

export type UserCreate = typeof UserCreateSchema.static;

// Modelo de Actualización
export const UserUpdateSchema = t.Object(
  {
  name: t.String(
    {
      description: "Nombre completo del usuario",
      required: true
    }
  ),
  email: t.String(
    {
      description: "Correo electrónico del usuario",
      required: true
    }
  ),
  },
  {
  description: 'Esquema para la actualización de un User'
  }
);

export type UserUpdate = typeof UserUpdateSchema.static;
