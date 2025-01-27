
import { t } from 'elysia';
import { ParkingSchema } from './parking';
import { EmployeeSchema } from './employee';

// Esquemas JSON adicionales
// No hay esquemas adicionales

// Modelo Principal
export const CashRegisterSchema = t.Object(
  {
    id: t.String({
          description: "Identificador único de la caja registradora",
          required: true
        }),
  number: t.Integer({
          description: "Número de la caja",
          required: true
        }),
  parkingId: t.String({
          description: "ID del estacionamiento asociado",
          required: true
        }),
  parking: ParkingSchema,
  employeeId: t.String({
          description: "ID del empleado asociado",
          required: true
        }),
  employee: EmployeeSchema,
  startDate: t.Union([
      t.String({
        description: 'Fecha de inicio de la caja',
        required: true
      }),
      t.Date({
        description: 'Fecha de inicio de la caja',
        required: true
      })
    ]),
  endDate: t.Union([
      t.String({
        description: 'Fecha de fin de la caja',
        required: true
      }),
      t.Date({
        description: 'Fecha de fin de la caja',
        required: true
      })
    ]),
  status: t.String({
          description: "Estado de la caja (activa, inactiva, etc.)",
          required: true
        }),
  createdAt: t.Union([
      t.String({
        description: 'Fecha de creación del registro',
        required: true
      }),
      t.Date({
        description: 'Fecha de creación del registro',
        required: true
      })
    ]),
  updatedAt: t.Union([
      t.String({
        description: 'Fecha de última actualización del registro',
        required: true
      }),
      t.Date({
        description: 'Fecha de última actualización del registro',
        required: true
      })
    ]),
  },
  {
    description: 'Esquema principal para la entidad CashRegister'
  }
);

export type CashRegister = typeof CashRegisterSchema.static;

// Modelo de Creación
export const CashRegisterCreateSchema = t.Object(
  {
    number: t.Integer({
          description: "Número de la caja",
          required: true
        }),
  parkingId: t.String({
          description: "ID del estacionamiento asociado",
          required: true
        }),
  employeeId: t.String({
          description: "ID del empleado asociado",
          required: true
        }),
  startDate: t.Union([
      t.String({
        description: 'Fecha de inicio de la caja',
        required: true
      }),
      t.Date({
        description: 'Fecha de inicio de la caja',
        required: true
      })
    ]),
  endDate: t.Union([
      t.String({
        description: 'Fecha de fin de la caja',
        required: true
      }),
      t.Date({
        description: 'Fecha de fin de la caja',
        required: true
      })
    ]),
  status: t.String({
          description: "Estado de la caja (activa, inactiva, etc.)",
          required: true
        }),
  },
  {
  description: 'Esquema para la creación de un CashRegister'
  }
);

export type CashRegisterCreate = typeof CashRegisterCreateSchema.static;

// Modelo de Actualización
export const CashRegisterUpdateSchema = t.Object(
  {
  number: t.Integer({
          description: "Número de la caja",
          required: true
        }),
  employeeId: t.String({
          description: "ID del empleado asociado",
          required: true
        }),
  startDate: t.Union([
      t.String({
        description: 'Fecha de inicio de la caja',
        required: true
      }),
      t.Date({
        description: 'Fecha de inicio de la caja',
        required: true
      })
    ]),
  endDate: t.Union([
      t.String({
        description: 'Fecha de fin de la caja',
        required: true
      }),
      t.Date({
        description: 'Fecha de fin de la caja',
        required: true
      })
    ]),
  status: t.String({
          description: "Estado de la caja (activa, inactiva, etc.)",
          required: true
        }),
  },
  {
  description: 'Esquema para la actualización de un CashRegister'
  }
);

export type CashRegisterUpdate = typeof CashRegisterUpdateSchema.static;
