
import Elysia from "elysia";
import { t } from 'elysia';
import { db } from "../db";
import { accessPlugin } from "../plugins/access";
import { levelService } from "../services/level";
import { LevelSchema, Level } from "../models/level";


export const levelController = new Elysia({ prefix: '/level', tags: ['level'], detail: { summary: 'Obtener todos los levels', description: 'Retorna una lista de todos los levels registrados.', security: [{ branchId: [], token: [] }] } })
  .use(accessPlugin)
  .use(levelService)
  .get('/', async ({ query }) => {
      const res = await db.level.findMany({});
      return res as Level[];
  }, {
      detail: {
          summary: 'Obtener todos los levels',
          description: 'Retorna una lista de todos los levels registrados.',
      },
      response: {
          200: t.Array(LevelSchema),
          400: t.String(),
          500: t.String(),
      },

  })
  .post('/', async ({ body }) => {
      const res = await db.level.create({
          data: body
      });
      return res as Level;
  }, {
      body: 'LevelCreateSchema',
      detail: {
          summary: 'Crear un nuevo level',
          description: 'Crea un nuevo registro de level con los datos proporcionados.',
      },
      response: {
          200: LevelSchema,
          400: t.String(),
          500: t.String(),
      },
  })
  .get('/:id', async ({ params }) => {
      const res = await db.level.findUnique({
          where: {
              id: params.id
          }
      });
      return res as Level;
  }, {
      detail: {
          summary: 'Obtener un level por ID',
          description: 'Retorna un level específico basado en su ID.',
      },
      response: {
          200: LevelSchema,
          400: t.String(),
          500: t.String(),
      },
  })
  .patch('/:id', async ({ params, body }) => {
      const res = await db.level.update({
          where: {
              id: params.id
          },
          data: body
      });
      return res as Level;
  }, {
      body: 'LevelUpdateSchema',
      detail: {
          summary: 'Actualizar un level',
          description: 'Actualiza un registro de level existente con los datos proporcionados.',
      },
      response: {
          200: LevelSchema,
          400: t.String(),
          500: t.String(),
      },
  })
  .delete('/:id', async ({ params }) => {
      const res = await db.level.delete({
          where: {
              id: params.id
          }
      });
      return res as Level;
  }, {
      detail: {
          summary: 'Eliminar un level',
          description: 'Elimina un registro de level basado en su ID.',
      },
      response: {
          200: LevelSchema,
          400: t.String(),
          500: t.String(),
      },
  });
