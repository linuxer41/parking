import '../config/app_config.dart';
import '../models/access_model.dart';
import 'base_service.dart';

class AccessService extends BaseService {
  AccessService() : super(path: AppConfig.apiEndpoints['access'] ?? '/access');

  Future<AccessModel> createEntry(AccessCreateModel access) async {
    return post<AccessModel>(
      endpoint: '/entry',
      body: access.toJson(),
      parser: (json) => parseModel(json, AccessModel.fromJson),
    );
  }

  Future<AccessModel> registerEntry(String entryId) async {
    return post<AccessModel>(
      endpoint: '/$entryId/entry',
      body: <String, dynamic>{},
      parser: (json) => parseModel(json, AccessModel.fromJson),
    );
  }

  Future<AccessModel> registerExit({
    required String entryId,
    required double amount,
    String? notes,
  }) async {
    final data = <String, dynamic>{'amount': amount};

    if (notes != null) {
      data['notes'] = notes;
    }

    return post<AccessModel>(
      endpoint: '/$entryId/exit',
      body: data,
      parser: (json) => parseModel(json, AccessModel.fromJson),
    );
  }

  Future<AccessModel> getAccess(String id) async {
    return get<AccessModel>(
      endpoint: '/$id',
      parser: (json) => parseModel(json, AccessModel.fromJson),
    );
  }

  Future<AccessModel> updateAccess(
    String id,
    Map<String, dynamic> data,
  ) async {
    return patch<AccessModel>(
      endpoint: '/$id',
      body: data,
      parser: (json) => parseModel(json, AccessModel.fromJson),
    );
  }

  Future<void> deleteAccess(String id) async {
    return delete<void>(endpoint: '/$id', parser: (_) => null);
  }

  Future<List<AccessModel>> getAccesssByParking(String parkingId) async {
    return get<List<AccessModel>>(
      endpoint: '?inParking=true',
      additionalHeaders: {'parkingId': parkingId},
      parser: (json) => parseModelList(json, AccessModel.fromJson),
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
