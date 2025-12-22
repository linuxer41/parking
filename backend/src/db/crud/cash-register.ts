import { PoolClient } from "pg";
import { getConnection, withClient } from "../connection";
import { CashRegister, CashRegisterCreate, CashRegisterUpdate, CashRegisterCreateSchema, CashRegisterUpdateSchema, CashRegisterResponse } from "../../models/cash-register";
import { getSchemaValidator } from "elysia";

class CashRegisterCrud {
  private TABLE_NAME = "t_cash_register";

  async create(input: CashRegisterCreate): Promise<CashRegisterResponse> {
    const validator = getSchemaValidator(CashRegisterCreateSchema);
    const validatedInput = validator.parse(input);
    const data = {
      ...validatedInput,
      id: crypto.randomUUID(),
      createdAt: new Date().toISOString(),

    };

    const columns = Object.keys(data)
      .map((key) => `"${key}"`)
      .join(", ");

    const values = Object.values(data).map((value) =>
      typeof value === "object" ? JSON.stringify(value) : value,
    );

    const placeholders = values.map((_, i) => `$${i + 1}`).join(", ");

    const query = {
      text: `INSERT INTO ${this.TABLE_NAME} (${columns}) VALUES (${placeholders}) RETURNING id`,
      values: values,
    };

    return withClient(async (client) => {
      const res = await client.query(query);
      const id = res.rows[0].id;
      const result = await this.getById(id);
      if (!result) {
        throw new Error(`Failed to retrieve created cash register with ID ${id}`);
      }
      return result;
    });
  }

  /**
   * Buscar un registro de caja por ID
   */
  async getById(id: string): Promise<CashRegisterResponse | undefined> {
    const sql = `
      SELECT
        cr."id", cr."createdAt", cr."updatedAt", cr."deletedAt", cr."number", cr."parkingId", cr."employeeId", cr."startDate", cr."endDate", cr."initialAmount", cr."status", cr."comment", cr."observation",
        json_build_object(
          'id', e."id",
          'role', e."role",
          'name', u."name",
          'email', u."email",
          'phone', u."phone"
        ) as employee,
        COALESCE((
          SELECT SUM(CASE WHEN m."type" = 'income' THEN m."amount" WHEN m."type" = 'expense' THEN -m."amount" ELSE 0 END)
          FROM t_movement m
          WHERE m."cashRegisterId" = cr."id" AND m."deletedAt" IS NULL
        ), 0) as "totalAmount"
      FROM ${this.TABLE_NAME} cr
      INNER JOIN t_employee e ON e."id" = cr."employeeId"
      INNER JOIN t_user u ON u."id" = e."userId"
      WHERE cr."id" = $1 AND cr."deletedAt" IS NULL
      LIMIT 1
    `;

    const query = {
      text: sql,
      values: [id],
    };

    return withClient(async (client) => {
      const res = await client.query<CashRegisterResponse>(query);
      return res.rows[0];
    });
  }

  /**
   * Buscar registros de caja por criterios
   */
  async find(where: Partial<CashRegister> = {}): Promise<CashRegisterResponse[]> {
    const conditions = Object.entries(where)
      .filter(([key]) => key !== 'employee') // Exclude nested objects from WHERE
      .map(([key, value], i) => `cr."${key}" = $${i + 1}`)
      .join(" AND ");

    const sql = `
      SELECT
        cr."id", cr."createdAt", cr."updatedAt", cr."deletedAt", cr."number", cr."parkingId", cr."employeeId", cr."startDate", cr."endDate", cr."initialAmount", cr."status", cr."comment", cr."observation",
        json_build_object(
          'id', e."id",
          'role', e."role",
          'name', u."name",
          'email', u."email",
          'phone', u."phone"
        ) as employee,
        COALESCE((
          SELECT SUM(CASE WHEN m."type" = 'income' THEN m."amount" WHEN m."type" = 'expense' THEN -m."amount" ELSE 0 END)
          FROM t_movement m
          WHERE m."cashRegisterId" = cr."id" AND m."deletedAt" IS NULL
        ), 0) as "totalAmount"
      FROM ${this.TABLE_NAME} cr
      INNER JOIN t_employee e ON e."id" = cr."employeeId"
      INNER JOIN t_user u ON u."id" = e."userId"
      ${conditions ? `WHERE ${conditions} AND cr."deletedAt" IS NULL` : 'WHERE cr."deletedAt" IS NULL'}
    `;

    const query = {
      text: sql,
      values: Object.values(where).filter((_, i) => !['employee'].includes(Object.keys(where)[i])),
    };

    return withClient(async (client) => {
      const res = await client.query<CashRegisterResponse>(query);
      return res.rows;
    });
  }

  /**
   * Actualizar un registro de caja
   */
  async update(id: string, input: CashRegisterUpdate): Promise<CashRegisterResponse> {
    const validator = getSchemaValidator(CashRegisterUpdateSchema);
    const data = validator.parse(input);

    const setClause = Object.keys(data)
      .map((key, i) => `"${key}" = $${i + 1}`)
      .join(", ");

    const values = Object.values(data).map((value) =>
      value !== null && typeof value === "object" ? JSON.stringify(value) : value,
    );

    const query = {
      text: `UPDATE ${this.TABLE_NAME} SET ${setClause}, "updatedAt" = NOW() WHERE id = $${Object.keys(data).length + 1} RETURNING id`,
      values: [...values, id],
    };

    return withClient(async (client) => {
      const res = await client.query(query);

      if (!res.rows || res.rows.length === 0) {
        throw new Error(`No se encontró el registro de caja con ID ${id} para actualizar`);
      }

      const result = await this.getById(id);
      if (!result) {
        throw new Error(`Failed to retrieve updated cash register with ID ${id}`);
      }
      return result;
    });
  }

  /**
   * Eliminar un registro de caja
   */
  async delete(id: string): Promise<CashRegisterResponse> {
    // First fetch the record before deleting
    const record = await this.getById(id);
    if (!record) {
      throw new Error(`No se encontró el registro de caja con ID ${id} para eliminar`);
    }

    const query = {
      text: `DELETE FROM ${this.TABLE_NAME} WHERE id = $1`,
      values: [id],
    };

    return withClient(async (client) => {
      await client.query(query);
      return record;
    });
  }
}

export const cashRegisterCrud = new CashRegisterCrud();
