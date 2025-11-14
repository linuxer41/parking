import { PoolClient } from "pg";
import { getConnection, withClient } from "../connection";
import { CashRegister, CashRegisterCreate, CashRegisterUpdate, CashRegisterCreateSchema, CashRegisterUpdateSchema } from "../../models/cash-register";
import { getSchemaValidator } from "elysia";

const TABLE_NAME = "t_cash_register";

// ===== CRUD OPERATIONS =====

/**
 * Crear un nuevo registro de caja
 */
export async function createCashRegister(input: CashRegisterCreate): Promise<CashRegister> {
  const validator = getSchemaValidator(CashRegisterCreateSchema);
  const data = validator.parse({
    ...input,
    id: crypto.randomUUID(),
    createdAt: new Date().toISOString(),
    // updatedAt: new Date().toISOString(),
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
    const res = await client.query<CashRegister>(query);
    return res.rows[0];
  });
}

/**
 * Buscar un registro de caja por ID
 */
export async function findCashRegisterById(id: string): Promise<CashRegister | undefined> {
  const query = {
    text: `SELECT * FROM ${TABLE_NAME} WHERE id = $1 LIMIT 1`,
    values: [id],
  };
  
  return withClient(async (client) => {
    const res = await client.query<CashRegister>(query);
    return res.rows[0];
  });
}

/**
 * Buscar registros de caja por criterios
 */
export async function findCashRegisters(where: Partial<CashRegister> = {}): Promise<CashRegister[]> {
  const conditions = Object.entries(where)
    .map(([key, value], i) => `"${key}" = $${i + 1}`)
    .join(" AND ");
  
  const query = {
    text: `SELECT * FROM ${TABLE_NAME} ${conditions ? `WHERE ${conditions}` : ""}`,
    values: Object.values(where),
  };
  
  return withClient(async (client) => {
    const res = await client.query<CashRegister>(query);
    return res.rows;
  });
}

/**
 * Actualizar un registro de caja
 */
export async function updateCashRegister(id: string, input: CashRegisterUpdate): Promise<CashRegister> {
  const validator = getSchemaValidator(CashRegisterUpdateSchema);
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
    const res = await client.query<CashRegister>(query);
    
    if (!res.rows || res.rows.length === 0) {
      throw new Error(`No se encontró el registro de caja con ID ${id} para actualizar`);
    }
    
    return res.rows[0];
  });
}

/**
 * Eliminar un registro de caja
 */
export async function deleteCashRegister(id: string): Promise<CashRegister> {
  const query = {
    text: `DELETE FROM ${TABLE_NAME} WHERE id = $1 RETURNING *`,
    values: [id],
  };
  
  return withClient(async (client) => {
    const res = await client.query<CashRegister>(query);
    
    if (!res.rows || res.rows.length === 0) {
      throw new Error(`No se encontró el registro de caja con ID ${id} para eliminar`);
    }
    
    return res.rows[0];
  });
}
