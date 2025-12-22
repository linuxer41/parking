import Elysia, { t } from "elysia";
import { db } from "../db";
import { withClient } from "../db/connection";
import {
  AreaCreateRequestSchema,
  AreaResponseSchema,
  AreaUpdateRequestSchema,
  ElementCreateRequestSchema,
  ElementResponseSchema,
  ElementUpdateRequestSchema,
  ParkingCreateSchema,
  ParkingDetailedResponseSchema,
  ParkingResponseSchema,
  ParkingUpdateSchema
} from "../models/parking";
import { authPlugin } from "../plugins";
import { ApiError, NotFoundError } from "../utils/error";

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
      const res = await db.parking.create(body);
      return res;
    },
    {
      body: ParkingCreateSchema,
      detail: {
        summary: "Crear un nuevo parking",
        description:
          "Crea un nuevo registro de parking con los datos proporcionados.",
      },
      response: {
        200: ParkingResponseSchema,
        400: t.String(),
        500: t.String(),
      },
    },
  )
  .patch(
    "/:parkingId",
    async ({ params, body, user, set }) => {


      // Verificar si el parking existe antes de actualizar
      const existingParking = await db.parking.findById(params.parkingId);

      if (!existingParking) {
        console.log("Parking no encontrado:", params.parkingId);
        set.status = 404;
        throw new NotFoundError("Parking no encontrado");
      }

      // Si se va a cambiar el modo de operación, validar que no haya vehículos activos
      if (body.operationMode && body.operationMode !== existingParking.operationMode) {
        // Verificar accesos activos (sin hora de salida)
        const activeAccessesQuery = {
          text: `SELECT COUNT(*) as count FROM t_access WHERE "parkingId" = $1 AND "exitTime" IS NULL`,
          values: [params.parkingId],
        };
        const activeAccessesResult = await withClient(async (client) => {
          return await client.query(activeAccessesQuery);
        });
        const activeAccessesCount = parseInt(activeAccessesResult.rows[0].count);

        if (activeAccessesCount > 0) {
          console.log("Hay accesos activos:", activeAccessesCount);
          set.status = 400;
          throw new ApiError("No se puede cambiar el modo de operación mientras haya vehículos con accesos activos (sin hora de salida)", 400);
        }

        // Verificar spots ocupados
        const occupiedSpotsQuery = {
          text: `SELECT COUNT(*) as count FROM v_element_occupancy occ WHERE occ.entry IS NOT NULL OR occ.booking IS NOT NULL OR occ.subscription IS NOT NULL`,
          values: [],
        };
        const occupiedSpotsResult = await withClient(async (client) => {
          return await client.query(occupiedSpotsQuery);
        });
        const occupiedSpotsCount = parseInt(occupiedSpotsResult.rows[0].count);

        if (occupiedSpotsCount > 0) {
          console.log("Hay spots ocupados:", occupiedSpotsCount);
          set.status = 400;
          throw new ApiError("No se puede cambiar el modo de operación mientras haya spots ocupados", 400);
        }
      }
      return await db.parking.update(params.parkingId, body);
    },
    {
      body: ParkingUpdateSchema,
      detail: {
        summary: "Actualizar un parking",
        description:
          "Actualiza un registro de parking existente con los datos proporcionados.",
      },
      response: {
        200: ParkingResponseSchema,
        400: t.String(),
        500: t.String(),
      },
    },
  )
  .delete(
    "/:parkingId",
    async ({ params }) => {
      const res = await db.parking.delete(params.parkingId);
      return await db.parking.findById(params.parkingId);
    },
    {
      detail: {
        summary: "Eliminar un parking",
        description: "Elimina un registro de parking basado en su ID.",
      },
      response: {
        200: ParkingResponseSchema,
        400: t.String(),
        500: t.String(),
      },
    },
  )
  .get(
    "/:parkingId",
    async ({ params, user }) => {
      const res = await db.parking.findById(params.parkingId);
      console.log("res", res);
      return res;
    },
    {
      detail: {
        summary: "Obtener todos los parkings",
        description: "Retorna una lista de todos los parkings registrados.",
      },
      response: {
        200: ParkingResponseSchema,
        400: t.String(),
        500: t.String(),
      },
    },
  )
  .get(
    "/:parkingId/detailed",
    async ({ params, user }) => {
      const res = await db.parking.getDetailed(params.parkingId, user.id);
      console.log("res", res);
      return res;
    },
    {
      detail: {
        summary: "Obtener todos los parkings",
        description: "Retorna una lista de todos los parkings registrados.",
      },
      response: {
        200: ParkingDetailedResponseSchema,
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
          const area = await db.parking.createArea(body, params.parkingId);
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
          const areas = await db.parking.findAreasByParkingId(params.parkingId);
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
          const area = await db.parking.findAreaById(params.areaId);
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
          const area = await db.parking.updateArea(params.areaId, body);
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
          const area = await db.parking.deleteArea(params.areaId);
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
              const elements = await db.parking.findElementsByAreaId(params.areaId);
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
          const element = await db.parking.createElement(body);
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
          const elements = await db.parking.findElementsByParkingId(params.parkingId);
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
          const element = await db.parking.findElementById(params.elementId);
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
          const element = await db.parking.updateElement(params.elementId, body);
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
          const element = await db.parking.deleteElement(params.elementId);
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
  