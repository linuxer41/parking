import '../config/app_config.dart';
import '../models/booking_model.dart';
import 'base_service.dart';

class BookingService extends BaseService {
  BookingService()
    : super(path: AppConfig.apiEndpoints['booking'] ?? '/booking');

  // ===== BOOKINGS (Reservas temporales) =====
  Future<BookingModel> getBooking(String id) async {
    return get<BookingModel>(
      endpoint: '/$id',
      parser: (json) => parseModel(json, BookingModel.fromJson),
    );
  }

  Future<BookingModel> createBooking(BookingCreateModel model) async {
    return post<BookingModel>(
      endpoint: '',
      body: model.toJson(),
      parser: (json) => parseModel(json, BookingModel.fromJson),
    );
  }

  Future<BookingModel> createReservation(ReservationCreateModel model) async {
    return post<BookingModel>(
      endpoint: '',
      body: model.toJson(),
      parser: (json) => parseModel(json, BookingModel.fromJson),
    );
  }

  Future<BookingModel> updateBooking(
    String id,
    BookingUpdateModel model,
  ) async {
    return patch<BookingModel>(
      endpoint: '/$id',
      body: model.toJson(),
      parser: (json) => parseModel(json, BookingModel.fromJson),
    );
  }

  Future<void> deleteBooking(String id) async {
    return delete<void>(endpoint: '/$id', parser: (_) => null);
  }

  Future<List<BookingModel>> getBookingsByParking(String parkingId) async {
    return get<List<BookingModel>>(
      endpoint: '',
      additionalHeaders: {'parkingId': parkingId},
      parser: (json) => parseModelList(json, BookingModel.fromJson),
    );
  }

  Future<List<BookingModel>> getBookingsByVehicle(String vehicleId) async {
    return get<List<BookingModel>>(
      endpoint: '',
      additionalHeaders: {'vehicleId': vehicleId},
      parser: (json) => parseModelList(json, BookingModel.fromJson),
    );
  }

  Future<Map<String, dynamic>> getBookingsPaginated({
    int page = 1,
    int limit = 10,
    String? search,
    String? parkingId,
    String? vehicleId,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }

    if (parkingId != null && parkingId.isNotEmpty) {
      queryParams['parkingId'] = parkingId;
    }

    if (vehicleId != null && vehicleId.isNotEmpty) {
      queryParams['vehicleId'] = vehicleId;
    }

    final queryString = queryParams.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');

    return get<Map<String, dynamic>>(
      endpoint: '?$queryString',
      parser: (json) => parsePaginatedResponse(json, BookingModel.fromJson),
    );
  }

  // ===== ENTRY-EXITS (Entradas y salidas) =====
  Future<BookingModel> createEntry(AccessCreateModel access) async {
    return post<BookingModel>(
      endpoint: '/entry-exit',
      body: access.toJson(),
      parser: (json) => parseModel(json, BookingModel.fromJson),
    );
  }

  Future<BookingModel> registerEntry(String entryId) async {
    return post<BookingModel>(
      endpoint: '/entry-exit/$entryId/entry',
      body: <String, dynamic>{},
      parser: (json) => parseModel(json, BookingModel.fromJson),
    );
  }

  Future<BookingModel> registerExit({
    required String entryId,
    required double amount,
    String? notes,
  }) async {
    final data = <String, dynamic>{'amount': amount};

    if (notes != null) {
      data['notes'] = notes;
    }

    return post<BookingModel>(
      endpoint: '/entry-exit/$entryId/exit',
      body: data,
      parser: (json) => parseModel(json, BookingModel.fromJson),
    );
  }

  // Método de compatibilidad para el código existente
  Future<BookingModel> registerExitLegacy({
    required String parkingId,
    required String bookingId,
    required double amount,
  }) async {
    return registerExit(entryId: bookingId, amount: amount);
  }

