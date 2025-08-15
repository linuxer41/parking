import Elysia from "elysia";
import { t } from "elysia";
import { db } from "../db";
import { accessPlugin } from "../plugins/access";
import { VehicleSchema, Vehicle, VehicleCreateSchema, VehicleUpdateSchema } from "../models/vehicle";

export const vehicleController = new Elysia({
  prefix: "/vehicles",
  tags: ["vehicle"],
  detail: {
    summary: "Obtener todos los vehicles",
    description: "Retorna una lista de todos los vehicles registrados.",
    security: [{ branchId: [], token: [] }],
  },
})
  .use(accessPlugin)
  .get(
    "/",
    async ({ query }) => {
      const res = await db.vehicle.findMany({});
      return res as Vehicle[];
    },
    {
      detail: {
        summary: "Obtener todos los vehicles",
        description: "Retorna una lista de todos los vehicles registrados.",
      },
      response: {
        200: t.Array(VehicleSchema),
        400: t.String(),
        500: t.String(),
      },
    },
  )
  .post(
    "/",
    async ({ body }) => {
      const res = await db.vehicle.create({
        data: body,
      });
      return res as Vehicle;
    },
    {
      body: VehicleCreateSchema,
      detail: {
        summary: "Crear un nuevo vehicle",
        description:
          "Crea un nuevo registro de vehicle con los datos proporcionados.",
      },
      response: {
        200: VehicleSchema,
        400: t.String(),
        500: t.String(),
      },
    },
  )
  .get(
    "/status",
    async ({ query }) => {
      const res = await db.vehicle.findUnique({
        where: {
          plate: query.plate,
          parkingId: query.parkingId,
        },
      });
      console.log(res);
      if (!res) {
        throw new Response("Vehículo no encontrado", { status: 404 });
      }
      return res;
    },
    {
      query: t.Object({
        plate: t.String({
          description: "Placa del vehículo",
          required: true,
        }),
        parkingId: t.String({
          description: "ID del estacionamiento",
          required: true,
        }),
      }),
      detail: {
        summary: "Obtener un vehicle por placa",
        description: "Retorna un vehicle específico basado en su placa.",
      },
      response: {
        200: VehicleSchema,
        400: t.String(),
        500: t.String(),
      },
    },
  )
  .get(
    "/:id",
    async ({ params }) => {
      const res = await db.vehicle.findUnique({
        where: {
          id: params.id,
        },
      });
      return res as Vehicle;
    },
    {
      detail: {
        summary: "Obtener un vehicle por ID",
        description: "Retorna un vehicle específico basado en su ID.",
      },
      response: {
        200: VehicleSchema,
        400: t.String(),
        500: t.String(),
      },
    },
  )
  .patch(
    "/:id",
    async ({ params, body }) => {
      const res = await db.vehicle.update({
        where: {
          id: params.id,
        },
        data: body,
      });
      return res as Vehicle;
    },
    {
      body: VehicleUpdateSchema,
      detail: {
        summary: "Actualizar un vehicle",
        description:
          "Actualiza un registro de vehicle existente con los datos proporcionados.",
      },
      response: {
        200: VehicleSchema,
        400: t.String(),
        500: t.String(),
      },
    },
  )
  .delete(
    "/:id",
    async ({ params }) => {
      const res = await db.vehicle.delete({
        where: {
          id: params.id,
        },
      });
      return res as Vehicle;
    },
    {
      detail: {
        summary: "Eliminar un vehicle",
        description: "Elimina un registro de vehicle basado en su ID.",
      },
      response: {
        200: VehicleSchema,
        400: t.String(),
        500: t.String(),
      },
    },
  );
