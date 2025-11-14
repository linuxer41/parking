  import jwt from "@elysiajs/jwt";
  import Elysia from "elysia";
  import { JWT_NAME } from "../config/constants";
  import { db } from "../db";
import { UnauthorizedError } from "../utils/error";

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
          set.status = 401;
          throw new UnauthorizedError("El token de acceso es requerido");
        }
        const jwtPayload = await jwt.verify(_authToken);
        if (!jwtPayload) {
          // handle error for access token is tempted or incorrect
          set.status = 403;
          throw new UnauthorizedError("El token de acceso es inválido");
        }

        const userId = (jwtPayload as any).sub;
        const users = await db.user.find({ id: userId });
        const user = users[0];

        if (!user) {
          // handle error for user not found from the provided access token
          set.status = 403;
          throw new UnauthorizedError("El usuario no existe");
        }

        const employees = await db.employee.find({ userId: userId });
        const employee = employees[0];
        if (!employee) {
          // handle error for employee not found from the provided access token
          set.status = 403;
          throw new UnauthorizedError("El usuario no tiene un cargo en el parking");
        }
        const parking = await db.parking.findParkingById(employee.parkingId);
        if (!parking) {
          // handle error for parking not found from the provided access token
          set.status = 403;
          throw new UnauthorizedError("El usuario no tiene un cargo en el parking");
        }



        return {
          user,
          employee,
          parking: parking,
        };
      },
    );

  export { authPlugin };
