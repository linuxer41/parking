import Elysia, { t } from "elysia";
import { db } from "../db";
import { accessPlugin } from "../plugins/access";
import { EmployeeSchema, Employee, EmployeeCreateSchema, EmployeeUpdateSchema } from "../models/employee";
import { NotFoundError } from "../utils/error";

export const employeeController = new Elysia({
  prefix: "/employees",
  tags: ["employee"],
  detail: {
    summary: "Obtener todos los employees",
    description: "Retorna una lista de todos los employees registrados.",
    security: [{ branchId: [], token: [] }],
  },
})
  .use(accessPlugin)
  .get(
    "/",
    async ({ query }) => {
      const res = await db.employee.findEmployees({});
      return res as Employee[];
    },
    {
      detail: {
        summary: "Obtener todos los employees",
        description: "Retorna una lista de todos los employees registrados.",
      },
      query: t.Object({
        parkingId: t.String({
          description: "ID del parking",
          required: false,
        }),
        role: t.String({
          description: "Rol del empleado",
          required: false,
        }),
      }),
      response: {
        200: t.Array(EmployeeSchema),
        400: t.String(),
        500: t.String(),
      },
    },
  )
  .post(
    "/",
    async ({ body }) => {
      const res = await db.employee.createEmployee(body);
      return res as Employee;
    },
    {
      body: EmployeeCreateSchema,
      detail: {
        summary: "Crear un nuevo employee",
        description:
          "Crea un nuevo registro de employee con los datos proporcionados.",
      },
      response: {
        200: EmployeeSchema,
        400: t.String(),
        500: t.String(),
      },
    },
  )
  .get(
    "/:id",
    async ({ params }) => {
      const res = await db.employee.findEmployeeById(params.id);
      if (!res) {
        throw new NotFoundError("Empleado no encontrado");
      }
      return res as Employee;
    },
    {
      detail: {
        summary: "Obtener un employee por ID",
        description: "Retorna un employee específico basado en su ID.",
      },
      response: {
        200: EmployeeSchema,
        400: t.String(),
        500: t.String(),
      },
    },
  )
  .patch(
    "/:id",
    async ({ params, body }) => {
      const res = await db.employee.updateEmployee(params.id, body);
      return res as Employee;
    },
    {
      body: EmployeeUpdateSchema,
      detail: {
        summary: "Actualizar un employee",
        description:
          "Actualiza un registro de employee existente con los datos proporcionados.",
      },
      response: {
        200: EmployeeSchema,
        400: t.String(),
        500: t.String(),
      },
    },
  )
  .delete(
    "/:id",
    async ({ params }) => {
      const res = await db.employee.deleteEmployee(params.id);
      return res as Employee;
    },
    {
      detail: {
        summary: "Eliminar un employee",
        description:
          "Elimina un registro de employee existente basado en su ID.",
      },
      response: {
        200: EmployeeSchema,
        400: t.String(),
        500: t.String(),
      },
    },
  );
