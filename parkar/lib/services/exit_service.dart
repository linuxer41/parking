
import '_base_service.dart';
import '../models/exit_model.dart';

class ExitService extends BaseService<ExitModel, ExitCreateModel, ExitUpdateModel> {
  ExitService() : super(path: '/exit', fromJsonFactory: ExitModel.fromJson);
}
