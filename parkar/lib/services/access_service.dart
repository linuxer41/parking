import '../config/app_config.dart';
import '../models/booking_model.dart';
import 'base_service.dart';

class AccessService extends BaseService {
  AccessService()
    : super(path: AppConfig.apiEndpoints['access'] ?? '/entry-exit');

  Future<BookingModel> createEntry(AccessCreateModel access) async {
    return post<BookingModel>(
      endpoint: '',
      body: access.toJson(),
      parser: (json) => parseModel(json, BookingModel.fromJson),
    );
  }

  Future<BookingModel> registerEntry(String entryId) async {
    return post<BookingModel>(
      endpoint: '/$entryId/entry',
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
      endpoint: '/$entryId/exit',
      body: data,
      parser: (json) => parseModel(json, BookingModel.fromJson),
    );
  }

  Future<BookingModel> getAccess(String id) async {
    return get<BookingModel>(
      endpoint: '/$id',
      parser: (json) => parseModel(json, BookingModel.fromJson),
    );
  }

  Future<BookingModel> updateAccess(
    String id,
    Map<String, dynamic> data,
  ) async {
    return patch<BookingModel>(
      endpoint: '/$id',
      body: data,
      parser: (json) => parseModel(json, BookingModel.fromJson),
    );
  }

  Future<void> deleteAccess(String id) async {
    return delete<void>(endpoint: '/$id', parser: (_) => null);
  }

  Future<List<BookingModel>> getAccesssByParking(String parkingId) async {
    return get<List<BookingModel>>(
      endpoint: '',
      additionalHeaders: {'parkingId': parkingId},
      parser: (json) => parseModelList(json, BookingModel.fromJson),
    );
  }

  Future<double> calculateExitFee(String entryId) async {
    final response = await get<Map<String, dynamic>>(
      endpoint: '/$entryId/fee',
      parser: (json) => json as Map<String, dynamic>,
    );

    return (response['amount'] as num).toDouble();
  }
}
