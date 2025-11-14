# 🚗 Parking Management API - Frontend Integration Guide

## 📋 Resumen de Cambios

### 🔄 Unificación de Modelos
- **Áreas y Elementos** ahora están unificados bajo el modelo de **Parking**
- **Estructura jerárquica**: `Parking → Areas → Elements`
- **Esquemas de occupancy** corregidos y unificados

### 🗂️ Archivos Eliminados
- ❌ `src/models/area.ts`
- ❌ `src/models/element.ts`
- ❌ `src/db/crud/area.ts`
- ❌ `src/db/crud/element.ts`
- ❌ `src/controllers/area.ts`
- ❌ `src/controllers/element.ts`

### ✅ Nuevos Archivos Unificados
- ✅ `src/models/parking.ts` - Todos los esquemas
- ✅ `src/db/crud/parking.ts` - CRUD unificado
- ✅ `src/controllers/parking.ts` - Rutas unificadas

---

## 🛣️ Nuevos Endpoints

### 📍 Estructura de Rutas
```
/parkings/:parkingId/areas          # Gestión de áreas
/parkings/:parkingId/elements       # Gestión de elementos
/parkings/:parkingId/areas/:areaId/elements  # Elementos por área
```

---

## 🏢 Gestión de Parkings

### Obtener Parking Detallado
```typescript
GET /parkings/:parkingId

// Response
{
  "id": "uuid",
  "name": "Estacionamiento Central",
  "email": "info@parking.com",
  "phone": "+1234567890",
  "address": "Calle Principal 123",
  "location": { "lat": 40.7128, "lng": -74.0060 },
  "logoUrl": "https://example.com/logo.png",
  "status": "active",
  "params": {
    "currency": "USD",
    "timeZone": "America/New_York",
    "decimalPlaces": 2,
    "countryCode": "US",
    "theme": "dark",
    "slogan": "Tu parking de confianza"
  },
  "rates": [...],
  "operationMode": "map",
  "areas": [
    {
      "id": "area-uuid",
      "name": "Planta Baja",
      "totalSpots": 50,
      "occupiedSpots": 30,
      "availableSpots": 20,
      "elements": [...]
    }
  ],
  "employees": [...],
  "isOwner": true,
  "areaCount": 3,
  "totalSpots": 150,
  "occupiedSpots": 90,
  "availableSpots": 60
}
```

### Crear Parking
```typescript
POST /parkings

// Request Body
{
  "name": "Nuevo Estacionamiento",
  "address": "Nueva Dirección 456",
  "location": { "lat": 40.7589, "lng": -73.9851 },
  "operationMode": "map"
}
```

### Actualizar Parking
```typescript
PATCH /parkings/:parkingId

// Request Body
{
  "name": "Estacionamiento Actualizado",
  "phone": "+1987654321",
  "status": "maintenance"
}
```

---

## 🏗️ Gestión de Áreas

### Crear Área
```typescript
POST /parkings/:parkingId/areas

// Request Body
{
  "name": "Planta Alta"
}

// Response
{
  "id": "area-uuid",
  "name": "Planta Alta",
  "parkingId": "parking-uuid",
  "createdAt": "2024-01-15T10:30:00Z",
  "updatedAt": null,
  "deletedAt": null
}
```

### Listar Áreas del Parking
```typescript
GET /parkings/:parkingId/areas

// Response
{
  "areas": [
    {
      "id": "area-uuid-1",
      "name": "Planta Baja",
      "totalSpots": 50,
      "occupiedSpots": 30,
      "availableSpots": 20,
      "elements": [
        {
          "id": "element-uuid",
          "name": "A-01",
          "type": "spot",
          "subType": 3,
          "posX": 10.5,
          "posY": 20.3,
          "posZ": 0,
          "rotation": 0,
          "scale": 1,
          "isActive": true,
          "occupancy": {
            "occupancy": {
              "id": "booking-uuid",
              "type": "access",
              "number": 1001,
              "startDate": "2024-01-15T08:00:00Z",
              "endDate": null,
              "amount": 0,
              "status": "entered",
              "entryTime": "2024-01-15T08:00:00Z",
              "vehicle": {
                "id": "vehicle-uuid",
                "plate": "ABC123",
                "color": "red",
                "type": "car",
                "ownerName": "Juan Pérez",
                "ownerDocument": "12345678",
                "ownerPhone": "+1234567890"
              },
              "employee": {
                "id": "employee-uuid",
                "role": "operator",
                "name": "María García",
                "email": "maria@parking.com",
                "phone": "+1234567890"
              }
            },
            "status": "occupied"
          }
        }
      ]
    }
  ]
}
```

### Obtener Área Específica
```typescript
GET /parkings/:parkingId/areas/:areaId

// Response (mismo formato que arriba, pero un solo objeto)
```

