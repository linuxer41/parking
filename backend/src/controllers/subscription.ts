import Elysia, { t } from "elysia";
import { db } from "../db";
import { authPlugin } from "../plugins";
import { 
  SubscriptionSchema, 
  Subscription, 
  SubscriptionCreateSchema, 
  SubscriptionUpdateSchema,
  SubscriptionCreateRequestSchema
} from "../models/subscription";
import Big from "big.js";

export const subscriptionController = new Elysia({
  prefix: "/subscriptions",
  name: "subscription/controller",
  tags: ["subscription"],
})
  .use(authPlugin)
  .get(
    "/",
    async ({ query }) => {
      const { parkingId, isActive, limit } = query;
      
      const subscriptions = await db.subscription.findMany({
        where: {
          parkingId,
          isActive
        },
        // limit: limit || 50
      });
      return subscriptions;
    },
    {
      query: t.Object({
        parkingId: t.Optional(t.String({
          description: "ID del estacionamiento para filtrar",
        })),
        isActive: t.Optional(t.Boolean({
          description: "Estado de las suscripciones: true para activas, false para inactivas",
        })),
        limit: t.Optional(t.Number({
          description: "Límite de resultados para suscripciones",
        })),
      }),
      detail: {
        summary: "Obtener suscripciones de estacionamiento",
        description: "Retorna una lista de suscripciones de estacionamiento. Se puede filtrar por estacionamiento y estado.",
      },
      response: {
        200: t.Array(SubscriptionSchema),
        400: t.String(),
        500: t.String(),
      },
    },
  )
  .post(
    "/",
    async ({ body, employee }) => {
      const parking = await db.parking.findUnique({
        where: {
          id: body.parkingId
        }
      });
      if (!parking) {
        throw new Response("Estacionamiento no encontrado", { status: 404 });
      }

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

      const taregtRate = parking.rates.find((rate) => rate.vehicleCategory === targetSpot.subType);
      if (!taregtRate) {
        throw new Response("Tarifa no encontrada", { status: 404 });
      }

      const targetPrice = taregtRate[body.period] || 0;
      if (targetPrice === 0) {
        throw new Response("Tarifa no configurada para el tipo de vehículo", { status: 404 });
      }

      const startDate = new Date(body.startDate);
      const endDate = new Date(startDate);
      if (body.period === "weekly") {
        endDate.setDate(endDate.getDate() + 7);
      } else if (body.period === "monthly") {
        endDate.setDate(endDate.getDate() + 30);
      } else if (body.period === "yearly") {
        endDate.setDate(endDate.getDate() + 365);
      }

      const amount = Number(Big(targetPrice).toFixed(2));

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
            ownerPhone: body.ownerPhone || null,
          }
        });
      } else {
        vehicle = await db.vehicle.update({
          where: { id: vehicle.id },
          data: { color: body.vehicleColor, type: body.vehicleType, ownerName: body.ownerName || null, ownerDocument: body.ownerDocument || null, ownerPhone: body.ownerPhone || null }
        });
      }
      
      // Registrar la suscripción en la base de datos
      const subscription = await db.subscription.create({
        data: {
          parkingId: body.parkingId,
          employeeId: employee.id,
          vehicleId: vehicle.id,
          spotId: body.spotId,
          startDate: body.startDate,
          endDate: endDate,
          amount: amount,
          isActive: true
        }
      });
      
      return subscription as Subscription;
    },
    {
      body: SubscriptionCreateRequestSchema,
      detail: {
        summary: "Crear una nueva suscripción",
        description: "Crea una nueva suscripción de estacionamiento para un vehículo",
      },
      response: {
        200: SubscriptionSchema,
        400: t.String(),
        404: t.String(),
        500: t.String(),
      },
    },
  )
  .get(
    "/:id",
    async ({ params }) => {
      const subscription = await db.subscription.findUnique({
        where: { id: params.id },
      });
      
      if (!subscription) {
        throw new Response("Suscripción no encontrada", { status: 404 });
      }
      
      return subscription as Subscription;
    },
    {
      params: t.Object({
        id: t.String({
          description: "ID de la suscripción a obtener",
          required: true,
        }),
      }),
      detail: {
        summary: "Obtener una suscripción por ID",
        description: "Retorna una suscripción específica basada en su ID.",
      },
      response: {
        200: SubscriptionSchema,
        404: t.String(),
        500: t.String(),
      },
    },
  )
  .patch(
    "/:id",
    async ({ params, body }) => {
      const subscription = await db.subscription.update({
        where: {
          id: params.id,
        },
        data: body,
      });
      return subscription as Subscription;
    },
    {
      body: SubscriptionUpdateSchema,
      detail: {
        summary: "Actualizar una suscripción",
        description:
          "Actualiza un registro de suscripción existente con los datos proporcionados.",
      },
      response: {
        200: SubscriptionSchema,
        400: t.String(),
        500: t.String(),
      },
    },
  )
  .delete(
    "/:id",
    async ({ params }) => {
      const subscription = await db.subscription.delete({
        where: {
          id: params.id,
        },
      });
      return subscription as Subscription;
    },
    {
      detail: {
        summary: "Eliminar una suscripción",
        description: "Elimina un registro de suscripción basado en su ID.",
      },
      response: {
        200: SubscriptionSchema,
        400: t.String(),
        500: t.String(),
      },
    },
  )
  // cancelar suscripcion
  .post(
    "/:id/cancel",
    async ({ params }) => {
      const subscription = await db.subscription.update({
        where: { id: params.id },
        data: { isActive: false }
      }); 
      return subscription as Subscription;
    },
    {
      detail: {
        summary: "Cancelar una suscripción",
        description: "Cancela una suscripción existente basado en su ID.",
      },
      params: t.Object({
        id: t.String({
          description: "ID de la suscripción a cancelar",
          required: true,
        }),
      }),
      response: {
        200: SubscriptionSchema,
        400: t.String(),
        500: t.String(),
      },
    },
  );
