
import { Elysia, t } from 'elysia';
import { ReservationSchema, ReservationCreateSchema, ReservationUpdateSchema } from "../models/reservation";

export const reservationService = new Elysia({ name: 'reservation/service' })
  .model({
      ReservationSchema,
      ReservationCreateSchema,
      ReservationUpdateSchema
  });