### Actualizar Área
```typescript
PATCH /parkings/:parkingId/areas/:areaId

// Request Body
{
  "name": "Planta Baja Renovada"
}
```

### Eliminar Área
```typescript
DELETE /parkings/:parkingId/areas/:areaId

// Response
{
  "id": "area-uuid",
  "name": "Planta Baja",
  "deletedAt": "2024-01-15T11:00:00Z"
}
```

---

## 🚗 Gestión de Elementos (Spots)

### Crear Elemento
```typescript
POST /parkings/:parkingId/elements

// Request Body
{
  "areaId": "area-uuid",
  "parkingId": "parking-uuid",
  "name": "A-02",
  "type": "spot",
  "subType": 3, // 1=bicicleta, 2=moto, 3=carro, 4=camión
  "posX": 15.5,
  "posY": 25.3,
  "posZ": 0,
  "rotation": 0,
  "scale": 1
}

// Response
{
  "id": "element-uuid",
  "areaId": "area-uuid",
  "parkingId": "parking-uuid",
  "name": "A-02",
  "type": "spot",
  "subType": 3,
  "posX": 15.5,
  "posY": 25.3,
  "posZ": 0,
  "rotation": 0,
  "scale": 1,
  "isActive": true,
  "createdAt": "2024-01-15T10:30:00Z",
  "updatedAt": null,
  "deletedAt": null
}
```

### Listar Elementos del Parking
```typescript
GET /parkings/:parkingId/elements

// Response
{
  "elements": [
    {
      "id": "element-uuid",
      "areaId": "area-uuid",
      "parkingId": "parking-uuid",
      "name": "A-01",
      "type": "spot",
      "subType": 3,
      "posX": 10.5,
      "posY": 20.3,
      "posZ": 0,
      "rotation": 0,
      "scale": 1,
      "isActive": true,
      "occupancy": {
        "occupancy": {
          "id": "booking-uuid",
          "type": "access",
          "number": 1001,
          "startDate": "2024-01-15T08:00:00Z",
          "endDate": null,
          "amount": 0,
          "status": "entered",
          "entryTime": "2024-01-15T08:00:00Z",
          "vehicle": {...},
          "employee": {...}
        },
        "status": "occupied"
      }
    }
  ]
}
```

### Obtener Elemento Específico
```typescript
GET /parkings/:parkingId/elements/:elementId

// Response (mismo formato que arriba, pero un solo objeto)
```

### Actualizar Elemento
```typescript
PATCH /parkings/:parkingId/elements/:elementId

// Request Body
{
  "name": "A-01-Renovado",
  "posX": 12.5,
  "posY": 22.3,
  "isActive": false
}
```

### Eliminar Elemento
```typescript
DELETE /parkings/:parkingId/elements/:elementId

// Response
{
  "id": "element-uuid",
  "name": "A-01",
  "deletedAt": "2024-01-15T11:00:00Z"
}
```

### Listar Elementos por Área
```typescript
GET /parkings/:parkingId/areas/:areaId/elements

// Response (mismo formato que listar elementos del parking)
```

---

## 🎫 Gestión de Bookings (Reservas, Accesos, Suscripciones)

### Crear Acceso
```typescript
POST /booking/access

// Headers
{
  "parking-id": "parking-uuid",
  "employee-id": "employee-uuid"
}

// Request Body
{
  "vehiclePlate": "ABC123",
  "vehicleType": "car",
  "vehicleColor": "red",
  "ownerName": "Juan Pérez",
  "ownerDocument": "12345678",
  "ownerPhone": "+1234567890",
  "spotId": "element-uuid",
  "areaId": "area-uuid",
  "operationMode": "map"
}

// Response
{
  "booking": {
    "id": "booking-uuid",
    "type": "access",
    "number": 1001,
    "parkingId": "parking-uuid",
    "employeeId": "employee-uuid",
    "vehicleId": "vehicle-uuid",
    "spotId": "element-uuid",
    "startDate": "2024-01-15T10:30:00Z",
    "endDate": null,
    "amount": 0,
    "status": "entered",
    "parentId": null,
    "entryTime": "2024-01-15T10:30:00Z",
    "exitTime": null,
    "exitEmployeeId": null,
    "isActive": null,
    "period": null
  }
}
```

