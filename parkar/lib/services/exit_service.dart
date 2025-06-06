import '_base_service.dart';
import '../models/exit_model.dart';

class ExitService
    extends BaseService<ExitModel, ExitCreateModel, ExitUpdateModel> {
  ExitService() : super(path: '/exit', fromJsonFactory: ExitModel.fromJson);

  Future<ExitModel> createExit(ExitModel exitModel) async {
    // Crear un modelo de creación a partir del modelo completo
    final createModel = ExitCreateModel(
      number: exitModel.number,
      parkingId: exitModel.parkingId,
      entryId: exitModel.entryId,
      employeeId: exitModel.employeeId,
      dateTime: exitModel.dateTime,
      amount: exitModel.amount,
    );

    // Llamar al método create del padre
    return await create(createModel);
  }
}
