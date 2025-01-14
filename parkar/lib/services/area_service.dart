
import '_base_service.dart';
import '../models/area_model.dart';

class AreaService extends BaseService<AreaModel, AreaCreateModel, AreaUpdateModel> {
  AreaService() : super(path: '/area', fromJsonFactory: AreaModel.fromJson);
}
