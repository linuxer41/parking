import { Elysia, t } from 'elysia';
import { 
  NotificationSchema, 
  NotificationCreateSchema, 
  NotificationUpdateSchema,
  NotificationFilterSchema
} from "../models/notification";

export const notificationService = new Elysia({ name: 'notification/service' })
  .model({
    NotificationSchema,
    NotificationCreateSchema,
    NotificationUpdateSchema,
    NotificationFilterSchema
  }); 