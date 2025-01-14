
import { Elysia, t } from 'elysia';
import { SpotSchema, SpotCreateSchema, SpotUpdateSchema } from "../models/spot";

export const spotService = new Elysia({ name: 'spot/service' })
  .model({
      SpotSchema,
      SpotCreateSchema,
      SpotUpdateSchema
  });
