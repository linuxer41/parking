import Big from "big.js";
import Elysia, { t } from "elysia";
import { db } from "../db";
import {
  Access,
  AccessCreateRequestSchema,
  AccessSchema
} from "../models/access";
import { authPlugin } from "../plugins";
import { broadcastAccessCompleted, broadcastNewAccess, broadcastSpotUpdate } from "../services/realtime-service";

export const accessController = new Elysia({
  name: "access/controller",
  prefix: "/accesses",
  tags: ["access"],
})
  .use(authPlugin)
  .get(
    "/",
    async ({ query }) => {
      const { parkingId, status, limit } = query;
      
      const accesses = await db.access.findMany({
        where: {
          parkingId,
          status
        },
        // limit: limit || 50
      });
      return accesses;
    },
    {
      query: t.Object({
        parkingId: t.Optional(t.String({
          description: "ID del estacionamiento para filtrar",
        })),
        status: t.Optional(t.String({
          description: "Estado de los accesos: active, completed, cancelled",
        })),
        limit: t.Optional(t.Number({
          description: "Límite de resultados para accesos completados",
        })),
      }),
      detail: {
        summary: "Obtener accesos de estacionamiento",
        description: "Retorna una lista de accesos de estacionamiento. Se puede filtrar por estacionamiento y estado.",
      },
      response: {
        200: t.Array(AccessSchema),
        400: t.String(),
        500: t.String(),
      },
    },
  )
  .post(
    "/",
    async ({ body, employee }) => {
      const targetSpot = await db.element.findFirst({
        where: {
          id: body.spotId,
          areaId: body.areaId,
          type: "spot",
          // status: "available"
        }
      });
      if (!targetSpot) {
        throw new Response("Spot no encontrado", { status: 404 });
      }
      
      // 2. Verificar si el spot está libre
      if (targetSpot.occupancy?.access) {
        throw new Response("El espacio de estacionamiento ya está ocupado por una entrada", { status: 400 });
      }
      if (targetSpot.occupancy?.subscription) {
        throw new Response("El espacio de estacionamiento ya está ocupado por una suscripción", { status: 400 });
      }

      if (targetSpot.occupancy?.reservation ) {
        throw new Response("El espacio de estacionamiento ya está reservado", { status: 400 });
      }

      let vehicle = await db.vehicle.findFirst({
        where: {
          plate: body.vehiclePlate,
          parkingId: body.parkingId
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
            ownerPhone: body.ownerPhone || null,
          }
        });
      }

      // check if the vehicle is already in the parking
      if (vehicle.subscription && vehicle.subscription?.spotId !== body.spotId) {
        throw new Response("El vehículo ya tiene una suscripción a otro espacio de estacionamiento", { status: 400 });
      }

      if (vehicle.reservation && vehicle.reservation?.spotId !== body.spotId) {
        throw new Response("El vehículo ya tiene una reserva a otro espacio de estacionamiento", { status: 400 });
      }

      if (vehicle.access) {
        throw new Response("El vehículo ya tiene esta entrada activa", { status: 400 });
      }
      
      
      // 3. Registrar la entrada en la base de datos primero
      const entry = await db.access.create({
        data: {
          parkingId: body.parkingId,
          entryEmployeeId: employee.id,
          vehicleId: vehicle.id,
          spotId: body.spotId,
          entryTime: new Date().toISOString()
        }
      });
      
      return entry as Access;
    },
    {
      body: AccessCreateRequestSchema,
      detail: {
        summary: "Registrar la entrada de un vehículo",
        description: "Marca un spot como ocupado y registra la entrada del vehículo",
      },
      response: {
        200: AccessSchema,
        400: t.String(),
        404: t.String(),
        500: t.String(),
      },
    },
  )
  .post(
    "/subscribed",
    async ({ body, user, employee }) => {

      const subscription = await db.subscription.findUnique({
        where: {
          id: body.subscriptionId
        }
      });

      if (!subscription) {
        throw new Response("Suscripción no encontrada", { status: 404 });
      }
      // crear entrada con suscripcion
      const access = await db.access.create({
        data: {
          parkingId: subscription.parkingId,
          entryEmployeeId: employee.id,
          subscriptionId: body.subscriptionId,
          vehicleId: subscription.vehicleId,
          spotId: subscription.spotId,
          entryTime: new Date().toISOString()
        }
      });

      return access;
      
    },
    {
      body: t.Object({
        subscriptionId: t.String({
          description: "ID de la suscripción",
          required: true,
        }),
      }),
      detail: {
        summary: "Registrar la entrada de un vehículo con suscripción",
        description: "Registra la entrada de un vehículo con suscripción",
      },
      response: {
        200: AccessSchema,
        400: t.String(),
        404: t.String(),
        500: t.String(),
      },
    }
  )
  .post(
    "/reserved",
    async ({ body, user, employee }) => {

      const reservation = await db.reservation.findUnique({
        where: {
          id: body.reservationId
        }
      });

      if (!reservation) {
        throw new Response("Reserva no encontrada", { status: 404 });
      }
      // crear entrada con suscripcion
      const access = await db.access.create({
        data: {
          parkingId: reservation.parkingId,
          entryEmployeeId: employee.id,
          reservationId: body.reservationId,
          vehicleId: reservation.vehicleId,
          spotId: reservation.spotId,
          entryTime: new Date().toISOString()
        }
      });

      return access;
      
    },
    {
      body: t.Object({
        reservationId: t.String({
          description: "ID de la reserva",
          required: true,
        }),
      }),
      detail: {
        summary: "Registrar la entrada de un vehículo con reserva",
        description: "Registra la entrada de un vehículo con reserva",
      },
      response: {
        200: AccessSchema,
        400: t.String(),
        404: t.String(),
        500: t.String(),
      },
    }
  )
  .post(
    "/exit",
    async ({ body, user, employee }) => {
      const parking = await db.parking.findUnique({
        where: {
          id: body.parkingId
        }
      });

      if (!parking) {
        throw new Response("Estacionamiento no encontrado", { status: 404 });
      }
  
      // 1. Encontrar la entrada correspondiente
      const access = await db.access.findUnique({
        where: {
          id: body.accessId
        }
      });
      
      if (!access) {
        throw new Response("Entrada no encontrada", { status: 404 });
      }

      const spot = await db.element.findUnique({
        where: {
          id: access.spotId
        }
      });

      if (!spot) {
        throw new Response("Spot no encontrado", { status: 404 });
      }

      if (access.status !== "active") {
        throw new Response("Entrada no está activa", { status: 400 });
      }

      const duration = new Date().getTime() - new Date(access.entryTime).getTime();

      // Calcular horas y minutos reales
      const totalMinutes = Math.floor(duration / (1000 * 60));
      const hours = Math.floor(totalMinutes / 60);
      const minutes = totalMinutes % 60;

      let amount = Big(parking.rates[0].hourly).mul(Big(hours));

      // Mostrar duración completa
      console.log({ hours, minutes, totalMinutes, duration, amount: Number(amount.toFixed(2)) });;

      

      // if hours is less than 1, set amount acording minutes
      if (hours < 1) {
        const minutes = Math.ceil(duration / (1000 * 60));
        if (minutes > 15) {
          amount = Big(parking.rates[0].hourly).div(2);
        } else {
          amount = Big(0);
        }
      }
      
      // 3. Registrar la salida en la base de datos
      const exit = await db.access.update({
        where: {
          id: body.accessId
        },
        data: {
          exitEmployeeId: employee.id,
          exitTime: new Date().toISOString(),
          amount: Number(amount.toFixed(2)),
          status: 'completed'
        }
      });

      // 6. Notificar a los clientes conectados sobre la nueva salida y actualización del spot
      // broadcastAccessCompleted(access.parkingId, { ...exit, access });
      // broadcastSpotUpdate(access.parkingId, access.spotId, false);
      
      return exit;
    },
    {
      body: t.Object({
        accessId: t.String({
          description: "ID de la entrada relacionada",
          required: true,
        }),
        parkingId: t.String({
          description: "ID del estacionamiento",
          required: true,
        }),
        amount: t.Optional(t.Number({
          description: "Monto de la entrada",
          required: false,
        })),

      }),
      detail: {
        summary: "Registrar la salida de un vehículo",
        description: "Marca un spot como libre y registra la salida del vehículo",
      },
      response: {
        200: AccessSchema,
        400: t.String(),
        404: t.String(),
        500: t.String(),
      },
    },
  )
  .get(
    "/:id",
    async ({ params }) => {
      const access = await db.access.findUnique({
        where: { id: params.id },
      });
      
      if (!access) {
        throw new Response("Acceso no encontrado", { status: 404 });
      }
      
      return access as Access;
    },
    {
      params: t.Object({
        id: t.String({
          description: "ID del acceso a obtener",
          required: true,
        }),
      }),
      detail: {
        summary: "Obtener un acceso por ID",
        description: "Retorna un acceso específico basado en su ID.",
      },
      response: {
        200: AccessSchema,
        404: t.String(),
        500: t.String(),
      },
    },
  )
