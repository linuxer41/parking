
import { Elysia, t } from 'elysia';
import { MovementSchema, MovementCreateSchema, MovementUpdateSchema } from "../models/movement";

export const movementService = new Elysia({ name: 'movement/service' })
  .model({
      MovementSchema,
      MovementCreateSchema,
      MovementUpdateSchema
  });
