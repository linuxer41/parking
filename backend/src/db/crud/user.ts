import { ParkingSimple } from "../../models/parking";
import { User, UserCreate, UserUpdate } from "../../models/user";
import { BaseCrud } from "./base-crud";

class UserCrud extends BaseCrud<User, UserCreate, UserUpdate> {
  constructor() {
    super("t_user", "u");
  }

  baseQuery() {
    return `
select u.* 
from t_user u
`;
  }

  async getUserParkings(id: string): Promise<ParkingSimple[]> {
    // Primero obtenemos los datos base de los estacionamientos
    const sql = `
      WITH parking_stats AS (
        SELECT 
          p.id as "parkingId",
          COUNT(e.id) FILTER (WHERE e."type" = 'spot' AND e."deletedAt" IS NULL) as "totalSpots",
          COUNT(e.id) FILTER (WHERE e."type" = 'spot' AND e."deletedAt" IS NULL AND occ."status" = 'available') as "availableSpots",
          COUNT(a.id) as "areaCount"
        FROM t_parking p
        LEFT JOIN t_area a ON a."parkingId" = p.id AND a."deletedAt" IS NULL
        LEFT JOIN t_element e ON (e."parkingId" = p.id OR e."areaId" = a.id) AND e."deletedAt" IS NULL
        LEFT JOIN v_element_occupancy occ ON occ."elementId" = e.id
        WHERE (p."ownerId" = $1 OR EXISTS (SELECT 1 FROM t_employee emp WHERE emp."parkingId" = p.id AND emp."userId" = $1))
        AND p."deletedAt" IS NULL
        GROUP BY p.id
      )
      SELECT 
        p.id,
        p.name,
        p.phone,
        p.address,
        p.email,
        p."logoUrl",
        p.rates,
        p.params,
        p."operationMode",
        p.capacity,
        CASE WHEN p."ownerId" = $1 THEN true ELSE false END as "isOwner",
        true as "isActive",
        p.status,
        ps."areaCount"::INTEGER as "areaCount",
        ps."totalSpots"::INTEGER as "totalSpots",
        (ps."totalSpots" - ps."availableSpots")::INTEGER as "occupiedSpots",
        ps."availableSpots"::INTEGER as "availableSpots"
      FROM t_parking p
      JOIN parking_stats ps ON ps."parkingId" = p.id
      WHERE (p."ownerId" = $1
      OR EXISTS (SELECT 1 FROM t_employee e WHERE e."parkingId" = p.id AND e."userId" = $1))
      AND p."deletedAt" IS NULL
      GROUP BY p.id, p.name, p.phone, p.address, p.email, p."logoUrl", p."ownerId", p.status, p.rates, p.params,
               ps."areaCount", ps."totalSpots", ps."availableSpots", p."operationMode", p.capacity
    `;
    const results = await this.query<ParkingSimple>({ sql, params: [id] });
    return results;
  }
}

export const userCrud = new UserCrud();
