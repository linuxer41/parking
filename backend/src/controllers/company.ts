
import Elysia from "elysia";
import { t } from 'elysia';
import { db } from "../db";
import { authPlugin } from "../plugins/auth";
import { companyService } from "../services/company";
import { CompanySchema, Company } from "../models/company";


export const companyController = new Elysia({ prefix: '/company', tags: ['company'], detail: { summary: 'Obtener todos los companys', description: 'Retorna una lista de todos los companys registrados.', security: [{ token: [] }] } })
  .use(authPlugin)
  .use(companyService)
  .get('/', async ({ query }) => {
      const res = await db.company.findMany({});
      return res as Company[];
  }, {
      detail: {
          summary: 'Obtener todos los companys',
          description: 'Retorna una lista de todos los companys registrados.',
      },
      response: {
          200: t.Array(CompanySchema),
          400: t.String(),
          500: t.String(),
      },

  })
  .post('/', async ({ body }) => {
      const res = await db.company.create({
          data: body
      });
      return res as Company;
  }, {
      body: 'CompanyCreateSchema',
      detail: {
          summary: 'Crear un nuevo company',
          description: 'Crea un nuevo registro de company con los datos proporcionados.',
      },
      response: {
          200: CompanySchema,
          400: t.String(),
          500: t.String(),
      },
  })
  .get('/:id', async ({ params }) => {
      const res = await db.company.findUnique({
          where: {
              id: params.id
          }
      });
      return res as Company;
  }, {
      detail: {
          summary: 'Obtener un company por ID',
          description: 'Retorna un company específico basado en su ID.',
      },
      response: {
          200: CompanySchema,
          400: t.String(),
          500: t.String(),
      },
  })
  .patch('/:id', async ({ params, body }) => {
      const res = await db.company.update({
          where: {
              id: params.id
          },
          data: body
      });
      return res as Company;
  }, {
      body: 'CompanyUpdateSchema',
      detail: {
          summary: 'Actualizar un company',
          description: 'Actualiza un registro de company existente con los datos proporcionados.',
      },
      response: {
          200: CompanySchema,
          400: t.String(),
          500: t.String(),
      },
  })
  .delete('/:id', async ({ params }) => {
      const res = await db.company.delete({
          where: {
              id: params.id
          }
      });
      return res as Company;
  }, {
      detail: {
          summary: 'Eliminar un company',
          description: 'Elimina un registro de company basado en su ID.',
      },
      response: {
          200: CompanySchema,
          400: t.String(),
          500: t.String(),
      },
  });
