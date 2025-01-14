
import { Elysia, t } from 'elysia';
import { ExitSchema, ExitCreateSchema, ExitUpdateSchema } from "../models/exit";

export const exitService = new Elysia({ name: 'exit/service' })
  .model({
      ExitSchema,
      ExitCreateSchema,
      ExitUpdateSchema
  });
