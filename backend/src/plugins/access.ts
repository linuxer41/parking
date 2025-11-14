import Elysia, { t } from "elysia";
import { db } from "../db";
import jwt from "@elysiajs/jwt";

const authPlugin = new Elysia()
  .use(
    jwt({
      name: "jwt",
      secret: Bun.env.JWT_SECRET!,
    }),
  )
  .derive({ as: "scoped" }, async ({ headers, jwt, set }) => {
    let _authToken = headers.authorization?.split(" ")[1];
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

    const userId = jwtPayload.sub as string;
    const tenant = jwtPayload.tenant as string;
    const employeeId = jwtPayload.employee as string;
    const scope = jwtPayload.scope as string;

    const users = await db.user.find({ id: userId });
    const user = users[0];

    if (!user) {
      // handle error for user not found from the provided access token
      set.status = "Forbidden";
      throw new Error("Access token is invalid");
    }


    const parkings = await db.parking.findParkings({ id: tenant });
    const parking = parkings[0];

    if (!parking) {
      // handle error for parking not found
      set.status = "Forbidden";
      throw new Error("El parking no existe");
    }

    // Validate access based on scope and employees
    if (scope === "app") {
      // Admin can access any parking they own or have employees in
      
    } else {
      set.status = "Forbidden";
      throw new Error("Scope no válido");
    }

    return {
      user,
      parking,
      employee: {
        id: employeeId,
        role: jwtPayload.role,
        parkingId: tenant,
      },
      scope,
    };
  });

export { authPlugin };
