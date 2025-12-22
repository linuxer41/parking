import { bookingCrud } from "./crud/booking";
import { accessCrud } from "./crud/access";
import { subscriptionCrud } from "./crud/subscription";
import { parkingCrud } from "./crud/parking";
import { vehicleCrud } from "./crud/vehicle";
import { employeeCrud } from "./crud/employee";
import { userCrud } from "./crud/user";
import { cashRegisterCrud } from "./crud/cash-register";
import { movementCrud } from "./crud/movement";
import { notificationCrud } from "./crud/notification";
import { reportCrud } from "./crud/report";

export const db = {
  // ===== BOOKING (RESERVAS) =====
  booking: bookingCrud,

  // ===== ENTRY/EXIT (ACCESOS) =====
  access: accessCrud,

  // ===== SUBSCRIPTION (SUSCRIPCIONES) =====
  subscription: subscriptionCrud,

  // ===== PARKING =====
  parking: parkingCrud,


  // ===== VEHICLE =====
  vehicle: vehicleCrud,

  // ===== EMPLOYEE =====
  employee: employeeCrud,

  // ===== USER =====
  user: userCrud,

  // ===== CASH REGISTER =====
  cashRegister: cashRegisterCrud,

  // ===== MOVEMENT =====
  movement: movementCrud,

  // ===== NOTIFICATION =====
  notification: notificationCrud,

  // ===== REPORT =====
  report: reportCrud,
};
