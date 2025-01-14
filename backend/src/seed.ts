import { db } from './db';


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
        pasePrice: 30,
        baseTime: 30,
        currency: "BOB",
        timeZone: "America/La_Paz",
        decimalPlaces: 2,
        theme: "dark",
      },
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


  // Verificar e insertar nivel
  const defaultLevel = {
    id: getUUID(),
    name: "Nivel 1",
    parkingId: parking.id,
  };

  let level = await db.level.findUnique({
    where: { id: defaultLevel.id },
  });
  if (!level) {
    level = await db.level.create({ data: defaultLevel });
  }

  // Verificar e insertar áreas
  const defaultAreas = Array.from({ length: 2 }, (_, i) => ({
    id: getUUID(),
    name: `Área ${i + 1}`,
    parkingId: parking.id,
    levelId: level.id,
  }));

  let areas = await db.area.findMany({
    where: { parkingId: defaultAreas[0].parkingId },
  });
  if (areas.length === 0) {
    for (const area of defaultAreas) {
      areas.push(await db.area.create({ data: area }));
    }
  }

  // Verificar e insertar lugares de estacionamiento

  for (const area of areas) {
    const defaultSpots = Array.from({ length: 25 }, (_, i) => ({
      id: getUUID(),
      name: `Lugar ${i + 1}`,
      coordinates: { x0: 0, y0: 0, x1: 10, y1: 10 },
      status: "free",
      parkingId: parking.id,
      areaId: area.id,
    }));

    let spots = await db.spot.findMany({
      where: { parkingId: defaultSpots[0].parkingId, areaId: defaultSpots[0].areaId },
    });
    if (spots.length === 0) {
      for (const spot of defaultSpots) {
        spots.push(await db.spot.create({ data: spot }));
      }
    }
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