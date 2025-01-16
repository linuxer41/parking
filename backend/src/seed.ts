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

  const defaultSpots = Array.from({ length: 25 }, (_, i) => {
    const x0 =  2 * i;
    const y0 = 4 * i;
    return {
    id: getUUID(),
    name: `Lugar ${i + 1}`,
    coordinates: { x0: x0, y0: y0, x1: x0 + 2, y1: y0 + 4 },
    status: "free",
    parkingId: parking.id,
  }});

  let spots = await db.spot.findMany({
    where: { parkingId: defaultSpots[0].parkingId },
  });
  if (spots.length === 0) {
    for (const spot of defaultSpots) {
      spots.push(await db.spot.create({ data: spot }));
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