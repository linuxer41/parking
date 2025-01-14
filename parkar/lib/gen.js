const fs = require('fs');
const path = require('path');

// Entidades del sistema y sus campos
const entities = {
  User: {
    fields: {
      id: { type: 'String', composite: false, description: 'Identificador único del usuario', required: true, isArray: false },
      name: { type: 'String', composite: false, description: 'Nombre completo del usuario', required: true, isArray: false },
      email: { type: 'String', composite: false, description: 'Correo electrónico del usuario', required: true, isArray: false },
      password: { type: 'String', composite: false, description: 'Contraseña encriptada del usuario', required: true, isArray: false },
      createdAt: { type: 'Date', composite: false, description: 'Fecha de creación del registro', required: true, isArray: false },
      updatedAt: { type: 'Date', composite: false, description: 'Fecha de última actualización del registro', required: true, isArray: false },
    },
    createFields: ['name', 'email', 'password'],
    updateFields: ['name', 'email'],
    imports: [],
    jsonSchemas: {}, // No hay esquemas adicionales
  },
  Company: {
    fields: {
      id: { type: 'String', composite: false, description: 'Identificador único de la empresa', required: true, isArray: false },
      name: { type: 'String', composite: false, description: 'Nombre de la empresa', required: true, isArray: false },
      email: { type: 'String', composite: false, description: 'Correo electrónico de la empresa', required: true, isArray: false },
      phone: { type: 'String', composite: false, description: 'Número de teléfono de la empresa', required: false, isArray: false },
      logoUrl: { type: 'String', composite: false, description: 'URL del logo de la empresa', required: false, isArray: false },
      userId: { type: 'String', composite: false, description: 'ID del usuario que creó la empresa', required: true, isArray: false },
      owner: { type: 'User', composite: true, description: 'Usuario propietario de la empresa', required: false, isArray: false },
      params: { type: 'CompanyParams', composite: true, description: 'Parámetros adicionales de la empresa', required: false, isArray: false },
      createdAt: { type: 'Date', composite: false, description: 'Fecha de creación del registro', required: true, isArray: false },
      updatedAt: { type: 'Date', composite: false, description: 'Fecha de última actualización del registro', required: true, isArray: false },
    },
    createFields: ['name', 'userId', 'email', 'phone', 'logoUrl'],
    updateFields: ['name', 'userId', 'email', 'phone', 'logoUrl'],
    imports: ['user'],
    jsonSchemas: {
      CompanyParamsSchema: {
        fields: {
          slogan: { type: 'String', composite: false, description: 'Nombre del tipo de vehículo', required: true, isArray: false },
        },
      },
    },
  },
  Employee: {
    fields: {
      id: { type: 'String', composite: false, description: 'Identificador único del empleado', required: true, isArray: false },
      userId: { type: 'String', composite: false, description: 'ID del usuario asociado al empleado', required: true, isArray: false },
      user: { type: 'User', composite: true, description: 'Usuario asociado al empleado', required: false, isArray: false },
      companyId: { type: 'String', composite: false, description: 'ID de la empresa a la que pertenece el empleado', required: true, isArray: false },
      company: { type: 'Company', composite: true, description: 'Empresa asociada al empleado', required: false, isArray: false },
      role: { type: 'String', composite: false, description: 'Rol del empleado', required: true, isArray: false },
      assignedParkings: { type: 'String', composite: false, description: 'Estacionamientos asignados al empleado', required: true, isArray: true },
      createdAt: { type: 'Date', composite: false, description: 'Fecha de creación del registro', required: true, isArray: false },
      updatedAt: { type: 'Date', composite: false, description: 'Fecha de última actualización del registro', required: true, isArray: false },
    },
    createFields: ['userId', 'companyId', 'role', 'assignedParkings'],
    updateFields: ['role', 'assignedParkings'],
    imports: ['user', 'company'],
    jsonSchemas: {}, // No hay esquemas adicionales
  },
  Parking: {
    fields: {
      id: { type: 'String', composite: false, description: 'Identificador único del estacionamiento', required: true, isArray: false },
      name: { type: 'String', composite: false, description: 'Nombre del estacionamiento', required: true, isArray: false },
      companyId: { type: 'String', composite: false, description: 'ID de la empresa a la que pertenece el estacionamiento', required: true, isArray: false },
      company: { type: 'Company', composite: true, description: 'Empresa asociada al estacionamiento', required: false, isArray: false },
      vehicleTypes: { type: 'VehicleType', composite: true, description: 'Tipos de vehículos permitidos en el estacionamiento', required: true, isArray: true },
      params: { type: 'ParkingParams', composite: true, description: 'Parámetros adicionales del estacionamiento', required: true, isArray: false },
      createdAt: { type: 'Date', composite: false, description: 'Fecha de creación del registro', required: true, isArray: false },
      updatedAt: { type: 'Date', composite: false, description: 'Fecha de última actualización del registro', required: true, isArray: false },
    },
    createFields: ['name', 'companyId'],
    updateFields: ['name'],
    imports: ['company'],
    jsonSchemas: {
      VehicleTypeSchema: {
        fields: {
          id: { type: 'Integer', composite: false, description: 'Identificador único del tipo de vehículo', required: true, isArray: false },
          name: { type: 'String', composite: false, description: 'Nombre del tipo de vehículo', required: true, isArray: false },
          description: { type: 'String', composite: false, description: 'Descripción del tipo de vehículo', required: false, isArray: false },
        },
        createFields: ['name', 'description'],
        updateFields: ['name', 'description'],
      },
      ParkingParamsSchema: {
        fields: {
          baseTime: { type: 'Integer', composite: false, description: 'Tiempo base del pase', required: true, isArray: false },
          pasePrice: { type: 'Numeric', composite: false, description: 'Precio del pase', required: true, isArray: false },
          currency: { type: 'String', composite: false, description: 'Moneda del pase', required: true, isArray: false },
          timeZone: { type: 'String', composite: false, description: 'Zona horaria del pase', required: true, isArray: false },
          decimalPlaces: { type: 'Integer', composite: false, description: 'Decimales del pase', required: true, isArray: false },
          theme: { type: 'String', composite: false, description: 'Tema del pase', required: true, isArray: false },
        },
      }
    },
  },
  Level: {
    fields: {
      id: { type: 'String', composite: false, description: 'Identificador único del nivel', required: true, isArray: false },
      name: { type: 'String', composite: false, description: 'Nombre del nivel', required: true, isArray: false },
      parkingId: { type: 'String', composite: false, description: 'ID del estacionamiento al que pertenece el nivel', required: true, isArray: false },
      parking: { type: 'Parking', composite: true, description: 'Estacionamiento asociado al nivel', required: false, isArray: false },
      createdAt: { type: 'Date', composite: false, description: 'Fecha de creación del registro', required: true, isArray: false },
      updatedAt: { type: 'Date', composite: false, description: 'Fecha de última actualización del registro', required: true, isArray: false },
    },
    createFields: ['name', 'parkingId'],
    updateFields: ['name'],
    imports: ['parking'],
    jsonSchemas: {}, // No hay esquemas adicionales
  },
  Area: {
    fields: {
      id: { type: 'String', composite: false, description: 'Identificador único del área', required: true, isArray: false },
      name: { type: 'String', composite: false, description: 'Nombre del área', required: true, isArray: false },
      parkingId: { type: 'String', composite: false, description: 'ID del estacionamiento asociado', required: true, isArray: false },
      parking: { type: 'Parking', composite: true, description: 'Estacionamiento asociado al área', required: false, isArray: false },
      levelId: { type: 'String', composite: false, description: 'ID del nivel al que pertenece el área', required: true, isArray: false },
      level: { type: 'Level', composite: true, description: 'Nivel asociado al área', required: false, isArray: false },
      createdAt: { type: 'Date', composite: false, description: 'Fecha de creación del registro', required: true, isArray: false },
      updatedAt: { type: 'Date', composite: false, description: 'Fecha de última actualización del registro', required: true, isArray: false },
    },
    createFields: ['name', 'parkingId', 'levelId'],
    updateFields: ['name'],
    imports: ['parking', 'level'],
    jsonSchemas: {}, // No hay esquemas adicionales
  },
  Spot: {
    fields: {
      id: { type: 'String', composite: false, description: 'Identificador único del lugar de estacionamiento', required: true, isArray: false },
      name: { type: 'String', composite: false, description: 'Nombre del lugar', required: true, isArray: false },
      coordinates: { type: 'Coordinates', composite: true, description: 'Coordenadas del lugar', required: true, isArray: false },
      status: { type: 'String', composite: false, description: 'Estado del lugar (libre, ocupado, etc.)', required: true, isArray: false },
      parkingId: { type: 'String', composite: false, description: 'ID del estacionamiento asociado', required: true, isArray: false },
      parking: { type: 'Parking', composite: true, description: 'Estacionamiento asociado al lugar', required: false, isArray: false },
      areaId: { type: 'String', composite: false, description: 'ID del área a la que pertenece el lugar', required: true, isArray: false },
      area: { type: 'Area', composite: true, description: 'Área asociada al lugar', required: false, isArray: false },
      createdAt: { type: 'Date', composite: false, description: 'Fecha de creación del registro', required: true, isArray: false },
      updatedAt: { type: 'Date', composite: false, description: 'Fecha de última actualización del registro', required: true, isArray: false },
    },
    createFields: ['name', 'coordinates', 'status', 'parkingId', 'areaId'],
    updateFields: ['name', 'coordinates', 'status'],
    imports: ['parking', 'area'],
    jsonSchemas: {
      CoordinatesSchema: {
        fields: {
          x0: { type: 'Integer', composite: false, description: 'Coordenada X inicial', required: true, isArray: false },
          y0: { type: 'Integer', composite: false, description: 'Coordenada Y inicial', required: true, isArray: false },
          x1: { type: 'Integer', composite: false, description: 'Coordenada X final', required: true, isArray: false },
          y1: { type: 'Integer', composite: false, description: 'Coordenada Y final', required: true, isArray: false },
        },
        createFields: ['x', 'y'],
        updateFields: ['x', 'y'],
      },
    },
  },
  Vehicle: {
    fields: {
      id: { type: 'String', composite: false, description: 'Identificador único del vehículo', required: true, isArray: false },
      parkingId: { type: 'String', composite: false, description: 'ID del estacionamiento asociado', required: true, isArray: false },
      parking: { type: 'Parking', composite: true, description: 'Estacionamiento asociado al vehículo', required: true, isArray: false },
      typeId: { type: 'String', composite: false, description: 'ID del tipo de vehículo', required: true, isArray: false },
      plate: { type: 'String', composite: false, description: 'Placa del vehículo', required: true, isArray: false },
      isSubscriber: { type: 'Boolean', composite: false, description: 'Indica si el vehículo es abonado', required: true, isArray: false },
      createdAt: { type: 'Date', composite: false, description: 'Fecha de creación del registro', required: true, isArray: false },
      updatedAt: { type: 'Date', composite: false, description: 'Fecha de última actualización del registro', required: true, isArray: false },
    },
    createFields: ['parkingId', 'typeId', 'plate', 'isSubscriber'],
    updateFields: ['typeId', 'plate', 'isSubscriber'],
    imports: ['parking'],
    jsonSchemas: {}, // No hay esquemas adicionales
  },
  Price: {
    fields: {
      id: { type: 'String', composite: false, description: 'Identificador único del precio', required: true, isArray: false },
      parkingId: { type: 'String', composite: false, description: 'ID del estacionamiento asociado', required: true, isArray: false },
      parking: { type: 'Parking', composite: true, description: 'Estacionamiento asociado al precio', required: true, isArray: false },
      vehicleTypeId: { type: 'String', composite: false, description: 'ID del tipo de vehículo', required: true, isArray: false },
      timeRangeId: { type: 'String', composite: false, description: 'ID del rango de tiempo', required: true, isArray: false },
      amount: { type: 'Numeric', composite: false, description: 'Monto del precio', required: true, isArray: false },
      createdAt: { type: 'Date', composite: false, description: 'Fecha de creación del registro', required: true, isArray: false },
      updatedAt: { type: 'Date', composite: false, description: 'Fecha de última actualización del registro', required: true, isArray: false },
    },
    createFields: ['parkingId', 'vehicleTypeId', 'timeRangeId', 'amount'],
    updateFields: ['vehicleTypeId', 'timeRangeId', 'amount'],
    imports: ['parking'],
    jsonSchemas: {}, // No hay esquemas adicionales
  },
  Subscriber: {
    fields: {
      id: { type: 'String', composite: false, description: 'Identificador único del abonado', required: true, isArray: false },
      parkingId: { type: 'String', composite: false, description: 'ID del estacionamiento asociado', required: true, isArray: false },
      parking: { type: 'Parking', composite: true, description: 'Estacionamiento asociado al abonado', required: true, isArray: false },
      employeeId: { type: 'String', composite: false, description: 'ID del empleado asociado', required: true, isArray: false },
      employee: { type: 'Employee', composite: true, description: 'Empleado asociado al abonado', required: true, isArray: false },
      vehicleId: { type: 'String', composite: false, description: 'ID del vehículo asociado', required: true, isArray: false },
      vehicle: { type: 'Vehicle', composite: true, description: 'Vehículo asociado al abonado', required: true, isArray: false },
      planId: { type: 'String', composite: false, description: 'ID del plan de suscripción', required: true, isArray: false },
      plan: { type: 'SubscriptionPlan', composite: true, description: 'Plan de suscripción asociado al abonado', required: true, isArray: false },
      startDate: { type: 'Date', composite: false, description: 'Fecha de inicio del abono', required: true, isArray: false },
      endDate: { type: 'Date', composite: false, description: 'Fecha de fin del abono', required: true, isArray: false },
      isActive: { type: 'Boolean', composite: false, description: 'Indica si el abono está activo', required: true, isArray: false },
      createdAt: { type: 'Date', composite: false, description: 'Fecha de creación del registro', required: true, isArray: false },
      updatedAt: { type: 'Date', composite: false, description: 'Fecha de última actualización del registro', required: true, isArray: false },
    },
    createFields: ['parkingId', 'employeeId', 'vehicleId', 'planId', 'startDate', 'endDate', 'isActive'],
    updateFields: ['planId', 'startDate', 'endDate', 'isActive'],
    imports: ['parking', 'employee', 'vehicle', 'subscription-plan'],
    jsonSchemas: {}, // No hay esquemas adicionales
  },
  SubscriptionPlan: {
    fields: {
      id: { type: 'String', composite: false, description: 'Identificador único del plan de suscripción', required: true, isArray: false },
      name: { type: 'String', composite: false, description: 'Nombre del plan', required: true, isArray: false },
      description: { type: 'String', composite: false, description: 'Descripción opcional del plan', required: false, isArray: false },
      price: { type: 'Numeric', composite: false, description: 'Precio del plan', required: true, isArray: false },
      duration: { type: 'Integer', composite: false, description: 'Duración del plan en días', required: true, isArray: false },
      parkingId: { type: 'String', composite: false, description: 'ID del estacionamiento asociado', required: true, isArray: false },
      parking: { type: 'Parking', composite: true, description: 'Estacionamiento asociado al plan', required: true, isArray: false },
      createdAt: { type: 'Date', composite: false, description: 'Fecha de creación del registro', required: true, isArray: false },
      updatedAt: { type: 'Date', composite: false, description: 'Fecha de última actualización del registro', required: true, isArray: false },
    },
    createFields: ['name', 'description', 'price', 'duration', 'parkingId'],
    updateFields: ['name', 'description', 'price', 'duration'],
    imports: ['parking'],
    jsonSchemas: {}, // No hay esquemas adicionales
  },
  Entry: {
    fields: {
      id: { type: 'String', composite: false, description: 'Identificador único de la entrada', required: true, isArray: false },
      number: { type: 'Integer', composite: false, description: 'Número de la entrada', required: true, isArray: false },
      parkingId: { type: 'String', composite: false, description: 'ID del estacionamiento asociado', required: true, isArray: false },
      parking: { type: 'Parking', composite: true, description: 'Estacionamiento asociado a la entrada', required: true, isArray: false },
      employeeId: { type: 'String', composite: false, description: 'ID del empleado asociado', required: true, isArray: false },
      employee: { type: 'Employee', composite: true, description: 'Empleado asociado a la entrada', required: true, isArray: false },
      vehicleId: { type: 'String', composite: false, description: 'ID del vehículo que ingresó', required: true, isArray: false },
      vehicle: { type: 'Vehicle', composite: true, description: 'Vehículo asociado a la entrada', required: true, isArray: false },
      spotId: { type: 'String', composite: false, description: 'ID del lugar de estacionamiento asignado', required: true, isArray: false },
      spot: { type: 'Spot', composite: true, description: 'Lugar de estacionamiento asignado', required: true, isArray: false },
      dateTime: { type: 'Date', composite: false, description: 'Fecha y hora de la entrada', required: true, isArray: false },
      createdAt: { type: 'Date', composite: false, description: 'Fecha de creación del registro', required: true, isArray: false },
      updatedAt: { type: 'Date', composite: false, description: 'Fecha de última actualización del registro', required: true, isArray: false },
    },
    createFields: ['number', 'parkingId', 'employeeId', 'vehicleId', 'spotId', 'dateTime'],
    updateFields: ['number', 'employeeId', 'vehicleId', 'spotId', 'dateTime'],
    imports: ['parking', 'employee', 'vehicle', 'spot'],
    jsonSchemas: {}, // No hay esquemas adicionales
  },
  Exit: {
    fields: {
      id: { type: 'String', composite: false, description: 'Identificador único de la salida', required: true, isArray: false },
      number: { type: 'Integer', composite: false, description: 'Número de la salida', required: true, isArray: false },
      parkingId: { type: 'String', composite: false, description: 'ID del estacionamiento asociado', required: true, isArray: false },
      parking: { type: 'Parking', composite: true, description: 'Estacionamiento asociado a la salida', required: true, isArray: false },
      entryId: { type: 'String', composite: false, description: 'ID de la entrada asociada', required: true, isArray: false },
      entry: { type: 'Entry', composite: true, description: 'Entrada asociada a la salida', required: true, isArray: false },
      employeeId: { type: 'String', composite: false, description: 'ID del empleado asociado', required: true, isArray: false },
      employee: { type: 'Employee', composite: true, description: 'Empleado asociado a la salida', required: true, isArray: false },
      dateTime: { type: 'Date', composite: false, description: 'Fecha y hora de la salida', required: true, isArray: false },
      amount: { type: 'Numeric', composite: false, description: 'Monto cobrado', required: true, isArray: false },
      createdAt: { type: 'Date', composite: false, description: 'Fecha de creación del registro', required: true, isArray: false },
      updatedAt: { type: 'Date', composite: false, description: 'Fecha de última actualización del registro', required: true, isArray: false },
    },
    createFields: ['number', 'parkingId', 'entryId', 'employeeId', 'dateTime', 'amount'],
    updateFields: ['number', 'employeeId', 'dateTime', 'amount'],
    imports: ['parking', 'entry', 'employee'],
    jsonSchemas: {}, // No hay esquemas adicionales
  },
  CashRegister: {
    fields: {
      id: { type: 'String', composite: false, description: 'Identificador único de la caja registradora', required: true, isArray: false },
      number: { type: 'Integer', composite: false, description: 'Número de la caja', required: true, isArray: false },
      parkingId: { type: 'String', composite: false, description: 'ID del estacionamiento asociado', required: true, isArray: false },
      parking: { type: 'Parking', composite: true, description: 'Estacionamiento asociado a la caja', required: true, isArray: false },
      employeeId: { type: 'String', composite: false, description: 'ID del empleado asociado', required: true, isArray: false },
      employee: { type: 'Employee', composite: true, description: 'Empleado asociado a la caja', required: true, isArray: false },
      startDate: { type: 'Date', composite: false, description: 'Fecha de inicio de la caja', required: true, isArray: false },
      endDate: { type: 'Date', composite: false, description: 'Fecha de fin de la caja', required: true, isArray: false },
      status: { type: 'String', composite: false, description: 'Estado de la caja (activa, inactiva, etc.)', required: true, isArray: false },
      createdAt: { type: 'Date', composite: false, description: 'Fecha de creación del registro', required: true, isArray: false },
      updatedAt: { type: 'Date', composite: false, description: 'Fecha de última actualización del registro', required: true, isArray: false },
    },
    createFields: ['number', 'parkingId', 'employeeId', 'startDate', 'endDate', 'status'],
    updateFields: ['number', 'employeeId', 'startDate', 'endDate', 'status'],
    imports: ['parking', 'employee'],
    jsonSchemas: {}, // No hay esquemas adicionales
  },
  Movement: {
    fields: {
      id: { type: 'String', composite: false, description: 'Identificador único del movimiento', required: true, isArray: false },
      cashRegisterId: { type: 'String', composite: false, description: 'ID de la caja registradora asociada', required: true, isArray: false },
      cashRegister: { type: 'CashRegister', composite: true, description: 'Caja registradora asociada al movimiento', required: true, isArray: false },
      type: { type: 'String', composite: false, description: 'Tipo de movimiento (ingreso, egreso)', required: true, isArray: false },
      amount: { type: 'Numeric', composite: false, description: 'Monto del movimiento', required: true, isArray: false },
      description: { type: 'String', composite: false, description: 'Descripción del movimiento', required: true, isArray: false },
      createdAt: { type: 'Date', composite: false, description: 'Fecha de creación del registro', required: true, isArray: false },
      updatedAt: { type: 'Date', composite: false, description: 'Fecha de última actualización del registro', required: true, isArray: false },
    },
    createFields: ['cashRegisterId', 'type', 'amount', 'description'],
    updateFields: ['type', 'amount', 'description'],
    imports: ['cashRegister'],
    jsonSchemas: {}, // No hay esquemas adicionales
  },
  Reservation: {
    fields: {
      id: { type: 'String', composite: false, description: 'Identificador único de la reserva', required: true, isArray: false },
      number: { type: 'Integer', composite: false, description: 'Número de la reserva', required: true, isArray: false },
      parkingId: { type: 'String', composite: false, description: 'ID del estacionamiento asociado', required: true, isArray: false },
      parking: { type: 'Parking', composite: true, description: 'Estacionamiento asociado a la reserva', required: true, isArray: false },
      employeeId: { type: 'String', composite: false, description: 'ID del empleado asociado', required: true, isArray: false },
      employee: { type: 'Employee', composite: true, description: 'Empleado asociado a la reserva', required: true, isArray: false },
      vehicleId: { type: 'String', composite: false, description: 'ID del vehículo que realiza la reserva', required: true, isArray: false },
      vehicle: { type: 'Vehicle', composite: true, description: 'Vehículo asociado a la reserva', required: true, isArray: false },
      spotId: { type: 'String', composite: false, description: 'ID del puesto reservado', required: true, isArray: false },
      spot: { type: 'Spot', composite: true, description: 'Puesto reservado', required: true, isArray: false },
      startDate: { type: 'Date', composite: false, description: 'Fecha y hora de inicio de la reserva', required: true, isArray: false },
      endDate: { type: 'Date', composite: false, description: 'Fecha y hora de fin de la reserva', required: true, isArray: false },
      status: { type: 'String', composite: false, description: 'Estado de la reserva (activa, cancelada, etc.)', required: true, isArray: false },
      amount: { type: 'Numeric', composite: false, description: 'Monto de la reserva', required: true, isArray: false },
      createdAt: { type: 'Date', composite: false, description: 'Fecha de creación del registro', required: true, isArray: false },
      updatedAt: { type: 'Date', composite: false, description: 'Fecha de última actualización del registro', required: true, isArray: false },
    },
    createFields: ['number', 'parkingId', 'employeeId', 'vehicleId', 'spotId', 'startDate', 'endDate', 'status', 'amount'],
    updateFields: ['number', 'employeeId', 'vehicleId', 'spotId', 'startDate', 'endDate', 'status', 'amount'],
    imports: ['parking', 'employee', 'vehicle', 'spot'],
    jsonSchemas: {}, // No hay esquemas adicionales
  },
};

