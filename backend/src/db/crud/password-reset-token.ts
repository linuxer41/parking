import { withClient } from "../connection";
import { PasswordResetToken, PasswordResetTokenCreate } from "../../models/password-reset-token";

export const passwordResetTokenCrud = {
  async create(data: PasswordResetTokenCreate): Promise<PasswordResetToken> {
    const query = `
      INSERT INTO t_password_reset_token ("id", "userId", "token", "expiresAt", "createdAt")
      VALUES ($1, $2, $3, $4, $5)
      RETURNING *;
    `;
    const values = [
      data.id,
      data.userId,
      data.token,
      data.expiresAt,
      data.createdAt || new Date().toISOString(),
    ];

    return withClient(async (client) => {
      const result = await client.query(query, values);
      return result.rows[0];
    });
  },

  async findByToken(token: string): Promise<PasswordResetToken | null> {
    const query = `
      SELECT * FROM t_password_reset_token
      WHERE token = $1 AND used = false AND "expiresAt" > NOW() AND "deletedAt" IS NULL
      LIMIT 1;
    `;
    return withClient(async (client) => {
      const result = await client.query(query, [token]);
      return result.rows[0] || null;
    });
  },

  async findByUserId(userId: string): Promise<PasswordResetToken[]> {
    const query = `
      SELECT * FROM t_password_reset_token
      WHERE "userId" = $1 AND used = false AND "expiresAt" > NOW() AND "deletedAt" IS NULL
      ORDER BY "createdAt" DESC;
    `;
    return withClient(async (client) => {
      const result = await client.query(query, [userId]);
      return result.rows;
    });
  },

  async markAsUsed(id: string): Promise<void> {
    const query = `
      UPDATE t_password_reset_token
      SET used = true, "updatedAt" = NOW()
      WHERE id = $1;
    `;
    await withClient(async (client) => {
      await client.query(query, [id]);
    });
  },

  async deleteExpired(): Promise<void> {
    const query = `
      UPDATE t_password_reset_token
      SET "deletedAt" = NOW()
      WHERE "expiresAt" < NOW() AND used = false;
    `;
    await withClient(async (client) => {
      await client.query(query);
    });
  },

  async deleteByUserId(userId: string): Promise<void> {
    const query = `
      UPDATE t_password_reset_token
      SET "deletedAt" = NOW()
      WHERE "userId" = $1 AND used = false;
    `;
    await withClient(async (client) => {
      await client.query(query, [userId]);
    });
  },
};