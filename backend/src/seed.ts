import { pool } from "./db/connection";
import { Rate } from "./models/parking";
import { ELEMENT_TYPES, ELEMENT_STATUS, SPOT_SUBTYPES, FACILITY_SUBTYPES, SIGNAGE_SUBTYPES } from "./models/parking";

function getUUID() {
  return crypto.randomUUID().toString();
}

// Configuración de dimensiones para elementos
const ELEMENT_CONFIG = {
  // Dimensiones basadas en el código Flutter para vehículos normales
  spotWidth: 80.0,
  spotHeight: 160.0,
  columnSpacing: 20.0,
  rowSpacing: 40.0,
  officeSize: 120.0,
  indicatorWidth: 60.0,
  indicatorHeight: 30.0,
};

// Tarifas base para estacionamientos
const BASE_RATES: Rate[] = [
  {
    id: getUUID(),
    name: "Bicicleta",
    vehicleCategory: 1,
    tolerance: 10,
    hourly: 1.5 + Math.random() * 1.5,
    daily: 8.0 + Math.random() * 4,
    weekly: 40.0 + Math.random() * 10,
    monthly: 150.0 + Math.random() * 30,
    yearly: 1500.0 + Math.random() * 300,
    isActive: true,
  },
  {
    id: getUUID(),
    name: "Motocicleta",
    vehicleCategory: 2,
    tolerance: 10,
    hourly: 2.5 + Math.random() * 2,
    daily: 12.0 + Math.random() * 6,
    weekly: 60.0 + Math.random() * 20,
    monthly: 220.0 + Math.random() * 60,
    yearly: 2200.0 + Math.random() * 600,
    isActive: true,
  },
  {
    id: getUUID(),
    name: "Vehículo liviano",
    vehicleCategory: 3,
    tolerance: 10,
    hourly: 4.0 + Math.random() * 3,
    daily: 20.0 + Math.random() * 10,
    weekly: 100.0 + Math.random() * 40,
    monthly: 350.0 + Math.random() * 100,
    yearly: 3500.0 + Math.random() * 1000,
    isActive: true,
  },
  {
    id: getUUID(),
    name: "Vehículo pesado",
    vehicleCategory: 4,
    tolerance: 15,
     hourly: 7.0 + Math.random() * 3,
    daily: 35.0 + Math.random() * 10,
    weekly: 180.0 + Math.random() * 40,
    monthly: 650.0 + Math.random() * 100,
    yearly: 6500.0 + Math.random() * 1000,
    isActive: true,
  },
];

// Configuración de parámetros base para estacionamientos
const BASE_PARAMS = {
  currency: "BOB",
  timeZone: "America/La_Paz",
  decimalPlaces: 2,
  theme: "dark",
  countryCode: "BO",
};

// Función para generar dirección según ubicación
function generateAddress(location: string): string {
  const addresses = {
    "Zona Norte": `Av. América Norte #${Math.floor(Math.random() * 1000) + 100}, ${location}`,
    "Zona Sur": `Calle Los Pinos #${Math.floor(Math.random() * 1000) + 100}, ${location}`,
    "Zona Este": `Av. Banzer #${Math.floor(Math.random() * 1000) + 100}, ${location}`,
    "Centro": `Calle Principal #${Math.floor(Math.random() * 1000) + 100}, ${location}`,
  };
  return addresses[location as keyof typeof addresses] || addresses["Centro"];
}

// Función para crear elementos en una cuadrícula
function createGridElements(
  startX: number,
  startY: number,
  columns: number,
  rows: number,
  prefix: string,
  areaId: string,
  parkingId: string,
  type: string = 'spot'
): any[] {
  const elements: any[] = [];
  
  for (let row = 0; row < rows; row++) {
    for (let col = 0; col < columns; col++) {
      const posX = startX + col * (ELEMENT_CONFIG.spotWidth + ELEMENT_CONFIG.columnSpacing);
      const posY = startY + row * (ELEMENT_CONFIG.spotHeight + ELEMENT_CONFIG.rowSpacing);
      
      elements.push({
        id: getUUID(),
        areaId,
        parkingId,
        name: `${prefix}${row + 1}-${col + 1}`,
        type,
        subType: type === 'spot' ? SPOT_SUBTYPES.CAR : 1,
        posX,
        posY,
        posZ: 0,
        rotation: 0,
        scale: 1,
        isActive: true,
      });
    }
  }
  
  return elements;
}

