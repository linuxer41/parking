import { PoolClient } from "pg";
import { getConnection, withClient } from "../connection";
import { 
  Parking, ParkingCreate, ParkingUpdate, ParkingCreateSchema, ParkingUpdateSchema, ParkingCreateRequest, ParkingUpdateRequest, ParkingResponse, ParkingDetailedResponse,
  Area, AreaCreate, AreaUpdate, AreaCreateSchema, AreaUpdateSchema, AreaCreateRequest, AreaUpdateRequest, AreaResponse,
  Element, ElementCreate, ElementUpdate, ElementCreateSchema, ElementUpdateSchema, ElementCreateRequest, ElementUpdateRequest, ElementResponse
} from "../../models/parking";
import { getSchemaValidator } from "elysia";

const TABLE_NAME = "t_parking";
const AREA_TABLE_NAME = "t_area";
const ELEMENT_TABLE_NAME = "t_element";

// ===== CRUD OPERATIONS =====

/**
 * Crear un nuevo parking
 */
export async function createParking(input: ParkingCreateRequest): Promise<Parking> {
  const validator = getSchemaValidator(ParkingCreateSchema);
  const data = validator.parse({
    ...input,
  });

  const columns = Object.keys(data)
    .map((key) => `"${key}"`)
    .join(", ");

  const values = Object.values(data).map((value) =>
    typeof value === "object" ? JSON.stringify(value) : value,
  );

  const placeholders = values.map((_, i) => `$${i + 1}`).join(", ");
  
  const query = {
    text: `INSERT INTO ${TABLE_NAME} (${columns}) VALUES (${placeholders}) RETURNING *`,
    values: values,
  };
  
  return withClient(async (client) => {
    const res = await client.query<Parking>(query);
    return res.rows[0];
  });
}

/**
 * Buscar un parking por ID
 */
export async function findParkingById(id: string): Promise<Parking | undefined> {
  const query = {
    text: `SELECT * FROM ${TABLE_NAME} WHERE id = $1 LIMIT 1`,
    values: [id],
  };
  
  return withClient(async (client) => {
    const res = await client.query<Parking>(query);
    return res.rows[0];
  });
}

/**
 * Buscar parkings por criterios
 */
export async function findParkings(where: Partial<Parking> = {}): Promise<Parking[]> {
  const conditions = Object.entries(where)
    .map(([key, value], i) => `"${key}" = $${i + 1}`)
    .join(" AND ");
  
  const query = {
    text: `SELECT * FROM ${TABLE_NAME} ${conditions ? `WHERE ${conditions}` : ""}`,
    values: Object.values(where),
  };
  
  return withClient(async (client) => {
    const res = await client.query<Parking>(query);
    return res.rows;
  });
}

/**
 * Actualizar un parking
 */
export async function updateParking(id: string, input: ParkingUpdateRequest): Promise<Parking> {
  const validator = getSchemaValidator(ParkingUpdateSchema);
  const data = validator.parse(input);
  
  const setClause = Object.keys(data)
    .map((key, i) => `"${key}" = $${i + 1}`)
    .join(", ");

  const values = Object.values(data).map((value) =>
    typeof value === "object" ? JSON.stringify(value) : value,
  );
  
  const query = {
    text: `UPDATE ${TABLE_NAME} SET ${setClause}, "updatedAt" = NOW() WHERE id = $${Object.keys(data).length + 1} RETURNING *`,
    values: [...values, id],
  };
  
  return withClient(async (client) => {
    const res = await client.query<Parking>(query);
    
    if (!res.rows || res.rows.length === 0) {
      throw new Error(`No se encontró el parking con ID ${id} para actualizar`);
    }
    
    return res.rows[0];
  });
}

/**
 * Eliminar un parking
 */
export async function deleteParking(id: string): Promise<Parking> {
  const query = {
    text: `DELETE FROM ${TABLE_NAME} WHERE id = $1 RETURNING *`,
    values: [id],
  };
  
  return withClient(async (client) => {
    const res = await client.query<Parking>(query);
    
    if (!res.rows || res.rows.length === 0) {
      throw new Error(`No se encontró el parking con ID ${id} para eliminar`);
    }
    
    return res.rows[0];
  });
}

