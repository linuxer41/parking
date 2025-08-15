import { userCrud } from "./crud/user";
import { employeeCrud } from "./crud/employee";
import { parkingCrud } from "./crud/parking";
import { areaCrud } from "./crud/area";
import { vehicleCrud } from "./crud/vehicle";
import { accessCrud } from "./crud/access";
import { cashRegisterCrud } from "./crud/cash-register";
import { movementCrud } from "./crud/movement";
import { reservationCrud } from "./crud/reservation";
import { reportCrud } from "./crud/report";
import { notificationCrud } from "./crud/notification";
import { PoolClient } from "pg";
import { getConnection } from "./connection";
import { QueryResultRow } from "pg";
import { elementCrud } from "./crud/element";
import { subscriptionCrud } from "./crud/subscription";

// Función para realizar consultas SQL directas
async function query<T extends QueryResultRow = any>(sql: string, params: any[] = []): Promise<T[]> {
  let conn: PoolClient | undefined;
  try {
    conn = await getConnection();
    const result = await conn.query<T>(sql, params);
    return result.rows;
  } catch (error) {
    console.error("Error ejecutando consulta directa:", error);
    throw error;
  } finally {
    conn?.release();
  }
}

export const db = {
  user: userCrud,
  employee: employeeCrud,
  element: elementCrud,
  parking: parkingCrud,
  area: areaCrud,
  vehicle: vehicleCrud,
  subscription: subscriptionCrud,
  access: accessCrud,
  cashRegister: cashRegisterCrud,
  movement: movementCrud,
  reservation: reservationCrud,
  report: reportCrud,
  notification: notificationCrud,
  query, // Método de consulta directa
};
