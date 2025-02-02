
import { t } from 'elysia';
import { UserSchema } from './user';
import { CompanySchema } from './company';

// Esquemas JSON adicionales
// No hay esquemas adicionales

// Modelo Principal
export const EmployeeSchema = t.Object(
  {
    id: t.String({
          description: "Identificador único del empleado",
          required: true
        }),
  userId: t.String({
          description: "ID del usuario asociado al empleado",
          required: true
        }),
  user: t.Optional(UserSchema),
  companyId: t.String({
          description: "ID de la empresa a la que pertenece el empleado",
          required: true
        }),
  company: t.Optional(CompanySchema),
  role: t.String({
          description: "Rol del empleado",
          required: true
        }),
  assignedParkings: t.Array(t.String({
          description: "Estacionamientos asignados al empleado",
          required: true
        })),
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
    description: 'Esquema principal para la entidad Employee'
  }
);

export type Employee = typeof EmployeeSchema.static;

// Modelo de Creación
export const EmployeeCreateSchema = t.Object(
  {
    userId: t.String({
          description: "ID del usuario asociado al empleado",
          required: true
        }),
  companyId: t.String({
          description: "ID de la empresa a la que pertenece el empleado",
          required: true
        }),
  role: t.String({
          description: "Rol del empleado",
          required: true
        }),
  assignedParkings: t.Array(t.String({
          description: "Estacionamientos asignados al empleado",
          required: true
        })),
  },
  {
  description: 'Esquema para la creación de un Employee'
  }
);

export type EmployeeCreate = typeof EmployeeCreateSchema.static;

// Modelo de Actualización
export const EmployeeUpdateSchema = t.Object(
  {
  role: t.Optional(t.String({
          description: "Rol del empleado",
          required: true
        })),
  assignedParkings: t.Optional(t.Array(t.String({
          description: "Estacionamientos asignados al empleado",
          required: true
        }))),
  },
  {
  description: 'Esquema para la actualización de un Employee'
  }
);

export type EmployeeUpdate = typeof EmployeeUpdateSchema.static;
