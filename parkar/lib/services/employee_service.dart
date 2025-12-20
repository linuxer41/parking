import '../config/app_config.dart';
import '../models/employee_model.dart';
import 'base_service.dart';

class EmployeeService extends BaseService {
  EmployeeService() : super(path: AppConfig.apiEndpoints['employee']!);

  Future<EmployeeModel> createEmployee(Map<String, dynamic> employeeData) async {
    return post<EmployeeModel>(
      endpoint: '',
      body: employeeData,
      parser: (json) => parseModel(json, EmployeeModel.fromJson),
    );
  }

  Future<EmployeeModel> updateEmployee(String employeeId, Map<String, dynamic> employeeData) async {
    return put<EmployeeModel>(
      endpoint: '/$employeeId',
      body: employeeData,
      parser: (json) => parseModel(json, EmployeeModel.fromJson),
    );
  }

  Future<void> changeEmployeePassword(String employeeId, Map<String, dynamic> passwordData) async {
    return put<void>(
      endpoint: '/$employeeId/password',
      body: passwordData,
      parser: (_) => null,
    );
  }

  Future<void> deleteEmployee(String employeeId) async {
    return delete<void>(
      endpoint: '/$employeeId',
      parser: (_) => null,
    );
  }

  Future<List<EmployeeModel>> getEmployees({String? parkingId, String? role}) async {
    final queryParams = <String, String>{};
    if (parkingId != null) queryParams['parkingId'] = parkingId;
    if (role != null) queryParams['role'] = role;

    final queryString = queryParams.isNotEmpty
        ? '?${queryParams.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&')}'
        : '';

    return get<List<EmployeeModel>>(
      endpoint: queryString,
      parser: (json) => parseModelList(json, EmployeeModel.fromJson),
    );
  }

  Future<EmployeeModel> getEmployeeById(String employeeId) async {
    return get<EmployeeModel>(
      endpoint: '/$employeeId',
      parser: (json) => parseModel(json, EmployeeModel.fromJson),
    );
  }
}