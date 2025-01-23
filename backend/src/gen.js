const { table } = require('console');
const fs = require('fs');
const path = require('path');

// Definir las carpetas dinámicas
const folders = {
  controllers: './controllers', // Carpeta para los controladores
  services: './services',       // Carpeta para los servicios
  models: './models',
  crud: './db/crud',
  db: './db',                   // Carpeta para la conexión a la base de datos
};

// Crear las carpetas si no existen
Object.values(folders).forEach((folder) => {
  if (!fs.existsSync(folder)) {
    fs.mkdirSync(folder, { recursive: true });
  }
});

// Entidades del sistema y sus campos (ajustadas al esquema de Prisma)
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
      prices: { type: 'Price', composite: true, description: 'Precios del estacionamiento', required: true, isArray: true },
      subscriptionPlans: { type: 'SubscriptionPlan', composite: true, description: 'Planes de suscripción del estacionamiento', required: true, isArray: true },
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
          currency: { type: 'String', composite: false, description: 'Moneda del pase', required: true, isArray: false },
          timeZone: { type: 'String', composite: false, description: 'Zona horaria del pase', required: true, isArray: false },
          decimalPlaces: { type: 'Integer', composite: false, description: 'Decimales del pase', required: true, isArray: false },
          theme: { type: 'String', composite: false, description: 'Tema del pase', required: true, isArray: false },
        },
      },
      PriceSchema: {
        fields: {
          id: { type: 'String', composite: false, description: 'Identificador único del precio', required: true, isArray: false },
          name: { type: 'String', composite: false, description: 'Nombre del precio', required: true, isArray: false },
          baseTime: { type: 'Integer', composite: false, description: 'Tiempo base del pase', required: true, isArray: false },
          tolerance: { type: 'Integer', composite: false, description: 'Tolerancia del pase', required: true, isArray: false },
          pasePrice: { type: 'Numeric', composite: false, description: 'Precio del pase', required: true, isArray: false },
        },
        createFields: ['name', 'baseTime', 'tolerance', 'pasePrice'],
        updateFields: ['name', 'baseTime', 'tolerance', 'pasePrice'],
      },
      SubscriptionPlanSchema: {
        fields: {
          id: { type: 'String', composite: false, description: 'Identificador único del plan de suscripción', required: true, isArray: false },
          name: { type: 'String', composite: false, description: 'Nombre del plan', required: true, isArray: false },
          description: { type: 'String', composite: false, description: 'Descripción opcional del plan', required: false, isArray: false },
          price: { type: 'Numeric', composite: false, description: 'Precio del plan', required: true, isArray: false },
          duration: { type: 'Integer', composite: false, description: 'Duración del plan en días', required: true, isArray: false },
        },
        createFields: ['name', 'description', 'price', 'duration'],
        updateFields: ['name', 'description', 'price', 'duration'],
      }
    },
  },
  Level: {
    fields: {
      id: { type: 'String', composite: false, description: 'Identificador único del nivel', required: true, isArray: false },
      name: { type: 'String', composite: false, description: 'Nombre del nivel', required: true, isArray: false },
      parkingId: { type: 'String', composite: false, description: 'ID del estacionamiento al que pertenece el nivel', required: true, isArray: false },
      parking: { type: 'Parking', composite: true, description: 'Estacionamiento asociado al nivel', required: false, isArray: false },
      spots: { type: 'Spot', composite: true, description: 'Lugares asociados al nivel', required: true, isArray: true },
      indicators: { type: 'Indicator', composite: true, description: 'Indicadores asociados al nivel', required: true, isArray: true },
      offices: { type: 'Office', composite: true, description: 'Oficinas asociadas al nivel', required: true, isArray: true },
      createdAt: { type: 'Date', composite: false, description: 'Fecha de creación del registro', required: true, isArray: false },
      updatedAt: { type: 'Date', composite: false, description: 'Fecha de última actualización del registro', required: true, isArray: false },
    },
    createFields: ['name', 'parkingId'],
    updateFields: ['name'],
    imports: ['parking'],
    jsonSchemas: {
      SpotSchema: {
        fields: {
          id: { type: 'String', composite: false, description: 'Identificador único del lugar de estacionamiento', required: true, isArray: false },
          name: { type: 'String', composite: false, description: 'Nombre del lugar', required: true, isArray: false },
          posX: { type: 'Number', composite: false, description: 'Coordenada X del lugar', required: true, isArray: false },
          posY: { type: 'Number', composite: false, description: 'Coordenada Y del lugar', required: true, isArray: false },
          vehicleId: { type: 'String', composite: false, description: 'ID del vehículo que se encuentra en el lugar', required: false, isArray: false },
          spotType: { type: 'Integer', composite: false, description: 'Tipo de lugar (motocicleta, camión, etc.)', required: true, isArray: false },
          spotLevel: { type: 'Integer', composite: false, description: 'vip, normal, etc.', required: true, isArray: false },
        },
        createFields: ['name', 'posX', 'posY', 'vehicleId', 'spotTypeId', 'spotLevelId'],
        updateFields: ['name', 'posX', 'posY', 'vehicleId', 'spotTypeId', 'spotLevelId'],
      },
      IndicatorSchema: {
        fields: {
          id: { type: 'String', composite: false, description: 'Identificador único del indicador', required: true, isArray: false },
          posX: { type: 'Number', composite: false, description: 'Coordenada X del indicador', required: true, isArray: false },
          posY: { type: 'Number', composite: false, description: 'Coordenada Y del indicador', required: true, isArray: false },
          indicatorType: { type: "Integer", composite: false, description: 'Tipo de indicador (entrada, salida, etc.)', required: true, isArray: false },
        },
        createFields: ['posX', 'posY', 'indicatorType',],
        updateFields: ['posX', 'posY', 'indicatorType',],
      },
      OfficeSchema: {
        fields: {
          id: { type: 'String', composite: false, description: 'Identificador único de la oficina', required: true, isArray: false },
          name: { type: 'String', composite: false, description: 'Nombre de la oficina', required: true, isArray: false },
          posX: { type: 'Number', composite: false, description: 'Coordenada X de la oficina', required: true, isArray: false },
          posY: { type: 'Number', composite: false, description: 'Coordenada Y de la oficina', required: true, isArray: false },
        },
        createFields: ['posX', 'posY', 'name',],
        updateFields: ['posX', 'posY', 'name',],
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
    imports: ['parking', 'employee', 'vehicle'],
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
    imports: ['parking', 'employee', 'vehicle', 'level'],
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
    imports: ['parking', 'employee', 'vehicle', 'level'],
    jsonSchemas: {}, // No hay esquemas adicionales
  },
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
    .replace(/-/g, '_') // Convierte guiones a guiones
    .replace(/\s+/g, '_') // Convierte espacios a guiones
    .toLowerCase(); // Convierte todo a minúsculas
}


function getTypeDef(field) {
  const { type, description, required, isArray, composite } = field;
  if (type === 'Date') {
    return `t.Union([
    t.String(
      {
        description: '${description}',
        required: ${required}
      }
    ),
    t.Date(
      {
        description: '${description}',
        required: ${required}
      })
  ])`;
  }
  const baseType = composite ? `${type}Schema` : `t.${type}(
    {
      description: "${description}",
      required: ${required}
    }
  )`;

  return isArray ? `t.Array(${baseType})` : baseType;
}

/**
 * Genera los esquemas adicionales en formato TypeBox.
 * @param {Object} jsonSchemas - Objeto con los esquemas adicionales.
 * @returns {string} - Código TypeBox para los esquemas adicionales.
 */
function generateAdditionalSchemas(jsonSchemas) {
  if (Object.keys(jsonSchemas).length === 0) {
    return '// No hay esquemas adicionales';
  }
  return Object.entries(jsonSchemas)
    .map(([schemaName, schemaDefinition]) => {
        // Si es un objeto, se genera el esquema dinámicamente
        const fields = Object.entries(schemaDefinition.fields)
          .map(([field, fieldValue]) => {
            return `${field}: ${getTypeDef(fieldValue)},`;
          })
          .join('\n  ');
        return `export const ${schemaName} = t.Object(
  {
    ${fields}
  },
  {
    description: 'Esquema adicional: ${schemaName}'
  }
);

export type ${schemaName.replace('Schema', '')} = typeof ${schemaName}.static;
`;
    })
    .join('\n\n');
}

// Plantilla del controlador con OpenAPI
const controllerTemplate = (entity, fields, createFields, updateFields, imports, specialFields) => `
import Elysia from "elysia";
import { t } from 'elysia';
import { db } from "${path.relative(folders.controllers, folders.db).replace(/\\/g, '/')}";
import { ${specialFields.includes(entity) ? 'authPlugin' : 'accessPlugin'} } from "../plugins/${specialFields.includes(entity) ? 'auth' : 'access'}";
import { ${toCamelCase(entity)}Service } from "${path.relative(folders.controllers, folders.services).replace(/\\/g, '/')}/${toKebabCase(entity)}";
import { ${toPascalCase(entity)}Schema, ${toPascalCase(entity)} } from "../models/${toKebabCase(entity)}";


export const ${toCamelCase(entity)}Controller = new Elysia({ prefix: '/${toKebabCase(entity)}', tags: ['${toKebabCase(entity)}'], detail: { summary: 'Obtener todos los ${toKebabCase(entity)}s', description: 'Retorna una lista de todos los ${toKebabCase(entity)}s registrados.', security: [{ ${specialFields.includes(entity) ? 'token: []' : 'branchId: [], token: []'} }] } })
  .use(${specialFields.includes(entity) ? 'authPlugin' : 'accessPlugin'})
  .use(${toCamelCase(entity)}Service)
  .get('/', async ({ query }) => {
      const res = await db.${toCamelCase(entity)}.findMany({});
      return res as ${toPascalCase(entity)}[];
  }, {
      detail: {
          summary: 'Obtener todos los ${toKebabCase(entity)}s',
          description: 'Retorna una lista de todos los ${toKebabCase(entity)}s registrados.',
      },
      response: {
          200: t.Array(${toPascalCase(entity)}Schema),
          400: t.String(),
          500: t.String(),
      },

  })
  .post('/', async ({ body }) => {
      const res = await db.${toCamelCase(entity)}.create({
          data: body
      });
      return res as ${toPascalCase(entity)};
  }, {
      body: '${toPascalCase(entity)}CreateSchema',
      detail: {
          summary: 'Crear un nuevo ${toKebabCase(entity)}',
          description: 'Crea un nuevo registro de ${toKebabCase(entity)} con los datos proporcionados.',
      },
      response: {
          200: ${toPascalCase(entity)}Schema,
          400: t.String(),
          500: t.String(),
      },
  })
  .get('/:id', async ({ params }) => {
      const res = await db.${toCamelCase(entity)}.findUnique({
          where: {
              id: params.id
          }
      });
      return res as ${toPascalCase(entity)};
  }, {
      detail: {
          summary: 'Obtener un ${toKebabCase(entity)} por ID',
          description: 'Retorna un ${toKebabCase(entity)} específico basado en su ID.',
      },
      response: {
          200: ${toPascalCase(entity)}Schema,
          400: t.String(),
          500: t.String(),
      },
  })
  .patch('/:id', async ({ params, body }) => {
      const res = await db.${toCamelCase(entity)}.update({
          where: {
              id: params.id
          },
          data: body
      });
      return res as ${toPascalCase(entity)};
  }, {
      body: '${toPascalCase(entity)}UpdateSchema',
      detail: {
          summary: 'Actualizar un ${toKebabCase(entity)}',
          description: 'Actualiza un registro de ${toKebabCase(entity)} existente con los datos proporcionados.',
      },
      response: {
          200: ${toPascalCase(entity)}Schema,
          400: t.String(),
          500: t.String(),
      },
  })
  .delete('/:id', async ({ params }) => {
      const res = await db.${toCamelCase(entity)}.delete({
          where: {
              id: params.id
          }
      });
      return res as ${toPascalCase(entity)};
  }, {
      detail: {
          summary: 'Eliminar un ${toKebabCase(entity)}',
          description: 'Elimina un registro de ${toKebabCase(entity)} basado en su ID.',
      },
      response: {
          200: ${toPascalCase(entity)}Schema,
          400: t.String(),
          500: t.String(),
      },
  });
`;

// Plantilla del servicio con OpenAPI
const serviceTemplate = (entity, fields, createFields, updateFields, imports) => `
import { Elysia, t } from 'elysia';
import { ${entity}Schema, ${entity}CreateSchema, ${entity}UpdateSchema } from "${path.relative(folders.services, folders.models).replace(/\\/g, '/')}/${toKebabCase(entity)}";

export const ${toCamelCase(entity)}Service = new Elysia({ name: '${toKebabCase(entity)}/service' })
  .model({
      ${entity}Schema,
      ${entity}CreateSchema,
      ${entity}UpdateSchema
  });
`;

// Plantilla del modelo con OpenAPI
const modelTemplate = (entity, fields, createFields, updateFields, imports, jsonSchemas = {}) => `
import { t } from 'elysia';
${imports.map((imp) => `import { ${toPascalCase(imp)}Schema } from './${toKebabCase(imp)}';`).join('\n')}

// Esquemas JSON adicionales
${generateAdditionalSchemas(jsonSchemas)}

// Modelo Principal
export const ${entity}Schema = t.Object(
  {
    ${Object.entries(fields)
      .map(([field, fieldValue]) => {
        return `${field}: ${getTypeDef(fieldValue)},`;
      })
      .join('\n  ')}
  },
  {
    description: 'Esquema principal para la entidad ${entity}'
  }
);

export type ${entity} = typeof ${entity}Schema.static;

// Modelo de Creación
export const ${entity}CreateSchema = t.Object(
  {
    ${createFields
      .map((field) => {
        return `${field}: ${getTypeDef(fields[field])},`;
      })
      .join('\n  ')}
  },
  {
  description: 'Esquema para la creación de un ${entity}'
  }
);

export type ${entity}Create = typeof ${entity}CreateSchema.static;

// Modelo de Actualización
export const ${entity}UpdateSchema = t.Object(
  {
  ${updateFields
    .map((field) => {
      return `${field}: ${getTypeDef(fields[field])},`;
    })
    .join('\n  ')}
  },
  {
  description: 'Esquema para la actualización de un ${entity}'
  }
);

export type ${entity}Update = typeof ${entity}UpdateSchema.static;
`;

const buildBaseQuery = (entity, fields, jsonSchemas) => {
  const currentTableName = `t_${toSnakeCase(entity)}`;
  const joins = Object.entries(fields)
    .filter(([field, fieldValue]) => {
      // console.log(field);
      const { type, required, isArray, composite } = fieldValue;
      return composite && (!jsonSchemas[`${type}Schema`]);
    }).map(([field, fieldValue]) => {
      const { type, required, isArray } = fieldValue;
      return {
        tableName: `t_${toSnakeCase(field)}`,
        tableAlias: field.slice(0, 1),
        field,
        isArray,
      };
    });
    // inner join ${toSnakeCase(type)} t_${toSnakeCase(field)} on t.${toSnakeCase(field)} = t_${toSnakeCase(field)}.id
  return `
select ${currentTableName}.* ${joins.length? `, ${joins.map(({tableName , field}) => `to_jsonb(${tableName}.*) as "${field}"`).join(', ')}` : ''}
from ${currentTableName}
${joins.length? joins.map(({tableName, field}) => `inner join ${tableName} on ${tableName}.id = ${currentTableName}."${field}Id"`).join('\n') : ''}
`;
};

const crudTemplate = (entity, fields, createFields, updateFields, imports, jsonSchemas) => `
import { BaseCrud } from './base-crud';
import { ${entity}, ${entity}Create, ${entity}Update } from '../../models/${toKebabCase(entity)}';

class ${entity}Crud extends BaseCrud<${entity}, ${entity}Create, ${entity}Update> {
  constructor() {
    super('t_${toSnakeCase(entity)}');
  }

  baseQuery() {
    return \`${buildBaseQuery(entity, fields, jsonSchemas)}\`;
  }
}

export const ${toCamelCase(entity)}Crud = new ${entity}Crud()
`;

// Plantilla del archivo index.ts con OpenAPI
const indexTemplate = (entities) => `
import { Elysia, t } from 'elysia';
import { swagger } from '@elysiajs/swagger';
import { opentelemetry } from '@elysiajs/opentelemetry';
${entities.map((entity) => `import { ${toCamelCase(entity)}Controller } from './${path.relative('.', folders.controllers).replace(/\\/g, '/')}/${toKebabCase(entity)}';`).join('\n')}

const app = new Elysia()
  .use(opentelemetry())
  .use(swagger({
      documentation: {
          info: {
              title: 'API de Estacionamiento',
              version: '1.0.0',
              description: 'API para la gestión de estacionamientos, vehículos, empleados y más.'
          },
          tags: [
              ${entities.map((entity) => `{ name: '${toKebabCase(entity)}', description: 'Operaciones relacionadas con ${toKebabCase(entity)}s' }`).join(',\n    ')}
          ]
      }
  }))
  .onError(({ error, code }) => {
      if (code === 'NOT_FOUND') return 'Not Found :(';
      console.error(error);
  })
  .get('/', ({ path }) => {
      return {
          message: \`Hello from \${path}\`,
      };
  })
  ${entities.map((entity) => `.use(${toCamelCase(entity)}Controller)`).join('\n    ')}
  .listen(3000);

console.log(\`🦊 Elysia is running at http://\${app.server?.hostname}:\${app.server?.port}\`);
`;

// Crear archivos de controladores
const createControllers = () => {
  Object.entries(entities).forEach(([entity, { fields, createFields, updateFields, imports }]) => {
    // exclude Company and User from the controller
    if (entity === 'User') {
      return;
    }
    const filePath = path.join(folders.controllers, `${toKebabCase(entity)}.ts`);
    const specialFields = ['Company', 'Employee', 'User']
    const content = controllerTemplate(entity, fields, createFields, updateFields, imports, specialFields);
    fs.writeFileSync(filePath, content);
    console.log(`Controlador generado: ${filePath}`);
  });
};

// Crear archivos de servicios
const createServices = () => {
  Object.entries(entities).forEach(([entity, { fields, createFields, updateFields }]) => {
    const filePath = path.join(folders.services, `${toKebabCase(entity)}.ts`);
    const content = serviceTemplate(entity, fields, createFields, updateFields);
    fs.writeFileSync(filePath, content);
    console.log(`Servicio generado: ${filePath}`);
  });
};

// Crear archivos de modelos
const createModels = () => {
  Object.entries(entities).forEach(([entity, { fields, createFields, updateFields, imports, jsonSchemas }]) => {
    const filePath = path.join(folders.models, `${toKebabCase(entity)}.ts`);
    const content = modelTemplate(entity, fields, createFields, updateFields, imports, jsonSchemas);
    fs.writeFileSync(filePath, content);
    console.log(`Modelo generado: ${filePath}`);
  });
};

const generateCruds = () => {
  Object.entries(entities).forEach(([entity, { fields, createFields, updateFields, imports, jsonSchemas }]) => {
    const filePath = path.join(folders.crud, `${toKebabCase(entity)}.ts`);
    const content = crudTemplate(entity, fields, createFields, updateFields, imports, jsonSchemas);
    fs.writeFileSync(filePath, content);
    console.log(`Crud generado: ${filePath}`);
  });

  const indexText = `${Object.keys(entities).map((entity) => `import { ${toCamelCase(entity)}Crud } from './crud/${toKebabCase(entity)}';`).join('\n')}

  export const db = {
    ${Object.keys(entities).map((entity) => `${toCamelCase(entity)}: ${toCamelCase(entity)}Crud`).join(',\n    ')}
  };
  `
  const filePath = path.join(folders.db, 'index.ts');
  fs.writeFileSync(filePath, indexText);
  console.log(`Archivo index.ts generado: ${filePath}`);
};

// Crear archivo index.ts
const createIndexFile = () => {
  const indexFilePath = path.join(__dirname, 'index.ts');
  const content = indexTemplate(Object.keys(entities));
  fs.writeFileSync(indexFilePath, content);
  console.log(`Archivo index.ts generado: ${indexFilePath}`);
};


const generatePostgresTables = () => {
  const sqlStatements = [];

  Object.entries(entities).forEach(([entity, { fields, jsonSchemas }]) => {
    const tableName = `t_${toSnakeCase(entity)}`;
    const columns = Object.entries(fields)
      .filter(([field, fieldValue]) => {
        const { type, required, isArray, composite } = fieldValue;
        return !composite || (jsonSchemas[`${type}Schema`]);
      })
      .map(([field, fieldValue]) => {
        const { type, required, isArray } = fieldValue;
        if (field === 'id') {
          return `"${toCamelCase(field)}" text primary key not null`;
        }
        if (field === 'assignedParkings') {
          return `"${toCamelCase(field)}" jsonb not null`;
        }
        if (field === 'createdAt') {
          return `"${toCamelCase(field)}" timestamptz default now() not null`;
        }
        if (field === 'updatedAt') {
          return `"${toCamelCase(field)}" timestamptz default now()`;
        }
        if (field === 'deletedAt') {
          return `"${toCamelCase(field)}" timestamptz`;
        }
        // if (field.endsWith('Id')) {
        //   return `"${toCamelCase(field)}" text index not null`;
        // }
        let columnType;
        switch (type) {
          case 'String':
            columnType = 'text';
            break;
          case 'Integer':
            columnType = 'integer';
            break;
          case 'Numeric':
            columnType = 'numeric';
            break;
          case 'Boolean':
            columnType = 'boolean';
            break;
          case 'Date':
            columnType = 'timestamptz';
            break;
          default:
            columnType = 'jsonb';
            break;
            
        }
        return `"${toCamelCase(field)}" ${columnType} ${required ? 'not null' : ''}`;
      })
      .join(',\n  ');
    const indexes = Object.entries(fields).filter(([field, fieldSchema]) => field.endsWith('Id')).map(([field, fieldSchema]) => {
      return `create index ${tableName}_${toSnakeCase(field)} on ${tableName} ("${toCamelCase(field)}");`;
    }).join('\n');
    const sql = `
DROP TABLE IF EXISTS ${tableName};
CREATE TABLE ${tableName} (
  ${columns}
);

${indexes}
`;

    sqlStatements.push(sql);
  });

  const filePath = path.join(__dirname, 'postgres-schema.sql');
  fs.writeFileSync(filePath, sqlStatements.join('\n\n'));
  console.log(`Esquema de PostgreSQL generado: ${filePath}`);
};

// Ejecutar todos los generadores
const runGenerators = () => {
  // createControllers();
  // createServices();
  // generateCruds();
  createModels();
  generatePostgresTables();
  // createIndexFile();
};

// Ejecutar el script
runGenerators();

// .get('/:id/companies', async ({ params }) => {
//   const res = await db.$queryRawUnsafe<(Company & { parkings: Parking[] })[]>(`
//   SELECT c.*, (
//       SELECT json_agg(
//         to_jsonb(p.*)
//       ) FROM "Parking" p, jsonb_array_elements(e."assignedParkings") pa
//       WHERE p."companyId" = c.id
//       AND p.id = pa->>0
//   ) AS parkings
//   FROM "Company" c
//   INNER JOIN "Employee" e ON e."companyId" = c.id
//   INNER JOIN "User" u ON u.id = e."userId"
//   WHERE u.id = '${params.id}'
//   `);
//   return res;
// }, {
//   detail: {
//       summary: 'Obtener las companias de un user',
//       description: 'Retorna una lista de todas las companias de un user.',
//   },
//   response: {
//       200: t.Array(t.Composite([CompanySchema, 
//         t.Object({
//           parkings: t.Array(
//             t.Omit(ParkingSchema, ['company'])
//           )
//         })
//       ])),
//   }
// })