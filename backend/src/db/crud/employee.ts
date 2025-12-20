import { PoolClient } from "pg";
import { getConnection, withClient, withTransaction } from "../connection";
import { Employee, EmployeeCreate, EmployeeUpdate, EmployeeCreateSchema, EmployeeUpdateSchema, EmployeeCreateRequest, EmployeeUpdateRequest, EmployeePasswordChangeRequest } from "../../models/employee";
import { UserCreateSchema } from "../../models/user";
import { getSchemaValidator } from "elysia";
import { ConflictError } from "../../utils/error";
import { db } from "../index";

const TABLE_NAME = "t_employee";

// ===== CRUD OPERATIONS =====

/**
 * Crear un nuevo empleado
 */
export async function createEmployee(input: EmployeeCreateRequest): Promise<Employee> {
  // Verificar si el usuario ya existe
  const existingUsers = await db.user.find({ email: input.email });
  if (existingUsers.length > 0) {
    throw new ConflictError(`Ya existe un usuario con el email ${input.email}`);
  }

  return await withTransaction(async (client) => {
    const { password, ...restInput } = input;

    // Crear el usuario
    const userValidator = getSchemaValidator(UserCreateSchema);
    const userData = userValidator.parse({
      ...restInput,
      passwordHash: await Bun.password.hash(password),
      id: crypto.randomUUID(),
      createdAt: new Date().toISOString(),
    });

    const userQueryRes = await client.query(`
      INSERT INTO t_user ("id", "createdAt", "name", "email", "passwordHash", "phone")
      VALUES ($1, $2, $3, $4, $5, $6)
      RETURNING *
    `, [userData.id, userData.createdAt, userData.name, userData.email, userData.passwordHash, userData.phone]);

    const user = userQueryRes.rows[0];

    // Crear el empleado
    const employeeValidator = getSchemaValidator(EmployeeCreateSchema);
    const employeeData = employeeValidator.parse({
      userId: user.id,
      parkingId: input.parkingId,
      role: input.role,
      id: crypto.randomUUID(),
      createdAt: new Date().toISOString(),
    });

    const employeeQueryRes = await client.query<Employee>(`
      INSERT INTO t_employee ("id", "createdAt", "parkingId", "role", "userId")
      VALUES ($1, $2, $3, $4, $5)
      RETURNING *
    `, [employeeData.id, employeeData.createdAt, employeeData.parkingId, employeeData.role, employeeData.userId]);

    return employeeQueryRes.rows[0];
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

/**
 * Cambiar la contraseña de un empleado
 */
export async function changeEmployeePassword(employeeId: string, currentPassword: string, newPassword: string): Promise<void> {
  // Obtener el empleado
  const employee = await findEmployeeById(employeeId);
  if (!employee) {
    throw new Error(`No se encontró el empleado con ID ${employeeId}`);
  }

  // Obtener el usuario
  const users = await db.user.find({ id: employee.userId });
  const user = users[0];
  if (!user) {
    throw new Error(`No se encontró el usuario asociado al empleado`);
  }

  // Verificar la contraseña actual
  const matchPassword = await Bun.password.verify(currentPassword, user.passwordHash);
  if (!matchPassword) {
    throw new Error("La contraseña actual es incorrecta");
  }

  // Hash de la nueva contraseña
  const newPasswordHash = await Bun.password.hash(newPassword);

  // Actualizar la contraseña
  const query = {
    text: `UPDATE t_user SET "passwordHash" = $1, "updatedAt" = NOW() WHERE id = $2`,
    values: [newPasswordHash, user.id],
  };

  return withClient(async (client) => {
    await client.query(query);
  });
}
