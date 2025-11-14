import '../config/app_config.dart';
import 'base_service.dart';
import '../models/employee_model.dart';

class EmployeeService extends BaseService {
  EmployeeService() : super(path: AppConfig.apiEndpoints['employee']!);

  Future<EmployeeModel> getEmployee(String id) async {
    return get<EmployeeModel>(
      endpoint: '/$id',
      parser: (json) => parseModel(json, EmployeeModel.fromJson),
    );
  }

  Future<EmployeeModel> createEmployee(EmployeeCreateModel model) async {
    return post<EmployeeModel>(
      endpoint: '',
      body: model,
      parser: (json) => parseModel(json, EmployeeModel.fromJson),
    );
  }

  Future<EmployeeModel> updateEmployee(
    String id,
    EmployeeUpdateModel model,
  ) async {
    return patch<EmployeeModel>(
      endpoint: '/$id',
      body: model,
      parser: (json) => parseModel(json, EmployeeModel.fromJson),
    );
  }

  Future<void> deleteEmployee(String id) async {
    return delete<void>(endpoint: '/$id', parser: (_) => null);
  }

  Future<List<EmployeeModel>> getEmployeesByCompany(String companyId) async {
    return get<List<EmployeeModel>>(
      endpoint: '',
      additionalHeaders: {'companyId': companyId},
      parser: (json) => parseModelList(json, EmployeeModel.fromJson),
    );
  }

  Future<Map<String, dynamic>> getEmployeesPaginated({
    int page = 1,
    int limit = 10,
    String? search,
    String? companyId,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }

    if (companyId != null && companyId.isNotEmpty) {
      queryParams['companyId'] = companyId;
    }

    final queryString = queryParams.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');

    return get<Map<String, dynamic>>(
      endpoint: '/paginated?$queryString',
      parser: (json) => parsePaginatedResponse(json, EmployeeModel.fromJson),
    );
  }
}
