
import { Elysia, t } from 'elysia';
import { AreaSchema, AreaCreateSchema, AreaUpdateSchema } from "../models/area";

export const areaService = new Elysia({ name: 'area/service' })
  .model({
      AreaSchema,
      AreaCreateSchema,
      AreaUpdateSchema
  });
