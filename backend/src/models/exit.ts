
import { t } from 'elysia';
import { ParkingSchema } from './parking';
import { EntrySchema } from './entry';
import { EmployeeSchema } from './employee';

// Esquemas JSON adicionales
// No hay esquemas adicionales

// Modelo Principal
export const ExitSchema = t.Object(
  {
    id: t.String({
          description: "Identificador único de la salida",
          required: true
        }),
  number: t.Integer({
          description: "Número de la salida",
          required: true
        }),
  parkingId: t.String({
          description: "ID del estacionamiento asociado",
          required: true
        }),
  parking: ParkingSchema,
  entryId: t.String({
          description: "ID de la entrada asociada",
          required: true
        }),
  entry: EntrySchema,
  employeeId: t.String({
          description: "ID del empleado asociado",
          required: true
        }),
  employee: EmployeeSchema,
  dateTime: t.Union([
      t.String({
        description: 'Fecha y hora de la salida',
        required: true
      }),
      t.Date({
        description: 'Fecha y hora de la salida',
        required: true
      })
    ]),
  amount: t.Numeric({
          description: "Monto cobrado",
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
    description: 'Esquema principal para la entidad Exit'
  }
);

export type Exit = typeof ExitSchema.static;

// Modelo de Creación
export const ExitCreateSchema = t.Object(
  {
    number: t.Integer({
          description: "Número de la salida",
          required: true
        }),
  parkingId: t.String({
          description: "ID del estacionamiento asociado",
          required: true
        }),
  entryId: t.String({
          description: "ID de la entrada asociada",
          required: true
        }),
  employeeId: t.String({
          description: "ID del empleado asociado",
          required: true
        }),
  dateTime: t.Union([
      t.String({
        description: 'Fecha y hora de la salida',
        required: true
      }),
      t.Date({
        description: 'Fecha y hora de la salida',
        required: true
      })
    ]),
  amount: t.Numeric({
          description: "Monto cobrado",
          required: true
        }),
  },
  {
  description: 'Esquema para la creación de un Exit'
  }
);

export type ExitCreate = typeof ExitCreateSchema.static;

// Modelo de Actualización
export const ExitUpdateSchema = t.Object(
  {
  number: t.Optional(t.Integer({
          description: "Número de la salida",
          required: true
        })),
  employeeId: t.Optional(t.String({
          description: "ID del empleado asociado",
          required: true
        })),
  dateTime: t.Optional(t.Union([
      t.String({
        description: 'Fecha y hora de la salida',
        required: true
      }),
      t.Date({
        description: 'Fecha y hora de la salida',
        required: true
      })
    ])),
  amount: t.Optional(t.Numeric({
          description: "Monto cobrado",
          required: true
        })),
  },
  {
  description: 'Esquema para la actualización de un Exit'
  }
);

export type ExitUpdate = typeof ExitUpdateSchema.static;
