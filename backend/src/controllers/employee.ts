
import Elysia from "elysia";
import { t } from 'elysia';
import { db } from "../db";
import { authPlugin } from "../plugins/auth";
import { employeeService } from "../services/employee";
import { EmployeeSchema, Employee } from "../models/employee";


export const employeeController = new Elysia({ prefix: '/employee', tags: ['employee'], detail: { summary: 'Obtener todos los employees', description: 'Retorna una lista de todos los employees registrados.', security: [{ token: [] }] } })
  .use(authPlugin)
  .use(employeeService)
  .get('/', async ({ query }) => {
      const res = await db.employee.findMany({});
      return res as Employee[];
  }, {
      detail: {
          summary: 'Obtener todos los employees',
          description: 'Retorna una lista de todos los employees registrados.',
      },
      response: {
          200: t.Array(EmployeeSchema),
          400: t.String(),
          500: t.String(),
      },

  })
  .post('/', async ({ body }) => {
      const res = await db.employee.create({
          data: body
      });
      return res as Employee;
  }, {
      body: 'EmployeeCreateSchema',
      detail: {
          summary: 'Crear un nuevo employee',
          description: 'Crea un nuevo registro de employee con los datos proporcionados.',
      },
      response: {
          200: EmployeeSchema,
          400: t.String(),
          500: t.String(),
      },
  })
  .get('/:id', async ({ params }) => {
      const res = await db.employee.findUnique({
          where: {
              id: params.id
          }
      });
      return res as Employee;
  }, {
      detail: {
          summary: 'Obtener un employee por ID',
          description: 'Retorna un employee específico basado en su ID.',
      },
      response: {
          200: EmployeeSchema,
          400: t.String(),
          500: t.String(),
      },
  })
  .patch('/:id', async ({ params, body }) => {
      const res = await db.employee.update({
          where: {
              id: params.id
          },
          data: body
      });
      return res as Employee;
  }, {
      body: 'EmployeeUpdateSchema',
      detail: {
          summary: 'Actualizar un employee',
          description: 'Actualiza un registro de employee existente con los datos proporcionados.',
      },
      response: {
          200: EmployeeSchema,
          400: t.String(),
          500: t.String(),
      },
  })
  .delete('/:id', async ({ params }) => {
      const res = await db.employee.delete({
          where: {
              id: params.id
          }
      });
      return res as Employee;
  }, {
      detail: {
          summary: 'Eliminar un employee',
          description: 'Elimina un registro de employee basado en su ID.',
      },
      response: {
          200: EmployeeSchema,
          400: t.String(),
          500: t.String(),
      },
  });
