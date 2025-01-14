
import '_base_service.dart';
import '../models/level_model.dart';

class LevelService extends BaseService<LevelModel, LevelCreateModel, LevelUpdateModel> {
  LevelService() : super(path: '/level', fromJsonFactory: LevelModel.fromJson);
}
