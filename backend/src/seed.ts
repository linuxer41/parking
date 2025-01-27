import { db } from './db';
import { Facility, Signage, Spot } from './models/level';
import { Price, SubscriptionPlan } from './models/parking';


function getUUID() {
  return crypto.randomUUID().toString();
}

async function main() {


  // Verificar e insertar usuario por defecto
  const defaultUser = {
    id: getUUID(),
    name: "Usuario Admin",
    email: "admin@example.com",
    // password: await bcrypt.hash("password123", 10), // Generar contraseña con bcrypt
    password: await Bun.password.hash("password123")
  };

  let user = await db.user.findUnique({
    where: { email: defaultUser.email },
  });
  if (!user) {
    user = await db.user.create({ data: defaultUser });
  }

  // Verificar e insertar compañía
  const defaultCompany = {
    id: getUUID(),
    name: "Estacionamiento Central",
    userId: user.id,
    email: "company@example.com",
    phone: "123456789",
    logoUrl: "https://example.com/logo.png",
    params: {
      slogan: "Estacionamiento Central"
    }
  };

  let company = await db.company.findFirst({
    where: { userId: defaultCompany.userId },
  });
  if (!company) {
    company = await db.company.create({ data: defaultCompany });
  }

    // Verificar e insertar estacionamiento
    const defaultParking = {
      id: getUUID(),
      name: "Estacionamiento Centro",
      companyId: company.id,
      vehicleTypes: [{
        id: 1,
        name: "Automóvil",
        description: "Vehículo de automóvil",
      }, {
        id: 2,
        name: "Motocicleta",
        description: "Vehículo de motocicleta",
      }, {
        id: 3,
        name: "Camión",
        description: "Vehículo de camión",
      }],
      params: {
        currency: "BOB",
        timeZone: "America/La_Paz",
        decimalPlaces: 2,
        theme: "dark",
      },
      prices: [
        {
          id: getUUID(),
          name: "Vicicleta",
          baseTime: 30,
          tolerance: 5,
          pasePrice: 0.5,
        },
        {
          id: getUUID(),
          name: "Motocicleta",
          baseTime: 30,
          tolerance: 5,
          pasePrice: 1,
        },
        {
          id: getUUID(),
          name: "Vehiculo liviano",
          baseTime: 30,
          tolerance: 5,
          pasePrice: 1.5,
        },
        {
          id: getUUID(),
          name: "Vehiculo pesado",
          baseTime: 30,
          tolerance: 10,
          pasePrice: 3,
        }
      ] as Price[],
      subscriptionPlans: [
        {
          id: getUUID(),
          name: "Plan diario",
          description: "Plan diario",
          price: 5,
          duration: 1,
        },
        {
          id: getUUID(),
          name: "Plan mensual",
          description: "Plan mensual",
          price: 150,
          duration: 30,
        }
      ] as SubscriptionPlan[],
    };
  
    let parking = await db.parking.findFirst({
      where: { companyId: defaultParking.companyId },
    });
    if (!parking) {
      parking = await db.parking.create({ data: defaultParking });
    }

  // Verificar e insertar empleado
  const defaultEmployee = {
    id: getUUID(),
    userId: user.id,
    companyId: company.id,
    role: "supervisor",
    assignedParkings: [parking.id],
  };

  let employee = await db.employee.findFirst({
    where: { userId: defaultEmployee.userId, companyId: defaultEmployee.companyId },
  });
  if (!employee) {
    employee = await db.employee.create({ data: defaultEmployee });
  }


  const defaultSignages: Signage[] = [];
  const defaultFacilities: Facility[] = [];
  const defaultSpots: Spot[] = [];

  // Configuración
  const cuadroSize = 15; // Cada cuadro son 15 píxeles
  const spotWidth = 4 * cuadroSize; // Ancho de un spot (60 píxeles)
  const spotHeight = 8 * cuadroSize; // Largo de un spot (120 píxeles)
  const columnSpacing = 1 * cuadroSize; // Separación entre columnas (15 píxeles)
  const rowSpacing = 5 * cuadroSize; // Separación entre filas (75 píxeles)

  // Dimensiones de los indicadores y oficinas
  const indicatorWidth = 4 * cuadroSize; // Ancho del indicador (60 píxeles)
  const indicatorHeight = 2 * cuadroSize; // Alto del indicador (30 píxeles)
  const officeSize = 8 * cuadroSize; // Tamaño de la oficina (120 píxeles de ancho y alto)

  // Número de filas y columnas
  const rows = 3; // 3 filas (1 fila de spots, 1 fila de señales, 1 fila de spots)
  const columns = 15; // 15 columnas de spots

  // Posición inicial
  let offsetX = 0;
  let offsetY = 0;

  // Agregar la primera oficina en la posición inicial
  defaultFacilities.push({
      id: getUUID(),
      posX: offsetX,
      posY: offsetY,
      posZ: 0,
      rotation: 0,
      scale: 1,
      name: "Oficina",
      facilityType: 0, // Oficina
  });

  // Ajustar el offsetY para la siguiente fila
  offsetY += officeSize + rowSpacing;

  // Generar los spots en la primera fila
  for (let col = 0; col < columns; col++) {
      const posX = col * (spotWidth + columnSpacing);
      const posY = offsetY;

      defaultSpots.push({
          id: getUUID(),
          name: `A ${col + 1}`,
          posX,
          posY,
          posZ: 0,
          rotation: 0,
          scale: 1,
          vehicleId: '',
          spotType: 0,
          spotCategory: 0,
      });
  }

  // Ajustar el offsetY para la fila de señales
  offsetY += spotHeight + rowSpacing;

  // Generar los indicadores (entrada y salida) en la segunda fila
  const posYSignals = offsetY - rowSpacing / 2;

  // Indicador de entrada (izquierda)
  defaultSignages.push({
      id: getUUID(),
      posX: 0,
      posY: posYSignals - indicatorHeight / 2,
      posZ: 0,
      rotation: 0,
      scale: 1,
      direction: 0, // derecha
      signageType: 0, // Entrada
  });

  // Indicador de salida (derecha)
  defaultSignages.push({
      id: getUUID(),
      posX: columns * (spotWidth + columnSpacing) - indicatorWidth,
      posY: posYSignals - indicatorHeight / 2,
      posZ: 0,
      rotation: 0,
      scale: 1,
      direction: 0, // derecha
      signageType: 1, // Salida
  });

  // Ajustar el offsetY para la tercera fila de spots
  offsetY += rowSpacing;

  // Generar los spots en la tercera fila
  for (let col = 0; col < columns; col++) {
      const posX = col * (spotWidth + columnSpacing);
      const posY = offsetY;

      defaultSpots.push({
          id: getUUID(),
          name: `B ${ col + 1}`,
          posX,
          posY,
          posZ: 0,
          rotation: 0,
          scale: 1,
          vehicleId: '',
          spotType: 0,
          spotCategory: 0,
      });
  }

  // Generar la oficina en la parte superior derecha
  defaultFacilities.push({
      id: getUUID(),
      posX: columns * (spotWidth + columnSpacing) - officeSize,
      posY: 0,
      posZ: 0,
      rotation: 0,
      scale: 1,
      name: "Oficina",
      facilityType: 0, // Oficina
  });

  // Verificar e insertar nivel
  const defaultLevel = {
    id: getUUID(),
    name: "Nivel 1",
    parkingId: parking.id,
    spots: defaultSpots,
    signages: defaultSignages,
    facilities: defaultFacilities,
  };

  let level = await db.level.findUnique({
    where: { name: defaultLevel.name },
  });
  if (!level) {
    level = await db.level.create({ data: defaultLevel });
  }
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    // await db.$disconnect();
    console.log('Seed finalizado');
  });