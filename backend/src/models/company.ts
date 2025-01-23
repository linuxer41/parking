
import { t } from 'elysia';
import { UserSchema } from './user';

// Esquemas JSON adicionales
export const CompanyParamsSchema = t.Object(
  {
    slogan: t.String(
    {
      description: "Nombre del tipo de vehículo",
      required: true
    }
  ),
  },
  {
    description: 'Esquema adicional: CompanyParamsSchema'
  }
);

export type CompanyParams = typeof CompanyParamsSchema.static;


// Modelo Principal
export const CompanySchema = t.Object(
  {
    id: t.String(
    {
      description: "Identificador único de la empresa",
      required: true
    }
  ),
  name: t.String(
    {
      description: "Nombre de la empresa",
      required: true
    }
  ),
  email: t.String(
    {
      description: "Correo electrónico de la empresa",
      required: true
    }
  ),
  phone: t.String(
    {
      description: "Número de teléfono de la empresa",
      required: false
    }
  ),
  logoUrl: t.String(
    {
      description: "URL del logo de la empresa",
      required: false
    }
  ),
  userId: t.String(
    {
      description: "ID del usuario que creó la empresa",
      required: true
    }
  ),
  owner: UserSchema,
  params: CompanyParamsSchema,
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
    description: 'Esquema principal para la entidad Company'
  }
);

export type Company = typeof CompanySchema.static;

// Modelo de Creación
export const CompanyCreateSchema = t.Object(
  {
    name: t.String(
    {
      description: "Nombre de la empresa",
      required: true
    }
  ),
  userId: t.String(
    {
      description: "ID del usuario que creó la empresa",
      required: true
    }
  ),
  email: t.String(
    {
      description: "Correo electrónico de la empresa",
      required: true
    }
  ),
  phone: t.String(
    {
      description: "Número de teléfono de la empresa",
      required: false
    }
  ),
  logoUrl: t.String(
    {
      description: "URL del logo de la empresa",
      required: false
    }
  ),
  },
  {
  description: 'Esquema para la creación de un Company'
  }
);

export type CompanyCreate = typeof CompanyCreateSchema.static;

// Modelo de Actualización
export const CompanyUpdateSchema = t.Object(
  {
  name: t.String(
    {
      description: "Nombre de la empresa",
      required: true
    }
  ),
  userId: t.String(
    {
      description: "ID del usuario que creó la empresa",
      required: true
    }
  ),
  email: t.String(
    {
      description: "Correo electrónico de la empresa",
      required: true
    }
  ),
  phone: t.String(
    {
      description: "Número de teléfono de la empresa",
      required: false
    }
  ),
  logoUrl: t.String(
    {
      description: "URL del logo de la empresa",
      required: false
    }
  ),
  },
  {
  description: 'Esquema para la actualización de un Company'
  }
);

export type CompanyUpdate = typeof CompanyUpdateSchema.static;
