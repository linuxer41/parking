import { Parking, ParkingCreate, ParkingUpdate } from "../../models/parking";
import { BaseCrud } from "./base-crud";

class ParkingCrud extends BaseCrud<Parking, ParkingCreate, ParkingUpdate> {
  constructor() {
    super("t_parking", "p");
  }
  
  /**
   * Get detailed parking information including areas, availability statistics
   * @param parkingId ID of the parking
   * @param userId Optional user ID to check ownership
   * @returns Detailed parking information
   */
  async getDetailed(id: string, userId?: string) {
    const sql = `
WITH area_stats AS (
  SELECT 
    a.id as "areaId",
    COUNT(e.id) FILTER (WHERE e."type" = 'spot' AND e."deletedAt" IS NULL) as "totalSpots",
    COUNT(e.id) FILTER (WHERE e."type" = 'spot' AND e."deletedAt" IS NULL AND occ."status" = 'available') as "availableSpots"
  FROM t_area a
  LEFT JOIN t_element e ON e."areaId" = a.id AND e."deletedAt" IS NULL
  LEFT JOIN v_element_occupancy occ ON occ."elementId" = e.id
  WHERE a."parkingId" = $1 AND a."deletedAt" IS NULL
  GROUP BY a.id
),
parking_stats AS (
  SELECT 
    p.id as "parkingId",
    COUNT(e.id) FILTER (WHERE e."type" = 'spot' AND e."deletedAt" IS NULL) as "totalSpots",
    COUNT(e.id) FILTER (WHERE e."type" = 'spot' AND e."deletedAt" IS NULL AND occ."status" = 'available') as "availableSpots",
    COUNT(a.id) as "areaCount"
  FROM t_parking p
  LEFT JOIN t_area a ON a."parkingId" = p.id AND a."deletedAt" IS NULL
  LEFT JOIN t_element e ON (e."parkingId" = p.id OR e."areaId" = a.id) AND e."deletedAt" IS NULL
  LEFT JOIN v_element_occupancy occ ON occ."elementId" = e.id
  WHERE p.id = $1
  GROUP BY p.id
)
SELECT 
  p.*, 
  to_jsonb(u.*) as "owner",
  (
    SELECT json_agg(
      json_build_object(
        'id', a.id,
        'createdAt', a."createdAt",
        'updatedAt', a."updatedAt",
        'deletedAt', a."deletedAt",
        'name', a.name,
        'parkingId', a."parkingId",
        'elements', (
          SELECT json_agg(
            to_jsonb(e.*) || jsonb_build_object('occupancy', to_jsonb(occ))
          ) 
          FROM t_element e
          LEFT JOIN v_element_occupancy occ ON occ."elementId" = e.id
          WHERE e."areaId" = a.id AND e."deletedAt" IS NULL
        ),
        'totalSpots', ast."totalSpots",
        'occupiedSpots', (ast."totalSpots" - ast."availableSpots"),
        'availableSpots', ast."availableSpots"
      )
    )
    FROM t_area a
    JOIN area_stats ast ON ast."areaId" = a.id
    WHERE a."parkingId" = p.id AND a."deletedAt" IS NULL
  ) AS areas,
  (
    SELECT json_agg(
      to_jsonb(em.*) || jsonb_build_object(
        'name', eu.name,
        'email', eu.email,
        'phone', eu.phone
      )
    )
    FROM t_employee em
    INNER JOIN t_user eu ON eu.id = em."userId"
    WHERE em."parkingId" = p.id
  ) AS employees,
  CASE WHEN p."ownerId" = $2 THEN true ELSE false END as "isOwner",
  true as "isActive",
  ps."areaCount"::integer as "areaCount",
  ps."totalSpots"::integer as "totalSpots",
  (ps."totalSpots" - ps."availableSpots")::integer as "occupiedSpots",
  ps."availableSpots"::integer as "availableSpots"
FROM t_parking p
INNER JOIN t_user u ON u.id = p."ownerId"
JOIN parking_stats ps ON ps."parkingId" = p.id
WHERE p.id = $1`;
    
    const params = userId ? [id, userId] : [id, null];
    const res = await this.query<Parking>({ sql, params });
    const parking = res[0];
    return parking;
  }
}

export const parkingCrud = new ParkingCrud();
