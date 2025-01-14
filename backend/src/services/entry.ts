
import { Elysia, t } from 'elysia';
import { EntrySchema, EntryCreateSchema, EntryUpdateSchema } from "../models/entry";

export const entryService = new Elysia({ name: 'entry/service' })
  .model({
      EntrySchema,
      EntryCreateSchema,
      EntryUpdateSchema
  });
