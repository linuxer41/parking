import { jwt } from "@elysiajs/jwt";
import { Elysia } from "elysia";
import {
  ACCESS_TOKEN_EXP,
  JWT_NAME,
  REFRESH_TOKEN_EXP,
} from "../config/constants";
import { db } from "../db";
import { AuthResponseSchema, loginBodySchema, RegistrationSchema, signupBodySchema } from "../models/auth";
import { authPlugin } from "../plugins/auth";
import { registrationService } from "../services/registration-service";
import { getExpTimestamp } from "../utils/common";
import { ConflictError, UnauthorizedError } from "../utils/error";
import { reverseGeocodingAPI } from "../utils/geoapify";

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
      console.log(user);

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

      // create access token
      const accessJWTToken = await jwt.sign({
        sub: user.id,
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
      const userParkings = await db.parking.findParkingsByOwnerId(user.id);

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
    "/sign-up",
    async ({ body }) => {
      // Verificar si el usuario ya existe
      const existingUsers = await db.user.find({ email: body.email });
      const existingUser = existingUsers[0];
      
      if (existingUser) {
        throw new ConflictError(`Ya existe un usuario con el email ${body.email}`);
      }

      // hash password
      const password = await Bun.password.hash(body.password);

      // fetch user location from lat & lon
      let location: any;
      if (body.location) {
        const [lat, lon] = body.location;
        location = await reverseGeocodingAPI(lat, lon);
      }
      console.log(location);
      const user = await db.user.create({
        ...body,
        password,
        //   location,
      });
      return {
        message: "Cuenta creada exitosamente",
        data: {
          user,
        },
      };
    },
    {
      body: signupBodySchema,
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
      // create new access token
      const accessJWTToken = await jwt.sign({
        sub: user.id,
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
      const userParkings = await db.parking.findParkingsByOwnerId(user.id);

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
    "/register-complete",
    async ({ body, jwt, cookie: { authToken, refreshToken }, set }) => {
      console.log(body);
      // Realizar el registro completo
      const result = await registrationService.registerComplete(body);

      // Crear tokens de autenticación
      const accessJWTToken = await jwt.sign({
        sub: result.user.id,
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

      console.log({accessJWTToken, refreshJWTToken, result});

      // Obtener los parkings del usuario
      const userParkings = await db.parking.findParkingsByOwnerId(result.user.id);

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
    const userParkings = await db.parking.findParkingsByOwnerId(user.id);

    // Generate a fresh token
    const accessJWTToken = await jwt.sign({
      sub: user.id,
      exp: getExpTimestamp(ACCESS_TOKEN_EXP),
    });

    return {
      user: user,
      parkings: userParkings || [],
    };
  });
