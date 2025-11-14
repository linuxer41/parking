import { Elysia, t } from "elysia";
import { db } from "../db";
import { 
  BookingCreateRequestSchema,
  BookingUpdateSchema, 
  BookingResponseSchema,
  RESERVATION_STATUS
} from "../models/booking";
import { authPlugin } from "../plugins/access";
import { BadRequestError, NotFoundError } from "../utils/error";

export const bookingController = new Elysia({ prefix: "/booking", tags: ["booking"] })
  .use(authPlugin)
  
  // ===== ENDPOINTS PRINCIPALES =====
  
  // Listar reservas con filtros
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
    
    const bookings = await db.booking.find(filters);
    return bookings;
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
      summary: "Obtener todas las reservas",
      description: "Retorna una lista de todas las reservas con filtros opcionales.",
    },
    response: {
      200: t.Array(BookingResponseSchema),
      400: t.String(),
      500: t.String(),
    },
  })
  
  // Obtener una reserva por ID
  .get("/:id", async ({ params }) => {
    const booking = await db.booking.findById(params.id);
    if (!booking) {
      throw new NotFoundError("Reserva no encontrada");
    }
    return booking;
  }, {
    detail: {
      summary: "Obtener una reserva por ID",
      description: "Retorna una reserva específica por su ID.",
    },
    response: {
      200: BookingResponseSchema,
      404: t.String(),
      500: t.String(),
    },
  })
  
  // Crear una nueva reserva
  .post("/", async ({ body, parking, employee }) => {
    const booking = await db.booking.create(body, parking.id, employee.id);
    return booking;
  }, {
    body: BookingCreateRequestSchema,
    detail: {
      summary: "Crear una nueva reserva",
      description: "Crea una nueva reserva para un vehículo.",
    },
    response: {
      200: BookingResponseSchema,
      400: t.String(),
      500: t.String(),
    },
  })
  
  // Actualizar una reserva
  .patch("/:id", async ({ params, body }) => {
    const booking = await db.booking.update(params.id, body);
    if (!booking) {
      throw new NotFoundError("Reserva no encontrada");
    }
    return booking;
  }, {
    body: BookingUpdateSchema,
    detail: {
      summary: "Actualizar una reserva",
      description: "Actualiza los datos de una reserva existente.",
    },
    response: {
      200: BookingResponseSchema,
      404: t.String(),
      500: t.String(),
    },
  })
  
  // Eliminar una reserva
  .delete("/:id", async ({ params }) => {
    const deleted = await db.booking.delete(params.id);
    if (!deleted) {
      throw new NotFoundError("Reserva no encontrada");
    }
    return { message: "Reserva eliminada exitosamente" };
  }, {
    detail: {
      summary: "Eliminar una reserva",
      description: "Elimina una reserva existente.",
    },
    response: {
      200: t.Object({ message: t.String() }),
      404: t.String(),
      500: t.String(),
    },
  })
  
  // ===== ENDPOINTS ESPECÍFICOS =====
  
  // Obtener reservas activas para un spot
  .get("/spot/:spotId/active", async ({ params }) => {
    const bookings = await db.booking.getActiveForSpot(params.spotId);
    return bookings;
  }, {
    detail: {
      summary: "Obtener reservas activas para un spot",
      description: "Retorna todas las reservas activas para un spot específico.",
    },
    response: {
      200: t.Array(BookingResponseSchema),
      500: t.String(),
    },
  })
  
  // Obtener reservas activas para un vehículo
  .get("/vehicle/:vehicleId/active", async ({ params }) => {
    const bookings = await db.booking.getActiveForVehicle(params.vehicleId);
    return bookings;
  }, {
    detail: {
      summary: "Obtener reservas activas para un vehículo",
      description: "Retorna todas las reservas activas para un vehículo específico.",
    },
    response: {
      200: t.Array(BookingResponseSchema),
      500: t.String(),
    },
  })
  
  // Obtener estadísticas de reservas
  .get("/stats/:parkingId", async ({ params, query }) => {
    const { startDate, endDate } = query;
    const stats = await db.booking.getStats(
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
      summary: "Obtener estadísticas de reservas",
      description: "Retorna estadísticas de reservas para un parking específico.",
    },
    response: {
      200: t.Object({
        total: t.Number(),
        byStatus: t.Record(t.String(), t.Number()),
      }),
      500: t.String(),
    },
  });