// Función para convertir tipos de datos
const parseType = (type, composite, isArray, required) => {
  // Convertir tipos específicos
  if (type === 'Date') {
    type = 'DateTime'; // Convertir 'Date' a 'DateTime' en Dart
  } else if (type === 'Integer') {
    type = 'int'; // Convertir 'Integer' a 'int' en Dart
  } else if (type === 'Numeric') {
    type = 'double'; // Convertir 'Numeric' a 'double' en Dart
  } else if (type === 'Boolean') {
    type = 'bool'; // Convertir 'Boolean' a 'bool' en Dart
  }
  // Manejar tipos compuestos
  if (composite) {
    type = `${type}Model`; // Añadir 'Model' al final para tipos compuestos
  }

  // Manejar arrays
  if (isArray) {
    type = `List<${type}>`; // Convertir a List<Modelo> si es un array
  }

  return required ? type : `${type}?`;
};

// Funciones de utilidad
function toKebabCase(str) {
  return str
    .replace(/([a-z])([A-Z])/g, '$1-$2') // Separa camelCase o PascalCase
    .replace(/_/g, '-') // Convierte snake_case a kebab-case
    .replace(/\s+/g, '-') // Convierte espacios a guiones
    .toLowerCase(); // Convierte todo a minúsculas
}

