import { Elysia, t } from "elysia";
import { db } from "../db";
import { 
  SubscriptionCreateRequestSchema,
  SubscriptionUpdateSchema, 
  SubscriptionResponseSchema,
  SubscriptionRenewalRequestSchema,
  SUBSCRIPTION_STATUS
} from "../models/subscription";
import { accessPlugin } from "../plugins/access";
import { BadRequestError, NotFoundError } from "../utils/error";

export const subscriptionController = new Elysia({ prefix: "/subscription", tags: ["subscription"] })
  .use(accessPlugin)
  
  // ===== ENDPOINTS PRINCIPALES =====
  
  // Listar suscripciones con filtros
  .get("/", async ({ query }) => {
    const { 
      parkingId, 
      employeeId, 
      vehicleId, 
      spotId, 
      status, 
      period,
      isActive,
      startDate,
      endDate 
    } = query;
    
    const filters: any = {};
    if (parkingId) filters.parkingId = parkingId;
    if (employeeId) filters.employeeId = employeeId;
    if (vehicleId) filters.vehicleId = vehicleId;
    if (spotId) filters.spotId = spotId;
    if (status) filters.status = status;
    if (period) filters.period = period;
    if (isActive !== undefined) filters.isActive = isActive === 'true';
    if (startDate) filters.startDate = startDate;
    if (endDate) filters.endDate = endDate;
    
    const subscriptions = await db.subscription.find(filters);
    return subscriptions;
  }, {
    query: t.Object({
      parkingId: t.Optional(t.String()),
      employeeId: t.Optional(t.String()),
      vehicleId: t.Optional(t.String()),
      spotId: t.Optional(t.String()),
      status: t.Optional(t.String()),
      period: t.Optional(t.String()),
      isActive: t.Optional(t.String()),
      startDate: t.Optional(t.String()),
      endDate: t.Optional(t.String()),
    }),
    detail: {
      summary: "Obtener todas las suscripciones",
      description: "Retorna una lista de todas las suscripciones con filtros opcionales.",
    },
    response: {
      200: t.Array(SubscriptionResponseSchema),
      400: t.String(),
      500: t.String(),
    },
  })
  
  // Obtener una suscripción por ID
  .get("/:id", async ({ params }) => {
    const subscription = await db.subscription.findById(params.id);
    if (!subscription) {
      throw new NotFoundError("Suscripción no encontrada");
    }
    return subscription;
  }, {
    detail: {
      summary: "Obtener una suscripción por ID",
      description: "Retorna una suscripción específica por su ID.",
    },
    response: {
      200: SubscriptionResponseSchema,
      404: t.String(),
      500: t.String(),
    },
  })
  
  // Crear una nueva suscripción
  .post("/", async ({ body, headers }) => {
    const parkingId = headers["parking-id"];
    const employeeId = headers["employee-id"];
    
    if (!parkingId || !employeeId) {
      throw new BadRequestError("Se requiere parking-id y employee-id en headers");
    }
    
    const subscription = await db.subscription.create(body, parkingId, employeeId);
    return subscription;
  }, {
    body: SubscriptionCreateRequestSchema,
    detail: {
      summary: "Crear una nueva suscripción",
      description: "Crea una nueva suscripción para un vehículo.",
    },
    response: {
      200: SubscriptionResponseSchema,
      400: t.String(),
      500: t.String(),
    },
  })
  
  // Renovar una suscripción
  .post("/:id/renew", async ({ params, body, headers }) => {
    const parkingId = headers["parking-id"];
    const employeeId = headers["employee-id"];
    
    if (!parkingId || !employeeId) {
      throw new BadRequestError("Se requiere parking-id y employee-id en headers");
    }
    
    const subscription = await db.subscription.renew(params.id, body);
    return subscription;
  }, {
    body: SubscriptionRenewalRequestSchema,
    detail: {
      summary: "Renovar una suscripción",
      description: "Renueva una suscripción existente creando una nueva con el mismo vehículo.",
    },
    response: {
      200: SubscriptionResponseSchema,
      400: t.String(),
      404: t.String(),
      500: t.String(),
    },
  })
  
  // Actualizar una suscripción
  .patch("/:id", async ({ params, body }) => {
    const subscription = await db.subscription.update(params.id, body);
    if (!subscription) {
      throw new NotFoundError("Suscripción no encontrada");
    }
    return subscription;
  }, {
    body: SubscriptionUpdateSchema,
    detail: {
      summary: "Actualizar una suscripción",
      description: "Actualiza los datos de una suscripción existente.",
    },
    response: {
      200: SubscriptionResponseSchema,
      404: t.String(),
      500: t.String(),
    },
  })
  
  // Eliminar una suscripción
  .delete("/:id", async ({ params }) => {
    const deleted = await db.subscription.delete(params.id);
    if (!deleted) {
      throw new NotFoundError("Suscripción no encontrada");
    }
    return { message: "Suscripción eliminada exitosamente" };
  }, {
    detail: {
      summary: "Eliminar una suscripción",
      description: "Elimina una suscripción existente.",
    },
    response: {
      200: t.Object({ message: t.String() }),
      404: t.String(),
      500: t.String(),
    },
  })
  
  // ===== ENDPOINTS ESPECÍFICOS =====
  
  // Obtener suscripciones activas para un spot
  .get("/spot/:spotId/active", async ({ params }) => {
    const subscriptions = await db.subscription.getActiveForSpot(params.spotId);
    return subscriptions;
  }, {
    detail: {
      summary: "Obtener suscripciones activas para un spot",
      description: "Retorna todas las suscripciones activas para un spot específico.",
    },
    response: {
      200: t.Array(SubscriptionResponseSchema),
      500: t.String(),
    },
  })
  
  // Obtener suscripciones activas para un vehículo
  .get("/vehicle/:vehicleId/active", async ({ params }) => {
    const subscriptions = await db.subscription.getActiveForVehicle(params.vehicleId);
    return subscriptions;
  }, {
    detail: {
      summary: "Obtener suscripciones activas para un vehículo",
      description: "Retorna todas las suscripciones activas para un vehículo específico.",
    },
    response: {
      200: t.Array(SubscriptionResponseSchema),
      500: t.String(),
    },
  })
  
  // Obtener suscripciones que expiran pronto
  .get("/expiring", async ({ query }) => {
    const { days = "7" } = query;
    const subscriptions = await db.subscription.getExpiring(parseInt(days));
    return subscriptions;
  }, {
    query: t.Object({
      days: t.Optional(t.String()),
    }),
    detail: {
      summary: "Obtener suscripciones que expiran pronto",
      description: "Retorna suscripciones que expiran en los próximos días especificados.",
    },
    response: {
      200: t.Array(SubscriptionResponseSchema),
      500: t.String(),
    },
  })
  
  // Obtener estadísticas de suscripciones
  .get("/stats/:parkingId", async ({ params, query }) => {
    const { startDate, endDate } = query;
    const stats = await db.subscription.getStats(
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
      summary: "Obtener estadísticas de suscripciones",
      description: "Retorna estadísticas de suscripciones para un parking específico.",
    },
    response: {
      200: t.Object({
        total: t.Number(),
        active: t.Number(),
        expired: t.Number(),
        suspended: t.Number(),
        byPeriod: t.Record(t.String(), t.Number()),
      }),
      500: t.String(),
    },
  });
