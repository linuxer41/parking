
import Elysia from "elysia";
import { t } from 'elysia';
import { db } from "../db";
import { accessPlugin } from "../plugins/access";
import { exitService } from "../services/exit";
import { ExitSchema, Exit } from "../models/exit";


export const exitController = new Elysia({ prefix: '/exit', tags: ['exit'], detail: { summary: 'Obtener todos los exits', description: 'Retorna una lista de todos los exits registrados.', security: [{ branchId: [], token: [] }] } })
  .use(accessPlugin)
  .use(exitService)
  .get('/', async ({ query }) => {
      const res = await db.exit.findMany({});
      return res as Exit[];
  }, {
      detail: {
          summary: 'Obtener todos los exits',
          description: 'Retorna una lista de todos los exits registrados.',
      },
      response: {
          200: t.Array(ExitSchema),
          400: t.String(),
          500: t.String(),
      },

  })
  .post('/', async ({ body }) => {
      const res = await db.exit.create({
          data: body
      });
      return res as Exit;
  }, {
      body: 'ExitCreateSchema',
      detail: {
          summary: 'Crear un nuevo exit',
          description: 'Crea un nuevo registro de exit con los datos proporcionados.',
      },
      response: {
          200: ExitSchema,
          400: t.String(),
          500: t.String(),
      },
  })
  .get('/:id', async ({ params }) => {
      const res = await db.exit.findUnique({
          where: {
              id: params.id
          }
      });
      return res as Exit;
  }, {
      detail: {
          summary: 'Obtener un exit por ID',
          description: 'Retorna un exit específico basado en su ID.',
      },
      response: {
          200: ExitSchema,
          400: t.String(),
          500: t.String(),
      },
  })
  .patch('/:id', async ({ params, body }) => {
      const res = await db.exit.update({
          where: {
              id: params.id
          },
          data: body
      });
      return res as Exit;
  }, {
      body: 'ExitUpdateSchema',
      detail: {
          summary: 'Actualizar un exit',
          description: 'Actualiza un registro de exit existente con los datos proporcionados.',
      },
      response: {
          200: ExitSchema,
          400: t.String(),
          500: t.String(),
      },
  })
  .delete('/:id', async ({ params }) => {
      const res = await db.exit.delete({
          where: {
              id: params.id
          }
      });
      return res as Exit;
  }, {
      detail: {
          summary: 'Eliminar un exit',
          description: 'Elimina un registro de exit basado en su ID.',
      },
      response: {
          200: ExitSchema,
          400: t.String(),
          500: t.String(),
      },
  });
