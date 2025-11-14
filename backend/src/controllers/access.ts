import { Elysia, t } from "elysia";
import { db } from "../db";
import { 
  AccessCreateRequestSchema,
  AccessUpdateSchema, 
  AccessResponseSchema,
  ExitRequestSchema,
  ACCESS_STATUS
} from "../models/access";
import { authPlugin } from "../plugins/access";
import { BadRequestError, NotFoundError } from "../utils/error";

export const accessController = new Elysia({ prefix: "/access", tags: ["access"] })
  .use(authPlugin)
  
  // ===== ENDPOINTS PRINCIPALES =====
  
  // Listar accesos con filtros
  .get("/", async ({ query }) => {
    const { 
      parkingId, 
      employeeId, 
      vehicleId, 
      spotId, 
      status, 
      startDate,
      endDate 
    } = query;
    
    const filters: any = {};
    if (parkingId) filters.parkingId = parkingId;
    if (employeeId) filters.employeeId = employeeId;
    if (vehicleId) filters.vehicleId = vehicleId;
    if (spotId) filters.spotId = spotId;
    if (status) filters.status = status;
    if (startDate) filters.startDate = startDate;
    if (endDate) filters.endDate = endDate;
    
    const accesss = await db.access.find(filters);
    return accesss;
  }, {
    query: t.Object({
      parkingId: t.Optional(t.String()),
      employeeId: t.Optional(t.String()),
      vehicleId: t.Optional(t.String()),
      spotId: t.Optional(t.String()),
      status: t.Optional(t.String()),
      startDate: t.Optional(t.String()),
      endDate: t.Optional(t.String()),
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
    const access = await db.access.findById(params.id);
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
    const exitData = {
      ...body,
      exitEmployeeId: employee.id
    };

    const access = await db.access.registerExit(params.id, exitData);
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
  
  // Actualizar un acceso
  .patch("/:id", async ({ params, body }) => {
    const access = await db.access.update(params.id, body);
    if (!access) {
      throw new NotFoundError("Acceso no encontrado");
    }
    return access;
  }, {
    body: AccessUpdateSchema,
    detail: {
      summary: "Actualizar un acceso",
      description: "Actualiza los datos de un acceso existente.",
    },
    response: {
      200: AccessResponseSchema,
      404: t.String(),
      500: t.String(),
    },
  })
  
  // Eliminar un acceso
  .delete("/:id", async ({ params }) => {
    const deleted = await db.access.delete(params.id);
    if (!deleted) {
      throw new NotFoundError("Acceso no encontrado");
    }
    return { message: "Acceso eliminado exitosamente" };
  }, {
    detail: {
      summary: "Eliminar un acceso",
      description: "Elimina un acceso existente.",
    },
    response: {
      200: t.Object({ message: t.String() }),
      404: t.String(),
      500: t.String(),
    },
  })
  
  // ===== ENDPOINTS ESPECÍFICOS =====
  
  // Obtener accesos activos para un spot
  .get("/spot/:spotId/active", async ({ params }) => {
    const accesss = await db.access.getActiveForSpot(params.spotId);
    return accesss;
  }, {
    detail: {
      summary: "Obtener accesos activos para un spot",
      description: "Retorna todos los accesos activos para un spot específico.",
    },
    response: {
      200: t.Array(AccessResponseSchema),
      500: t.String(),
    },
  })
  
  // Obtener accesos activos para un vehículo
  .get("/vehicle/:vehicleId/active", async ({ params }) => {
    const accesss = await db.access.getActiveForVehicle(params.vehicleId);
    return accesss;
  }, {
    detail: {
      summary: "Obtener accesos activos para un vehículo",
      description: "Retorna todos los accesos activos para un vehículo específico.",
    },
    response: {
      200: t.Array(AccessResponseSchema),
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
