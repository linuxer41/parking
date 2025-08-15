import { CompleteRegistration } from "../models/auth";
import { userCrud } from "../db/crud/user";
import { parkingCrud } from "../db/crud/parking";
import { areaCrud } from "../db/crud/area";
import { elementCrud } from "../db/crud/element";
import { employeeCrud } from "../db/crud/employee";
import { ELEMENT_TYPES, SPOT_SUBTYPES, ELEMENT_STATUS } from "../models/element";

export interface RegistrationResult {
  user: any;
  parking: any;
  area: any;
  spots: any[];
  employee: any;
}

export class RegistrationService {
  /**
   * Registra un usuario completo con su estacionamiento, área, spots y empleado
   * @param data - Datos del registro completo
   * @returns Resultado del registro con todos los elementos creados
   */
  async registerComplete(data: CompleteRegistration): Promise<RegistrationResult> {
    return await userCrud.withTransaction(async (client) => {
      // 1. Crear el usuario
      const userData = {
        id: crypto.randomUUID(),
        ...data.user,
        password: await Bun.password.hash(data.user.password),
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
      };
      
      const user = await this.createUserWithClient(client, userData);
      
      // 2. Generar datos por defecto del parking
      let location: any = null;
      let address = data.parking.address || "Dirección por defecto";
      
      if (data.parking.location && Array.isArray(data.parking.location) && data.parking.location.length === 2) {
        const [lat, lon] = data.parking.location;
        location = await this.getLocationFromCoordinates(lat, lon);
        // Si no se proporcionó dirección pero sí coordenadas, usar la dirección obtenida
        if (!data.parking.address && location?.address) {
          address = location.address;
        }
      }
      
      // 3. Crear el parking con datos por defecto
      const parkingData = {
        id: crypto.randomUUID(),
        name: data.parking.name,
        email: `${data.user.email.split('@')[0]}_parking@${data.user.email.split('@')[1]}`,
        phone: data.user.phone,
        address: address,
        logoUrl: null,
        ownerId: user.id,
        status: "active",
        operationMode: data.parking.operationMode || "visual",
        capacity: data.parking.capacity,
        params: this.generateDefaultParams(),
        rates: this.generateDefaultRates(),
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
      };
      
      const parking = await this.createParkingWithClient(client, parkingData);
      
      // 3. Crear el empleado (el usuario como empleado del parking)
      const employeeData = {
        id: crypto.randomUUID(),
        userId: user.id,
        parkingId: parking.id,
        role: "owner",
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
      };
      
      const employee = await this.createEmployeeWithClient(client, employeeData);
      
      // 4. Crear un área por defecto
      const areaData = {
        id: crypto.randomUUID(),
        name: "Área Principal",
        parkingId: parking.id,
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
      };
      
      const area = await this.createAreaWithClient(client, areaData);
      
      // 5. Crear spots basados en la capacidad
      const spots = await this.createSpotsWithClient(
        client, 
        area.id, 
        parking.id, 
        data.parking.capacity
      );
      
      return {
        user,
        parking,
        area,
        spots,
        employee,
      };
    });
  }

  private async createUserWithClient(client: any, userData: any) {
    const columns = Object.keys(userData)
      .map((key) => `"${key}"`)
      .join(", ");
    const values = Object.values(userData);
    const placeholders = values.map((_, i) => `$${i + 1}`).join(", ");
    const sql = `INSERT INTO t_user (${columns}) VALUES (${placeholders}) RETURNING *`;
    
    const result = await client.query(sql, values);
    return result.rows[0];
  }

  private async createParkingWithClient(client: any, parkingData: any) {
    const columns = Object.keys(parkingData)
      .map((key) => `"${key}"`)
      .join(", ");
    const values = Object.values(parkingData).map((value) =>
      typeof value === "object" ? JSON.stringify(value) : value
    );
    const placeholders = values.map((_, i) => `$${i + 1}`).join(", ");
    const sql = `INSERT INTO t_parking (${columns}) VALUES (${placeholders}) RETURNING *`;
    
    const result = await client.query(sql, values);
    return result.rows[0];
  }

  private async createEmployeeWithClient(client: any, employeeData: any) {
    const columns = Object.keys(employeeData)
      .map((key) => `"${key}"`)
      .join(", ");
    const values = Object.values(employeeData);
    const placeholders = values.map((_, i) => `$${i + 1}`).join(", ");
    const sql = `INSERT INTO t_employee (${columns}) VALUES (${placeholders}) RETURNING *`;
    
    const result = await client.query(sql, values);
    return result.rows[0];
  }

  private async createAreaWithClient(client: any, areaData: any) {
    const columns = Object.keys(areaData)
      .map((key) => `"${key}"`)
      .join(", ");
    const values = Object.values(areaData);
    const placeholders = values.map((_, i) => `$${i + 1}`).join(", ");
    const sql = `INSERT INTO t_area (${columns}) VALUES (${placeholders}) RETURNING *`;
    
    const result = await client.query(sql, values);
    return result.rows[0];
  }

  private async createSpotsWithClient(client: any, areaId: string, parkingId: string, capacity: number) {
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
          id: crypto.randomUUID(),
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
          createdAt: new Date().toISOString(),
          updatedAt: new Date().toISOString(),
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
      currency: "USD",
      timeZone: "America/New_York",
      decimalPlaces: 2,
      countryCode: "US",
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
        name: "Tarifa Estándar",
        vehicleCategory: 3,
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
        name: "Tarifa Premium",
        vehicleCategory: 3,
        tolerance: 30,
        hourly: 3.50,
        daily: 35.00,
        weekly: 200.00,
        monthly: 700.00,
        yearly: 7000.00,
        isActive: true
      }
    ];
  }

  /**
   * Obtiene la ubicación desde coordenadas usando el servicio de geocodificación
   */
  private async getLocationFromCoordinates(lat: number, lon: number) {
    try {
      const { reverseGeocodingAPI } = await import("../utils/geoapify");
      return await reverseGeocodingAPI(lat, lon);
    } catch (error) {
      console.error("Error obteniendo ubicación:", error);
      return null;
    }
  }
}

export const registrationService = new RegistrationService();