function toCamelCase(str) {
  return str
    .replace(/([-_]\w)/g, (match) => match[1].toUpperCase()) // Convierte kebab-case o snake_case a camelCase
    .replace(/\s+/g, '') // Elimina espacios
    .replace(/^[A-Z]/, (match) => match.toLowerCase()); // Convierte la primera letra a minúscula
}

function toPascalCase(str) {
  return str
    .replace(/([-_]\w)/g, (match) => match[1].toUpperCase()) // Convierte kebab-case o snake_case a PascalCase
    .replace(/\s+/g, '') // Elimina espacios
    .replace(/^[a-z]/, (match) => match.toUpperCase()); // Convierte la primera letra a mayúscula
}

function toSnakeCase(str) {
  return str
    .replace(/([a-z])([A-Z])/g, '$1_$2') // Convierte camelCase a snake_case
    .replace(/-/g, '_') // Convierte guiones a guiones bajos
    .replace(/\s+/g, '_') // Convierte espacios a guiones bajos
    .toLowerCase(); // Convierte todo a minúsculas
}

// Plantilla del modelo
const modelTemplate = (entity, fields, createFields, updateFields, imports, additionalSchemas = {}) => `
import 'package:json_annotation/json_annotation.dart';
import '_base_model.dart';
${imports.map((imp) => `import '${toSnakeCase(imp)}_model.dart';`).join('\n')}

part '${toSnakeCase(entity)}_model.g.dart';

@JsonSerializable()
class ${entity}Model extends JsonConvertible<${entity}Model> {
  ${Object.entries(fields)
    .map(([field, { type, composite, isArray, required }]) => 
      `final ${parseType(type, composite, isArray, required)} ${field};`)
    .join('\n  ')}

  ${entity}Model({
    ${Object.entries(fields)
      .map(([field, { required }]) => `${required ? 'required' : ''} this.${field},`)
      .join('\n    ')}
  });

  factory ${entity}Model.fromJson(Map<String, dynamic> json) =>
      _\$${entity}ModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _\$${entity}ModelToJson(this);
}

@JsonSerializable()
class ${entity}CreateModel extends JsonConvertible<${entity}CreateModel> {
  ${Object.entries(createFields)
    .map(([field, { type, composite, isArray, required }]) => 
      `final ${parseType(type, composite, isArray, required)} ${field};`)
    .join('\n  ')}

  ${entity}CreateModel({
    ${Object.entries(createFields)
      .map(([field, { required }]) => `${required ? 'required' : ''} this.${field},`)
      .join('\n    ')}
  });

  factory ${entity}CreateModel.fromJson(Map<String, dynamic> json) =>
      _\$${entity}CreateModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _\$${entity}CreateModelToJson(this);
}

@JsonSerializable()
class ${entity}UpdateModel extends JsonConvertible<${entity}UpdateModel> {
  ${Object.entries(updateFields)
    .map(([field, { type, composite, isArray, required }]) => 
      `final ${parseType(type, composite, isArray, required)} ${field};`)
    .join('\n  ')}

  ${entity}UpdateModel({
    ${Object.entries(updateFields)
      .map(([field, { required }]) => `${required ? 'required' : ''} this.${field},`)
      .join('\n    ')}
  });

  factory ${entity}UpdateModel.fromJson(Map<String, dynamic> json) =>
      _\$${entity}UpdateModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _\$${entity}UpdateModelToJson(this);
}

${Object.entries(additionalSchemas)
  .map(([schemaName, schema]) => {
    const modelName = schemaName.replace('Schema', 'Model');
    return `
