
import { Elysia, t } from 'elysia';
import { VehicleSchema, VehicleCreateSchema, VehicleUpdateSchema } from "../models/vehicle";

export const vehicleService = new Elysia({ name: 'vehicle/service' })
  .model({
      VehicleSchema,
      VehicleCreateSchema,
      VehicleUpdateSchema
  });
