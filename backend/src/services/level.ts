
import { Elysia, t } from 'elysia';
import { LevelSchema, LevelCreateSchema, LevelUpdateSchema } from "../models/level";

export const levelService = new Elysia({ name: 'level/service' })
  .model({
      LevelSchema,
      LevelCreateSchema,
      LevelUpdateSchema
  });
