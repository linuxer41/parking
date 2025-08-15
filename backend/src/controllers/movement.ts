import Elysia from "elysia";
import { t } from "elysia";
import { db } from "../db";
import { accessPlugin } from "../plugins/access";
import { MovementSchema, Movement, MovementCreateSchema, MovementUpdateSchema } from "../models/movement";

export const movementController = new Elysia({
  prefix: "/movements",
  tags: ["movement"],
  detail: {
    summary: "Obtener todos los movements",
    description: "Retorna una lista de todos los movements registrados.",
    security: [{ branchId: [], token: [] }],
  },
})
  .use(accessPlugin)
  .get(
    "/",
    async ({ query }) => {
      const res = await db.movement.findMany({});
      return res as Movement[];
    },
    {
      detail: {
        summary: "Obtener todos los movements",
        description: "Retorna una lista de todos los movements registrados.",
      },
      response: {
        200: t.Array(MovementSchema),
        400: t.String(),
        500: t.String(),
      },
    },
  )
  .post(
    "/",
    async ({ body }) => {
      const res = await db.movement.create({
        data: body,
      });
      return res as Movement;
    },
    {
      body: MovementCreateSchema,
      detail: {
        summary: "Crear un nuevo movement",
        description:
          "Crea un nuevo registro de movement con los datos proporcionados.",
      },
      response: {
        200: MovementSchema,
        400: t.String(),
        500: t.String(),
      },
    },
  )
  .get(
    "/:id",
    async ({ params }) => {
      const res = await db.movement.findUnique({
        where: {
          id: params.id,
        },
      });
      return res as Movement;
    },
    {
      detail: {
        summary: "Obtener un movement por ID",
        description: "Retorna un movement específico basado en su ID.",
      },
      response: {
        200: MovementSchema,
        400: t.String(),
        500: t.String(),
      },
    },
  )
  .patch(
    "/:id",
    async ({ params, body }) => {
      const res = await db.movement.update({
        where: {
          id: params.id,
        },
        data: body,
      });
      return res as Movement;
    },
    {
      body: MovementUpdateSchema,
      detail: {
        summary: "Actualizar un movement",
        description:
          "Actualiza un registro de movement existente con los datos proporcionados.",
      },
      response: {
        200: MovementSchema,
        400: t.String(),
        500: t.String(),
      },
    },
  )
  .delete(
    "/:id",
    async ({ params }) => {
      const res = await db.movement.delete({
        where: {
          id: params.id,
        },
      });
      return res as Movement;
    },
    {
      detail: {
        summary: "Eliminar un movement",
        description: "Elimina un registro de movement basado en su ID.",
      },
      response: {
        200: MovementSchema,
        400: t.String(),
        500: t.String(),
      },
    },
  );
