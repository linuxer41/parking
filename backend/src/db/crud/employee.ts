import { PoolClient } from "pg";
import { getConnection, withClient } from "../connection";
import { Employee, EmployeeCreate, EmployeeUpdate, EmployeeCreateSchema, EmployeeUpdateSchema, EmployeeCreateRequest, EmployeeUpdateRequest } from "../../models/employee";
import { getSchemaValidator } from "elysia";

const TABLE_NAME = "t_employee";

// ===== CRUD OPERATIONS =====

/**
 * Crear un nuevo empleado
 */
export async function createEmployee(input: EmployeeCreateRequest): Promise<Employee> {
  const validator = getSchemaValidator(EmployeeCreateSchema);
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
    const res = await client.query<Employee>(query);
    return res.rows[0];
  });
}

/**
 * Buscar un empleado por ID
 */
export async function findEmployeeById(id: string): Promise<Employee | undefined> {
  const query = {
    text: `SELECT * FROM ${TABLE_NAME} WHERE id = $1 LIMIT 1`,
    values: [id],
  };
  
  return withClient(async (client) => {
    const res = await client.query<Employee>(query);
    return res.rows[0];
  });
}

/**
 * Buscar empleados por criterios
 */
export async function findEmployees(where: Partial<Employee> = {}): Promise<Employee[]> {
  const conditions = Object.entries(where)
    .map(([key, value], i) => `"${key}" = $${i + 1}`)
    .join(" AND ");
  
  const query = {
    text: `SELECT * FROM ${TABLE_NAME} ${conditions ? `WHERE ${conditions}` : ""}`,
    values: Object.values(where),
  };
  
  return withClient(async (client) => {
    const res = await client.query<Employee>(query);
    return res.rows;
  });
}

/**
 * Actualizar un empleado
 */
export async function updateEmployee(id: string, input: EmployeeUpdateRequest): Promise<Employee> {
  const validator = getSchemaValidator(EmployeeUpdateSchema);
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
    const res = await client.query<Employee>(query);
    
    if (!res.rows || res.rows.length === 0) {
      throw new Error(`No se encontró el empleado con ID ${id} para actualizar`);
    }
    
    return res.rows[0];
  });
}

/**
 * Eliminar un empleado
 */
export async function deleteEmployee(id: string): Promise<Employee> {
  const query = {
    text: `DELETE FROM ${TABLE_NAME} WHERE id = $1 RETURNING *`,
    values: [id],
  };
  
  return withClient(async (client) => {
    const res = await client.query<Employee>(query);
    
    if (!res.rows || res.rows.length === 0) {
      throw new Error(`No se encontró el empleado con ID ${id} para eliminar`);
    }
    
    return res.rows[0];
  });
}