// Función para crear elementos de oficina
function createOfficeElement(areaId: string, parkingId: string, name: string, posX: number, posY: number) {
  return {
    id: getUUID(),
    areaId,
    parkingId,
    name,
    type: ELEMENT_TYPES.FACILITY,
    subType: FACILITY_SUBTYPES.OFFICE,
    posX,
    posY,
    posZ: 0,
    rotation: 0,
    scale: 1,
    isActive: true,
  };
}

// Función para crear elementos de señalización
function createSignageElement(areaId: string, parkingId: string, name: string, subType: number, posX: number, posY: number) {
  return {
    id: getUUID(),
    areaId,
    parkingId,
    name,
    type: ELEMENT_TYPES.SIGNAGE,
    subType,
    posX,
    posY,
    posZ: 0,
    rotation: 0,
    scale: 1,
    isActive: true,
  };
}

// Función para crear un área con elementos
async function createArea(parkingId: string, name: string, level: number): Promise<string> {
  const areaId = getUUID();
  const createdAt = new Date().toISOString();
  
  // Crear área con query plano
  await pool.query(`
    INSERT INTO t_area ("id", "createdAt", "name", "parkingId")
    VALUES ($1, $2, $3, $4)
  `, [areaId, createdAt, name, parkingId]);
  
  const elements: any[] = [];
  
  // Configuraciones de spots según el nivel
  const spotConfigs = {
    1: [
      { startX: ELEMENT_CONFIG.officeSize + ELEMENT_CONFIG.columnSpacing, startY: 0, cols: 8, rows: 1, prefix: "A" },
      { startX: ELEMENT_CONFIG.officeSize + ELEMENT_CONFIG.columnSpacing, startY: ELEMENT_CONFIG.spotHeight + ELEMENT_CONFIG.rowSpacing * 2, cols: 1, rows: 4, prefix: "B" },
      { startX: ELEMENT_CONFIG.officeSize + ELEMENT_CONFIG.columnSpacing + 7 * (ELEMENT_CONFIG.spotWidth + ELEMENT_CONFIG.columnSpacing), startY: ELEMENT_CONFIG.spotHeight + ELEMENT_CONFIG.rowSpacing * 2, cols: 1, rows: 4, prefix: "C" },
      { startX: ELEMENT_CONFIG.officeSize + ELEMENT_CONFIG.columnSpacing + ELEMENT_CONFIG.spotWidth + ELEMENT_CONFIG.columnSpacing, startY: ELEMENT_CONFIG.spotHeight + ELEMENT_CONFIG.rowSpacing * 2 + 3 * (ELEMENT_CONFIG.spotHeight + ELEMENT_CONFIG.rowSpacing), cols: 6, rows: 1, prefix: "D" },
    ],
    2: [
      { startX: 0, startY: 0, cols: 10, rows: 2, prefix: "A" },
      { startX: 0, startY: ELEMENT_CONFIG.spotHeight * 2 + ELEMENT_CONFIG.rowSpacing * 3, cols: 10, rows: 2, prefix: "C" },
      { startX: 0, startY: (ELEMENT_CONFIG.spotHeight * 2 + ELEMENT_CONFIG.rowSpacing * 3) * 2, cols: 10, rows: 2, prefix: "E" },
    ],
    default: [
      { startX: 0, startY: 0, cols: 8, rows: 6, prefix: String.fromCharCode(65 + level - 3) },
    ]
  };
  
  const config = spotConfigs[level as keyof typeof spotConfigs] || spotConfigs.default;
  
  // Crear spots
  config.forEach(({ startX, startY, cols, rows, prefix }) => {
    elements.push(...createGridElements(startX, startY, cols, rows, prefix, areaId, parkingId, 'spot'));
  });
  
  // Agregar oficinas
  elements.push(createOfficeElement(areaId, parkingId, "Oficina Principal", 0, 0));
  elements.push(createOfficeElement(areaId, parkingId, "Sala de Control", 
    8 * (ELEMENT_CONFIG.spotWidth + ELEMENT_CONFIG.columnSpacing) - ELEMENT_CONFIG.officeSize,
    6 * (ELEMENT_CONFIG.spotHeight + ELEMENT_CONFIG.rowSpacing) - ELEMENT_CONFIG.officeSize
  ));
  
  // Agregar señales básicas
  elements.push(createSignageElement(areaId, parkingId, "Entrada", SIGNAGE_SUBTYPES.ENTRANCE, 
    ELEMENT_CONFIG.spotWidth * 2, ELEMENT_CONFIG.spotHeight * 2));
  elements.push(createSignageElement(areaId, parkingId, "Salida", SIGNAGE_SUBTYPES.EXIT, 
    ELEMENT_CONFIG.spotWidth * 6, ELEMENT_CONFIG.spotHeight * 2));
  
  // Agregar señales adicionales para niveles > 1
  if (level > 1) {
    elements.push(createSignageElement(areaId, parkingId, "Rampa", SIGNAGE_SUBTYPES.DIRECTION, 
      ELEMENT_CONFIG.spotWidth * 4, ELEMENT_CONFIG.spotHeight * 1));
    elements.push(createSignageElement(areaId, parkingId, "Escalera", SIGNAGE_SUBTYPES.DIRECTION, 
      ELEMENT_CONFIG.spotWidth * 4, ELEMENT_CONFIG.spotHeight * 5));
  }
  
  // Insertar todos los elementos con queries planos
  for (const element of elements) {
    const elementCreatedAt = new Date().toISOString();
    const columns = Object.keys(element)
      .map((key) => `"${key}"`)
      .join(", ");
    const values = Object.values(element).map((value) => {
      if (typeof value === "object") {
        return JSON.stringify(value);
      }
      return value;
    });
    const placeholders = values.map((_, i) => `$${i + 1}`).join(", ");
    
    await pool.query(`
      INSERT INTO t_element (${columns}, "createdAt")
      VALUES (${placeholders}, $${values.length + 1})
    `, [...values, elementCreatedAt]);
  }
  
  return areaId;
}

