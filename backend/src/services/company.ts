
import { Elysia, t } from 'elysia';
import { CompanySchema, CompanyCreateSchema, CompanyUpdateSchema } from "../models/company";

export const companyService = new Elysia({ name: 'company/service' })
  .model({
      CompanySchema,
      CompanyCreateSchema,
      CompanyUpdateSchema
  });
