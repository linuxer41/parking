import '../config/app_config.dart';
import 'base_service.dart';
import '../models/employee_model.dart';

class EmployeeService extends BaseService {
  EmployeeService() : super(path: AppConfig.apiEndpoints['employee']!);

  /// Get an employee by ID
  Future<EmployeeModel> getEmployee(String id) async {
    return get<EmployeeModel>(
      endpoint: '/$id',
      parser: (json) => EmployeeModel.fromJson(json),
    );
  }

  /// Create a new employee
  Future<EmployeeModel> createEmployee(EmployeeCreateModel model) async {
    return post<EmployeeModel>(
      endpoint: '',
      body: model,
      parser: (json) => EmployeeModel.fromJson(json),
    );
  }

  /// Update an employee
  Future<EmployeeModel> updateEmployee(
      String id, EmployeeUpdateModel model) async {
    return patch<EmployeeModel>(
      endpoint: '/$id',
      body: model,
      parser: (json) => EmployeeModel.fromJson(json),
    );
  }

  /// Delete an employee
  Future<void> deleteEmployee(String id) async {
    return delete<void>(
      endpoint: '/$id',
      parser: (_) {},
    );
  }

  /// Get employees by company
  Future<List<EmployeeModel>> getEmployeesByCompany(String companyId) async {
    return get<List<EmployeeModel>>(
      endpoint: '',
      additionalHeaders: {'companyId': companyId},
      parser: (data) => (data as List<dynamic>)
          .map((item) => EmployeeModel.fromJson(item))
          .toList(),
    );
  }
}
