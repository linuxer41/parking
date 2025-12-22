import { jwt } from "@elysiajs/jwt";
import { Elysia } from "elysia";
import {
  ACCESS_TOKEN_EXP,
  JWT_NAME,
  REFRESH_TOKEN_EXP,
} from "../config/constants";
import { db } from "../db";
import { AuthResponseSchema, loginBodySchema, RegistrationSchema } from "../models/auth";
import { authPlugin } from "../plugins";
import { registrationService } from "../services/registration-service";
import { getExpTimestamp } from "../utils/common";
import { UnauthorizedError } from "../utils/error";

export const authController = new Elysia({ prefix: "/auth", tags: ["auth"] })
  .use(
    jwt({
      name: JWT_NAME,
      secret: Bun.env.JWT_SECRET!,
    }),
  )
  .post(
    "/sign-in",
    async ({ body, jwt, cookie: { authToken, refreshToken }, set }) => {
      // match user email
      const users = await db.user.find({ email: body.email });
      const user = users[0];

      if (!user) {
        throw new UnauthorizedError(
          "El correo electrónico o la contraseña que ingresaste son incorrectos",
        );
      }

      // match password
      const matchPassword = await Bun.password.verify(
        body.password,
        user.passwordHash,
      );
      if (!matchPassword) {
        throw new UnauthorizedError(
          "El correo electrónico o la contraseña que ingresaste son incorrectos",
        );
      }

      // Get all employees for central app
      const employeeRecords = await db.employee.find({ userId: user.id });
      const firstEmployee = employeeRecords[0];
      if(!firstEmployee) {
        throw new UnauthorizedError(
          "El usuario no tiene empleados asociados",
        );
      }
      const tenant = firstEmployee.parkingId;
      const employee = firstEmployee.id;
      const role = firstEmployee.role;
      const scope = 'app';

      // create access token
      const accessJWTToken = await jwt.sign({
        sub: user.id,
        tenant,
        employee,
        role,
        scope,
        exp: getExpTimestamp(ACCESS_TOKEN_EXP),
      });
      authToken.set({
        value: accessJWTToken,
        httpOnly: true,
        maxAge: ACCESS_TOKEN_EXP,
        path: "/",
      });

      // create refresh token
      const refreshJWTToken = await jwt.sign({
        sub: user.id,
        exp: getExpTimestamp(REFRESH_TOKEN_EXP),
      });
      refreshToken.set({
        value: refreshJWTToken,
        httpOnly: true,
        maxAge: REFRESH_TOKEN_EXP,
        path: "/",
      });

      // Get user parkings
      const userParkings = await db.parking.findByUserId(user.id);

      return {
        auth: {
          token: accessJWTToken,
          refreshToken: refreshJWTToken,
        },
        user: user,
        parkings: userParkings || [],
      };
    },
    {
      body: loginBodySchema,
      response: AuthResponseSchema,
    },
  )
  .post(
    "/refresh",
    async ({ cookie: { authToken, refreshToken }, jwt }) => {
      if (!refreshToken.value) {
        throw new UnauthorizedError("Token de actualización faltante");
      }
      // get refresh token from cookie
      const jwtPayload = await jwt.verify(refreshToken.value);
      if (!jwtPayload) {
        throw new UnauthorizedError("Token de actualización inválido");
      }

      // get user from refresh token
      const userId = jwtPayload.sub;

      // verify user exists or not
      const users = await db.user.find({ id: userId });
      const user = users[0];

      if (!user) {
        throw new UnauthorizedError("Token de actualización inválido");
      }

      // Get employee info
      const employeeRecords = await db.employee.find({ userId: user.id });
      const firstEmployee = employeeRecords[0];
      if(!firstEmployee) {
        throw new UnauthorizedError("El usuario no tiene empleados asociados");
      }
      const tenant = firstEmployee.parkingId;
      const employee = firstEmployee.id;
      const role = firstEmployee.role;
      const scope = 'app';

      // create new access token
      const accessJWTToken = await jwt.sign({
        sub: user.id,
        tenant,
        employee,
        role,
        scope,
        exp: getExpTimestamp(ACCESS_TOKEN_EXP),
      });
      authToken.set({
        value: accessJWTToken,
        httpOnly: true,
        maxAge: ACCESS_TOKEN_EXP,
        path: "/",
      });

      // create new refresh token
      const refreshJWTToken = await jwt.sign({
        sub: user.id,
        exp: getExpTimestamp(REFRESH_TOKEN_EXP),
      });
      refreshToken.set({
        value: refreshJWTToken,
        httpOnly: true,
        maxAge: REFRESH_TOKEN_EXP,
        path: "/",
      });

      // Get user parkings
      const userParkings = await db.parking.findByUserId(user.id);

      return {
        auth: {
          token: accessJWTToken,
          refreshToken: refreshJWTToken,
        },
        user: user,
        parkings: userParkings || [],
      };
    },
  )
  .post(
    "/sign-up",
    async ({ body, jwt, cookie: { authToken, refreshToken }, set }) => {
      console.log(body);
      // Realizar el registro completo
      const result = await registrationService.registerComplete(body);

      // Get employee info
      const tenant = result.employee.parkingId;
      const employee = result.employee.id;
      const role = result.employee.role;
      const scope = 'app';

      // Crear tokens de autenticación
      const accessJWTToken = await jwt.sign({
        sub: result.user.id,
        tenant,
        employee,
        role,
        scope,
        exp: getExpTimestamp(ACCESS_TOKEN_EXP),
      });
      
      const refreshJWTToken = await jwt.sign({
        sub: result.user.id,
        exp: getExpTimestamp(REFRESH_TOKEN_EXP),
      });
      // Configurar cookies
      authToken.set({
        value: accessJWTToken,
        httpOnly: true,
        maxAge: ACCESS_TOKEN_EXP,
        path: "/",
      });

      refreshToken.set({
        value: refreshJWTToken,
        httpOnly: true,
        maxAge: REFRESH_TOKEN_EXP,
        path: "/",
      });

      // Obtener los parkings del usuario
      const userParkings = await db.parking.findByUserId(result.user.id);

      return {
        auth: {
          token: accessJWTToken,
          refreshToken: refreshJWTToken,
        },
        user: result.user,
        parkings: userParkings || [],
      };
    },
    {
      body: RegistrationSchema,
      response: AuthResponseSchema,
    },
  )
  .use(authPlugin)
  .post("/logout", async ({ cookie: { authToken, refreshToken }, user }) => {
    // remove refresh token and access token from cookies
    authToken.remove();
    refreshToken.remove();

    // remove refresh token from db & set user online status to offline
    // await db.user.update({
    //   where: {
    //     id: user.id,
    //   },
    //   data: {
    //     isOnline: false,
    //     refreshToken: null,
    //   },
    // });
    return {
      message: "Sesión cerrada exitosamente",
    };
  })
  .get("/me", async ({ user, jwt }) => {
    if (!user) {
      throw new UnauthorizedError("Usuario no autenticado");
    }
    // Get user parkings
    const userParkings = await db.parking.findByUserId(user.id);

    return {
      user: user,
      parkings: userParkings || [],
    };
  });