### Crear Suscripción
```typescript
POST /booking/subscribe

// Headers
{
  "parking-id": "parking-uuid",
  "employee-id": "employee-uuid"
}

// Request Body
{
  "vehiclePlate": "XYZ789",
  "vehicleType": "car",
  "vehicleColor": "blue",
  "ownerName": "María García",
  "ownerDocument": "87654321",
  "ownerPhone": "+1987654321",
  "spotId": "element-uuid",
  "areaId": "area-uuid",
  "operationMode": "map",
  "startDate": "2024-01-15T00:00:00Z",
  "period": "monthly" // weekly, monthly, yearly
}

// Response
{
  "booking": {
    "id": "booking-uuid",
    "type": "subscription",
    "number": 2001,
    "parkingId": "parking-uuid",
    "employeeId": "employee-uuid",
    "vehicleId": "vehicle-uuid",
    "spotId": "element-uuid",
    "startDate": "2024-01-15T00:00:00Z",
    "endDate": "2024-02-15T00:00:00Z",
    "amount": 0,
    "status": "active",
    "parentId": null,
    "entryTime": null,
    "exitTime": null,
    "exitEmployeeId": null,
    "isActive": true,
    "period": "monthly"
  }
}
```

### Crear Reserva
```typescript
POST /booking/reserve

// Headers
{
  "parking-id": "parking-uuid",
  "employee-id": "employee-uuid"
}

// Request Body
{
  "vehiclePlate": "DEF456",
  "vehicleType": "car",
  "vehicleColor": "green",
  "ownerName": "Carlos López",
  "ownerDocument": "11223344",
  "ownerPhone": "+1555666777",
  "spotId": "element-uuid",
  "areaId": "area-uuid",
  "operationMode": "map",
  "startDate": "2024-01-15T14:00:00Z",
  "duration": 2 // horas
}

// Response
{
  "booking": {
    "id": "booking-uuid",
    "type": "reservation",
    "number": 3001,
    "parkingId": "parking-uuid",
    "employeeId": "employee-uuid",
    "vehicleId": "vehicle-uuid",
    "spotId": "element-uuid",
    "startDate": "2024-01-15T14:00:00Z",
    "endDate": "2024-01-15T16:00:00Z",
    "amount": 0,
    "status": "active",
    "parentId": null,
    "entryTime": null,
    "exitTime": null,
    "exitEmployeeId": null,
    "isActive": null,
    "period": null
  }
}
```

### Registrar Salida de Acceso
```typescript
POST /booking/:bookingId/exit

// Request Body
{
  "exitEmployeeId": "employee-uuid",
  "amount": 15.50
}

// Response
{
  "access": {
    "id": "booking-uuid",
    "type": "access",
    "status": "exited",
    "exitTime": "2024-01-15T18:30:00Z",
    "exitEmployeeId": "employee-uuid",
    "amount": 15.50
  }
}
```

### Listar Bookings
```typescript
GET /booking?type=access&parkingId=parking-uuid&status=entered

// Query Parameters
- type: access | reservation | subscription
- parkingId: uuid
- employeeId: uuid
- vehicleId: uuid
- spotId: uuid
- status: entered | exited | active | completed | cancelled
- parentId: uuid
- startDate: ISO string
- endDate: ISO string

// Response
{
  "bookings": [
    {
      "id": "booking-uuid",
      "type": "access",
      "number": 1001,
      "parkingId": "parking-uuid",
      "employeeId": "employee-uuid",
      "vehicleId": "vehicle-uuid",
      "spotId": "element-uuid",
      "startDate": "2024-01-15T10:30:00Z",
      "endDate": null,
      "amount": 0,
      "status": "entered",
      "parentId": null,
      "entryTime": "2024-01-15T10:30:00Z",
      "exitTime": null,
      "exitEmployeeId": null,
      "isActive": null,
      "period": null
    }
  ]
}
```

---

## 🔧 Constantes y Tipos

### Tipos de Elementos
```typescript
ELEMENT_TYPES = {
  SPOT: 'spot',
  FACILITY: 'facility',
  SIGNAGE: 'signage'
}
```

### Subtipos de Spots
```typescript
SPOT_SUBTYPES = {
  BYCICLE: 1,
  MOTORCYCLE: 2,
  CAR: 3,
  TRUCK: 4
}
```

### Estados de Elementos
```typescript
ELEMENT_STATUS = {
  AVAILABLE: 'available',
  OCCUPIED: 'occupied',
  MAINTENANCE: 'maintenance',
  RESERVED: 'reserved',
  SUBSCRIBED: 'subscribed'
}
```

### Tipos de Booking
```typescript
BOOKING_TYPES = {
  RESERVATION: 'reservation',
  SUBSCRIPTION: 'subscription',
  ACCESS: 'access'
}
```

### Estados de Booking
```typescript
BOOKING_STATUS = {
  ACTIVE: 'active',
  COMPLETED: 'completed',
  CANCELLED: 'cancelled',
  EXPIRED: 'expired',
  ENTERED: 'entered',
  EXITED: 'exited',
  SUSPENDED: 'suspended',
  RENEWED: 'renewed'
}
```

---

## 📊 Estructura de Occupancy