@JsonSerializable()
class ${modelName} extends JsonConvertible<${modelName}> {
  ${Object.entries(schema.fields)
    .map(([field, { type, composite, isArray, required }]) => 
      `final ${parseType(type, composite, isArray, required)} ${field};`)
    .join('\n  ')}

  ${modelName}({
    ${Object.entries(schema.fields)
      .map(([field, { required }]) => `${required ? 'required' : ''} this.${field},`)
      .join('\n    ')}
  });

  factory ${modelName}.fromJson(Map<String, dynamic> json) =>
      _\$${modelName}FromJson(json);

  @override
  Map<String, dynamic> toJson() => _\$${modelName}ToJson(this);
}
`;
  }).join('\n')}
`;

// Plantilla del servicio
const serviceTemplate = (entity) => `
import '_base_service.dart';
import '../models/${toSnakeCase(entity)}_model.dart';

class ${entity}Service extends BaseService<${entity}Model, ${entity}CreateModel, ${entity}UpdateModel> {
  ${entity}Service() : super(path: '/${toSnakeCase(entity)}', fromJsonFactory: ${entity}Model.fromJson);
}
`;

// Plantilla del formulario
const formTemplate = (entity, fields, createFields, updateFields) => `
import 'package:flutter/material.dart';
import '../../models/${toSnakeCase(entity)}_model.dart';
import '../../services/${toSnakeCase(entity)}_service.dart';
import '../../di/di_container.dart';

class ${entity}Form extends StatefulWidget {
  final ${entity}Model? model;

  const ${entity}Form({super.key, this.model});

  @override
  State<${entity}Form> createState() => _${entity}FormState();
}

class _${entity}FormState extends State<${entity}Form> {
  final _formKey = GlobalKey<FormState>();
  final _service = DIContainer().resolve<${entity}Service>();

  ${Object.entries(fields)
    .filter(([field]) => createFields.includes(field) || updateFields.includes(field))
    .map(([field]) => `final _${field}Controller = TextEditingController();`)
    .join('\n  ')}

  @override
  void initState() {
    super.initState();
    if (widget.model != null) {
      ${Object.entries(fields)
        .filter(([field]) => updateFields.includes(field))
        .map(([field]) => `_${field}Controller.text = widget.model!.${field}.toString();`)
        .join('\n      ')}
    }
  }

  @override
  void dispose() {
    ${Object.entries(fields)
      .filter(([field]) => createFields.includes(field) || updateFields.includes(field))
      .map(([field]) => `_${field}Controller.dispose();`)
      .join('\n    ')}
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        if (widget.model == null) {
          final newModel = ${entity}CreateModel(
            ${Object.entries(fields)
              .filter(([field]) => createFields.includes(field))
              .map(([field, { type }]) => {
                if (type === 'Integer') return `${field}: int.parse(_${field}Controller.text),`;
                else if (type === 'Numeric') return `${field}: double.parse(_${field}Controller.text),`;
                else if (type === 'Date') return `${field}: DateTime.parse(_${field}Controller.text),`;
                else if (type === 'Boolean') return `${field}: _${field}Controller.text.toLowerCase() == 'true',`;
                else return `${field}: _${field}Controller.text,`;
              }).join('\n            ')}
          );
          await _service.create(newModel);
        } else {
          final updatedModel = ${entity}UpdateModel(
            ${Object.entries(fields)
              .filter(([field]) => updateFields.includes(field))
              .map(([field, { type }]) => {
                if (type === 'Integer') return `${field}: int.parse(_${field}Controller.text),`;
                else if (type === 'Numeric') return `${field}: double.parse(_${field}Controller.text),`;
                else if (type === 'Date') return `${field}: DateTime.parse(_${field}Controller.text),`;
                else if (type === 'Boolean') return `${field}: _${field}Controller.text.toLowerCase() == 'true',`;
                else return `${field}: _${field}Controller.text,`;
              }).join('\n            ')}
          );
          await _service.update(widget.model!.id, updatedModel);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${entity} \${widget.model == null ? 'creado' : 'actualizado'} correctamente')),
        );
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: \$e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.model == null ? 'Crear ${entity}' : 'Actualizar ${entity}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              ${Object.entries(fields)
                .filter(([field]) => createFields.includes(field) || updateFields.includes(field))
                .map(([field, { description, required, type }]) => `
              TextFormField(
                controller: _${field}Controller,
                decoration: const InputDecoration(
                  labelText: '${description}',
                ),
                validator: (value) {
                  if (${required} && (value == null || value.isEmpty)) {
                    return 'Este campo es obligatorio';
                  }
                  ${type === 'int' || type === 'double' ? `
                  if (value != null && value.isNotEmpty) {
                    try {
                      ${type === 'int' ? 'int.parse(value)' : 'double.parse(value)'};
                    } catch (e) {
                      return 'Ingrese un valor válido';
                    }
                  }
                  ` : ''}
                  ${type === 'DateTime' ? `
                  if (value != null && value.isNotEmpty) {
                    try {
                      DateTime.parse(value);
                    } catch (e) {
                      return 'Ingrese una fecha válida (YYYY-MM-DD)';
                    }
                  }
                  ` : ''}
                  ${type === 'bool' ? `
                  if (value != null && value.isNotEmpty && value.toLowerCase() != 'true' && value.toLowerCase() != 'false') {
                    return 'Ingrese "true" o "false"';
                  }
                  ` : ''}
                  return null;
                },
              ),
              `).join('\n              ')}
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text(widget.model == null ? 'Crear' : 'Actualizar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
`;

