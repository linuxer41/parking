import '../config/app_config.dart';
import '../models/movement_model.dart';
import 'base_service.dart';

class MovementService extends BaseService {
  MovementService()
    : super(path: AppConfig.apiEndpoints['movement'] ?? '/movement');

  Future<MovementModel> registerMovement(MovementCreateModel model) async {
    return post<MovementModel>(
      endpoint: '',
      body: model,
      parser: (json) => parseModel(json, MovementModel.fromJson),
    );
  }

  Future<List<MovementModel>> getVehicleMovements(String licensePlate) async {
    return get<List<MovementModel>>(
      endpoint: '/vehicle/$licensePlate',
      parser: (json) => parseModelList(json, MovementModel.fromJson),
    );
  }

  Future<List<MovementModel>> getParkingMovements(
    String parkingId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final queryParams = <String, String>{'parkingId': parkingId};

    if (startDate != null) {
      queryParams['startDate'] = startDate.toIso8601String();
    }
    if (endDate != null) {
      queryParams['endDate'] = endDate.toIso8601String();
    }

    return get<List<MovementModel>>(
      endpoint: '/parking',
      additionalHeaders: queryParams,
      parser: (json) => parseModelList(json, MovementModel.fromJson),
    );
  }

  Future<List<MovementModel>> getMovementsByCashRegister(String cashRegisterId) async {
    return get<List<MovementModel>>(
      endpoint: '/cash-register/$cashRegisterId',
      parser: (json) => parseModelList(json, MovementModel.fromJson),
    );
  }

  Future<MovementModel> getMovement(String id) async {
    return get<MovementModel>(
      endpoint: '/$id',
      parser: (json) => parseModel(json, MovementModel.fromJson),
    );
  }

  Future<MovementModel> updateMovement(
    String id,
    MovementUpdateModel model,
  ) async {
    return patch<MovementModel>(
      endpoint: '/$id',
      body: model,
      parser: (json) => parseModel(json, MovementModel.fromJson),
    );
  }

  Future<void> deleteMovement(String id) async {
    return delete<void>(endpoint: '/$id', parser: (_) => null);
  }

  Future<Map<String, dynamic>> getMovementsPaginated({
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
      endpoint: '/paginated?$queryString',
      parser: (json) => parsePaginatedResponse(json, MovementModel.fromJson),
    );
  }
}
