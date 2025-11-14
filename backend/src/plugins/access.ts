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

    const userId = jwtPayload.sub as string;
    const tenant = jwtPayload.tenant as string | null;
    const employees = jwtPayload.employees as Array<{ id: string; parkingId: string; role: string }> | undefined;
    const scope = jwtPayload.scope as string;

    const users = await db.user.find({ id: userId });
    const user = users[0];

    if (!user) {
      // handle error for user not found from the provided access token
      set.status = "Forbidden";
      throw new Error("Access token is invalid");
    }

    let parkingId = headers["parking-id"] as string | undefined;

    // If tenant is set in JWT, use it as parkingId
    if (tenant) {
      parkingId = tenant;
    }

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

    // Validate access based on scope and employees
    if (scope === "admin-central") {
      // Admin can access any parking they own or have employees in
      const isOwner = parking.ownerId === user.id;
      const hasEmployee = employees?.some(emp => emp.parkingId === parkingId);

      if (!isOwner && !hasEmployee) {
        set.status = "Forbidden";
        throw new Error("No tiene acceso a este parking");
      }
    } else if (scope === "employee") {
      // Employee scope: check if they have an active employee record for this parking
      const employee = employees?.find(emp => emp.parkingId === parkingId);
      if (!employee) {
        set.status = "Forbidden";
        throw new Error("No tiene acceso a este parking");
      }
    } else {
      set.status = "Forbidden";
      throw new Error("Scope no válido");
    }

    return {
      user,
      parking,
      employees: employees || [],
      scope,
    };
  });

export { accessPlugin };
