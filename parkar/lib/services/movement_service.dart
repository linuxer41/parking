
import '_base_service.dart';
import '../models/movement_model.dart';

class MovementService extends BaseService<MovementModel, MovementCreateModel, MovementUpdateModel> {
  MovementService() : super(path: '/movement', fromJsonFactory: MovementModel.fromJson);
}
