import Elysia, { t } from "elysia";
import { db } from "../db";
import { Parking, ParkingSchema, ParkingCreateSchema, ParkingUpdateSchema } from "../models/parking";
import { authPlugin } from "../plugins";

export const parkingController = new Elysia({
  prefix: "/parkings",
  tags: ["parking"],
  detail: {
    summary: "Obtener todos los parkings",
    description: "Retorna una lista de todos los parkings registrados.",
    security: [{ branchId: [], token: [] }],
  },
})
  .use(authPlugin)
  .post(
    "/",
    async ({ body }) => {
      const res = await db.parking.create({
        data: body,
      });
      return res as Parking;
    },
    {
      body: ParkingCreateSchema,
      detail: {
        summary: "Crear un nuevo parking",
        description:
          "Crea un nuevo registro de parking con los datos proporcionados.",
      },
      response: {
        200: ParkingSchema,
        400: t.String(),
        500: t.String(),
      },
    },
  )
  .patch(
    "/:parkingId",
    async ({ params, body, user }) => {
      await db.parking.update({
        where: {
          id: params.parkingId,
        },
        data: body,
      });
      // get detailed
      const detailed = await db.parking.getDetailed(params.parkingId, user?.id);
      return detailed;
    },
    {
      body: ParkingUpdateSchema,
      detail: {
        summary: "Actualizar un parking",
        description:
          "Actualiza un registro de parking existente con los datos proporcionados.",
      },
      response: {
        200: ParkingSchema,
        400: t.String(),
        500: t.String(),
      },
    },
  )
  .delete(
    "/:parkingId",
    async ({ params }) => {
      const res = await db.parking.delete({
        where: {
          id: params.parkingId,
        },
      });
      return res as Parking;
    },
    {
      detail: {
        summary: "Eliminar un parking",
        description: "Elimina un registro de parking basado en su ID.",
      },
      response: {
        200: ParkingSchema,
        400: t.String(),
        500: t.String(),
      },
    },
  )
  .get(
    "/:parkingId",
    async ({ params, user }) => {
      const res = await db.parking.getDetailed(params.parkingId, user?.id);
      return res;
    },
    {
      detail: {
        summary: "Obtener un parking detallado",
        description: "Retorna un parking específico detallado basado en su ID.",
      },
      response: {
        200: ParkingSchema,
        400: t.String(),
        500: t.String(),
      },
    },
  )
  