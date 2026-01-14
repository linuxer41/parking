import Elysia, { t } from "elysia";
import { db } from "../db";
import { authPlugin } from "../plugins/access";
import { EmployeeResponseSchema, EmployeeResponse, EmployeeCreateSchema, EmployeeUpdateSchema, EmployeeCreateRequestSchema, EmployeeUpdateRequestSchema, EmployeePasswordChangeRequestSchema } from "../models/employee";
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
  .use(authPlugin)
  .get(
    "/",
    async ({ query }) => {
      const res = await db.employee.find({});
      return res as EmployeeResponse[];
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
        200: t.Array(EmployeeResponseSchema),
        400: t.String(),
        500: t.String(),
      },
    },
  )
  .post(
    "/",
    async ({ parking, body }) => {
      const res = await db.employee.create(body, parking.id );
      return res
    },
    {
      body: EmployeeCreateRequestSchema,
      detail: {
        summary: "Crear un nuevo employee",
        description:
          "Crea un nuevo registro de employee con los datos proporcionados.",
      },
      response: {
        200: EmployeeResponseSchema,
        400: t.String(),
        500: t.String(),
      },
    },
  )
  .get(
    "/:id",
    async ({ params }) => {
      const res = await db.employee.findById(params.id);
      if (!res) {
        throw new NotFoundError("Empleado no encontrado");
      }
      return res as EmployeeResponse;
    },
    {
      detail: {
        summary: "Obtener un employee por ID",
        description: "Retorna un employee específico basado en su ID.",
      },
      response: {
        200: EmployeeResponseSchema,
        400: t.String(),
        500: t.String(),
      },
    },
  )
  .put(
    "/:id",
    async ({ params, body }) => {
      const res = await db.employee.update(params.id, body);
      return res as EmployeeResponse;
    },
    {
      body: EmployeeUpdateRequestSchema,
      detail: {
        summary: "Actualizar un employee",
        description:
          "Actualiza un registro de employee existente con los datos proporcionados.",
      },
      response: {
        200: EmployeeResponseSchema,
        400: t.String(),
        500: t.String(),
      },
    },
  )
  .put(
    "/:id/password",
    async ({ params, body }) => {
      await db.employee.changePassword(params.id, body.currentPassword, body.newPassword);
      return { message: "Contraseña actualizada exitosamente" };
    },
    {
      body: EmployeePasswordChangeRequestSchema,
      detail: {
        summary: "Cambiar contraseña de un employee",
        description:
          "Cambia la contraseña de un employee existente.",
      },
      response: {
        200: t.Object({ message: t.String() }),
        400: t.String(),
        500: t.String(),
      },
    },
  )
  .delete(
    "/:id",
    async ({ params }) => {
      const res = await db.employee.delete(params.id);
      return res as EmployeeResponse;
    },
    {
      detail: {
        summary: "Eliminar un employee",
        description:
          "Elimina un registro de employee existente basado en su ID.",
      },
      response: {
        200: EmployeeResponseSchema,
        400: t.String(),
        500: t.String(),
      },
    },
  );