// Función para crear un estacionamiento
async function createParking(name: string, ownerId: string, numAreas: number = 3, location: string = "Centro"): Promise<string> {
  const parkingId = getUUID();
  const createdAt = new Date().toISOString();
  
  const parkingData = {
    id: parkingId,
    name: `Estacionamiento ${name}`,
    email: `parking.${name.toLowerCase()}@example.com`,
    phone: `${Math.floor(Math.random() * 900000) + 100000}`,
    address: generateAddress(location),
    logoUrl: `https://example.com/logo-${name.toLowerCase()}.png`,
    status: "active",
    ownerId,
    params: {
      ...BASE_PARAMS,
      theme: Math.random() > 0.5 ? "dark" : "light",
      slogan: `Estacionamiento ${name} - ${location}`,
    },
    rates: BASE_RATES.map(rate => ({ ...rate, id: getUUID() })),
    operationMode: "map",
  };

  // Crear parking con query plano
  const parkingColumns = Object.keys(parkingData)
    .map((key) => `"${key}"`)
    .join(", ");
  const parkingValues = Object.values(parkingData).map((value) => {
    if (typeof value === "object") {
      return JSON.stringify(value);
    }
    return value;
  });
  const parkingPlaceholders = parkingValues.map((_, i) => `$${i + 1}`).join(", ");
  
  await pool.query(`
    INSERT INTO t_parking (${parkingColumns}, "createdAt")
    VALUES (${parkingPlaceholders}, $${parkingValues.length + 1})
  `, [...parkingValues, createdAt]);
  
  // Crear áreas
  for (let i = 1; i <= numAreas; i++) {
    await createArea(parkingId, `Nivel ${i}`, i);
  }
  
  // Crear empleado con query plano
  const employeeId = getUUID();
  const employeeCreatedAt = new Date().toISOString();
  await pool.query(`
    INSERT INTO t_employee ("id", "createdAt", "userId", "parkingId", "role")
    VALUES ($1, $2, $3, $4, $5)
  `, [employeeId, employeeCreatedAt, ownerId, parkingId, "operator"]);
  
  return parkingId;
}

