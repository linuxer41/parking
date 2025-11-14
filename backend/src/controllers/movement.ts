import Elysia, { t } from "elysia";
import { db } from "../db";
import { authPlugin } from "../plugins/access";
import { MovementSchema, Movement, MovementCreateSchema, MovementUpdateSchema } from "../models/movement";
import { NotFoundError } from "../utils/error";

export const movementController = new Elysia({
  prefix: "/movements",
  tags: ["movement"],
  detail: {
    summary: "Obtener todos los movements",
    description: "Retorna una lista de todos los movements registrados.",
    security: [{ branchId: [], token: [] }],
  },
})
  .use(authPlugin)
  .get(
    "/",
    async ({ query }) => {
      const res = await db.movement.find({});
      return res as Movement[];
    },
    {
      detail: {
        summary: "Obtener todos los movements",
        description: "Retorna una lista de todos los movements registrados.",
      },
      query: t.Object({
        parkingId: t.String({
          description: "ID del parking",
          required: false,
        }),
        cashRegisterId: t.String({
          description: "ID de la caja registradora",
          required: false,
        }),
      }),
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
      const res = await db.movement.create(body);
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
      const res = await db.movement.findById(params.id);
      if (!res) {
        throw new NotFoundError("Movimiento no encontrado");
      }
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
      const res = await db.movement.update(params.id, body);
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
      const res = await db.movement.delete(params.id);
      return res as Movement;
    },
    {
      detail: {
        summary: "Eliminar un movement",
        description:
          "Elimina un registro de movement existente basado en su ID.",
      },
      response: {
        200: MovementSchema,
        400: t.String(),
        500: t.String(),
      },
    },
  );
