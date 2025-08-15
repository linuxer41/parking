import Elysia, { t } from "elysia";
import { db } from "../db";
import { authPlugin } from "../plugins";
import { 
  ReservationSchema, 
  Reservation, 
  ReservationCreateSchema, 
  ReservationUpdateSchema,
  ReservationCreateRequestSchema
} from "../models/reservation";

export const reservationController = new Elysia({
  name: "reservation/controller",
  prefix: "/reservations",
  tags: ["reservation"],
})
  .use(authPlugin)
  .get(
    "/",
    async ({ query }) => {
      const { parkingId, status, limit } = query;
      
      const reservations = await db.reservation.findMany({
        where: {
          parkingId,
          status
        },
        // limit: limit || 50
      });
      return reservations;
    },
    {
      query: t.Object({
        parkingId: t.Optional(t.String({
          description: "ID del estacionamiento para filtrar",
        })),
        status: t.Optional(t.String({
          description: "Estado de las reservas: active, completed, cancelled",
        })),
        limit: t.Optional(t.Number({
          description: "Límite de resultados para reservas completadas",
        })),
      }),
      detail: {
        summary: "Obtener reservas de estacionamiento",
        description: "Retorna una lista de reservas de estacionamiento. Se puede filtrar por estacionamiento y estado.",
      },
      response: {
        200: t.Array(ReservationSchema),
        400: t.String(),
        500: t.String(),
      },
    },
  )
  .post(
    "",
    async ({ body, employee }) => {
      const targetSpot = await db.element.findFirst({
        where: {
          id: body.spotId,
          areaId: body.areaId,
          type: "spot",
        }
      });
      if (!targetSpot) {
        throw new Response("Spot no encontrado", { status: 404 });
      }
      
      // Verificar si el spot está libre
      if (targetSpot.occupancy.status !== "available") {
        throw new Response("El spot ya está ocupado", { status: 400 });
      }

      let vehicle = await db.vehicle.findFirst({
        where: {
          plate: body.vehiclePlate
        }
      });

      if (!vehicle) {
        vehicle = await db.vehicle.create({
          data: {
            parkingId: body.parkingId,
            plate: body.vehiclePlate,
            color: body.vehicleColor,
            type: body.vehicleType,
            ownerName: body.ownerName || null,
            ownerDocument: body.ownerDocument || null,
            ownerPhone: body.ownerPhone || null
          }
        });
      }
      
      // Generar número de reserva único
      const lastReservation = await db.reservation.findFirst({
        where: {
          parkingId: body.parkingId
        }
      });

      const nextNumber = (lastReservation?.number || 0) + 1;

      const endDate = new Date(body.startDate);
      endDate.setHours(endDate.getHours() + body.durationHours);
      
      // Registrar la reserva en la base de datos
      const reservation = await db.reservation.create({
        data: {
          number: nextNumber,
          parkingId: body.parkingId,
          employeeId: employee.id,
          vehicleId: vehicle.id,
          spotId: body.spotId,
          startDate: body.startDate,
          endDate: endDate,
          status: 'active',
          amount: body.amount
        }
      });
      
      return reservation;
    },
    {
      body: ReservationCreateRequestSchema,
      detail: {
        summary: "Crear una nueva reserva",
        description: "Crea una nueva reserva de estacionamiento para un vehículo",
      },
      response: {
        200: ReservationSchema,
        400: t.String(),
        404: t.String(),
        500: t.String(),
      },
    },
  )
  .get(
    "/reservations/:id",
    async ({ params }) => {
      const reservation = await db.reservation.findUnique({
        where: { id: params.id },
      });
      
      if (!reservation) {
        throw new Response("Reserva no encontrada", { status: 404 });
      }
      
      return reservation as Reservation;
    },
    {
      params: t.Object({
        id: t.String({
          description: "ID de la reserva a obtener",
          required: true,
        }),
      }),
      detail: {
        summary: "Obtener una reserva por ID",
        description: "Retorna una reserva específica basada en su ID.",
      },
      response: {
        200: ReservationSchema,
        404: t.String(),
        500: t.String(),
      },
    },
  )
  .patch(
    "/reservations/:id",
    async ({ params, body }) => {
      const reservation = await db.reservation.update({
        where: {
          id: params.id,
        },
        data: body,
      });
      return reservation as Reservation;
    },
    {
      body: ReservationUpdateSchema,
      detail: {
        summary: "Actualizar una reserva",
        description:
          "Actualiza un registro de reserva existente con los datos proporcionados.",
      },
      response: {
        200: ReservationSchema,
        400: t.String(),
        500: t.String(),
      },
    },
  )
  .delete(
    "/reservations/:id",
    async ({ params }) => {
      const reservation = await db.reservation.delete({
        where: {
          id: params.id,
        },
      });
      return reservation as Reservation;
    },
    {
      detail: {
        summary: "Eliminar una reserva",
        description: "Elimina un registro de reserva basado en su ID.",
      },
      response: {
        200: ReservationSchema,
        400: t.String(),
        500: t.String(),
      },
    },
  )
  .post(
    "/:id/cancel",
    async ({ params }) => {
      const reservation = await db.reservation.update({
        where: { id: params.id },
        data: { status: 'cancelled' }
      });
      return reservation as Reservation;
    },
    {
      detail: {
        summary: "Cancelar una reserva",
        description: "Cancela una reserva existente basado en su ID.",
      },
      response: {
        200: ReservationSchema,
        400: t.String(),
        500: t.String(),
      },
    },
  );