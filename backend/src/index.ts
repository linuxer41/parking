import { Elysia, t } from "elysia";
import { swagger } from "@elysiajs/swagger";
import { cors } from "@elysiajs/cors";
import { opentelemetry } from "@elysiajs/opentelemetry";
import { userController } from "./controllers/user";
import { employeeController } from "./controllers/employee";
import { parkingController } from "./controllers/parking";
import { areaController } from "./controllers/area";
import { elementController } from "./controllers/element";
import { vehicleController } from "./controllers/vehicle";
import { subscriptionController } from "./controllers/subscription";
import { accessController } from "./controllers/access";
import { cashRegisterController } from "./controllers/cash-register";
import { movementController } from "./controllers/movement";
import { reservationController } from "./controllers/reservation";
import { reportController } from "./controllers/report";
import { notificationController } from "./controllers/notification";
import { notificationProcessorController } from "./controllers/notification-processor";
import { authController } from "./controllers/auth";
import { realtimeService } from "./services/realtime-service";

const app = new Elysia()
  .use(
    swagger({
      path: "/docs",
      documentation: {
        info: {
          title: "Parkar API Documentation",
          version: "1.0.0",
        },
      },
    }),
  )
  .use(
    cors({
      origin: "*",
      credentials: true,
      methods: "*",
    }),
  )
  .use(opentelemetry())
  .ws('/ws', {
      message(ws, message) {
          ws.send(message)
      }
  })
  .use(authController)
  .use(userController)
  .use(employeeController)
  .use(parkingController)
  .use(areaController)
  .use(elementController)
  .use(vehicleController)
  .use(subscriptionController)
  .use(accessController)
  .use(cashRegisterController)
  .use(movementController)
  .use(reservationController)
  .use(reportController)
  .use(notificationController)
  .use(notificationProcessorController)
  .use(realtimeService)
  .onAfterHandle(({ response }) => {
    console.log(response);
  })
  .onError(({ code, error }) => {
    console.error(error);
    return {
      code,
      message: error.message,
    };
  })
  .listen(3002)


console.log("🦊 Elysia is running at", app.server?.hostname, app.server?.port);

// Para TypeScript
export type ElysiaApp = typeof app;
