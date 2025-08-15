import '../config/app_config.dart';
import '../models/area_model.dart';
import 'base_service.dart';

/// Servicio para gestionar entradas y salidas de vehículos
class AreaService extends BaseService {
  /// Constructor
  AreaService() : super(path: AppConfig.apiEndpoints['area'] ?? '/areas');

  /// Get all areas
  Future<List<AreaModel>> getAreas() async {
    return get<List<AreaModel>>(
      endpoint: '',
      parser: (data) => (data as List<dynamic>).map((item) => AreaModel.fromJson(item)).toList(),
    );
  }

  /// Get an area by ID
  Future<AreaModel> getAreaById(String id) async {
    return get<AreaModel>(
      endpoint: '/$id',
      parser: (data) => AreaModel.fromJson(data),
    );
  }

  /// Create a new area
  Future<AreaModel> createArea(AreaCreateModel model) async {
    return post<AreaModel>(
      endpoint: '',
      body: model,
      parser: (data) => AreaModel.fromJson(data),
    );
  }       

  /// Update an area
  Future<AreaModel> updateArea(String id, AreaUpdateModel model) async {
    return patch<AreaModel>(
      endpoint: '/$id',
      body: model,
      parser: (data) => AreaModel.fromJson(data),
    );
  }

  /// Delete an area
  Future<void> deleteArea(String id) async {
    await delete(
      endpoint: '/$id',
      parser: (_) => null,
    );
  }
}
