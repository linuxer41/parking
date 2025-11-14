# 📚 Documentación de API - Ejemplos de Uso

## 🎯 Resumen

Esta documentación proporciona ejemplos prácticos de cómo usar la API para crear y gestionar:
- **Bookings (Reservas)**: Reservas de espacios de estacionamiento
- **Entry/Exit (Accesos)**: Entradas y salidas de vehículos
- **Subscriptions (Suscripciones)**: Suscripciones mensuales/anuales

---

## 🔐 Autenticación

Todas las peticiones requieren autenticación. Incluye estos headers:

```http
Authorization: Bearer <tu_token_jwt>
parking-id: <id_del_estacionamiento>
employee-id: <id_del_empleado>
```

---

## 📅 1. CREAR UNA RESERVA (BOOKING)

### Endpoint
```http
POST /booking
```

### Ejemplo de Request

```json
{
  "vehiclePlate": "ABC123",
  "vehicleType": "car",
  "vehicleColor": "rojo",
  "ownerName": "Juan Pérez",
  "ownerDocument": "12345678",
  "ownerPhone": "+573001234567",
  "spotId": "550e8400-e29b-41d4-a716-446655440000",
  "startDate": "2024-01-15T10:00:00Z",
  "duration": 2,
  "notes": "Reserva para reunión de trabajo"
}
```

### Campos Requeridos
- `vehiclePlate`: Placa del vehículo
- `startDate`: Fecha y hora de inicio
- `duration`: Duración en horas

### Campos Opcionales
- `vehicleType`: Tipo de vehículo (car, motorcycle, truck, bus, van)
- `vehicleColor`: Color del vehículo
- `ownerName`: Nombre del propietario
- `ownerDocument`: Documento del propietario
- `ownerPhone`: Teléfono del propietario
- `spotId`: ID del espacio específico
- `notes`: Notas adicionales

### Ejemplo de Response

```json
{
  "success": true,
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440001",
    "number": 1001,
    "parkingId": "550e8400-e29b-41d4-a716-446655440000",
    "employeeId": "550e8400-e29b-41d4-a716-446655440002",
    "vehicleId": "550e8400-e29b-41d4-a716-446655440003",
    "spotId": "550e8400-e29b-41d4-a716-446655440000",
    "startDate": "2024-01-15T10:00:00Z",
    "endDate": "2024-01-15T12:00:00Z",
    "amount": 0,
    "status": "pending",
    "notes": "Reserva para reunión de trabajo",
    "createdAt": "2024-01-15T09:30:00Z",
    "parking": {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "name": "Estacionamiento Centro"
    },
    "employee": {
      "id": "550e8400-e29b-41d4-a716-446655440002",
      "name": "María García",
      "email": "maria@parking.com",
      "phone": "+573001234568"
    },
    "vehicle": {
      "id": "550e8400-e29b-41d4-a716-446655440003",
      "plate": "ABC123",
      "type": "car",
      "color": "rojo",
      "ownerName": "Juan Pérez",
      "ownerDocument": "12345678",
      "ownerPhone": "+573001234567"
    }
  }
}
```

---

## 🚗 2. CREAR UN ACCESO (ENTRY/EXIT)

### Endpoint
```http
POST /entry-exit
```

### Ejemplo de Request

```json
{
  "vehiclePlate": "XYZ789",
  "vehicleType": "car",
  "vehicleColor": "azul",
  "ownerName": "Ana López",
  "ownerDocument": "87654321",
  "ownerPhone": "+573009876543",
  "spotId": "550e8400-e29b-41d4-a716-446655440004",
  "notes": "Cliente frecuente"
}
```

### Campos Requeridos
- `vehiclePlate`: Placa del vehículo

### Campos Opcionales
- `vehicleType`: Tipo de vehículo (car, motorcycle, truck, bus, van)
- `vehicleColor`: Color del vehículo
- `ownerName`: Nombre del propietario
- `ownerDocument`: Documento del propietario
- `ownerPhone`: Teléfono del propietario
- `spotId`: ID del espacio específico
- `notes`: Notas adicionales

### Ejemplo de Response

