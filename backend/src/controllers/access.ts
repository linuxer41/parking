import { Elysia, t } from "elysia";
import { db } from "../db";
import {
  AccessCreateRequestSchema,
  AccessUpdateSchema,
  AccessResponseSchema,
  ExitRequestSchema,
  FeeUpdateRequestSchema,
  ACCESS_STATUS
} from "../models/access";
import { authPlugin } from "../plugins/access";
import { BadRequestError, NotFoundError } from "../utils/error";

export const accessController = new Elysia({ prefix: "/access", tags: ["access"] })
  .use(authPlugin)
  
  // ===== ENDPOINTS PRINCIPALES =====
  
  // Listar accesos con filtros
  .get("/", async ({ query, parking }) => {
    const {
      employeeId,
      vehicleId,
      vehiclePlate,
      spotId,
      status,
      startDate,
      endDate,
      inParking
    } = query;

    const filters: any = {
      parkingId: parking.id
    };
    if (employeeId) filters.employeeId = employeeId;
    if (vehicleId) filters.vehicleId = vehicleId;
    if (vehiclePlate) filters.vehiclePlate = vehiclePlate;
    if (spotId) filters.spotId = spotId;
    if (status) filters.status = status;
    if (startDate) filters.startDate = startDate;
    if (endDate) filters.endDate = endDate;
    if (inParking !== undefined) filters.inParking = inParking === true;
    console.log({filters});

    const accesss = await db.access.find(filters);
    return accesss;
  }, {
    query: t.Object({
      employeeId: t.Optional(t.String()),
      vehicleId: t.Optional(t.String()),
      vehiclePlate: t.Optional(t.String()),
      spotId: t.Optional(t.String()),
      status: t.Optional(t.String()),
      startDate: t.Optional(t.String()),
      endDate: t.Optional(t.String()),
      inParking: t.Optional(t.Boolean()),
    }),
    detail: {
      summary: "Obtener todos los accesos",
      description: "Retorna una lista de todos los accesos con filtros opcionales.",
    },
    response: {
      200: t.Array(AccessResponseSchema),
      400: t.String(),
      500: t.String(),
    },
  })
  
  // Obtener un acceso por ID
  .get("/:id", async ({ params }) => {
    const access = await db.access.getById(params.id);
    if (!access) {
      throw new NotFoundError("Acceso no encontrado");
    }
    return access;
  }, {
    detail: {
      summary: "Obtener un acceso por ID",
      description: "Retorna un acceso específico por su ID.",
    },
    response: {
      200: AccessResponseSchema,
      404: t.String(),
      500: t.String(),
    },
  })
  
  // Crear un nuevo acceso (entrada)
  .post("/entry", async ({ body, parking, employee }) => {
    const access = await db.access.create(body, parking.id, employee.id);
    return access;
  }, {
    body: AccessCreateRequestSchema,
    detail: {
      summary: "Crear un nuevo acceso",
      description: "Crea un nuevo acceso (entrada) para un vehículo.",
    },
    response: {
      200: AccessResponseSchema,
      400: t.String(),
      500: t.String(),
    },
  })
  
  // Registrar salida de un vehículo
  .post("/:id/exit", async ({ params, body, employee }) => {
    const access = await db.access.registerExit(params.id, employee.id, body);
    return access;
  }, {
    body: ExitRequestSchema,
    detail: {
      summary: "Registrar salida de un vehículo",
      description: "Registra la salida de un vehículo y calcula el monto a pagar.",
    },
    response: {
      200: AccessResponseSchema,
      400: t.String(),
      404: t.String(),
      500: t.String(),
    },
  })
  
  // Obtener estadísticas de accesos
  .get("/stats/:parkingId", async ({ params, query }) => {
    const { startDate, endDate } = query;
    const stats = await db.access.getStats(
      params.parkingId, 
      startDate as string, 
      endDate as string
    );
    return stats;
  }, {
    query: t.Object({
      startDate: t.Optional(t.String()),
      endDate: t.Optional(t.String()),
    }),
    detail: {
      summary: "Obtener estadísticas de accesos",
      description: "Retorna estadísticas de accesos para un parking específico.",
    },
    response: {
      200: t.Object({
        total: t.Number(),
        entered: t.Number(),
        exited: t.Number(),
        cancelled: t.Number(),
      }),
      500: t.String(),
    },
  });