  Future<BookingModel> getAccess(String id) async {
    return get<BookingModel>(
      endpoint: '/entry-exit/$id',
      parser: (json) => parseModel(json, BookingModel.fromJson),
    );
  }

  Future<BookingModel> updateAccess(
    String id,
    Map<String, dynamic> data,
  ) async {
    return patch<BookingModel>(
      endpoint: '/entry-exit/$id',
      body: data,
      parser: (json) => parseModel(json, BookingModel.fromJson),
    );
  }

  Future<void> deleteAccess(String id) async {
    return delete<void>(endpoint: '/entry-exit/$id', parser: (_) => null);
  }

  Future<List<BookingModel>> getAccesssByParking(String parkingId) async {
    return get<List<BookingModel>>(
      endpoint: '/entry-exit',
      additionalHeaders: {'parkingId': parkingId},
      parser: (json) => parseModelList(json, BookingModel.fromJson),
    );
  }

  Future<double> calculateExitFee(String entryId) async {
    final response = await get<Map<String, dynamic>>(
      endpoint: '/entry-exit/$entryId/fee',
      parser: (json) => json as Map<String, dynamic>,
    );

    return (response['amount'] as num).toDouble();
  }

  // Método de compatibilidad para el código existente
  Future<double> calculateExitFeeLegacy(
    String parkingId,
    String bookingId,
  ) async {
    return calculateExitFee(bookingId);
  }

  // ===== SUBSCRIPTIONS (Suscripciones) =====
  Future<BookingModel> createSubscription(
    SubscriptionCreateModel subscription,
  ) async {
    return post<BookingModel>(
      endpoint: '/subscription',
      body: subscription.toJson(),
      parser: (json) => parseModel(json, BookingModel.fromJson),
    );
  }

  Future<BookingModel> renewSubscription(
    String subscriptionId, {
    String? period,
    double? amount,
    String? notes,
  }) async {
    final data = <String, dynamic>{};

    if (period != null) data['period'] = period;
    if (amount != null) data['amount'] = amount;
    if (notes != null) data['notes'] = notes;

    return post<BookingModel>(
      endpoint: '/subscription/$subscriptionId/renew',
      body: data,
      parser: (json) => parseModel(json, BookingModel.fromJson),
    );
  }

  Future<BookingModel> getSubscription(String id) async {
    return get<BookingModel>(
      endpoint: '/subscription/$id',
      parser: (json) => parseModel(json, BookingModel.fromJson),
    );
  }

  Future<BookingModel> updateSubscription(
    String id,
    Map<String, dynamic> data,
  ) async {
    return patch<BookingModel>(
      endpoint: '/subscription/$id',
      body: data,
      parser: (json) => parseModel(json, BookingModel.fromJson),
    );
  }

  Future<List<BookingModel>> getSubscriptionsByParking(String parkingId) async {
    return get<List<BookingModel>>(
      endpoint: '/subscription',
      additionalHeaders: {'parkingId': parkingId},
      parser: (json) => parseModelList(json, BookingModel.fromJson),
    );
  }

  Future<List<BookingModel>> getSubscriptionsByVehicle(String vehicleId) async {
    return get<List<BookingModel>>(
      endpoint: '/subscription',
      additionalHeaders: {'vehicleId': vehicleId},
      parser: (json) => parseModelList(json, BookingModel.fromJson),
    );
  }

  // ===== MÉTODOS DE COMPATIBILIDAD (para mantener funcionalidad existente) =====
  Future<BookingModel> registerSubscribedEntry(String subscriptionId) async {
    return registerEntry(subscriptionId);
  }

  Future<BookingModel> registerReservedEntry(String reservationId) async {
    return registerEntry(reservationId);
  }

  Future<void> cancelSubscription(String subscriptionId) async {
    return deleteAccess(subscriptionId);
  }

  Future<void> cancelReservation(String reservationId) async {
    return deleteBooking(reservationId);
  }
}
