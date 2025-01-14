
import '_base_service.dart';
import '../models/cash_register_model.dart';

class CashRegisterService extends BaseService<CashRegisterModel, CashRegisterCreateModel, CashRegisterUpdateModel> {
  CashRegisterService() : super(path: '/cash_register', fromJsonFactory: CashRegisterModel.fromJson);
}
