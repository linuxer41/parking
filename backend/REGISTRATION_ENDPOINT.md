# Endpoint de Registro Completo

## Descripción

El endpoint `/auth/register-complete` permite registrar un usuario completo junto con su estacionamiento, área, spots y empleado en una sola transacción de base de datos.

## URL

```
POST /auth/register-complete
```

## Estructura del Request

```json
{
  "user": {
    "name": "string",
    "email": "string",
    "password": "string",
    "phone": "string"
  },
  "parking": {
    "name": "string",
    "capacity": "number (mínimo: 1)",
    "operationMode": "visual | simple (opcional, default: visual)",
    "location": "[number, number] (opcional) - [latitud, longitud]"
  }
}
```

**Nota**: Los campos `params` y `rates` NO se reciben en el request, se generan automáticamente en el backend con valores por defecto.

## Ejemplo de Request

```json
{
  "user": {
    "name": "Juan Pérez",
    "email": "juan@estacionamiento.com",
    "password": "password123",
    "phone": "+1234567890"
  },
  "parking": {
    "name": "Estacionamiento Central",
    "capacity": 50,
    "operationMode": "visual",
    "location": [-12.0464, -77.0428]
  }
}
```

## Respuesta Exitosa

```json
{
  "token": "jwt_access_token",
  "user": {
    "id": "user_id",
    "name": "Juan Pérez",
    "email": "juan@estacionamiento.com",
    "phone": "+1234567890",
    "createdAt": "2024-01-01T00:00:00.000Z",
    "updatedAt": "2024-01-01T00:00:00.000Z"
  },
  "parkings": [
    {
      "id": "parking_id",
      "name": "Estacionamiento Central",
      "email": "juan_parking@estacionamiento.com",
      "phone": "+1234567890",
      "address": "Dirección por defecto",
      "ownerId": "user_id",
      "status": "active",
      "operationMode": "visual",
      "capacity": 50,
      "params": { ... },
      "rates": [ ... ],
      "createdAt": "2024-01-01T00:00:00.000Z",
      "updatedAt": "2024-01-01T00:00:00.000Z"
    }
  ]
}
```

**Nota**: La respuesta es idéntica a la del endpoint de login (`/auth/sign-in`).

## Códigos de Respuesta

- **200 OK**: Registro exitoso
- **400 Bad Request**: Datos inválidos
- **409 Conflict**: Email ya existe
- **500 Internal Server Error**: Error del servidor

## Proceso de Registro

El endpoint realiza las siguientes operaciones en una transacción de base de datos:

1. **Crear Usuario**: Se crea el usuario con la contraseña encriptada
2. **Generar Datos por Defecto**: Se generan automáticamente:
   - Email del parking: `{usuario}_parking@{dominio}`
   - Teléfono del parking: igual al del usuario
   - Dirección: obtenida de las coordenadas o "Dirección por defecto"
   - Parámetros por defecto: USD, America/New_York, 2 decimales, US, tema default
   - Tarifas por defecto: Estándar ($2.50/hora) y Premium ($3.50/hora)
3. **Crear Parking**: Se crea el estacionamiento con todos los datos generados
4. **Crear Empleado**: Se crea el empleado con rol "owner" para el usuario
5. **Crear Área**: Se crea un área por defecto llamada "Área Principal"
6. **Crear Spots**: Se crean spots según la capacidad especificada
7. **Generar Tokens**: Se generan tokens de acceso y refresh
8. **Configurar Cookies**: Se configuran las cookies de autenticación

## Características

- **Transacción Atómica**: Todas las operaciones se realizan en una sola transacción
- **Rollback Automático**: Si falla cualquier operación, se revierten todos los cambios
- **Autenticación Inmediata**: El usuario queda autenticado después del registro
- **Validación Completa**: Se validan todos los datos antes de procesar
- **Manejo de Errores**: Manejo robusto de errores con mensajes descriptivos

## Notas Importantes

- El usuario creado se convierte automáticamente en propietario del estacionamiento
- Se crea un área por defecto llamada "Área Principal"
- Los spots se crean con nombres secuenciales (Spot 001, Spot 002, etc.)
- Todos los spots se crean como tipo "car" (subType: 3)
- El empleado se crea con rol "owner"
- La contraseña se encripta automáticamente
- Los tokens de autenticación se generan y configuran automáticamente
- **Datos Generados Automáticamente**:
  - Email del parking: `{usuario}_parking@{dominio}`
  - Teléfono del parking: igual al del usuario
  - Parámetros: USD, America/New_York, 2 decimales, US, tema default
  - Tarifas: Estándar ($2.50/hora) y Premium ($3.50/hora)
  - Dirección: obtenida de las coordenadas o "Dirección por defecto"
