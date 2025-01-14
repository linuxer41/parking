
import Elysia from "elysia";
import { t } from 'elysia';
import { db } from "../db";
import { accessPlugin } from "../plugins/access";
import { reservationService } from "../services/reservation";
import { ReservationSchema, Reservation } from "../models/reservation";


export const reservationController = new Elysia({ prefix: '/reservation', tags: ['reservation'], detail: { summary: 'Obtener todos los reservations', description: 'Retorna una lista de todos los reservations registrados.', security: [{ branchId: [], token: [] }] } })
  .use(accessPlugin)
  .use(reservationService)
  .get('/', async ({ query }) => {
      const res = await db.reservation.findMany({});
      return res as Reservation[];
  }, {
      detail: {
          summary: 'Obtener todos los reservations',
          description: 'Retorna una lista de todos los reservations registrados.',
      },
      response: {
          200: t.Array(ReservationSchema),
          400: t.String(),
          500: t.String(),
      },

  })
  .post('/', async ({ body }) => {
      const res = await db.reservation.create({
          data: body
      });
      return res as Reservation;
  }, {
      body: 'ReservationCreateSchema',
      detail: {
          summary: 'Crear un nuevo reservation',
          description: 'Crea un nuevo registro de reservation con los datos proporcionados.',
      },
      response: {
          200: ReservationSchema,
          400: t.String(),
          500: t.String(),
      },
  })
  .get('/:id', async ({ params }) => {
      const res = await db.reservation.findUnique({
          where: {
              id: params.id
          }
      });
      return res as Reservation;
  }, {
      detail: {
          summary: 'Obtener un reservation por ID',
          description: 'Retorna un reservation específico basado en su ID.',
      },
      response: {
          200: ReservationSchema,
          400: t.String(),
          500: t.String(),
      },
  })
  .patch('/:id', async ({ params, body }) => {
      const res = await db.reservation.update({
          where: {
              id: params.id
          },
          data: body
      });
      return res as Reservation;
  }, {
      body: 'ReservationUpdateSchema',
      detail: {
          summary: 'Actualizar un reservation',
          description: 'Actualiza un registro de reservation existente con los datos proporcionados.',
      },
      response: {
          200: ReservationSchema,
          400: t.String(),
          500: t.String(),
      },
  })
  .delete('/:id', async ({ params }) => {
      const res = await db.reservation.delete({
          where: {
              id: params.id
          }
      });
      return res as Reservation;
  }, {
      detail: {
          summary: 'Eliminar un reservation',
          description: 'Elimina un registro de reservation basado en su ID.',
      },
      response: {
          200: ReservationSchema,
          400: t.String(),
          500: t.String(),
      },
  });
