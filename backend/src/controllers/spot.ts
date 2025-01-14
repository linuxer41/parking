
import Elysia from "elysia";
import { t } from 'elysia';
import { db } from "../db";
import { accessPlugin } from "../plugins/access";
import { spotService } from "../services/spot";
import { SpotSchema, Spot } from "../models/spot";


export const spotController = new Elysia({ prefix: '/spot', tags: ['spot'], detail: { summary: 'Obtener todos los spots', description: 'Retorna una lista de todos los spots registrados.', security: [{ branchId: [], token: [] }] } })
  .use(accessPlugin)
  .use(spotService)
  .get('/', async ({ query }) => {
      const res = await db.spot.findMany({});
      return res as Spot[];
  }, {
      detail: {
          summary: 'Obtener todos los spots',
          description: 'Retorna una lista de todos los spots registrados.',
      },
      response: {
          200: t.Array(SpotSchema),
          400: t.String(),
          500: t.String(),
      },

  })
  .post('/', async ({ body }) => {
      const res = await db.spot.create({
          data: body
      });
      return res as Spot;
  }, {
      body: 'SpotCreateSchema',
      detail: {
          summary: 'Crear un nuevo spot',
          description: 'Crea un nuevo registro de spot con los datos proporcionados.',
      },
      response: {
          200: SpotSchema,
          400: t.String(),
          500: t.String(),
      },
  })
  .get('/:id', async ({ params }) => {
      const res = await db.spot.findUnique({
          where: {
              id: params.id
          }
      });
      return res as Spot;
  }, {
      detail: {
          summary: 'Obtener un spot por ID',
          description: 'Retorna un spot específico basado en su ID.',
      },
      response: {
          200: SpotSchema,
          400: t.String(),
          500: t.String(),
      },
  })
  .patch('/:id', async ({ params, body }) => {
      const res = await db.spot.update({
          where: {
              id: params.id
          },
          data: body
      });
      return res as Spot;
  }, {
      body: 'SpotUpdateSchema',
      detail: {
          summary: 'Actualizar un spot',
          description: 'Actualiza un registro de spot existente con los datos proporcionados.',
      },
      response: {
          200: SpotSchema,
          400: t.String(),
          500: t.String(),
      },
  })
  .delete('/:id', async ({ params }) => {
      const res = await db.spot.delete({
          where: {
              id: params.id
          }
      });
      return res as Spot;
  }, {
      detail: {
          summary: 'Eliminar un spot',
          description: 'Elimina un registro de spot basado en su ID.',
      },
      response: {
          200: SpotSchema,
          400: t.String(),
          500: t.String(),
      },
  });
