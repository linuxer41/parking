import { Pool, types } from "pg";
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

// Función para ejecutar una consulta
async function query(sql: string, params: any[] = []) {
  const client = await getConnection();
  try {
    const result = await client.query(sql, params);
    return result.rows;
  } catch (error) {
    console.error("Error al ejecutar la consulta:", error);
    throw error;
  } finally {
    client.release(); // Liberar la conexión al pool
  }
}

// Exportar el pool y las funciones
export { pool, getConnection, query };
