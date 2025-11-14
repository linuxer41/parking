# 📚 Actualización de API - Parkar

## 🎯 Resumen de Cambios

Esta actualización implementa los cambios necesarios para que la aplicación Flutter use la nueva estructura de API documentada, que incluye endpoints simplificados y modelos de datos actualizados para:

- **Bookings (Reservas)**: Reservas de espacios de estacionamiento
- **Entry/Exit (Accesos)**: Entradas y salidas de vehículos  
- **Subscriptions (Suscripciones)**: Suscripciones mensuales/anuales

---

## 🔄 Cambios Realizados

### 1. Modelos de Datos Actualizados

#### `lib/models/booking_model.dart`

**Cambios en los modelos de creación:**

- **AccessCreateModel**: Simplificado para incluir solo los campos necesarios
  - `vehiclePlate` (requerido)
  - `vehicleType`, `vehicleColor`, `ownerName`, `ownerDocument`, `ownerPhone` (opcionales)
  - `spotId`, `notes` (opcionales)

- **ReservationCreateModel**: Actualizado para reservas temporales
  - `vehiclePlate`, `startDate`, `duration` (requeridos)
  - Campos opcionales para información del vehículo y propietario
  - `notes` para comentarios adicionales

- **SubscriptionCreateModel**: Agregado campo `amount` requerido
  - `vehiclePlate`, `startDate`, `period`, `amount` (requeridos)
  - Campos opcionales para información del vehículo y propietario
  - `notes` para comentarios adicionales

### 2. Servicios Actualizados

#### `lib/services/booking_service.dart`

**Endpoints actualizados:**
- `/booking` → `/booking` (sin cambios)
- `/bookings/{id}` → `/{id}`
- `/bookings` → `/` (para listar)

**Nuevos métodos:**
- `createReservation()`: Método específico para crear reservas
- `renewSubscription()`: Mejorado para aceptar parámetros opcionales

#### `lib/services/access_service.dart`

**Endpoints actualizados:**
- `/entry-exits` → `/entry-exit`
- `/entry-exits/{id}` → `/entry-exit/{id}`

**Mejoras:**
- `registerExit()`: Agregado parámetro `notes` opcional

#### `lib/services/subscription_service.dart`

**Endpoints actualizados:**
- `/subscriptions` → `/subscription`
- `/subscriptions/{id}` → `/subscription/{id}`

**Nuevos métodos:**
- `deleteSubscription()`: Para eliminar suscripciones
- `getSubscriptionStats()`: Para obtener estadísticas

### 3. Configuración Actualizada

#### `lib/config/app_config.dart`

**Endpoints por defecto agregados:**
```dart
static Map<String, String> apiEndpoints = {
  'booking': '/booking',
  'access': '/entry-exit', 
  'subscription': '/subscription',
  'parking': '/parking',
  'vehicle': '/vehicle',
  'employee': '/employee',
  'user': '/user',
  'auth': '/auth',
};
```

### 4. Componentes Actualizados

#### `lib/screens/parking/widgets/manage_subscription.dart`

**Cambios principales:**
- Uso del nuevo `SubscriptionService` para operaciones de suscripción
- Creación de accesos usando `AccessCreateModel` con datos de la suscripción
- Eliminación de suscripciones usando el método correcto
- Mejora en el manejo de errores y validaciones

### 5. Ejemplos de Uso

#### `lib/examples/api_usage_examples.dart`

**Nuevo archivo con ejemplos completos:**
- Creación de reservas, accesos y suscripciones
- Flujos completos de entrada/salida
- Manejo de diferentes tipos de vehículos
- Ejemplos de renovación de suscripciones

---

## 🚀 Cómo Usar la Nueva API

### Crear una Reserva

```dart
final bookingModel = ReservationCreateModel(
  vehiclePlate: 'ABC123',
  vehicleType: 'car',
  vehicleColor: 'rojo',
  ownerName: 'Juan Pérez',
  ownerPhone: '+573001234567',
  startDate: '2024-01-15T10:00:00Z',
  duration: 2,
  notes: 'Reserva para reunión',
);

final booking = await bookingService.createReservation(bookingModel);
```

### Crear un Acceso

