
import { Elysia, t } from 'elysia';
import { CashRegisterSchema, CashRegisterCreateSchema, CashRegisterUpdateSchema } from "../models/cash-register";

export const cashRegisterService = new Elysia({ name: 'cash-register/service' })
  .model({
      CashRegisterSchema,
      CashRegisterCreateSchema,
      CashRegisterUpdateSchema
  });
