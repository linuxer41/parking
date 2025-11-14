import Elysia, { t } from "elysia";
import { db } from "../db";
import { authPlugin } from "../plugins/access";
import { VehicleSchema, Vehicle, VehicleCreateSchema, VehicleUpdateSchema } from "../models/vehicle";
import { NotFoundError } from "../utils/error";

export const vehicleController = new Elysia({
  prefix: "/vehicles",
  tags: ["vehicle"],
  detail: {
    summary: "Obtener todos los vehicles",
    description: "Retorna una lista de todos los vehicles registrados.",
    security: [{ branchId: [], token: [] }],
  },
})
  .use(authPlugin)
  .get(
    "/",
    async ({ query }) => {
      const res = await db.vehicle.find({});
      return res as Vehicle[];
    },
    {
      detail: {
        summary: "Obtener todos los vehicles",
        description: "Retorna una lista de todos los vehicles registrados.",
      },
      query: t.Object({
        parkingId: t.String({
          description: "ID del parking",
          required: false,
        }),
        plate: t.String({
          description: "Placa del vehículo",
          required: false,
        }),
      }),
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
      const res = await db.vehicle.create(body);
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
      const vehicles = await db.vehicle.find({
        plate: query.plate,
        parkingId: query.parkingId,
      });
      
      if (vehicles.length === 0) {
        throw new NotFoundError("Vehículo no encontrado");
      }
      
      return vehicles[0];
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
      const res = await db.vehicle.findById(params.id);
      if (!res) {
        throw new NotFoundError("Vehículo no encontrado");
      }
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
      const res = await db.vehicle.update(params.id, body);
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
      const res = await db.vehicle.delete(params.id);
      return res as Vehicle;
    },
    {
      detail: {
        summary: "Eliminar un vehicle",
        description:
          "Elimina un registro de vehicle existente basado en su ID.",
      },
      response: {
        200: VehicleSchema,
        400: t.String(),
        500: t.String(),
      },
    },
  );
