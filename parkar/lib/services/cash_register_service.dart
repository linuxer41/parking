import '../config/app_config.dart';
import 'base_service.dart';
import '../models/cash_register_model.dart';

class CashRegisterService extends BaseService {
  CashRegisterService() : super(path: AppConfig.apiEndpoints['cashRegister']!);

  /// Get a cash register by ID
  Future<CashRegisterModel> getCashRegister(String id) async {
    return get<CashRegisterModel>(
      endpoint: '/$id',
      parser: (json) => CashRegisterModel.fromJson(json),
    );
  }

  /// Get cash registers by parking
  Future<List<CashRegisterModel>> getCashRegistersByParking(
      String parkingId) async {
    return get<List<CashRegisterModel>>(
      endpoint: '',
      additionalHeaders: {'parkingId': parkingId},
      parser: (data) => (data as List<dynamic>)
          .map((item) => CashRegisterModel.fromJson(item))
          .toList(),
    );
  }
}