export async function findParkingsByOwnerId(ownerId: string): Promise<ParkingResponse[]> {
  const sql = `
  WITH parking_stats AS (
    SELECT 
      p.id as "parkingId",
      COUNT(e.id) FILTER (WHERE e."type" = 'spot' AND e."deletedAt" IS NULL) as "totalSpots",
      COUNT(e.id) FILTER (WHERE e."type" = 'spot' AND e."deletedAt" IS NULL) as "availableSpots",
      COUNT(a.id) as "areaCount"
    FROM t_parking p
    LEFT JOIN t_area a ON a."parkingId" = p.id AND a."deletedAt" IS NULL
    LEFT JOIN t_element e ON (e."parkingId" = p.id OR e."areaId" = a.id) AND e."deletedAt" IS NULL
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
    p.location,
    p."operationMode",
    p.status,
    CASE WHEN p."ownerId" = $1 THEN true ELSE false END as "isOwner",
    true as "isActive",
    ps."areaCount"::INTEGER as "areaCount",
    ps."totalSpots"::INTEGER as "totalSpots",
    (ps."totalSpots" - ps."availableSpots")::INTEGER as "occupiedSpots",
    ps."availableSpots"::INTEGER as "availableSpots"
  FROM t_parking p
  JOIN parking_stats ps ON ps."parkingId" = p.id
  WHERE (p."ownerId" = $1
  OR EXISTS (SELECT 1 FROM t_employee e WHERE e."parkingId" = p.id AND e."userId" = $1))
  AND p."deletedAt" IS NULL
`;
 const query = {
  text: sql,
  values: [ownerId],
 };
  return withClient(async (client) => {
    const res = await client.query<ParkingResponse>(query);
    return res.rows;
  });
}

