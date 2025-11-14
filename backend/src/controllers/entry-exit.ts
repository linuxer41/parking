import { Elysia, t } from "elysia";
import { db } from "../db";
import { 
  EntryExitCreateRequestSchema,
  EntryExitUpdateSchema, 
  EntryExitResponseSchema,
  ExitRequestSchema,
  ACCESS_STATUS
} from "../models/entry-exit";
import { accessPlugin } from "../plugins/access";
import { BadRequestError, NotFoundError } from "../utils/error";

export const entryExitController = new Elysia({ prefix: "/entry-exit", tags: ["entry-exit"] })
  .use(accessPlugin)
  
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
    
    const entryExits = await db.entryExit.find(filters);
    return entryExits;
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
      200: t.Array(EntryExitResponseSchema),
      400: t.String(),
      500: t.String(),
    },
  })
  
  // Obtener un acceso por ID
  .get("/:id", async ({ params }) => {
    const entryExit = await db.entryExit.findById(params.id);
    if (!entryExit) {
      throw new NotFoundError("Acceso no encontrado");
    }
    return entryExit;
  }, {
    detail: {
      summary: "Obtener un acceso por ID",
      description: "Retorna un acceso específico por su ID.",
    },
    response: {
      200: EntryExitResponseSchema,
      404: t.String(),
      500: t.String(),
    },
  })
  
  // Crear un nuevo acceso (entrada)
  .post("/", async ({ body, headers }) => {
    const parkingId = headers["parking-id"];
    const employeeId = headers["employee-id"];
    
    if (!parkingId || !employeeId) {
      throw new BadRequestError("Se requiere parking-id y employee-id en headers");
    }
    
    const entryExit = await db.entryExit.create(body, parkingId, employeeId);
    return entryExit;
  }, {
    body: EntryExitCreateRequestSchema,
    detail: {
      summary: "Crear un nuevo acceso",
      description: "Crea un nuevo acceso (entrada) para un vehículo.",
    },
    response: {
      200: EntryExitResponseSchema,
      400: t.String(),
      500: t.String(),
    },
  })
  
  // Registrar salida de un vehículo
  .post("/:id/exit", async ({ params, body, headers }) => {
    const exitEmployeeId = headers["employee-id"];
    
    if (!exitEmployeeId) {
      throw new BadRequestError("Se requiere employee-id en headers");
    }
    
    const exitData = {
      ...body,
      exitEmployeeId
    };
    
    const entryExit = await db.entryExit.registerExit(params.id, exitData);
    return entryExit;
  }, {
    body: ExitRequestSchema,
    detail: {
      summary: "Registrar salida de un vehículo",
      description: "Registra la salida de un vehículo y calcula el monto a pagar.",
    },
    response: {
      200: EntryExitResponseSchema,
      400: t.String(),
      404: t.String(),
      500: t.String(),
    },
  })
  
  // Actualizar un acceso
  .patch("/:id", async ({ params, body }) => {
    const entryExit = await db.entryExit.update(params.id, body);
    if (!entryExit) {
      throw new NotFoundError("Acceso no encontrado");
    }
    return entryExit;
  }, {
    body: EntryExitUpdateSchema,
    detail: {
      summary: "Actualizar un acceso",
      description: "Actualiza los datos de un acceso existente.",
    },
    response: {
      200: EntryExitResponseSchema,
      404: t.String(),
      500: t.String(),
    },
  })
  
  // Eliminar un acceso
  .delete("/:id", async ({ params }) => {
    const deleted = await db.entryExit.delete(params.id);
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
    const entryExits = await db.entryExit.getActiveForSpot(params.spotId);
    return entryExits;
  }, {
    detail: {
      summary: "Obtener accesos activos para un spot",
      description: "Retorna todos los accesos activos para un spot específico.",
    },
    response: {
      200: t.Array(EntryExitResponseSchema),
      500: t.String(),
    },
  })
  
  // Obtener accesos activos para un vehículo
  .get("/vehicle/:vehicleId/active", async ({ params }) => {
    const entryExits = await db.entryExit.getActiveForVehicle(params.vehicleId);
    return entryExits;
  }, {
    detail: {
      summary: "Obtener accesos activos para un vehículo",
      description: "Retorna todos los accesos activos para un vehículo específico.",
    },
    response: {
      200: t.Array(EntryExitResponseSchema),
      500: t.String(),
    },
  })
  
  // Obtener estadísticas de accesos
  .get("/stats/:parkingId", async ({ params, query }) => {
    const { startDate, endDate } = query;
    const stats = await db.entryExit.getStats(
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
