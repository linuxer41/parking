
import { Elysia, t } from 'elysia';
import { SubscriberSchema, SubscriberCreateSchema, SubscriberUpdateSchema } from "../models/subscriber";

export const subscriberService = new Elysia({ name: 'subscriber/service' })
  .model({
      SubscriberSchema,
      SubscriberCreateSchema,
      SubscriberUpdateSchema
  });
