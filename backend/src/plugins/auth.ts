import jwt from "@elysiajs/jwt";
import Elysia from "elysia";
import { JWT_NAME } from "../config/constants";
import { db } from "../db";

const authPlugin = new Elysia()
  .use(
    jwt({
      name: "jwt",
      secret: Bun.env.JWT_SECRET!,
    }),
  )
  .derive(
    { as: "scoped" },
    async ({ headers, jwt, cookie: { authToken }, set }) => {
      let _authToken = authToken.value || headers.authorization?.split(" ")[1];
      if (!_authToken) {
        // handle error for access token is not available
        set.status = "Unauthorized";
        throw new Error("Access token is missing");
      }
      const jwtPayload = await jwt.verify(_authToken);
      if (!jwtPayload) {
        // handle error for access token is tempted or incorrect
        set.status = "Forbidden";
        throw new Error("Access token is invalid");
      }

      const userId = jwtPayload.sub;
      const user = await db.user.findUnique({
        where: {
          id: userId,
        },
      });

      if (!user) {
        // handle error for user not found from the provided access token
        set.status = "Forbidden";
        throw new Error("Access token is invalid");
      }

      const employee = await db.employee.findUnique({
        where: {
          userId: userId,
        },
      });

      if (!employee) {
        // handle error for employee not found from the provided access token
        set.status = "Forbidden";
        throw new Error("Employee not found");
      }

      return {
        user,
        employee,
      };
    },
  );

export { authPlugin };