### Nuevo Formato Unificado
```typescript
// Antes (obsoleto)
{
  "access": { ... },
  "reservation": { ... },
  "subscription": { ... },
  "status": "occupied"
}

// Ahora (nuevo)
{
  "occupancy": {
    "id": "booking-uuid",
    "type": "access", // Prioridad: access > reservation > subscription
    "startDate": "2024-01-15T10:30:00Z",
    "endDate": null,
    "vehicle": { ... },
    "employee": { ... },
    "amount": 0
  },
  "status": "occupied"
}
```

---

## 🚀 Ejemplos de Uso Frontend

### React/TypeScript Example
```typescript
// Obtener parking con áreas y elementos
const getParkingDetails = async (parkingId: string) => {
  const response = await fetch(`/parkings/${parkingId}`, {
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    }
  });
  
  const parking = await response.json();
  
  // Renderizar áreas
  parking.areas.forEach(area => {
    console.log(`Área: ${area.name}`);
    console.log(`Spots disponibles: ${area.availableSpots}/${area.totalSpots}`);
    
    // Renderizar elementos con occupancy
    area.elements.forEach(element => {
      const status = element.occupancy?.status || 'available';
      const vehicle = element.occupancy?.occupancy?.vehicle;
      
      console.log(`Spot ${element.name}: ${status}`);
      if (vehicle) {
        console.log(`Vehículo: ${vehicle.plate} - ${vehicle.ownerName}`);
      }
    });
  });
};

// Crear nuevo acceso
const createAccess = async (parkingId: string, accessData: any) => {
  const response = await fetch('/booking/access', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json',
      'parking-id': parkingId,
      'employee-id': employeeId
    },
    body: JSON.stringify(accessData)
  });
  
  const result = await response.json();
  return result.booking;
};
```

### Vue.js Example
```javascript
// Composables para parking
export const useParking = () => {
  const getParkingDetails = async (parkingId) => {
    const { data } = await $fetch(`/parkings/${parkingId}`);
    return data;
  };
  
  const createArea = async (parkingId, areaData) => {
    const { data } = await $fetch(`/parkings/${parkingId}/areas`, {
      method: 'POST',
      body: areaData
    });
    return data;
  };
  
  const createElement = async (parkingId, elementData) => {
    const { data } = await $fetch(`/parkings/${parkingId}/elements`, {
      method: 'POST',
      body: elementData
    });
    return data;
  };
  
  return {
    getParkingDetails,
    createArea,
    createElement
  };
};
```

---

## ⚠️ Cambios Importantes

### 1. Estructura de Rutas
- **Antes**: `/areas`, `/elements` (rutas separadas)
- **Ahora**: `/parkings/:parkingId/areas`, `/parkings/:parkingId/elements`

### 2. Esquemas de Occupancy
- **Antes**: Campos separados `access`, `reservation`, `subscription`
- **Ahora**: Campo unificado `occupancy` con priorización automática

### 3. Importaciones
- **Antes**: `import { ... } from '../models/area'`
- **Ahora**: `import { ... } from '../models/parking'`

### 4. CRUD Operations
- **Antes**: `db.area.create()`, `db.element.create()`
- **Ahora**: `db.area.create()`, `db.element.create()` (misma API, implementación unificada)

---

## 🔄 Migración

### 1. Actualizar Importaciones
```typescript
// Antes
import { AreaSchema, ElementSchema } from '../models/area';
import { ElementSchema } from '../models/element';

// Ahora
import { AreaSchema, ElementSchema } from '../models/parking';
```

### 2. Actualizar Rutas
```typescript
// Antes
const areas = await fetch('/areas');
const elements = await fetch('/elements');

// Ahora
const areas = await fetch(`/parkings/${parkingId}/areas`);
const elements = await fetch(`/parkings/${parkingId}/elements`);
```

### 3. Actualizar Occupancy
```typescript
// Antes
const status = element.access ? 'occupied' : 
               element.reservation ? 'reserved' : 
               element.subscription ? 'subscribed' : 'available';

// Ahora
const status = element.occupancy?.status || 'available';
const booking = element.occupancy?.occupancy;
```

---

## 📝 Notas Adicionales

- ✅ **Compatibilidad**: La API mantiene compatibilidad con el frontend existente
- ✅ **Jerarquía**: Estructura clara: Parking → Areas → Elements
- ✅ **Occupancy**: Sistema unificado con priorización automática
- ✅ **Validación**: Todos los esquemas incluyen validación completa
- ✅ **Documentación**: Swagger/OpenAPI actualizado automáticamente

---

## 🆘 Soporte

Para dudas o problemas con la integración, revisar:
1. **Logs del servidor** para errores de validación
2. **Headers de autenticación** en todas las requests
3. **Formato de fechas** (ISO 8601)
4. **UUIDs válidos** para todos los IDs
