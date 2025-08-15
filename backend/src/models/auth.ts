import { t } from "elysia";
import { UserCreateSchema } from "./user";
import { ParkingCreateSchema } from "./parking";

const loginBodySchema = t.Object({
  email: t.String({ format: "email" }),
  password: t.String({ minLength: 8 }),
});

const signupBodySchema = t.Object({
  name: t.String({ maxLength: 60, minLength: 1 }),
  email: t.String({ format: "email" }),
  password: t.String({ minLength: 8 }),
  phone: t.String({ minLength: 1 }),
  location: t.Optional(t.Tuple([t.Number(), t.Number()])),
});

// Esquema para el registro completo (usuario + parking)
export const CompleteRegistrationSchema = t.Object({
  user: UserCreateSchema,
  parking: t.Object({
    name: t.String({
      description: "Nombre del estacionamiento",
      required: true,
    }),
    capacity: t.Number({
      description: "Capacidad máxima del parqueo",
      required: true,
      minimum: 1,
    }),
    operationMode: t.Optional(t.Union([t.Literal("visual"), t.Literal("simple")], {
      description: "Modo de operación del parqueo: visual o simple",
      required: false,
      default: "visual",
    })),
    location: t.Optional(t.Union([
      t.Tuple([t.Number(), t.Number()], {
        description: "Ubicación del estacionamiento [latitud, longitud]",
      }),
      t.Array(t.Number(), { minItems: 0, maxItems: 0 })
    ], {
      description: "Ubicación del estacionamiento [latitud, longitud] o array vacío",
      required: false,
    })),
    address: t.Optional(t.String({
      description: "Dirección del estacionamiento",
      required: false,
    })),
  }, {
    description: "Datos mínimos del estacionamiento para el registro completo",
  }),
}, {
  description: "Esquema para el registro completo de usuario y estacionamiento",
});

export type CompleteRegistration = typeof CompleteRegistrationSchema.static;

export { loginBodySchema, signupBodySchema };
