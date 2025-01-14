
import Elysia from "elysia";
import { t } from 'elysia';
import { db } from "../db";
import { accessPlugin } from "../plugins/access";
import { entryService } from "../services/entry";
import { EntrySchema, Entry } from "../models/entry";


export const entryController = new Elysia({ prefix: '/entry', tags: ['entry'], detail: { summary: 'Obtener todos los entrys', description: 'Retorna una lista de todos los entrys registrados.', security: [{ branchId: [], token: [] }] } })
  .use(accessPlugin)
  .use(entryService)
  .get('/', async ({ query }) => {
      const res = await db.entry.findMany({});
      return res as Entry[];
  }, {
      detail: {
          summary: 'Obtener todos los entrys',
          description: 'Retorna una lista de todos los entrys registrados.',
      },
      response: {
          200: t.Array(EntrySchema),
          400: t.String(),
          500: t.String(),
      },

  })
  .post('/', async ({ body }) => {
      const res = await db.entry.create({
          data: body
      });
      return res as Entry;
  }, {
      body: 'EntryCreateSchema',
      detail: {
          summary: 'Crear un nuevo entry',
          description: 'Crea un nuevo registro de entry con los datos proporcionados.',
      },
      response: {
          200: EntrySchema,
          400: t.String(),
          500: t.String(),
      },
  })
  .get('/:id', async ({ params }) => {
      const res = await db.entry.findUnique({
          where: {
              id: params.id
          }
      });
      return res as Entry;
  }, {
      detail: {
          summary: 'Obtener un entry por ID',
          description: 'Retorna un entry específico basado en su ID.',
      },
      response: {
          200: EntrySchema,
          400: t.String(),
          500: t.String(),
      },
  })
  .patch('/:id', async ({ params, body }) => {
      const res = await db.entry.update({
          where: {
              id: params.id
          },
          data: body
      });
      return res as Entry;
  }, {
      body: 'EntryUpdateSchema',
      detail: {
          summary: 'Actualizar un entry',
          description: 'Actualiza un registro de entry existente con los datos proporcionados.',
      },
      response: {
          200: EntrySchema,
          400: t.String(),
          500: t.String(),
      },
  })
  .delete('/:id', async ({ params }) => {
      const res = await db.entry.delete({
          where: {
              id: params.id
          }
      });
      return res as Entry;
  }, {
      detail: {
          summary: 'Eliminar un entry',
          description: 'Elimina un registro de entry basado en su ID.',
      },
      response: {
          200: EntrySchema,
          400: t.String(),
          500: t.String(),
      },
  });