async function main() {
  // Crear usuario por defecto
  const defaultUserId = getUUID();
  const defaultUserCreatedAt = new Date().toISOString();
  const defaultUser = {
    id: defaultUserId,
    name: "Usuario Admin",
    email: "admin@example.com",
    passwordHash: await Bun.password.hash("password123"),
    phone: "123456789",
  };

  // Verificar si el usuario ya existe
  const existingUsers = await pool.query(`
    SELECT * FROM t_user WHERE "email" = $1
  `, [defaultUser.email]);
  
  let user = existingUsers.rows[0];
  if (!user) {
    // Crear usuario con query plano
    await pool.query(`
      INSERT INTO t_user ("id", "createdAt", "name", "email", "passwordHash", "phone")
      VALUES ($1, $2, $3, $4, $5, $6)
    `, [defaultUser.id, defaultUserCreatedAt, defaultUser.name, defaultUser.email, defaultUser.passwordHash, defaultUser.phone]);
    user = defaultUser;
  }

  // Crear estacionamiento por defecto
  const defaultParkingId = getUUID();
  const defaultParkingCreatedAt = new Date().toISOString();
  const defaultParking = {
    id: defaultParkingId,
    name: "Estacionamiento Centro",
    email: "parking@example.com",
    phone: "123456789",
    address: "Av. Central #123, Zona Centro",
    logoUrl: "https://example.com/logo.png",
    status: "active",
    ownerId: user.id,
    params: {
      ...BASE_PARAMS,
      slogan: "Estacionamiento Central",
    },
    rates: BASE_RATES.map(rate => ({ ...rate, id: getUUID() })),
    operationMode: "map",
  };

  // Verificar si el parking ya existe
  const existingParkings = await pool.query(`
    SELECT * FROM t_parking WHERE "ownerId" = $1
  `, [defaultParking.ownerId]);
  
  let parking = existingParkings.rows[0];
  if (!parking) {
    // Crear parking con query plano
    const parkingColumns = Object.keys(defaultParking)
      .map((key) => `"${key}"`)
      .join(", ");
    const parkingValues = Object.values(defaultParking).map((value) => {
      if (typeof value === "object") {
        return JSON.stringify(value);
      }
      return value;
    });
    const parkingPlaceholders = parkingValues.map((_, i) => `$${i + 1}`).join(", ");
    
    await pool.query(`
      INSERT INTO t_parking (${parkingColumns}, "createdAt")
      VALUES (${parkingPlaceholders}, $${parkingValues.length + 1})
    `, [...parkingValues, defaultParkingCreatedAt]);
    parking = defaultParking;
  }

  // Crear empleado por defecto
  const defaultEmployeeId = getUUID();
  const defaultEmployeeCreatedAt = new Date().toISOString();
  const defaultEmployee = {
    id: defaultEmployeeId,
    userId: user.id,
    parkingId: parking.id,
    role: "supervisor",
  };

  // Verificar si el empleado ya existe
  const existingEmployees = await pool.query(`
    SELECT * FROM t_employee WHERE "userId" = $1 AND "parkingId" = $2
  `, [defaultEmployee.userId, defaultEmployee.parkingId]);
  
  let employee = existingEmployees.rows[0];
  if (!employee) {
    // Crear empleado con query plano
    await pool.query(`
      INSERT INTO t_employee ("id", "createdAt", "userId", "parkingId", "role")
      VALUES ($1, $2, $3, $4, $5)
    `, [defaultEmployee.id, defaultEmployeeCreatedAt, defaultEmployee.userId, defaultEmployee.parkingId, defaultEmployee.role]);
    employee = defaultEmployee;
  }

  // Crear área por defecto si no existe
  const existingAreas = await pool.query(`
    SELECT * FROM t_area WHERE "name" = $1 AND "parkingId" = $2
  `, ["Nivel 1", parking.id]);
  
  let area = existingAreas.rows[0];
  
  if (!area) {
    await createArea(parking.id, "Nivel 1", 1);
  }
  
  // Crear estacionamientos adicionales
  console.log("Creando estacionamientos adicionales...");
  await createParking("Norte", user.id, 4, "Zona Norte");
  await createParking("Sur", user.id, 3, "Zona Sur");
  await createParking("Este", user.id, 2, "Zona Este");
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    console.log("Seed finalizado");
  });
