import { t } from "elysia";
import { UserSchema } from "./user";
import { ParkingSchema } from "./parking";
import { BaseSchema } from "./base-model";

// ===== ESQUEMA PRINCIPAL =====
export const EmployeeSchema = t.Composite([
  BaseSchema,
  t.Object({
    // Campos específicos
    userId: t.String({
      description: "ID del usuario asociado al empleado",
      required: true,
      format: "uuid",
    }),
    parkingId: t.String({
      description: "ID del estacionamiento al que pertenece el empleado",
      required: true,
      format: "uuid",
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
  }),
  ],
  {
    description: "Esquema principal para la entidad Empleado",
  }
);

// ===== ESQUEMA DE CREACIÓN =====
export const EmployeeCreateSchema = t.Pick(EmployeeSchema, ["id", "createdAt", "parkingId", "role", "userId"], {
  description: "Esquema para la creación de un Empleado",
});

// ===== ESQUEMA DE ACTUALIZACIÓN =====
export const EmployeeUpdateSchema = t.Pick(EmployeeSchema, ["updatedAt", "role"], {
  description: "Esquema para la actualización de un Empleado",
});

// ===== ESQUEMAS DE REQUEST =====
export const EmployeeCreateRequestSchema = t.Pick(EmployeeSchema, ["parkingId", "role", "userId"], {
  description: "Esquema de request para la creación de un Empleado",
});

export const EmployeeUpdateRequestSchema = t.Partial(t.Pick(EmployeeSchema, ["role"]), {
  description: "Esquema de request para la actualización de un Empleado",
});

export const EmployeeResponseSchema = t.Pick(EmployeeSchema, ["id", "role", "name", "email", "phone"], {
  description: "Esquema para la vista previa de un Empleado",
});

// ===== EXPORT TYPES =====
export type Employee = typeof EmployeeSchema.static;
export type EmployeeCreate = typeof EmployeeCreateSchema.static;
export type EmployeeUpdate = typeof EmployeeUpdateSchema.static;
export type EmployeeCreateRequest = typeof EmployeeCreateRequestSchema.static;
export type EmployeeUpdateRequest = typeof EmployeeUpdateRequestSchema.static;
export type EmployeeResponse = typeof EmployeeResponseSchema.static;