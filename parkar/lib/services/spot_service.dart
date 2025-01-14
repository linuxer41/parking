
import '_base_service.dart';
import '../models/spot_model.dart';

class SpotService extends BaseService<SpotModel, SpotCreateModel, SpotUpdateModel> {
  SpotService() : super(path: '/spot', fromJsonFactory: SpotModel.fromJson);
}
