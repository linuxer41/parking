import '../config/app_config.dart';
import 'base_service.dart';
import '../models/cash_register_model.dart';

class CashRegisterService extends BaseService {
  CashRegisterService() : super(path: AppConfig.apiEndpoints['cashRegister']!);

  Future<CashRegisterModel> getCashRegister(String id) async {
    return get<CashRegisterModel>(
      endpoint: '/$id',
      parser: (json) => parseModel(json, CashRegisterModel.fromJson),
    );
  }

  Future<List<CashRegisterModel>> getCashRegistersByParking(
    String parkingId,
  ) async {
    return get<List<CashRegisterModel>>(
      endpoint: '',
      additionalHeaders: {'parkingId': parkingId},
      parser: (json) => parseModelList(json, CashRegisterModel.fromJson),
    );
  }

  Future<CashRegisterModel?> getCurrentCashRegister() async {
    try {
      return get<CashRegisterModel>(
        endpoint: '/current',
        parser: (json) => parseModel(json, CashRegisterModel.fromJson),
      );
    } catch (e) {
      // If no current cash register, return null
      return null;
    }
  }

  Future<CashRegisterModel> createCashRegister(
    CashRegisterCreateModel model,
  ) async {
    return post<CashRegisterModel>(
      endpoint: '',
      body: model,
      parser: (json) => parseModel(json, CashRegisterModel.fromJson),
    );
  }

  Future<CashRegisterModel> openCashRegister(
    CashRegisterCreateModel model,
  ) async {
    return post<CashRegisterModel>(
      endpoint: '/open',
      body: model,
      parser: (json) => parseModel(json, CashRegisterModel.fromJson),
    );
  }


  Future<CashRegisterModel> updateCashRegister(
    String id,
    CashRegisterUpdateModel model,
  ) async {
    return patch<CashRegisterModel>(
      endpoint: '/$id',
      body: model,
      parser: (json) => parseModel(json, CashRegisterModel.fromJson),
    );
  }

  Future<CashRegisterModel> closeCashRegister(String id, CashRegisterCloseModel model) async {
    return post<CashRegisterModel>(
      endpoint: '/$id/close',
      body: model,
      parser: (json) => parseModel(json, CashRegisterModel.fromJson),
    );
  }

  Future<void> deleteCashRegister(String id) async {
    return delete<void>(endpoint: '/$id', parser: (_) => null);
  }

  Future<Map<String, dynamic>> getCashRegistersPaginated({
    int page = 1,
    int limit = 10,
    String? search,
    String? parkingId,
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

    final queryString = queryParams.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');

    return get<Map<String, dynamic>>(
      endpoint: '/paginated?$queryString',
      parser: (json) =>
          parsePaginatedResponse(json, CashRegisterModel.fromJson),
    );
  }
}