// Función para crear modelos
const createModels = () => {
  const modelsDir = path.join(__dirname, './models');
  if (!fs.existsSync(modelsDir)) fs.mkdirSync(modelsDir);

  Object.entries(entities).forEach(([entity, { fields, createFields, updateFields, imports, jsonSchemas }]) => {
    const createModelFields = Object.fromEntries(
      Object.entries(fields).filter(([field]) => createFields.includes(field))
    );
    const updateModelFields = Object.fromEntries(
      Object.entries(fields).filter(([field]) => updateFields.includes(field))
    );

    const modelPath = path.join(modelsDir, `${toSnakeCase(entity)}_model.dart`);
    fs.writeFileSync(
      modelPath,
      modelTemplate(entity, fields, createModelFields, updateModelFields, imports, jsonSchemas)
    );
    console.log(`Modelo generado: ${modelPath}`);
  });
};

// Función para crear servicios
const createServices = () => {
  const servicesDir = path.join(__dirname, './services');
  if (!fs.existsSync(servicesDir)) fs.mkdirSync(servicesDir);

  Object.keys(entities).forEach((entity) => {
    const servicePath = path.join(servicesDir, `${toSnakeCase(entity)}_service.dart`);
    fs.writeFileSync(servicePath, serviceTemplate(entity));
    console.log(`Servicio generado: ${servicePath}`);
  });
};

// Función para crear formularios
const createForms = () => {
  const formsDir = path.join(__dirname, './widgets/forms');
  if (!fs.existsSync(formsDir)) fs.mkdirSync(formsDir, { recursive: true });

  Object.entries(entities).forEach(([entity, { fields, createFields, updateFields }]) => {
    const formPath = path.join(formsDir, `${toSnakeCase(entity)}_form.dart`);
    fs.writeFileSync(formPath, formTemplate(entity, fields, createFields, updateFields));
    console.log(`Formulario generado: ${formPath}`);
  });
};

// Función principal
const generateAll = () => {
  createModels();
  // createServices();
  createForms();
};

// Ejecutar el generador
generateAll();