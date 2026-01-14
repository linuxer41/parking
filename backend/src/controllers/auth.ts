import { jwt } from "@elysiajs/jwt";
import { Elysia } from "elysia";
import {
  ACCESS_TOKEN_EXP,
  JWT_NAME,
  REFRESH_TOKEN_EXP,
} from "../config/constants";
import { db } from "../db";
import { AuthResponseSchema, loginBodySchema, RegistrationSchema, PasswordResetRequestSchema, PasswordResetConfirmSchema } from "../models/auth";
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
  .post(
    "/request-password-reset",
    async ({ body }) => {
      // Find user by email
      const users = await db.user.find({ email: body.email });
      const user = users[0];

      if (!user) {
        // Don't reveal if email exists or not for security
        return { message: "Si el correo existe, se ha enviado un código de verificación" };
      }

      // Delete any existing unused tokens for this user
      await db.passwordResetToken.deleteByUserId(user.id);

      // Generate 6-digit code
      const token = Math.floor(100000 + Math.random() * 900000).toString();

      // Set expiration to 15 minutes from now
      const expiresAt = new Date(Date.now() + 15 * 60 * 1000).toISOString();

      // Create token record
      await db.passwordResetToken.create({
        id: crypto.randomUUID(),
        userId: user.id,
        token,
        expiresAt,
        createdAt: new Date().toISOString(),
      });

      // Send email (for now, just log it)
      console.log(`[PASSWORD RESET] Código para ${body.email}: ${token}`);

      // In production, send actual email here
      // await sendPasswordResetEmail(body.email, token);

      return { message: "Si el correo existe, se ha enviado un código de verificación" };
    },
    {
      body: PasswordResetRequestSchema,
    },
  )
  .post(
    "/reset-password",
    async ({ body }) => {
      // Find valid token
      const resetToken = await db.passwordResetToken.findByToken(body.token);

      if (!resetToken) {
        throw new UnauthorizedError("Código inválido o expirado");
      }

      // Find user
      const users = await db.user.find({ id: resetToken.userId });
      const user = users[0];

      if (!user) {
        throw new UnauthorizedError("Usuario no encontrado");
      }

      // Verify email matches
      if (user.email !== body.email) {
        throw new UnauthorizedError("El correo no coincide con el código");
      }

      // Hash new password
      const newPasswordHash = await Bun.password.hash(body.newPassword);

      // Update user password
      await db.user.updatePassword(user.id, newPasswordHash);

      // Mark token as used
      await db.passwordResetToken.markAsUsed(resetToken.id);

      return { message: "Contraseña actualizada exitosamente" };
    },
    {
      body: PasswordResetConfirmSchema,
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
