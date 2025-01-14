
import { Elysia, t } from 'elysia';
import { swagger } from '@elysiajs/swagger';
import { cors } from '@elysiajs/cors'
import { opentelemetry } from '@elysiajs/opentelemetry';
import { userController } from './controllers/user';
import { companyController } from './controllers/company';
import { employeeController } from './controllers/employee';
import { parkingController } from './controllers/parking';
import { levelController } from './controllers/level';
import { areaController } from './controllers/area';
import { spotController } from './controllers/spot';
import { vehicleController } from './controllers/vehicle';
import { priceController } from './controllers/price';
import { subscriberController } from './controllers/subscriber';
import { subscriptionPlanController } from './controllers/subscription-plan';
import { entryController } from './controllers/entry';
import { exitController } from './controllers/exit';
import { cashRegisterController } from './controllers/cash-register';
import { movementController } from './controllers/movement';
import { reservationController } from './controllers/reservation';
import { authController } from './controllers/auth';

const app = new Elysia()
  .use(opentelemetry())
  .use(cors(
    {
      origin: '*',
      methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
      allowedHeaders: ['Content-Type', 'Authorization', 'Access-Control-Allow-Origin', 'Access-Control-Allow-Headers', 'Access-Control-Allow-Methods', 'Access-Code'],
      credentials: true,
      maxAge: 86400,
    }
  ))
  .use(swagger({
      documentation: {
          info: {
              title: 'API de Estacionamiento',
              version: '1.0.0',
              description: 'API para la gestión de estacionamientos, vehículos, empleados y más.'
          },
          tags: [
              { name: 'user', description: 'Operaciones relacionadas con users' },
    { name: 'company', description: 'Operaciones relacionadas con companys' },
    { name: 'employee', description: 'Operaciones relacionadas con employees' },
    { name: 'parking', description: 'Operaciones relacionadas con parkings' },
    { name: 'level', description: 'Operaciones relacionadas con levels' },
    { name: 'area', description: 'Operaciones relacionadas con areas' },
    { name: 'spot', description: 'Operaciones relacionadas con spots' },
    { name: 'vehicle', description: 'Operaciones relacionadas con vehicles' },
    { name: 'price', description: 'Operaciones relacionadas con prices' },
    { name: 'subscriber', description: 'Operaciones relacionadas con subscribers' },
    { name: 'subscription-plan', description: 'Operaciones relacionadas con subscription-plans' },
    { name: 'entry', description: 'Operaciones relacionadas con entrys' },
    { name: 'exit', description: 'Operaciones relacionadas con exits' },
    { name: 'cash-register', description: 'Operaciones relacionadas con cash-registers' },
    { name: 'movement', description: 'Operaciones relacionadas con movements' },
    { name: 'reservation', description: 'Operaciones relacionadas con reservations' }
          ],
    components: {
        securitySchemes: {
            token: {
              type: 'http',
              scheme: 'bearer',
              bearerFormat: 'JWT',
            },
            branchId: {
                type: 'apiKey',
                name: 'branch-id',
                in: 'header',
            }
          },
    }
      },
      scalarConfig: {
          layout: 'classic',
          hideModels: true,
          
      },
      provider: 'swagger-ui'
    
      
  }))

  .onError(({ error, code }) => {
      if (code === 'NOT_FOUND') return 'Not Found :(';
      console.error(error);
  })
  .get('/', ({ path }) => {
      return {
          message: `Hello from ${path}`,
      };
  })
  .use(authController)
  .use(userController)
    .use(companyController)
    .use(employeeController)
    .use(parkingController)
    .use(levelController)
    .use(areaController)
    .use(spotController)
    .use(vehicleController)
    .use(priceController)
    .use(subscriberController)
    .use(subscriptionPlanController)
    .use(entryController)
    .use(exitController)
    .use(cashRegisterController)
    .use(movementController)
    .use(reservationController)
  .listen(3001);

console.log(`🦊 Elysia is running at http://${app.server?.hostname}:${app.server?.port}`);
