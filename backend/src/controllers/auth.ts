import { Elysia } from "elysia";
import { loginBodySchema, signupBodySchema, CompleteRegistrationSchema } from "../models/auth";
import { db } from "../db";
import { reverseGeocodingAPI } from "../utils/geoapify";
import { jwt } from "@elysiajs/jwt";
import {
  ACCESS_TOKEN_EXP,
  JWT_NAME,
  REFRESH_TOKEN_EXP,
} from "../config/constants";
import { getExpTimestamp } from "../utils/common";
import { authPlugin } from "../plugins/auth";
import { registrationService } from "../services/registration-service";

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
      console.log(body);

      // match user email
      const user = await db.user.findUnique({
        where: { email: body.email },
      });

      if (!user) {
        set.status = "Bad Request";
        throw new Error(
          "The email address or password you entered is incorrect",
        );
      }
      console.log(user);

      // match password
      const matchPassword = await Bun.password.verify(
        body.password,
        user.password,
      );
      if (!matchPassword) {
        set.status = "Bad Request";
        throw new Error(
          "The email address or password you entered is incorrect",
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
      const userParkings = await db.user.getUserParkings(user.id);

      return {
        token: accessJWTToken,
        user: user,
        parkings: userParkings || [],
      };
    },
    {
      body: loginBodySchema,
    },
  )
  .post(
    "/sign-up",
    async ({ body }) => {
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
        data: {
          ...body,
          password,
          //   location,
        },
      });
      return {
        message: "Account created successfully",
        data: {
          user,
        },
      };
    },
    {
      body: signupBodySchema,
      error({ code, set, body }) {
        // handle duplicate email error throw by db
        // P2002 duplicate field erro code
        if ((code as unknown) === "P2002") {
          set.status = "Conflict";
          return {
            name: "Error",
            message: `The email address provided ${body.email} already exists`,
          };
        }
      },
    },
  )
  .post(
    "/refresh",
    async ({ cookie: { authToken, refreshToken }, jwt, set }) => {
      if (!refreshToken.value) {
        // handle error for refresh token is not available
        set.status = "Unauthorized";
        throw new Error("Refresh token is missing");
      }
      // get refresh token from cookie
      const jwtPayload = await jwt.verify(refreshToken.value);
      if (!jwtPayload) {
        // handle error for refresh token is tempted or incorrect
        set.status = "Forbidden";
        throw new Error("Refresh token is invalid");
      }

      // get user from refresh token
      const userId = jwtPayload.sub;

      // verify user exists or not
      const user = await db.user.findUnique({
        where: {
          id: userId,
        },
      });

      if (!user) {
        // handle error for user not found from the provided refresh token
        set.status = "Forbidden";
        throw new Error("Refresh token is invalid");
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
      const userParkings = await db.user.getUserParkings(user.id);

      return {
        token: accessJWTToken,
        user: user,
        parkings: userParkings || [],
      };
    },
  )
  .post(
    "/register-complete",
    async ({ body, jwt, cookie: { authToken, refreshToken }, set }) => {
      try {
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

        // Obtener los parkings del usuario
        const userParkings = await db.user.getUserParkings(result.user.id);

        return {
          token: accessJWTToken,
          user: result.user,
          parkings: userParkings || [],
        };
      } catch (error) {
        console.error("Error en registro completo:", error);
        set.status = "Internal Server Error";
        throw new Error("Error al realizar el registro completo");
      }
    },
    {
      body: CompleteRegistrationSchema,
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
      message: "Logout successfully",
    };
  })
  .get("/me", async ({ user, jwt }) => {
    if (!user) {
      throw new Error("User not authenticated");
    }

    // Get user parkings
    const userParkings = await db.user.getUserParkings(user.id);

    // Generate a fresh token
    const accessJWTToken = await jwt.sign({
      sub: user.id,
      exp: getExpTimestamp(ACCESS_TOKEN_EXP),
    });

    return {
      token: accessJWTToken,
      user: user,
      parkings: userParkings || [],
    };
  });
