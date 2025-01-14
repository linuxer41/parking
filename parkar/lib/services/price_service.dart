
import '_base_service.dart';
import '../models/price_model.dart';

class PriceService extends BaseService<PriceModel, PriceCreateModel, PriceUpdateModel> {
  PriceService() : super(path: '/price', fromJsonFactory: PriceModel.fromJson);
}
