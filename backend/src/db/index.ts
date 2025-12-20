import { bookingCrud } from "./crud/booking";
import { accessCrud } from "./crud/access";
import { subscriptionCrud } from "./crud/subscription";
import * as parkingCrud from "./crud/parking";
import * as vehicleCrud from "./crud/vehicle";
import * as employeeCrud from "./crud/employee";
import * as userCrud from "./crud/user";
import * as cashRegisterCrud from "./crud/cash-register";
import * as movementCrud from "./crud/movement";
import * as notificationCrud from "./crud/notification";
import * as reportCrud from "./crud/report";

export const db = {
  // ===== BOOKING (RESERVAS) =====
  booking: {
    create: bookingCrud.createBooking,
    find: bookingCrud.findBookings,
    findById: bookingCrud.getBookingById,
    update: bookingCrud.updateBooking,
    delete: bookingCrud.deleteBooking,
    getActiveForSpot: bookingCrud.getActiveBookingsForSpot,
    getActiveForVehicle: bookingCrud.getActiveBookingsForVehicle,
    getStats: bookingCrud.getBookingStats,
    generateNumber: bookingCrud.generateBookingNumber,
  },

  // ===== ENTRY/EXIT (ACCESOS) =====
  access: {
    create: accessCrud.createAccess,
    find: accessCrud.findAccesss,
    findById: accessCrud.getAccessById,
    update: accessCrud.updateAccess,
    updateFee: accessCrud.updateFee,
    calculateCurrentFee: accessCrud.calculateCurrentFee,
    delete: accessCrud.deleteAccess,
    registerExit: accessCrud.registerExit,
    getActiveForSpot: accessCrud.getActiveAccesssForSpot,
    getActiveForVehicle: accessCrud.getActiveAccesssForVehicle,
    getStats: accessCrud.getAccessStats,
    generateNumber: accessCrud.generateAccessNumber,
  },

  // ===== SUBSCRIPTION (SUSCRIPCIONES) =====
  subscription: {
    create: subscriptionCrud.createSubscription,
    find: subscriptionCrud.findSubscriptions,
    findById: subscriptionCrud.getSubscriptionById,
    update: subscriptionCrud.updateSubscription,
    delete: subscriptionCrud.deleteSubscription,
    renew: subscriptionCrud.renewSubscription,
    getActiveForSpot: subscriptionCrud.getActiveSubscriptionsForSpot,
    getActiveForVehicle: subscriptionCrud.getActiveSubscriptionsForVehicle,
    getExpiring: subscriptionCrud.getExpiringSubscriptions,
    getStats: subscriptionCrud.getSubscriptionStats,
    generateNumber: subscriptionCrud.generateSubscriptionNumber,
  },

  // ===== PARKING =====
  parking: parkingCrud,

  // ===== AREA (MANEJADO POR PARKING CRUD) =====
  area: {
    create: parkingCrud.createArea,
    findById: parkingCrud.findAreaById,
    findByParkingId: parkingCrud.findAreasByParkingId,
    update: parkingCrud.updateArea,
    delete: parkingCrud.deleteArea,
  },

  // ===== ELEMENT (MANEJADO POR PARKING CRUD) =====
  element: {
    create: parkingCrud.createElement,
    findById: parkingCrud.findElementById,
    findByAreaId: parkingCrud.findElementsByAreaId,
    findByParkingId: parkingCrud.findElementsByParkingId,
    update: parkingCrud.updateElement,
    delete: parkingCrud.deleteElement,
  },

  // ===== VEHICLE =====
  vehicle: {
    create: vehicleCrud.createVehicle,
    find: vehicleCrud.findVehicles,
    findById: vehicleCrud.findVehicleById,
    update: vehicleCrud.updateVehicle,
    delete: vehicleCrud.deleteVehicle,
  },

  // ===== EMPLOYEE =====
  employee: {
    create: employeeCrud.createEmployee,
    find: employeeCrud.findEmployees,
    findById: employeeCrud.findEmployeeById,
    update: employeeCrud.updateEmployee,
    delete: employeeCrud.deleteEmployee,
    changePassword: employeeCrud.changeEmployeePassword,
  },

  // ===== USER =====
  user: {
    create: userCrud.createUser,
    find: userCrud.findUsers,
    findById: userCrud.findUserById,
    update: userCrud.updateUser,
    delete: userCrud.deleteUser,
  },

  // ===== CASH REGISTER =====
  cashRegister: {
    create: cashRegisterCrud.createCashRegister,
    find: cashRegisterCrud.findCashRegisters,
    findById: cashRegisterCrud.findCashRegisterById,
    update: cashRegisterCrud.updateCashRegister,
    delete: cashRegisterCrud.deleteCashRegister,
  },

  // ===== MOVEMENT =====
  movement: {
    create: movementCrud.createMovement,
    find: movementCrud.findMovements,
    findById: movementCrud.findMovementById,
    update: movementCrud.updateMovement,
    delete: movementCrud.deleteMovement,
  },

  // ===== NOTIFICATION =====
  notification: {
    create: notificationCrud.createNotification,
    find: notificationCrud.findNotifications,
    findById: notificationCrud.findNotificationById,
    update: notificationCrud.updateNotification,
    delete: notificationCrud.deleteNotification,
  },

  // ===== REPORT =====
  report: reportCrud,
};
