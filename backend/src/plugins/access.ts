import Elysia, { t } from "elysia";
import { db } from "../db";
import jwt from "@elysiajs/jwt";

const accessPlugin = new Elysia()
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

    const userId = jwtPayload.sub;
    const users = await db.user.find({ id: userId });
    const user = users[0];

    if (!user) {
      // handle error for user not found from the provided access token
      set.status = "Forbidden";
      throw new Error("Access token is invalid");
    }
    const parkingId = headers["parking-id"];
    if (!parkingId) {
      // handle error for parking id is not available
      set.status = "Unauthorized";
      throw new Error("Requiere un parking");
    }

    const parkings = await db.parking.findParkings({ id: parkingId });
    const parking = parkings[0];

    if (!parking) {
      // handle error for parking not found
      set.status = "Forbidden";
      throw new Error("El parking no existe");
    }

    // Verificar si el usuario es propietario del parking o es un empleado
    const isOwner = parking.ownerId === user.id;

    if (!isOwner) {
      // Si no es propietario, verificar si es empleado de este parking
      const employees = await db.employee.find({ 
        userId: user.id,
        parkingId: parking.id,
      });
      const employee = employees[0];

      if (!employee) {
        // handle error for employee not found
        set.status = "Forbidden";
        throw new Error("No tiene acceso a este parking");
      }
    }

    return {
      user,
      parking,
      // employee,
    };
  });

export { accessPlugin };
