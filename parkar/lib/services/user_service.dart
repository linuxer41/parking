import '../config/app_config.dart';
import '../models/user_model.dart';
import '../models/parking_model.dart';
import 'base_service.dart';

class UserService extends BaseService {
  UserService() : super(path: AppConfig.apiEndpoints['user'] ?? '/users');

  Future<UserModel> getUser(String id) async {
    return get<UserModel>(
      endpoint: '/$id',
      parser: (json) => parseModel(json, UserModel.fromJson),
    );
  }

  Future<UserModel> createUser(UserCreateModel model) async {
    return post<UserModel>(
      endpoint: '',
      body: model,
      parser: (json) => parseModel(json, UserModel.fromJson),
    );
  }

  Future<UserModel> updateUser(String id, UserUpdateModel model) async {
    return patch<UserModel>(
      endpoint: '/$id',
      body: model,
      parser: (json) => parseModel(json, UserModel.fromJson),
    );
  }

  Future<void> deleteUser(String id) async {
    return delete<void>(endpoint: '/$id', parser: (_) => null);
  }

  Future<List<UserModel>> getUsersByCompany(String companyId) async {
    return get<List<UserModel>>(
      endpoint: '',
      additionalHeaders: {'companyId': companyId},
      parser: (json) => parseModelList(json, UserModel.fromJson),
    );
  }

  Future<List<ParkingSimpleModel>> getParkings(String userId) async {
    return get<List<ParkingSimpleModel>>(
      endpoint: '/$userId/parkings',
      parser: (json) => parseModelList(json, ParkingSimpleModel.fromJson),
    );
  }

  Future<Map<String, dynamic>> getUsersPaginated({
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
      parser: (json) => parsePaginatedResponse(json, UserModel.fromJson),
    );
  }
}
