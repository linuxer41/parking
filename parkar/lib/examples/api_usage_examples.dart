import '../services/booking_service.dart';
import '../services/access_service.dart';
import '../services/subscription_service.dart';
import '../models/booking_model.dart';

/// Ejemplos de uso de la API para crear reservas, accesos y suscripciones
/// Basado en la documentación de la API proporcionada
class ApiUsageExamples {
  final BookingService _bookingService;
  final AccessService _accessService;
  final SubscriptionService _subscriptionService;

  ApiUsageExamples({
    required BookingService bookingService,
    required AccessService accessService,
    required SubscriptionService subscriptionService,
  }) : _bookingService = bookingService,
       _accessService = accessService,
       _subscriptionService = subscriptionService;

  /// Ejemplo 1: Crear una reserva (booking)
  Future<BookingModel> createBookingExample() async {
    final bookingModel = ReservationCreateModel(
      vehiclePlate: 'ABC123',
      vehicleType: 'car',
      vehicleColor: 'rojo',
      ownerName: 'Juan Pérez',
      ownerDocument: '12345678',
      ownerPhone: '+573001234567',
      spotId: '550e8400-e29b-41d4-a716-446655440000',
      startDate: '2024-01-15T10:00:00Z',
      duration: 2,
      notes: 'Reserva para reunión de trabajo',
    );

    // Usar el método específico para reservas en el BookingService
    return await _bookingService.createReservation(bookingModel);
  }

  /// Ejemplo 2: Crear un acceso (entry/exit)
  Future<BookingModel> createEntryExample() async {
    final accessModel = AccessCreateModel(
      vehiclePlate: 'XYZ789',
      vehicleType: 'car',
      vehicleColor: 'azul',
      ownerName: 'Ana López',
      ownerDocument: '87654321',
      ownerPhone: '+573009876543',
      spotId: '550e8400-e29b-41d4-a716-446655440004',
      notes: 'Cliente frecuente',
    );

    return await _accessService.createEntry(accessModel);
  }

  /// Ejemplo 3: Registrar salida de un vehículo
  Future<BookingModel> registerExitExample(String entryId) async {
    return await _accessService.registerExit(
      entryId: entryId,
      amount: 5000.0,
      notes: 'Pago en efectivo',
    );
  }

  /// Ejemplo 4: Crear una suscripción
  Future<BookingModel> createSubscriptionExample() async {
    final subscriptionModel = SubscriptionCreateModel(
      vehiclePlate: 'DEF456',
      vehicleType: 'car',
      vehicleColor: 'blanco',
      ownerName: 'Carlos Rodríguez',
      ownerDocument: '11223344',
      ownerPhone: '+573005566778',
      spotId: '550e8400-e29b-41d4-a716-446655440008',
      startDate: '2024-01-15T00:00:00Z',
      period: 'monthly',
      amount: 150000.0,
      notes: 'Suscripción mensual para empleado',
    );

    return await _subscriptionService.createSubscription(subscriptionModel);
  }

  /// Ejemplo 5: Renovar una suscripción
  Future<BookingModel> renewSubscriptionExample(String subscriptionId) async {
    return await _subscriptionService.renewSubscription(
      subscriptionId,
      period: 'monthly',
      amount: 150000.0,
      notes: 'Renovación automática',
    );
  }

  /// Ejemplo 6: Obtener estadísticas de suscripciones
  Future<Map<String, dynamic>> getSubscriptionStatsExample(
    String parkingId,
  ) async {
    return await _subscriptionService.getSubscriptionStats(
      parkingId,
      startDate: '2024-01-01',
      endDate: '2024-01-31',
    );
  }

  /// Ejemplo 7: Obtener reservas por parking
  Future<List<BookingModel>> getBookingsByParkingExample(
    String parkingId,
  ) async {
    return await _bookingService.getBookingsByParking(parkingId);
  }

  /// Ejemplo 8: Obtener accesos por parking
  Future<List<BookingModel>> getAccesssByParkingExample(
    String parkingId,
  ) async {
    return await _accessService.getAccesssByParking(parkingId);
  }

  /// Ejemplo 9: Obtener suscripciones por parking
  Future<List<BookingModel>> getSubscriptionsByParkingExample(
    String parkingId,
  ) async {
    return await _subscriptionService.getSubscriptionsByParking(parkingId);
  }

  /// Ejemplo 10: Calcular tarifa de salida
  Future<double> calculateExitFeeExample(String entryId) async {
    return await _accessService.calculateExitFee(entryId);
  }

  /// Ejemplo completo: Flujo de entrada y salida
  Future<void> completeAccessFlowExample() async {
    try {
      // 1. Crear entrada
      final entry = await createEntryExample();
      print('Entrada creada: ${entry.id}');

      // 2. Calcular tarifa
      final fee = await calculateExitFeeExample(entry.id);
      print('Tarifa calculada: \$${fee}');

      // 3. Registrar salida
      final exit = await registerExitExample(entry.id);
      print('Salida registrada: ${exit.id}');
    } catch (e) {
      print('Error en el flujo: $e');
    }
  }

  /// Ejemplo completo: Flujo de suscripción
  Future<void> completeSubscriptionFlowExample() async {
    try {
      // 1. Crear suscripción
      final subscription = await createSubscriptionExample();
      print('Suscripción creada: ${subscription.id}');

      // 2. Renovar suscripción
      final renewed = await renewSubscriptionExample(subscription.id);
      print('Suscripción renovada: ${renewed.id}');
    } catch (e) {
      print('Error en el flujo: $e');
    }
  }
}

/// Ejemplos de uso con diferentes tipos de vehículos
class VehicleTypeExamples {
  final ApiUsageExamples _apiExamples;

  VehicleTypeExamples(this._apiExamples);

  /// Crear acceso para moto
  Future<BookingModel> createMotorcycleEntry() async {
    final accessModel = AccessCreateModel(
      vehiclePlate: 'MOT001',
      vehicleType: 'motorcycle',
      vehicleColor: 'negro',
      ownerName: 'Pedro García',
      ownerPhone: '+573001112223',
      notes: 'Moto de repartidor',
    );

    // Asumiendo que tienes acceso al AccessService
    // return await _accessService.createEntry(accessModel);
    throw UnimplementedError('Implementar acceso al AccessService');
  }

  /// Crear acceso para camión
  Future<BookingModel> createTruckEntry() async {
    final accessModel = AccessCreateModel(
      vehiclePlate: 'CAM001',
      vehicleType: 'truck',
      vehicleColor: 'blanco',
      ownerName: 'Empresa Transportes S.A.',
      ownerPhone: '+573004445556',
      notes: 'Carga pesada',
    );

    // Asumiendo que tienes acceso al AccessService
    // return await _accessService.createEntry(accessModel);
    throw UnimplementedError('Implementar acceso al AccessService');
  }

  /// Crear suscripción anual
  Future<BookingModel> createYearlySubscription() async {
    final subscriptionModel = SubscriptionCreateModel(
      vehiclePlate: 'EMP001',
      vehicleType: 'car',
      vehicleColor: 'gris',
      ownerName: 'María López',
      ownerPhone: '+573007778889',
      startDate: '2024-01-01T00:00:00Z',
      period: 'yearly',
      amount: 1500000.0, // 1.5 millones por año
      notes: 'Suscripción anual para empleado VIP',
    );

    // Asumiendo que tienes acceso al SubscriptionService
    // return await _subscriptionService.createSubscription(subscriptionModel);
    throw UnimplementedError('Implementar acceso al SubscriptionService');
  }
}
