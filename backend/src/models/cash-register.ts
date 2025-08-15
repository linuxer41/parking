import { t } from "elysia";
import { ParkingSchema } from "./parking";
import { EmployeeSchema } from "./employee";
import { BaseSchema } from "./base-model";

// Esquemas JSON adicionales
// No hay esquemas adicionales

// Modelo Principal
export const CashRegisterSchema = t.Object(
  {
    // Campos base
    ...BaseSchema.properties,
    // Campos específicos
    number: t.Integer({
      description: "Número de la caja",
      required: true,
    }),
    parkingId: t.String({
      description: "ID del estacionamiento asociado",
      required: true,
    }),
    parking: ParkingSchema,
    employeeId: t.String({
      description: "ID del empleado asociado",
      required: true,
    }),
    employee: EmployeeSchema,
    startDate: t.Union([
      t.String({
        description: "Fecha de inicio de la caja",
        required: true,
      }),
      t.Date({
        description: "Fecha de inicio de la caja",
        required: true,
      }),
    ]),
    endDate: t.Union([
      t.String({
        description: "Fecha de fin de la caja",
        required: true,
      }),
      t.Date({
        description: "Fecha de fin de la caja",
        required: true,
      }),
    ]),
    status: t.String({
      description: "Estado de la caja (activa, inactiva, etc.)",
      required: true,
    }),
  },
  {
    description: "Esquema principal para la entidad CashRegister",
  },
);

export type CashRegister = typeof CashRegisterSchema.static;

// Modelo de Creación
export const CashRegisterCreateSchema = t.Pick(CashRegisterSchema, ["number", "parkingId", "employeeId", "startDate"], {
  description: "Esquema para la creación de un CashRegister",
});

export type CashRegisterCreate = typeof CashRegisterCreateSchema.static;

// Modelo de Actualización
export const CashRegisterUpdateSchema = t.Pick(CashRegisterSchema, ["number", "employeeId", "startDate", "endDate", "status"], {
  description: "Esquema para la actualización de un CashRegister",
});

export type CashRegisterUpdate = typeof CashRegisterUpdateSchema.static;
