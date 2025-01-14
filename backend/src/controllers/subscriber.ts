
import Elysia from "elysia";
import { t } from 'elysia';
import { db } from "../db";
import { accessPlugin } from "../plugins/access";
import { subscriberService } from "../services/subscriber";
import { SubscriberSchema, Subscriber } from "../models/subscriber";


export const subscriberController = new Elysia({ prefix: '/subscriber', tags: ['subscriber'], detail: { summary: 'Obtener todos los subscribers', description: 'Retorna una lista de todos los subscribers registrados.', security: [{ branchId: [], token: [] }] } })
  .use(accessPlugin)
  .use(subscriberService)
  .get('/', async ({ query }) => {
      const res = await db.subscriber.findMany({});
      return res as Subscriber[];
  }, {
      detail: {
          summary: 'Obtener todos los subscribers',
          description: 'Retorna una lista de todos los subscribers registrados.',
      },
      response: {
          200: t.Array(SubscriberSchema),
          400: t.String(),
          500: t.String(),
      },

  })
  .post('/', async ({ body }) => {
      const res = await db.subscriber.create({
          data: body
      });
      return res as Subscriber;
  }, {
      body: 'SubscriberCreateSchema',
      detail: {
          summary: 'Crear un nuevo subscriber',
          description: 'Crea un nuevo registro de subscriber con los datos proporcionados.',
      },
      response: {
          200: SubscriberSchema,
          400: t.String(),
          500: t.String(),
      },
  })
  .get('/:id', async ({ params }) => {
      const res = await db.subscriber.findUnique({
          where: {
              id: params.id
          }
      });
      return res as Subscriber;
  }, {
      detail: {
          summary: 'Obtener un subscriber por ID',
          description: 'Retorna un subscriber específico basado en su ID.',
      },
      response: {
          200: SubscriberSchema,
          400: t.String(),
          500: t.String(),
      },
  })
  .patch('/:id', async ({ params, body }) => {
      const res = await db.subscriber.update({
          where: {
              id: params.id
          },
          data: body
      });
      return res as Subscriber;
  }, {
      body: 'SubscriberUpdateSchema',
      detail: {
          summary: 'Actualizar un subscriber',
          description: 'Actualiza un registro de subscriber existente con los datos proporcionados.',
      },
      response: {
          200: SubscriberSchema,
          400: t.String(),
          500: t.String(),
      },
  })
  .delete('/:id', async ({ params }) => {
      const res = await db.subscriber.delete({
          where: {
              id: params.id
          }
      });
      return res as Subscriber;
  }, {
      detail: {
          summary: 'Eliminar un subscriber',
          description: 'Elimina un registro de subscriber basado en su ID.',
      },
      response: {
          200: SubscriberSchema,
          400: t.String(),
          500: t.String(),
      },
  });
