import { getSchemaValidator } from "elysia";
import { PoolClient } from "pg";
import { withTransaction } from "../db/connection";
import { db } from "../db";
import { CompleteRegistration } from "../models/auth";
import { Area, AreaCreateSchema, Element, ELEMENT_TYPES, SPOT_SUBTYPES } from "../models/parking";
import { Employee, EmployeeCreateSchema } from "../models/employee";
import { Parking, ParkingCreateSchema } from "../models/parking";
import { User, UserCreateSchema } from "../models/user";
import { ConflictError } from "../utils/error";

export interface RegistrationResult {
  user: User;
  parking: Parking;
  area: Area;
  spots: Element[];
  employee: Employee;
}

export class RegistrationService {
  /**
   * Registra un usuario completo con su estacionamiento, área, spots y empleado
   * @param data - Datos del registro completo
   * @returns Resultado del registro con todos los elementos creados
   */
  async registerComplete(data: CompleteRegistration): Promise<RegistrationResult> {
    // Verificar si el usuario ya existe
    const existingUsers = await db.user.find({ email: data.user.email });
    
    if (existingUsers.length > 0) {
      throw new ConflictError(`Ya existe un usuario con el email ${data.user.email}`);
    }

    return await withTransaction(async (client) => {
      const { password, ...restUserData } = data.user;
      const validator = getSchemaValidator(UserCreateSchema);
      const userData = validator.parse({
        ...restUserData,
        passwordHash: await Bun.password.hash(password),
        id: crypto.randomUUID(),
        createdAt: new Date().toISOString(),
      });
      
      const userQueryRes = await client.query<User>(`
        INSERT INTO t_user ("id", "createdAt", "name", "email", "passwordHash", "phone")
        VALUES ($1, $2, $3, $4, $5, $6)
        ON CONFLICT ("email") DO NOTHING
        RETURNING *
      `, [userData.id, userData.createdAt, userData.name, userData.email, userData.passwordHash, userData.phone]);

      const user = userQueryRes.rows[0];
      // console.log("user", user);
      
      // 2. Generar datos por defecto del parking
      // let location: any = null;
      let address = data.parking.address || "Dirección por defecto";
      
      // TODO: Implementar geocoding para obtener la dirección
      // if (data.parking.location && data.parking.location.lat && data.parking.location.lng) {
      //   location = await this.getLocationFromCoordinates(data.parking.location.lat, data.parking.location.lng);
      //   // Si no se proporcionó dirección pero sí coordenadas, usar la dirección obtenida
      //   if (!data.parking.address && location?.address) {
      //     address = location.address;
      //   }
      // }
      
      // 3. Crear el parking con datos por defecto
      const parkingValidator = getSchemaValidator(ParkingCreateSchema);
      const parkingData = parkingValidator.parse({
        name: data.parking.name,
        email: data.user.email,
        phone: data.user.phone,
        address: address,
        operationMode: data.parking.operationMode || "map",
        logoUrl: undefined,
        ownerId: user.id,
        status: "active",
        params: this.generateDefaultParams(),
        rates: this.generateDefaultRates(),
        id: crypto.randomUUID(),
        createdAt: new Date().toISOString(),
      });

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
      
      const parkingQueryRes = await client.query<Parking>(`
        INSERT INTO t_parking (${parkingColumns}) VALUES (${parkingPlaceholders}) RETURNING *
      `, parkingValues);

      const parking = parkingQueryRes.rows[0];
      // console.log("parking", parking);
      
      // 3. Crear el empleado (el usuario como empleado del parking)
      const employeeValidator = getSchemaValidator(EmployeeCreateSchema);
      const employeeData = employeeValidator.parse({
        userId: user.id,
        parkingId: parking.id,
        role: "owner",
        id: crypto.randomUUID(),
        createdAt: new Date().toISOString(),
      });
      
      const employeeQueryRes = await client.query<Employee>(`
        INSERT INTO t_employee ("id", "createdAt", "parkingId", "role", "userId")
        VALUES ($1, $2, $3, $4, $5)
        RETURNING *
      `, [employeeData.id, employeeData.createdAt, employeeData.parkingId, employeeData.role, employeeData.userId]);

      const employee = employeeQueryRes.rows[0];
      // console.log("employee", employee);
      
      // 4. Crear un área por defecto
      const areaValidator = getSchemaValidator(AreaCreateSchema);
      const areaData = areaValidator.parse({
        name: "Área Principal",
        parkingId: parking.id,
        id: crypto.randomUUID(),
        createdAt: new Date().toISOString(),
      });
      
      const areaQueryRes = await client.query<Area>(`
        INSERT INTO t_area ("id", "createdAt", "name", "parkingId")
        VALUES ($1, $2, $3, $4)
        RETURNING *
      `, [areaData.id, areaData.createdAt, areaData.name, areaData.parkingId]);

      const area = areaQueryRes.rows[0];
      // console.log("area", area);
      // 5. Crear spots - 20 spots por defecto siempre
      const spots = await this.createSpotsWithClient(
        client, 
        area.id, 
        parking.id, 
        20
      );
      // console.log("spots", spots);
      return {
        user,
        parking,
        area,
        spots,
        employee,
      };
    });
  }

