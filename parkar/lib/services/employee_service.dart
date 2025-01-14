
import '_base_service.dart';
import '../models/employee_model.dart';

class EmployeeService extends BaseService<EmployeeModel, EmployeeCreateModel, EmployeeUpdateModel> {
  EmployeeService() : super(path: '/employee', fromJsonFactory: EmployeeModel.fromJson);
}
