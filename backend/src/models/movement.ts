
import { t } from 'elysia';
import { CashRegisterSchema } from './cash-register';

// Esquemas JSON adicionales
// No hay esquemas adicionales

// Modelo Principal
export const MovementSchema = t.Object(
  {
    id: t.String(
    {
      description: "Identificador único del movimiento",
      required: true
    }
  ),
  cashRegisterId: t.String(
    {
      description: "ID de la caja registradora asociada",
      required: true
    }
  ),
  cashRegister: CashRegisterSchema,
  type: t.String(
    {
      description: "Tipo de movimiento (ingreso, egreso)",
      required: true
    }
  ),
  amount: t.Numeric(
    {
      description: "Monto del movimiento",
      required: true
    }
  ),
  description: t.String(
    {
      description: "Descripción del movimiento",
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
    description: 'Esquema principal para la entidad Movement'
  }
);

export type Movement = typeof MovementSchema.static;

// Modelo de Creación
export const MovementCreateSchema = t.Object(
  {
    cashRegisterId: t.String(
    {
      description: "ID de la caja registradora asociada",
      required: true
    }
  ),
  type: t.String(
    {
      description: "Tipo de movimiento (ingreso, egreso)",
      required: true
    }
  ),
  amount: t.Numeric(
    {
      description: "Monto del movimiento",
      required: true
    }
  ),
  description: t.String(
    {
      description: "Descripción del movimiento",
      required: true
    }
  ),
  },
  {
  description: 'Esquema para la creación de un Movement'
  }
);

export type MovementCreate = typeof MovementCreateSchema.static;

// Modelo de Actualización
export const MovementUpdateSchema = t.Object(
  {
  type: t.String(
    {
      description: "Tipo de movimiento (ingreso, egreso)",
      required: true
    }
  ),
  amount: t.Numeric(
    {
      description: "Monto del movimiento",
      required: true
    }
  ),
  description: t.String(
    {
      description: "Descripción del movimiento",
      required: true
    }
  ),
  },
  {
  description: 'Esquema para la actualización de un Movement'
  }
);

export type MovementUpdate = typeof MovementUpdateSchema.static;