  private async createSpotsWithClient(client: PoolClient, areaId: string, parkingId: string, capacity: number) {
    const spots = [];
    
    // Configuración de dimensiones basada en el seed
    const ELEMENT_CONFIG = {
      spotWidth: 80.0,
      spotHeight: 160.0,
      columnSpacing: 20.0,
      rowSpacing: 40.0,
    };
    
    // Calcular dimensiones de la cuadrícula para crear un layout cuadrado
    const gridSize = Math.ceil(Math.sqrt(capacity));
    const cols = gridSize;
    const rows = Math.ceil(capacity / cols);
    
    let spotIndex = 1;
    
    for (let row = 0; row < rows && spotIndex <= capacity; row++) {
      for (let col = 0; col < cols && spotIndex <= capacity; col++) {
        const posX = col * (ELEMENT_CONFIG.spotWidth + ELEMENT_CONFIG.columnSpacing);
        const posY = row * (ELEMENT_CONFIG.spotHeight + ELEMENT_CONFIG.rowSpacing);
        
        const spotData = {
          areaId,
          parkingId,
          name: `Spot ${spotIndex.toString().padStart(3, '0')}`,
          type: ELEMENT_TYPES.SPOT,
          subType: SPOT_SUBTYPES.CAR, // Tipo vehicle (CAR = 3)
          posX,
          posY,
          posZ: 0,
          rotation: 0,
          scale: 1,
          isActive: true,
        };
        
        const columns = Object.keys(spotData)
          .map((key) => `"${key}"`)
          .join(", ");
        const values = Object.values(spotData);
        const placeholders = values.map((_, i) => `$${i + 1}`).join(", ");
        const sql = `INSERT INTO t_element (${columns}) VALUES (${placeholders}) RETURNING *`;
        
        const result = await client.query(sql, values);
        spots.push(result.rows[0]);
        
        spotIndex++;
      }
    }
    
    return spots;
  }

  /**
   * Genera parámetros por defecto para el parking
   */
  private generateDefaultParams() {
    return {
      currency: "BOB",
      timeZone: "America/La_Paz",
      decimalPlaces: 2,
      countryCode: "BO",
      theme: "default",
      slogan: "Tu estacionamiento de confianza"
    };
  }

  /**
   * Genera tarifas por defecto para el parking
   */
  private generateDefaultRates() {
    return [
      {
        id: crypto.randomUUID(),
        name: "Tarifa Bicicleta",
        vehicleCategory: 0,
        tolerance: 30,
        hourly: 3.50,
        daily: 35.00,
        weekly: 200.00,
        monthly: 700.00,
        yearly: 7000.00,
        isActive: true
      },
      {
        id: crypto.randomUUID(),
        name: "Tarifa Motocicleta",
        vehicleCategory: 1,
        tolerance: 15,
        hourly: 2.50,
        daily: 25.00,
        weekly: 150.00,
        monthly: 500.00,
        yearly: 5000.00,
        isActive: true
      },
      {
        id: crypto.randomUUID(),
        name: "Tarifa Vehículo",
        vehicleCategory: 2,
        tolerance: 30,
        hourly: 3.50,
        daily: 35.00,
        weekly: 200.00,
        monthly: 700.00,
        yearly: 7000.00,
        isActive: true
      },
      {
        id: crypto.randomUUID(),
        name: "Tarifa Camion",
        vehicleCategory: 3,
        tolerance: 15,
        hourly: 2.50,
        daily: 25.00,
        weekly: 150.00,
        monthly: 500.00,
        yearly: 5000.00,
        isActive: true
      },
    ];
  }

  /**
   * Obtiene la ubicación desde coordenadas usando el servicio de geocodificación
   */
  private async getLocationFromCoordinates(lat: number, lon: number) {
    const { reverseGeocodingAPI } = await import("../utils/geoapify");
    return await reverseGeocodingAPI(lat, lon);
  }
}

export const registrationService = new RegistrationService();