export async function getDetailedParking(id: string, userId: string): Promise<ParkingDetailedResponse> {
  const sql = `
WITH area_stats AS (
  SELECT 
    a.id as "areaId",
    COUNT(e.id) FILTER (WHERE e."type" = 'spot' AND e."deletedAt" IS NULL) as "totalSpots",
    COUNT(e.id) FILTER (WHERE e."type" = 'spot' AND e."deletedAt" IS NULL) as "availableSpots"
  FROM t_area a
  LEFT JOIN t_element e ON e."areaId" = a.id AND e."deletedAt" IS NULL
  WHERE a."parkingId" = $1 AND a."deletedAt" IS NULL
  GROUP BY a.id
),
parking_stats AS (
  SELECT 
    p.id as "parkingId",
    COUNT(e.id) FILTER (WHERE e."type" = 'spot' AND e."deletedAt" IS NULL) as "totalSpots",
    COUNT(e.id) FILTER (WHERE e."type" = 'spot' AND e."deletedAt" IS NULL) as "availableSpots",
    COUNT(a.id) as "areaCount"
  FROM t_parking p
  LEFT JOIN t_area a ON a."parkingId" = p.id AND a."deletedAt" IS NULL
  LEFT JOIN t_element e ON (e."parkingId" = p.id OR e."areaId" = a.id) AND e."deletedAt" IS NULL
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
             jsonb_build_object(
               'id', e.id,
               'name', e.name,
               'type', e."type",
               'status', 'free',
               'subType', e."subType",
               'description', 'e."description"',
               'rotation', e."rotation",
               'scale', e."scale",
               'isActive', e."isActive",
               'posX', e."posX",
               'posY', e."posY",
               'posZ', e."posZ",
               'entry', occ.entry,
               'subscription', occ.subscription,
               'booking', occ.booking
             )
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
 const query = {
  text: sql,
  values: [id, userId],
 };
  return withClient(async (client) => {
    const res = await client.query<ParkingDetailedResponse>(query);
    console.log("res", res.rows[0]);
    return res.rows[0];
  });
}

// ===== CRUD OPERATIONS FOR AREA =====

/**
 * Crear un nuevo área
 */
export async function createArea(input: AreaCreateRequest, parkingId: string): Promise<AreaResponse> {
  const validator = getSchemaValidator(AreaCreateSchema);
  const data = validator.parse({
    ...input,
    parkingId,
  });

  const columns = Object.keys(data)
    .map((key) => `"${key}"`)
    .join(", ");

  const values = Object.values(data).map((value) =>
    typeof value === "object" ? JSON.stringify(value) : value,
  );

  const placeholders = values.map((_, i) => `$${i + 1}`).join(", ");
  
  const query = {
    text: `INSERT INTO ${AREA_TABLE_NAME} (${columns}) VALUES (${placeholders}) RETURNING *`,
    values: values,
  };
  
  return withClient(async (client) => {
    const res = await client.query<AreaResponse>(query);
    return res.rows[0];
  });
}

/**
 * Buscar un área por ID
 */
export async function findAreaById(id: string): Promise<AreaResponse | undefined> {
  const query = {
    text: `SELECT * FROM ${AREA_TABLE_NAME} WHERE id = $1 AND "deletedAt" IS NULL LIMIT 1`,
    values: [id],
  };
  
  return withClient(async (client) => {
    const res = await client.query<AreaResponse>(query);
    return res.rows[0];
  });
}

/**
 * Buscar áreas por parking ID
 */
export async function findAreasByParkingId(parkingId: string): Promise<AreaResponse[]> {
  const sql = `
    WITH area_stats AS (
      SELECT 
        a.id as "areaId",
        COUNT(e.id) FILTER (WHERE e."type" = 'spot' AND e."deletedAt" IS NULL) as "totalSpots",
        COUNT(e.id) FILTER (WHERE e."type" = 'spot' AND e."deletedAt" IS NULL) as "availableSpots"
      FROM t_area a
      LEFT JOIN t_element e ON e."areaId" = a.id AND e."deletedAt" IS NULL
      WHERE a."parkingId" = $1 AND a."deletedAt" IS NULL
      GROUP BY a.id
    )
    SELECT 
      a.id,
      a.name,
      ast."totalSpots"::INTEGER as "totalSpots",
      (ast."totalSpots" - ast."availableSpots")::INTEGER as "occupiedSpots",
      ast."availableSpots"::INTEGER as "availableSpots",
      (
        SELECT json_agg(
          to_jsonb(e.*)
        ) 
        FROM t_element e
        WHERE e."areaId" = a.id AND e."deletedAt" IS NULL
      ) as elements
    FROM t_area a
    JOIN area_stats ast ON ast."areaId" = a.id
    WHERE a."parkingId" = $1 AND a."deletedAt" IS NULL
  `;
  
  const query = {
    text: sql,
    values: [parkingId],
  };
  
  return withClient(async (client) => {
    const res = await client.query<AreaResponse>(query);
    return res.rows;
  });
}

/**
 * Actualizar un área
 */
export async function updateArea(id: string, input: AreaUpdateRequest): Promise<AreaResponse> {
  const validator = getSchemaValidator(AreaUpdateSchema);
  const data = validator.parse(input);
  
  const setClause = Object.keys(data)
    .map((key, i) => `"${key}" = $${i + 1}`)
    .join(", ");

  const values = Object.values(data).map((value) =>
    typeof value === "object" ? JSON.stringify(value) : value,
  );
  
  const query = {
    text: `UPDATE ${AREA_TABLE_NAME} SET ${setClause}, "updatedAt" = NOW() WHERE id = $${Object.keys(data).length + 1} AND "deletedAt" IS NULL RETURNING *`,
    values: [...values, id],
  };
  
  return withClient(async (client) => {
    const res = await client.query<AreaResponse>(query);
    
    if (!res.rows || res.rows.length === 0) {
      throw new Error(`No se encontró el área con ID ${id} para actualizar`);
    }
    
    return res.rows[0];
  });
}

/**
 * Eliminar un área
 */
export async function deleteArea(id: string): Promise<AreaResponse> {
  const query = {
    text: `UPDATE ${AREA_TABLE_NAME} SET "deletedAt" = NOW() WHERE id = $1 AND "deletedAt" IS NULL RETURNING *`,
    values: [id],
  };
  
  return withClient(async (client) => {
    const res = await client.query<AreaResponse>(query);
    
    if (!res.rows || res.rows.length === 0) {
      throw new Error(`No se encontró el área con ID ${id} para eliminar`);
    }
    
    return res.rows[0];
  });
}

// ===== CRUD OPERATIONS FOR ELEMENT =====

/**
 * Crear un nuevo elemento
 */
export async function createElement(input: ElementCreateRequest): Promise<ElementResponse> {
  const validator = getSchemaValidator(ElementCreateSchema);
  const data = validator.parse({
    ...input,
  });

  const columns = Object.keys(data)
    .map((key) => `"${key}"`)
    .join(", ");

  const values = Object.values(data).map((value) =>
    typeof value === "object" ? JSON.stringify(value) : value,
  );

  const placeholders = values.map((_, i) => `$${i + 1}`).join(", ");
  
  const query = {
    text: `INSERT INTO ${ELEMENT_TABLE_NAME} (${columns}) VALUES (${placeholders}) RETURNING *`,
    values: values,
  };
  
  return withClient(async (client) => {
    const res = await client.query<ElementResponse>(query);
    return res.rows[0];
  });
}

/**
 * Buscar un elemento por ID
 */
export async function findElementById(id: string): Promise<ElementResponse | undefined> {
  const sql = `
    SELECT 
      e.*,
      occ.entry,
      occ.subscription,
      occ.booking
    FROM t_element e
    LEFT JOIN v_element_occupancy occ ON occ."elementId" = e.id
    WHERE e.id = $1 AND e."deletedAt" IS NULL
    LIMIT 1
  `;
  
  const query = {
    text: sql,
    values: [id],
  };
  
  return withClient(async (client) => {
    const res = await client.query<ElementResponse>(query);
    return res.rows[0];
  });
}

/**
 * Buscar elementos por área ID
 */
export async function findElementsByAreaId(areaId: string): Promise<ElementResponse[]> {
  const sql = `
    SELECT 
      e.*,
      occ.entry,
      occ.subscription,
      occ.booking
    FROM t_element e
    LEFT JOIN v_element_occupancy occ ON occ."elementId" = e.id
    WHERE e."areaId" = $1 AND e."deletedAt" IS NULL
    ORDER BY e.name
  `;
  
  const query = {
    text: sql,
    values: [areaId],
  };
  
  return withClient(async (client) => {
    const res = await client.query<ElementResponse>(query);
    return res.rows;
  });
}

/**
 * Buscar elementos por parking ID
 */
export async function findElementsByParkingId(parkingId: string): Promise<ElementResponse[]> {
  const sql = `
    SELECT 
      e.*,
      occ.entry,
      occ.subscription,
      occ.booking
    FROM t_element e
    LEFT JOIN v_element_occupancy occ ON occ."elementId" = e.id
    WHERE e."parkingId" = $1 AND e."deletedAt" IS NULL
    ORDER BY e.name
  `;
  
  const query = {
    text: sql,
    values: [parkingId],
  };
  
  return withClient(async (client) => {
    const res = await client.query<ElementResponse>(query);
    return res.rows;
  });
}

/**
 * Actualizar un elemento
 */
export async function updateElement(id: string, input: ElementUpdateRequest): Promise<ElementResponse> {
  const validator = getSchemaValidator(ElementUpdateSchema);
  const data = validator.parse(input);
  
  const setClause = Object.keys(data)
    .map((key, i) => `"${key}" = $${i + 1}`)
    .join(", ");

  const values = Object.values(data).map((value) =>
    typeof value === "object" ? JSON.stringify(value) : value,
  );
  
  const query = {
    text: `UPDATE ${ELEMENT_TABLE_NAME} SET ${setClause}, "updatedAt" = NOW() WHERE id = $${Object.keys(data).length + 1} AND "deletedAt" IS NULL RETURNING *`,
    values: [...values, id],
  };
  
  return withClient(async (client) => {
    const res = await client.query<ElementResponse>(query);
    
    if (!res.rows || res.rows.length === 0) {
      throw new Error(`No se encontró el elemento con ID ${id} para actualizar`);
    }
    
    return res.rows[0];
  });
}

/**
 * Eliminar un elemento
 */
export async function deleteElement(id: string): Promise<ElementResponse> {
  const query = {
    text: `UPDATE ${ELEMENT_TABLE_NAME} SET "deletedAt" = NOW() WHERE id = $1 AND "deletedAt" IS NULL RETURNING *`,
    values: [id],
  };
  
  return withClient(async (client) => {
    const res = await client.query<ElementResponse>(query);
    
    if (!res.rows || res.rows.length === 0) {
      throw new Error(`No se encontró el elemento con ID ${id} para eliminar`);
    }
    
    return res.rows[0];
  });
}
