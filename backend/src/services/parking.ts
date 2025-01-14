
import { Elysia, t } from 'elysia';
import { ParkingSchema, ParkingCreateSchema, ParkingUpdateSchema } from "../models/parking";

export const parkingService = new Elysia({ name: 'parking/service' })
  .model({
      ParkingSchema,
      ParkingCreateSchema,
      ParkingUpdateSchema
  });
