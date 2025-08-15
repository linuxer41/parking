import Elysia, { t } from "elysia";
import { db } from "../db";
import { User, UserSchema, UserCreateSchema, UserUpdateSchema } from "../models/user";
import { authPlugin } from "../plugins/auth";
import { ParkingSimpleSchema } from "../models/parking";

export const userController = new Elysia({
  prefix: "/users",
  tags: ["user"],
  detail: {
    summary: "Obtener todos los users",
    description: "Retorna una lista de todos los users registrados.",
    security: [{ token: [] }],
  },
})
  .use(authPlugin)
  .get(
    "/",
    async ({ query }) => {
      const res = await db.user.findMany({});
      return res as User[];
    },
    {
      detail: {
        summary: "Obtener todos los users",
        description: "Retorna una lista de todos los users registrados.",
      },
      response: {
        200: t.Array(UserSchema),
        400: t.String(),
        500: t.String(),
      },
    },
  )
  .post(
    "/",
    async ({ body }) => {
      const res = await db.user.create({
        data: body,
      });
      return res as User;
    },
    {
      body: UserCreateSchema,
      detail: {
        summary: "Crear un nuevo user",
        description:
          "Crea un nuevo registro de user con los datos proporcionados.",
      },
      response: {
        200: UserSchema,
        400: t.String(),
        500: t.String(),
      },
    },
  )
  .get(
    "/:id",
    async ({ params }) => {
      const res = await db.user.findUnique({
        where: {
          id: params.id,
        },
      });
      return res as User;
    },
    {
      detail: {
        summary: "Obtener un user por ID",
        description: "Retorna un user específico basado en su ID.",
      },
      response: {
        200: UserSchema,
        400: t.String(),
        500: t.String(),
      },
    },
  )
  .patch(
    "/:id",
    async ({ params, body }) => {
      const res = await db.user.update({
        where: {
          id: params.id,
        },
        data: body,
      });
      return res as User;
    },
    {
      body: UserUpdateSchema,
      detail: {
        summary: "Actualizar un user",
        description:
          "Actualiza un registro de user existente con los datos proporcionados.",
      },
      response: {
        200: UserSchema,
        400: t.String(),
        500: t.String(),
      },
    },
  )
  .delete(
    "/:id",
    async ({ params }) => {
      const res = await db.user.delete({
        where: {
          id: params.id,
        },
      });
      return res as User;
    },
    {
      detail: {
        summary: "Eliminar un user",
        description: "Elimina un registro de user basado en su ID.",
      },
      response: {
        200: UserSchema,
        400: t.String(),
        500: t.String(),
      },
    },
  )
  .get(
    "/:id/parkings",
    async ({ params }) => {
      const userId = params.id;
      return await db.user.getUserParkings(userId);
    },
    {
      detail: {
        summary: "Obtener los parkings de un usuario",
        description: "Retorna una lista de todos los parkings de un usuario.",
      },
      response: {
        200: t.Array(ParkingSimpleSchema),
        400: t.String(),
        500: t.String(),
      },
    },
  );
