
import { Elysia, t } from 'elysia';
import { SubscriptionPlanSchema, SubscriptionPlanCreateSchema, SubscriptionPlanUpdateSchema } from "../models/subscription-plan";

export const subscriptionPlanService = new Elysia({ name: 'subscription-plan/service' })
  .model({
      SubscriptionPlanSchema,
      SubscriptionPlanCreateSchema,
      SubscriptionPlanUpdateSchema
  });
