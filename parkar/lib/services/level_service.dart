import '../config/app_config.dart';
import 'base_service.dart';

class LevelService extends BaseService {
  LevelService() : super(path: AppConfig.apiEndpoints['level'] ?? '/levels');

  Future<Map<String, dynamic>> getLevel(String id) async {
    return get<Map<String, dynamic>>(
      endpoint: '/$id',
      parser: (json) => json as Map<String, dynamic>,
    );
  }

  Future<Map<String, dynamic>> createLevel(Map<String, dynamic> model) async {
    return post<Map<String, dynamic>>(
      endpoint: '',
      body: model,
      parser: (json) => json as Map<String, dynamic>,
    );
  }

  Future<Map<String, dynamic>> updateLevel(
    String id,
    Map<String, dynamic> model,
  ) async {
    return patch<Map<String, dynamic>>(
      endpoint: '/$id',
      body: model,
      parser: (json) => json as Map<String, dynamic>,
    );
  }

  Future<void> deleteLevel(String id) async {
    return delete<void>(endpoint: '/$id', parser: (_) => null);
  }

  Future<List<Map<String, dynamic>>> getLevelsByParking(
    String parkingId,
  ) async {
    return get<List<Map<String, dynamic>>>(
      endpoint: '',
      additionalHeaders: {'parkingId': parkingId},
      parser: (json) =>
          parseModelList(json, (item) => item as Map<String, dynamic>),
    );
  }

  Future<Map<String, dynamic>> getLevelsPaginated({
    int page = 1,
    int limit = 10,
    String? search,
    String? parkingId,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }

    if (parkingId != null && parkingId.isNotEmpty) {
      queryParams['parkingId'] = parkingId;
    }

    final queryString = queryParams.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');

    return get<Map<String, dynamic>>(
      endpoint: '/paginated?$queryString',
      parser: (json) =>
          parsePaginatedResponse(json, (item) => item as Map<String, dynamic>),
    );
  }
}