```dart
final accessModel = AccessCreateModel(
  vehiclePlate: 'XYZ789',
  vehicleType: 'car',
  vehicleColor: 'azul',
  ownerName: 'Ana López',
  ownerPhone: '+573009876543',
  notes: 'Cliente frecuente',
);

final entry = await accessService.createEntry(accessModel);
```

### Crear una Suscripción

```dart
final subscriptionModel = SubscriptionCreateModel(
  vehiclePlate: 'DEF456',
  vehicleType: 'car',
  vehicleColor: 'blanco',
  ownerName: 'Carlos Rodríguez',
  ownerPhone: '+573005566778',
  startDate: '2024-01-15T00:00:00Z',
  period: 'monthly',
  amount: 150000.0,
  notes: 'Suscripción mensual',
);

final subscription = await subscriptionService.createSubscription(subscriptionModel);
```

### Registrar Salida

```dart
final exit = await accessService.registerExit(
  entryId: entryId,
  amount: 5000.0,
  notes: 'Pago en efectivo',
);
```

### Renovar Suscripción

```dart
final renewed = await subscriptionService.renewSubscription(
  subscriptionId,
  period: 'monthly',
  amount: 150000.0,
  notes: 'Renovación automática',
);
```

---

## 🔧 Compatibilidad

### Código Existente

Los cambios mantienen compatibilidad con el código existente mediante:

1. **Métodos de compatibilidad** en `BookingService`:
   - `registerSubscribedEntry()`
   - `registerReservedEntry()`
   - `cancelSubscription()`
   - `cancelReservation()`

2. **Endpoints por defecto** en la configuración para evitar errores

3. **Modelos actualizados** que mantienen la estructura básica

### Migración

Para migrar código existente:

1. **Reservas**: Usar `createReservation()` en lugar de `createBooking()`
2. **Accesos**: Usar `createEntry()` con `AccessCreateModel`
3. **Suscripciones**: Usar `SubscriptionService` en lugar de métodos genéricos

---

## 🧪 Testing

### Verificar Endpoints

```bash
# Crear reserva
curl -X POST http://localhost:3002/booking \
  -H "Authorization: Bearer <token>" \
  -H "parking-id: <parking_id>" \
  -H "employee-id: <employee_id>" \
  -H "Content-Type: application/json" \
  -d '{
    "vehiclePlate": "ABC123",
    "startDate": "2024-01-15T10:00:00Z",
    "duration": 2
  }'

# Crear acceso
curl -X POST http://localhost:3002/entry-exit \
  -H "Authorization: Bearer <token>" \
  -H "parking-id: <parking_id>" \
  -H "employee-id: <employee_id>" \
  -H "Content-Type: application/json" \
  -d '{
    "vehiclePlate": "XYZ789"
  }'

# Crear suscripción
curl -X POST http://localhost:3002/subscription \
  -H "Authorization: Bearer <token>" \
  -H "parking-id: <parking_id>" \
  -H "employee-id: <employee_id>" \
  -H "Content-Type: application/json" \
  -d '{
    "vehiclePlate": "DEF456",
    "startDate": "2024-01-15T00:00:00Z",
    "period": "monthly",
    "amount": 150000
  }'
```

---

## 📝 Notas Importantes

### Autenticación

Todas las peticiones requieren:
- `Authorization: Bearer <token>`
- `parking-id: <parking_id>`
- `employee-id: <employee_id>`

### Formatos de Fecha

Todas las fechas deben estar en formato ISO 8601:
- `2024-01-15T10:00:00Z`

### Tipos de Vehículos

Tipos soportados:
- `car` (automóvil)
- `motorcycle` (motocicleta)
- `truck` (camión)
- `bus` (autobús)
- `van` (furgoneta)

### Períodos de Suscripción

Períodos soportados:
- `weekly` (semanal)
- `monthly` (mensual)
- `yearly` (anual)

---

## 🔗 Referencias

- [Documentación de la API](./api_documentation.md)
- [Ejemplos de uso](./examples/api_usage_examples.dart)
- [Modelos de datos](./models/booking_model.dart)

---

**Versión**: 1.0.0  
**Fecha**: Enero 2024  
**Autor**: Equipo de Desarrollo Parkar
