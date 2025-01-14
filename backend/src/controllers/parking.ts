
import Elysia from "elysia";
import { t } from 'elysia';
import { db } from "../db";
import { accessPlugin } from "../plugins/access";
import { parkingService } from "../services/parking";
import { ParkingSchema, Parking } from "../models/parking";
import { ParkingCompleteSchema } from "../models/composite-models";


export const parkingController = new Elysia({ prefix: '/parking', tags: ['parking'], detail: { summary: 'Obtener todos los parkings', description: 'Retorna una lista de todos los parkings registrados.', security: [{ branchId: [], token: [] }] } })
  .use(accessPlugin)
  .use(parkingService)
  .get('/', async ({ query }) => {
      const res = await db.parking.findMany({});
      return res as Parking[];
  }, {
      detail: {
          summary: 'Obtener todos los parkings',
          description: 'Retorna una lista de todos los parkings registrados.',
      },
      response: {
          200: t.Array(ParkingSchema),
          400: t.String(),
          500: t.String(),
      },

  })
  .post('/', async ({ body }) => {
      const res = await db.parking.create({
          data: body
      });
      return res as Parking;
  }, {
      body: 'ParkingCreateSchema',
      detail: {
          summary: 'Crear un nuevo parking',
          description: 'Crea un nuevo registro de parking con los datos proporcionados.',
      },
      response: {
          200: ParkingSchema,
          400: t.String(),
          500: t.String(),
      },
  })
  .get('/:id', async ({ params }) => {
      const res = await db.parking.findUnique({
          where: {
              id: params.id
          }
      });
      return res as Parking;
  }, {
      detail: {
          summary: 'Obtener un parking por ID',
          description: 'Retorna un parking específico basado en su ID.',
      },
      response: {
          200: ParkingSchema,
          400: t.String(),
          500: t.String(),
      },
  })
  .patch('/:id', async ({ params, body }) => {
      const res = await db.parking.update({
          where: {
              id: params.id
          },
          data: body
      });
      return res as Parking;
  }, {
      body: 'ParkingUpdateSchema',
      detail: {
          summary: 'Actualizar un parking',
          description: 'Actualiza un registro de parking existente con los datos proporcionados.',
      },
      response: {
          200: ParkingSchema,
          400: t.String(),
          500: t.String(),
      },
  })
  .delete('/:id', async ({ params }) => {
      const res = await db.parking.delete({
          where: {
              id: params.id
          }
      });
      return res as Parking;
  }, {
      detail: {
          summary: 'Eliminar un parking',
          description: 'Elimina un registro de parking basado en su ID.',
      },
      response: {
          200: ParkingSchema,
          400: t.String(),
          500: t.String(),
      },
  })
  .get('/:id/detailed', async ({ params }) => {
    return await db.parking.getDetailed(params.id);
  }, {
    detail: {
        summary: 'Obtener un parking detallado',
        description: 'Retorna un parking específico detallado basado en su ID.',
    },
    response: {
        200: ParkingCompleteSchema,
        400: t.String(),
        500: t.String(),
    }
  });