```json
{
  "success": true,
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440005",
    "number": 2001,
    "parkingId": "550e8400-e29b-41d4-a716-446655440000",
    "employeeId": "550e8400-e29b-41d4-a716-446655440002",
    "vehicleId": "550e8400-e29b-41d4-a716-446655440006",
    "spotId": "550e8400-e29b-41d4-a716-446655440004",
    "entryTime": "2024-01-15T14:30:00Z",
    "exitTime": null,
    "exitEmployeeId": null,
    "amount": 0,
    "status": "entered",
    "notes": "Cliente frecuente",
    "createdAt": "2024-01-15T14:30:00Z",
    "parking": {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "name": "Estacionamiento Centro"
    },
    "employee": {
      "id": "550e8400-e29b-41d4-a716-446655440002",
      "name": "María García",
      "email": "maria@parking.com",
      "phone": "+573001234568"
    },
    "vehicle": {
      "id": "550e8400-e29b-41d4-a716-446655440006",
      "plate": "XYZ789",
      "type": "car",
      "color": "azul",
      "ownerName": "Ana López",
      "ownerDocument": "87654321",
      "ownerPhone": "+573009876543"
    }
  }
}
```

### Registrar Salida

Para registrar la salida de un vehículo:

```http
POST /entry-exit/{id}/exit
```

```json
{
  "exitEmployeeId": "550e8400-e29b-41d4-a716-446655440007",
  "amount": 5000,
  "notes": "Pago en efectivo"
}
```

---

## 📋 3. CREAR UNA SUSCRIPCIÓN

### Endpoint
```http
POST /subscription
```

### Ejemplo de Request

```json
{
  "vehiclePlate": "DEF456",
  "vehicleType": "car",
  "vehicleColor": "blanco",
  "ownerName": "Carlos Rodríguez",
  "ownerDocument": "11223344",
  "ownerPhone": "+573005566778",
  "spotId": "550e8400-e29b-41d4-a716-446655440008",
  "startDate": "2024-01-15T00:00:00Z",
  "period": "monthly",
  "amount": 150000,
  "notes": "Suscripción mensual para empleado"
}
```

### Campos Requeridos
- `vehiclePlate`: Placa del vehículo
- `startDate`: Fecha de inicio de la suscripción
- `period`: Período (weekly, monthly, yearly)
- `amount`: Monto de la suscripción

### Campos Opcionales
- `vehicleType`: Tipo de vehículo (car, motorcycle, truck, bus, van)
- `vehicleColor`: Color del vehículo
- `ownerName`: Nombre del propietario
- `ownerDocument`: Documento del propietario
- `ownerPhone`: Teléfono del propietario
- `spotId`: ID del espacio específico
- `notes`: Notas adicionales

### Ejemplo de Response

```json
{
  "success": true,
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440009",
    "number": 3001,
    "parkingId": "550e8400-e29b-41d4-a716-446655440000",
    "employeeId": "550e8400-e29b-41d4-a716-446655440002",
    "vehicleId": "550e8400-e29b-41d4-a716-446655440010",
    "spotId": "550e8400-e29b-41d4-a716-446655440008",
    "startDate": "2024-01-15T00:00:00Z",
    "endDate": "2024-02-15T00:00:00Z",
    "amount": 150000,
    "status": "active",
    "period": "monthly",
    "isActive": true,
    "parentId": null,
    "notes": "Suscripción mensual para empleado",
    "createdAt": "2024-01-15T10:00:00Z",
    "parking": {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "name": "Estacionamiento Centro"
    },
    "employee": {
      "id": "550e8400-e29b-41d4-a716-446655440002",
      "name": "María García",
      "email": "maria@parking.com",
      "phone": "+573001234568"
    },
    "vehicle": {
      "id": "550e8400-e29b-41d4-a716-446655440010",
      "plate": "DEF456",
      "type": "car",
      "color": "blanco",
      "ownerName": "Carlos Rodríguez",
      "ownerDocument": "11223344",
      "ownerPhone": "+573005566778"
    }
  }
}
```

---

## 🔄 4. RENOVAR UNA SUSCRIPCIÓN

### Endpoint
```http
POST /subscription/{id}/renew
```

### Ejemplo de Request

```json
{
  "period": "monthly",
  "amount": 150000,
  "notes": "Renovación automática"
}
```

---

## 📊 5. CONSULTAR ESTADÍSTICAS

### Estadísticas de Reservas
```http
GET /booking/stats/{parkingId}?startDate=2024-01-01&endDate=2024-01-31
```

### Estadísticas de Accesos
```http
GET /entry-exit/stats/{parkingId}?startDate=2024-01-01&endDate=2024-01-31
```

