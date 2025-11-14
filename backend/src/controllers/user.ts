import Elysia, { t } from "elysia";
import { db } from "../db";
import { accessPlugin } from "../plugins/access";
import { UserSchema, User, UserCreateSchema, UserUpdateSchema } from "../models/user";
import { NotFoundError } from "../utils/error";
import { ParkingSimpleSchema } from "../models/parking";

export const userController = new Elysia({
  prefix: "/users",
  tags: ["user"],
  detail: {
    summary: "Obtener todos los users",
    description: "Retorna una lista de todos los users registrados.",
    security: [{ branchId: [], token: [] }],
  },
})
  .use(accessPlugin)
  .get(
    "/",
    async ({ query }) => {
      const res = await db.user.find({});
      return res as User[];
    },
    {
      detail: {
        summary: "Obtener todos los users",
        description: "Retorna una lista de todos los users registrados.",
      },
      query: t.Object({
        email: t.String({
          description: "Email del usuario",
          required: false,
        }),
        role: t.String({
          description: "Rol del usuario",
          required: false,
        }),
      }),
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
      const res = await db.user.createUser(body);
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
      const res = await db.user.findUserById(params.id);
      if (!res) {
        throw new NotFoundError("Usuario no encontrado");
      }
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
      const res = await db.user.updateUser(params.id, body);
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
      const res = await db.user.deleteUser(params.id);
      return res as User;
    },
    {
      detail: {
        summary: "Eliminar un user",
        description:
          "Elimina un registro de user existente basado en su ID.",
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
