
import Elysia from "elysia";
import { t } from 'elysia';
import { db } from "../db";
import { accessPlugin } from "../plugins/access";
import { priceService } from "../services/price";
import { PriceSchema, Price } from "../models/price";


export const priceController = new Elysia({ prefix: '/price', tags: ['price'], detail: { summary: 'Obtener todos los prices', description: 'Retorna una lista de todos los prices registrados.', security: [{ branchId: [], token: [] }] } })
  .use(accessPlugin)
  .use(priceService)
  .get('/', async ({ query }) => {
      const res = await db.price.findMany({});
      return res as Price[];
  }, {
      detail: {
          summary: 'Obtener todos los prices',
          description: 'Retorna una lista de todos los prices registrados.',
      },
      response: {
          200: t.Array(PriceSchema),
          400: t.String(),
          500: t.String(),
      },

  })
  .post('/', async ({ body }) => {
      const res = await db.price.create({
          data: body
      });
      return res as Price;
  }, {
      body: 'PriceCreateSchema',
      detail: {
          summary: 'Crear un nuevo price',
          description: 'Crea un nuevo registro de price con los datos proporcionados.',
      },
      response: {
          200: PriceSchema,
          400: t.String(),
          500: t.String(),
      },
  })
  .get('/:id', async ({ params }) => {
      const res = await db.price.findUnique({
          where: {
              id: params.id
          }
      });
      return res as Price;
  }, {
      detail: {
          summary: 'Obtener un price por ID',
          description: 'Retorna un price específico basado en su ID.',
      },
      response: {
          200: PriceSchema,
          400: t.String(),
          500: t.String(),
      },
  })
  .patch('/:id', async ({ params, body }) => {
      const res = await db.price.update({
          where: {
              id: params.id
          },
          data: body
      });
      return res as Price;
  }, {
      body: 'PriceUpdateSchema',
      detail: {
          summary: 'Actualizar un price',
          description: 'Actualiza un registro de price existente con los datos proporcionados.',
      },
      response: {
          200: PriceSchema,
          400: t.String(),
          500: t.String(),
      },
  })
  .delete('/:id', async ({ params }) => {
      const res = await db.price.delete({
          where: {
              id: params.id
          }
      });
      return res as Price;
  }, {
      detail: {
          summary: 'Eliminar un price',
          description: 'Elimina un registro de price basado en su ID.',
      },
      response: {
          200: PriceSchema,
          400: t.String(),
          500: t.String(),
      },
  });
