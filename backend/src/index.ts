import { Elysia, t } from "elysia";
import { swagger } from "@elysiajs/swagger";
import { cors } from "@elysiajs/cors";
import { opentelemetry } from "@elysiajs/opentelemetry";
import { userController } from "./controllers/user";
import { employeeController } from "./controllers/employee";
import { parkingController } from "./controllers/parking";
import { vehicleController } from "./controllers/vehicle";
import { cashRegisterController } from "./controllers/cash-register";
import { movementController } from "./controllers/movement";
import { bookingController } from "./controllers/booking";
import { accessController } from "./controllers/access";
import { subscriptionController } from "./controllers/subscription";
import { reportController } from "./controllers/report";
import { notificationController } from "./controllers/notification";
import { notificationProcessorController } from "./controllers/notification-processor";
import { authController } from "./controllers/auth";
import { realtimeService } from "./services/realtime-service";
import { 
  ApiError, 
  BadRequestError, 
  UnauthorizedError, 
  ForbiddenError, 
  NotFoundError, 
  ConflictError, 
  InternalServerError 
} from "./utils/error";

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
  .onError(({ error, set }) => {
    console.error(error);
   
    // Si es un error personalizado de nuestra API
    if (error instanceof ApiError) {
      // Asegurar que el statusCode sea válido
      const statusCode = error.statusCode >= 100 && error.statusCode < 600 ? error.statusCode : 500;
      set.status = statusCode;
      return {
        success: false,
        error: {
          code: statusCode,
          message: error.message,
          type: error.constructor.name
        }
      };
    }
    let statusCode = 500;
    set.status = statusCode;
    return {
      success: false,
      error: {
        code: statusCode,
        message: error instanceof Error ? error.message : "Error interno del servidor",
        type: "InternalServerError"
      }
    };
  })
  .use(authController)
  .use(userController)
  .use(employeeController)
  .use(parkingController)
  .use(vehicleController)
  .use(cashRegisterController)
  .use(movementController)
  .use(bookingController)
  .use(accessController)
  .use(subscriptionController)
  .use(reportController)
  .use(notificationController)
  .use(notificationProcessorController)
  .use(realtimeService)
  // .onAfterHandle(({ response }) => {
  //   console.log(response);
  // })
  // .onRequest(({ request }) => {
  //   console.log("Request:", request.method, request.url);
  // })

  .listen(3002)


console.log("🦊 Elysia is running at", app.server?.hostname, app.server?.port);

// Para TypeScript
export type ElysiaApp = typeof app;
