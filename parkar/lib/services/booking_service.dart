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

  // ===== MÉTODOS DE COMPATIBILIDAD (para mantener funcionalidad existente) =====
  Future<void> cancelReservation(String reservationId) async {
    return deleteBooking(reservationId);
  }
}
