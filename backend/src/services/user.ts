
import { Elysia, t } from 'elysia';
import { UserSchema, UserCreateSchema, UserUpdateSchema } from "../models/user";

export const userService = new Elysia({ name: 'user/service' })
  .model({
      UserSchema,
      UserCreateSchema,
      UserUpdateSchema
  });
