
import Elysia from "elysia";
import { t } from 'elysia';
import { db } from "../db";
import { accessPlugin } from "../plugins/access";
import { subscriptionPlanService } from "../services/subscription-plan";
import { SubscriptionPlanSchema, SubscriptionPlan } from "../models/subscription-plan";


export const subscriptionPlanController = new Elysia({ prefix: '/subscription-plan', tags: ['subscription-plan'], detail: { summary: 'Obtener todos los subscription-plans', description: 'Retorna una lista de todos los subscription-plans registrados.', security: [{ branchId: [], token: [] }] } })
  .use(accessPlugin)
  .use(subscriptionPlanService)
  .get('/', async ({ query }) => {
      const res = await db.subscriptionPlan.findMany({});
      return res as SubscriptionPlan[];
  }, {
      detail: {
          summary: 'Obtener todos los subscription-plans',
          description: 'Retorna una lista de todos los subscription-plans registrados.',
      },
      response: {
          200: t.Array(SubscriptionPlanSchema),
          400: t.String(),
          500: t.String(),
      },

  })
  .post('/', async ({ body }) => {
      const res = await db.subscriptionPlan.create({
          data: body
      });
      return res as SubscriptionPlan;
  }, {
      body: 'SubscriptionPlanCreateSchema',
      detail: {
          summary: 'Crear un nuevo subscription-plan',
          description: 'Crea un nuevo registro de subscription-plan con los datos proporcionados.',
      },
      response: {
          200: SubscriptionPlanSchema,
          400: t.String(),
          500: t.String(),
      },
  })
  .get('/:id', async ({ params }) => {
      const res = await db.subscriptionPlan.findUnique({
          where: {
              id: params.id
          }
      });
      return res as SubscriptionPlan;
  }, {
      detail: {
          summary: 'Obtener un subscription-plan por ID',
          description: 'Retorna un subscription-plan específico basado en su ID.',
      },
      response: {
          200: SubscriptionPlanSchema,
          400: t.String(),
          500: t.String(),
      },
  })
  .patch('/:id', async ({ params, body }) => {
      const res = await db.subscriptionPlan.update({
          where: {
              id: params.id
          },
          data: body
      });
      return res as SubscriptionPlan;
  }, {
      body: 'SubscriptionPlanUpdateSchema',
      detail: {
          summary: 'Actualizar un subscription-plan',
          description: 'Actualiza un registro de subscription-plan existente con los datos proporcionados.',
      },
      response: {
          200: SubscriptionPlanSchema,
          400: t.String(),
          500: t.String(),
      },
  })
  .delete('/:id', async ({ params }) => {
      const res = await db.subscriptionPlan.delete({
          where: {
              id: params.id
          }
      });
      return res as SubscriptionPlan;
  }, {
      detail: {
          summary: 'Eliminar un subscription-plan',
          description: 'Elimina un registro de subscription-plan basado en su ID.',
      },
      response: {
          200: SubscriptionPlanSchema,
          400: t.String(),
          500: t.String(),
      },
  });
