import { Pool, types, PoolClient } from "pg";
import Big from "big.js";

function parseDate(value: string): string {
  return value.toString();
}
types.setTypeParser(types.builtins.TIMESTAMPTZ, parseDate);
types.setTypeParser(types.builtins.DATE, parseDate);
types.setTypeParser(types.builtins.TIMESTAMP, parseDate);
types.setTypeParser(types.builtins.NUMERIC, function (val) {
  return val === null ? null : new Big(val).toNumber();
});

// Configuración de la conexión
console.log("DATABASE_URL", process.env.DATABASE_URL);
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  max: 20, // Número máximo de conexiones en el pool
  idleTimeoutMillis: 30000, // Tiempo máximo de inactividad de una conexión
  connectionTimeoutMillis: 2000, // Tiempo máximo para establecer una conexión
});

// Función para obtener una conexión del pool
async function getConnection() {
  try {
    const client = await pool.connect();
    return client;
  } catch (error) {
    console.error("Error al conectar a la base de datos:", error);
    throw error;
  }
}

// ===== HELPER FUNCTIONS =====

/**
 * Helper function para manejo automático del cliente
 * Maneja automáticamente la conexión y liberación del cliente
 */
async function withClient<T>(operation: (client: PoolClient) => Promise<T>): Promise<T> {
  const client = await getConnection();
  try {
    return await operation(client);
  } finally {
    client.release();
  }
}

/**
 * Helper function para manejo automático de transacciones
 * Maneja automáticamente el inicio, commit y rollback de transacciones
 */
async function withTransaction<T>(operation: (client: PoolClient) => Promise<T>): Promise<T> {
  const client = await getConnection();
  try {
    await client.query('BEGIN');
    const result = await operation(client);
    await client.query('COMMIT');
    return result;
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}

// Exportar el pool y las funciones
export { pool, getConnection, withClient, withTransaction };
