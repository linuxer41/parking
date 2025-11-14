import Elysia, { t } from "elysia";
import { db } from "../db";
import {
  AreaCreateRequestSchema,
  AreaResponseSchema,
  AreaUpdateRequestSchema,
  ElementCreateRequestSchema,
  ElementResponseSchema,
  ElementUpdateRequestSchema,
  Parking,
  ParkingCreateSchema,
  ParkingSchema,
  ParkingUpdateSchema
} from "../models/parking";
import { authPlugin } from "../plugins";
import { ApiError, InternalServerError, NotFoundError } from "../utils/error";

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
  
  // ===== RUTAS PRINCIPALES DE PARKING =====
  .post(
    "/",
    async ({ body }) => {
      const res = await db.parking.createParking(body);
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
    async ({ params, body, user, set }) => {
      try {
        console.log("PATCH /parkings/:parkingId - Iniciando");
        console.log("Params:", params);
        console.log("Body:", body);
        console.log("User:", user?.id);
        
        // Verificar si el parking existe antes de actualizar
        const existingParking = await db.parking.findParkingById(params.parkingId);
        
        if (!existingParking) {
          console.log("Parking no encontrado:", params.parkingId);
          set.status = 404;
          throw new NotFoundError("Parking no encontrado");
        }
        
        console.log("Parking encontrado, actualizando...");
        await db.parking.updateParking(params.parkingId, body);
        
        console.log("Parking actualizado, obteniendo detalles...");
        // get detailed
        const detailed = await db.parking.findParkingById(params.parkingId);
        
        if (!detailed) {
          console.log("Error al obtener detalles del parking");
          set.status = 500;
          throw new InternalServerError("Error al obtener los detalles del parking");
        }
        
        console.log("Detalles obtenidos exitosamente");
        return detailed;
      } catch (error) {
        console.error("Error en PATCH /parkings/:parkingId:", error);
        
        // Asegurar que el error tenga un status code válido
        if (error instanceof ApiError) {
          set.status = error.statusCode;
        } else {
          set.status = 500;
        }
        
        throw error as Error;
      }
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
      const res = await db.parking.deleteParking(params.parkingId);
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
      const res = await db.parking.getDetailedParking(params.parkingId, user.id);
      console.log("res", res);
      return res;
    },
    {
      detail: {
        summary: "Obtener todos los parkings",
        description: "Retorna una lista de todos los parkings registrados.",
      },
      response: {
        // 200: ParkingDetailedResponseSchema,
        400: t.String(),
        500: t.String(),
      },
    },
  )
  
  // ===== GRUPO DE RUTAS DE ÁREAS =====
  .group("/:parkingId/areas", (app) =>
    app
      .post(
        "/",
        async ({ params, body }) => {
          const area = await db.area.create(body, params.parkingId);
          return area;
        },
        {
          body: AreaCreateRequestSchema,
          detail: {
            summary: "Crear un nuevo área",
            description: "Crea un nuevo área en el parking especificado.",
          },
          response: {
            200: AreaResponseSchema,
            400: t.String(),
            500: t.String(),
          },
        },
      )
      .get(
        "/",
        async ({ params }) => {
          const areas = await db.area.findByParkingId(params.parkingId);
          return areas;
        },
        {
          detail: {
            summary: "Obtener áreas del parking",
            description: "Retorna todas las áreas del parking especificado.",
          },
          response: {
            200: t.Array(AreaResponseSchema),
            400: t.String(),
            500: t.String(),
          },
        },
      )
      .get(
        "/:areaId",
        async ({ params }) => {
          const area = await db.area.findById(params.areaId);
          if (!area) {
            throw new NotFoundError("Área no encontrada");
          }
          return area;
        },
        {
          detail: {
            summary: "Obtener un área específica",
            description: "Retorna un área específica del parking.",
          },
          response: {
            200: AreaResponseSchema,
            400: t.String(),
            404: t.String(),
            500: t.String(),
          },
        },
      )
      .patch(
        "/:areaId",
        async ({ params, body }) => {
          const area = await db.area.update(params.areaId, body);
          return area;
        },
        {
          body: AreaUpdateRequestSchema,
          detail: {
            summary: "Actualizar un área",
            description: "Actualiza un área existente.",
          },
          response: {
            200: AreaResponseSchema,
            400: t.String(),
            404: t.String(),
            500: t.String(),
          },
        },
      )
      .delete(
        "/:areaId",
        async ({ params }) => {
          const area = await db.area.delete(params.areaId);
          return area;
        },
        {
          detail: {
            summary: "Eliminar un área",
            description: "Elimina un área del parking.",
          },
          response: {
            200: AreaResponseSchema,
            400: t.String(),
            404: t.String(),
            500: t.String(),
          },
        },
      )
      // ===== SUBGRUPO DE ELEMENTOS POR ÁREA =====
      .group("/:areaId/elements", (subApp) =>
        subApp
          .get(
            "/",
            async ({ params }) => {
              const elements = await db.element.findByAreaId(params.areaId);
              return elements;
            },
            {
              detail: {
                summary: "Obtener elementos de un área",
                description: "Retorna todos los elementos de un área específica.",
              },
              response: {
                200: t.Array(ElementResponseSchema),
                400: t.String(),
                500: t.String(),
              },
            },
          )
      )
  )
  
  // ===== GRUPO DE RUTAS DE ELEMENTOS =====
  .group("/:parkingId/elements", (app) =>
    app
      .post(
        "/",
        async ({ params, body }) => {
          const element = await db.element.create(body);
          return element;
        },
        {
          body: ElementCreateRequestSchema,
          detail: {
            summary: "Crear un nuevo elemento",
            description: "Crea un nuevo elemento en el parking especificado.",
          },
          response: {
            200: ElementResponseSchema,
            400: t.String(),
            500: t.String(),
          },
        },
      )
      .get(
        "/",
        async ({ params }) => {
          const elements = await db.element.findByParkingId(params.parkingId);
          return elements;
        },
        {
          detail: {
            summary: "Obtener elementos del parking",
            description: "Retorna todos los elementos del parking especificado.",
          },
          response: {
            200: t.Array(ElementResponseSchema),
            400: t.String(),
            500: t.String(),
          },
        },
      )
      .get(
        "/:elementId",
        async ({ params }) => {
          const element = await db.element.findById(params.elementId);
          if (!element) {
            throw new NotFoundError("Elemento no encontrado");
          }
          return element;
        },
        {
          detail: {
            summary: "Obtener un elemento específico",
            description: "Retorna un elemento específico del parking.",
          },
          response: {
            200: ElementResponseSchema,
            400: t.String(),
            404: t.String(),
            500: t.String(),
          },
        },
      )
      .patch(
        "/:elementId",
        async ({ params, body }) => {
          const element = await db.element.update(params.elementId, body);
          return element;
        },
        {
          body: ElementUpdateRequestSchema,
          detail: {
            summary: "Actualizar un elemento",
            description: "Actualiza un elemento existente.",
          },
          response: {
            200: ElementResponseSchema,
            400: t.String(),
            404: t.String(),
            500: t.String(),
          },
        },
      )
      .delete(
        "/:elementId",
        async ({ params }) => {
          const element = await db.element.delete(params.elementId);
          return element;
        },
        {
          detail: {
            summary: "Eliminar un elemento",
            description: "Elimina un elemento del parking.",
          },
          response: {
            200: ElementResponseSchema,
            400: t.String(),
            404: t.String(),
            500: t.String(),
          },
        },
      )
  );
  