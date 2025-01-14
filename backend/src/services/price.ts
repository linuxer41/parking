
import { Elysia, t } from 'elysia';
import { PriceSchema, PriceCreateSchema, PriceUpdateSchema } from "../models/price";

export const priceService = new Elysia({ name: 'price/service' })
  .model({
      PriceSchema,
      PriceCreateSchema,
      PriceUpdateSchema
  });