### Estadísticas de Suscripciones
```http
GET /subscription/stats/{parkingId}?startDate=2024-01-01&endDate=2024-01-31
```

---

## 🚨 6. CÓDIGOS DE ERROR COMUNES

### 400 - Bad Request
```json
{
  "success": false,
  "error": {
    "code": 400,
    "message": "Datos de entrada inválidos",
    "type": "BadRequestError"
  }
}
```

### 401 - Unauthorized
```json
{
  "success": false,
  "error": {
    "code": 401,
    "message": "Token de autorización inválido",
    "type": "UnauthorizedError"
  }
}
```

### 404 - Not Found
```json
{
  "success": false,
  "error": {
    "code": 404,
    "message": "Recurso no encontrado",
    "type": "NotFoundError"
  }
}
```

### 500 - Internal Server Error
```json
{
  "success": false,
  "error": {
    "code": 500,
    "message": "Error interno del servidor",
    "type": "InternalServerError"
  }
}
```

---

## 🛠️ 7. EJEMPLOS CON CURL

### Crear una Reserva
```bash
curl -X POST http://localhost:3002/booking \
  -H "Authorization: Bearer tu_token_aqui" \
  -H "parking-id: 550e8400-e29b-41d4-a716-446655440000" \
  -H "employee-id: 550e8400-e29b-41d4-a716-446655440002" \
  -H "Content-Type: application/json" \
  -d '{
    "vehiclePlate": "ABC123",
    "vehicleType": "car",
    "vehicleColor": "rojo",
    "ownerName": "Juan Pérez",
    "ownerPhone": "+573001234567",
    "startDate": "2024-01-15T10:00:00Z",
    "duration": 2,
    "notes": "Reserva para reunión"
  }'
```

### Crear un Acceso
```bash
curl -X POST http://localhost:3002/entry-exit \
  -H "Authorization: Bearer tu_token_aqui" \
  -H "parking-id: 550e8400-e29b-41d4-a716-446655440000" \
  -H "employee-id: 550e8400-e29b-41d4-a716-446655440002" \
  -H "Content-Type: application/json" \
  -d '{
    "vehiclePlate": "XYZ789",
    "vehicleType": "car",
    "vehicleColor": "azul",
    "ownerName": "Ana López",
    "ownerPhone": "+573009876543",
    "notes": "Cliente frecuente"
  }'
```

### Crear una Suscripción
```bash
curl -X POST http://localhost:3002/subscription \
  -H "Authorization: Bearer tu_token_aqui" \
  -H "parking-id: 550e8400-e29b-41d4-a716-446655440000" \
  -H "employee-id: 550e8400-e29b-41d4-a716-446655440002" \
  -H "Content-Type: application/json" \
  -d '{
    "vehiclePlate": "DEF456",
    "vehicleType": "car",
    "vehicleColor": "blanco",
    "ownerName": "Carlos Rodríguez",
    "ownerPhone": "+573005566778",
    "startDate": "2024-01-15T00:00:00Z",
    "period": "monthly",
    "amount": 150000,
    "notes": "Suscripción mensual"
  }'
```

---

## 📝 8. NOTAS IMPORTANTES

### Creación Automática de Vehículos
- Si el vehículo no existe, se crea automáticamente
- Si ya existe, se usa el vehículo existente

### Números Únicos
- Cada booking, entry-exit y subscription tiene un número único por parking
- Los números se generan automáticamente

### Estados
- **Reservas**: pending, active, completed, cancelled, expired
- **Accesos**: entered, exited
- **Suscripciones**: active, suspended, expired, cancelled, renewed

### Fechas
- Todas las fechas deben estar en formato ISO 8601
- Ejemplo: `2024-01-15T10:00:00Z`

---

## 🔗 9. ENDPOINTS ADICIONALES

### Listar Elementos
```http
GET /parking/{parkingId}/elements
```

### Obtener Elemento por ID
```http
GET /parking/{parkingId}/elements/{elementId}
```

### Listar Áreas
```http
GET /parking/{parkingId}/areas
```

### Obtener Estadísticas de Parking
```http
GET /parking/{parkingId}
```

---

## 📞 Soporte

Para soporte técnico o preguntas sobre la API, contacta al equipo de desarrollo.

**Versión de la API**: 1.0.0  
**Última actualización**: Enero 2024
