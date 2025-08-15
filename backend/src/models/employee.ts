import { t } from "elysia";
import { UserSchema } from "./user";
import { ParkingSchema } from "./parking";
import { BaseSchema } from "./base-model";

// Esquemas JSON adicionales
// No hay esquemas adicionales

// Modelo Principal
export const EmployeeSchema = t.Object(
  {
    // Campos base
    ...BaseSchema.properties,
    // Campos específicos
    userId: t.String({
      description: "ID del usuario asociado al empleado",
      required: true,
    }),
    parkingId: t.String({
      description: "ID del estacionamiento al que pertenece el empleado",
      required: true,
    }),
    role: t.String({
      description: "Rol del empleado",
      required: true,
    }),
    name: t.String({
      description: "Nombre del empleado",
      required: true,
    }),
    email: t.Nullable(t.String({
      description: "Email del empleado",
      required: false,
    })),
    phone: t.Nullable(t.String({
      description: "Teléfono del empleado",
      required: false,
    })),
  },
  {
    description: "Esquema principal para la entidad Empleado",
  },
);

export type Employee = typeof EmployeeSchema.static;

// Modelo de Creación
export const EmployeeCreateSchema = t.Pick(EmployeeSchema, ["parkingId", "role", "userId"], {
  description: "Esquema para la creación de un Empleado",
});

export type EmployeeCreate = typeof EmployeeCreateSchema.static;

// Modelo de Actualización
export const EmployeeUpdateSchema = t.Pick(EmployeeSchema, ["role"], {
  description: "Esquema para la actualización de un Empleado",
});

export type EmployeeUpdate = typeof EmployeeUpdateSchema.static;


export const EmployeePreviewSchema = t.Pick(EmployeeSchema, ["id", "role", "name", "email", "phone"], {
  description: "Esquema para la vista previa de un Empleado",
});

export type EmployeePreview = typeof EmployeePreviewSchema.static;