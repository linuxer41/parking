
import Elysia from "elysia";
import { t } from 'elysia';
import { db } from "../db";
import { accessPlugin } from "../plugins/access";
import { areaService } from "../services/area";
import { AreaSchema, Area } from "../models/area";


export const areaController = new Elysia({ prefix: '/area', tags: ['area'], detail: { summary: 'Obtener todos los areas', description: 'Retorna una lista de todos los areas registrados.', security: [{ branchId: [], token: [] }] } })
  .use(accessPlugin)
  .use(areaService)
  .get('/', async ({ query }) => {
      const res = await db.area.findMany({});
      return res as Area[];
  }, {
      detail: {
          summary: 'Obtener todos los areas',
          description: 'Retorna una lista de todos los areas registrados.',
      },
      response: {
          200: t.Array(AreaSchema),
          400: t.String(),
          500: t.String(),
      },

  })
  .post('/', async ({ body }) => {
      const res = await db.area.create({
          data: body
      });
      return res as Area;
  }, {
      body: 'AreaCreateSchema',
      detail: {
          summary: 'Crear un nuevo area',
          description: 'Crea un nuevo registro de area con los datos proporcionados.',
      },
      response: {
          200: AreaSchema,
          400: t.String(),
          500: t.String(),
      },
  })
  .get('/:id', async ({ params }) => {
      const res = await db.area.findUnique({
          where: {
              id: params.id
          }
      });
      return res as Area;
  }, {
      detail: {
          summary: 'Obtener un area por ID',
          description: 'Retorna un area específico basado en su ID.',
      },
      response: {
          200: AreaSchema,
          400: t.String(),
          500: t.String(),
      },
  })
  .patch('/:id', async ({ params, body }) => {
      const res = await db.area.update({
          where: {
              id: params.id
          },
          data: body
      });
      return res as Area;
  }, {
      body: 'AreaUpdateSchema',
      detail: {
          summary: 'Actualizar un area',
          description: 'Actualiza un registro de area existente con los datos proporcionados.',
      },
      response: {
          200: AreaSchema,
          400: t.String(),
          500: t.String(),
      },
  })
  .delete('/:id', async ({ params }) => {
      const res = await db.area.delete({
          where: {
              id: params.id
          }
      });
      return res as Area;
  }, {
      detail: {
          summary: 'Eliminar un area',
          description: 'Elimina un registro de area basado en su ID.',
      },
      response: {
          200: AreaSchema,
          400: t.String(),
          500: t.String(),
      },
  });
