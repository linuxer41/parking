import { PoolClient } from "pg";
import { getConnection } from "../connection";

export class BaseCrud<MainSchema extends {id: string; createdAt: string | Date; updatedAt: string | Date}, CreateSchema extends object, UpdateSchema extends object> {
  constructor(protected tableName: string) {}

  baseQuery(){
    return `SELECT ${this.tableName}.* FROM ${this.tableName}`;
  }

  async query<T extends object>({ sql, params = [] }: { sql: string, params: any[] }): Promise<T[]> {
    let conn: PoolClient|undefined;
    try {
      conn = await getConnection();
      const result = await conn.query<T>(sql, params);
      return result.rows;
    } catch (error) {
      console.error('Error al ejecutar la consulta:', this.tableName);
      throw error;
    }
    finally {
      conn?.release();
    }
  }

  async create({ data }: { data: CreateSchema }): Promise<MainSchema> {
    const columns = Object.keys(data).map((key) => `"${key}"`).join(', ');
    // check if is array to inser al jsonstring
    const values = Object.values(data).map((value) => typeof value === 'object' ? JSON.stringify(value) : value);
    const placeholders = values.map((_, i) => `$${i + 1}`).join(', ');
    const sql = `INSERT INTO ${this.tableName} (${columns}) VALUES (${placeholders}) RETURNING *`;
    const res = await this.query<MainSchema>({ sql, params: values });
    const model = await this.findUnique({ where: { id: res[0].id } as any });
    return model;
  }

  async findUnique({ where }: { where: Partial<MainSchema> }) {
    const conditions = Object.entries(where || {})
      .map(([key, value], i) => `${this.tableName}."${key}" = $${i + 1}`)
      .join(' AND ');
    const sql = `${this.baseQuery()} WHERE ${conditions} LIMIT 1`;
    const res = await this.query<MainSchema>({ sql, params: Object.values(where) });
    return res[0];
  }

  async findMany({ where = {} }: { where?: Partial<MainSchema> }): Promise<MainSchema[]> {
    const conditions = Object.entries(where || {})
      .map(([key, value], i) => `${this.tableName}."${key}" = $${i + 1}`)
      .join(' AND ');
    const sql = `${this.baseQuery()} ${conditions ? `WHERE ${conditions}` : ''}`;
    return this.query<MainSchema>({ sql, params: Object.values(where) });
  }

  async findFirst({ where = {} }: { where?: Partial<MainSchema> }): Promise<MainSchema | undefined> {
    const conditions = Object.entries(where || {})
      .map(([key, value], i) => `${this.tableName}."${key}" = $${i + 1}`)
      .join(' AND ');
    const sql = `${this.baseQuery()} ${conditions ? `WHERE ${conditions}` : ''} LIMIT 1`;
    const res = await this.query<MainSchema>({ sql, params: Object.values(where) });
    return res[0];
  }

  async update({ where, data }: { where: Partial<MainSchema>, data: UpdateSchema }): Promise<MainSchema> {
    const setClause = Object.keys(data)
      .map((key, i) => `"${key}" = $${i + 1}`)
      .join(', ');
    const conditions = Object.keys(where)
      .map((key, i) => `"${key}" = $${Object.keys(data).length + i + 1}`)
      .join(' AND ');
    const sql = `UPDATE ${this.tableName} SET ${setClause} WHERE ${conditions} RETURNING *`;
    const values = Object.values(data).map((value) => typeof value === 'object' ? JSON.stringify(value) : value);
    const res = await this.query<MainSchema>({ sql, params: [...values, ...Object.values(where)] });
    return res[0];
  }

  async delete({ where }: { where: Partial<MainSchema> }): Promise<MainSchema> {
    const conditions = Object.keys(where)
      .map((key, i) => `${this.tableName}."${key}" = $${i + 1}`)
      .join(' AND ');
    const sql = `DELETE FROM ${this.tableName} t WHERE ${conditions} RETURNING *`;
    const res = await this.query<MainSchema>({ sql, params: Object.values(where) });
    return res[0];
  }
}
