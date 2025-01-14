
import { Elysia, t } from 'elysia';
import { EmployeeSchema, EmployeeCreateSchema, EmployeeUpdateSchema } from "../models/employee";

export const employeeService = new Elysia({ name: 'employee/service' })
  .model({
      EmployeeSchema,
      EmployeeCreateSchema,
      EmployeeUpdateSchema
  });
