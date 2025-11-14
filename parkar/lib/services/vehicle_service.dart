// import 'dart:convert';
// import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import '../models/vehicle_model.dart';
import 'base_service.dart';
import 'api_exception.dart';

/// Service for managing vehicles
class VehicleService extends BaseService {
  /// Constructor
  VehicleService()
    : super(path: AppConfig.apiEndpoints['vehicle'] ?? '/vehicles');

  /// Obtiene la lista de vehículos con parsing profesional
  Future<List<VehicleModel>> getVehicles() async {
    try {
      return await get<List<VehicleModel>>(
        endpoint: '/',
        parser: (json) => parseModelList(json, VehicleModel.fromJson),
      );
    } catch (e) {
      debugPrint('Error al obtener vehículos: $e');
      return [];
    }
  }

  /// Obtiene la lista de vehículos por parking ID con parsing profesional
  Future<List<VehicleModel>> getVehiclesByParking(String parkingId) async {
    try {
      return await get<List<VehicleModel>>(
        endpoint: '/parking/$parkingId',
        parser: (json) => parseModelList(json, VehicleModel.fromJson),
      );
    } catch (e) {
      debugPrint('Error al obtener vehículos por parking: $e');
      return [];
    }
  }

  /// Obtiene información detallada de un vehículo por placa con parsing profesional
  /// Incluye información sobre reservas, suscripciones o accesos activos
  Future<VehicleModel> getVehicleByPlate(String parkingId, String plate) async {
    try {
      debugPrint('Obteniendo información del vehículo con placa: $plate');

      return await get<VehicleModel>(
        endpoint: '/status?plate=$plate&parkingId=$parkingId',
        parser: (json) => parseModel(json, VehicleModel.fromJson),
      );
    } catch (e) {
      debugPrint('Error al obtener información del vehículo: $e');
      rethrow;
    }
  }

  /// Obtiene un vehículo por ID con parsing profesional
  Future<VehicleModel> getVehicleById(String id) async {
    try {
      return await get<VehicleModel>(
        endpoint: '/$id',
        parser: (json) => parseModel(json, VehicleModel.fromJson),
      );
    } catch (e) {
      debugPrint('Error al obtener vehículo por ID: $e');
      rethrow;
    }
  }

  /// Crea un nuevo vehículo con parsing profesional
  Future<VehicleModel> createVehicle(VehicleCreateModel model) async {
    try {
      return await post<VehicleModel>(
        endpoint: '/',
        body: model,
        parser: (json) => parseModel(json, VehicleModel.fromJson),
      );
    } catch (e) {
      debugPrint('Error al crear vehículo: $e');
      rethrow;
    }
  }

  /// Actualiza un vehículo con parsing profesional
  Future<VehicleModel> updateVehicle(
    String id,
    VehicleUpdateModel model,
  ) async {
    try {
      return await patch<VehicleModel>(
        endpoint: '/$id',
        body: model,
        parser: (json) => parseModel(json, VehicleModel.fromJson),
      );
    } catch (e) {
      debugPrint('Error al actualizar vehículo: $e');
      rethrow;
    }
  }

  /// Elimina un vehículo
  Future<void> deleteVehicle(String id) async {
    try {
      await delete<void>(endpoint: '/$id', parser: (_) => null);
    } catch (e) {
      debugPrint('Error al eliminar vehículo: $e');
      rethrow;
    }
  }

  /// Obtiene vehículos con paginación profesional
  Future<Map<String, dynamic>> getVehiclesPaginated({
    int page = 1,
    int limit = 10,
    String? search,
    String? parkingId,
  }) async {
    try {
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

      return await get<Map<String, dynamic>>(
        endpoint: '/paginated?$queryString',
        parser: (json) => parsePaginatedResponse(json, VehicleModel.fromJson),
      );
    } catch (e) {
      debugPrint('Error al obtener vehículos paginados: $e');
      rethrow;
    }
  }

  /// Obtiene vehículos con respuesta flexible (puede ser lista o paginado)
  Future<dynamic> getVehiclesFlexible({
    String? parkingId,
    String? search,
  }) async {
    try {
      final queryParams = <String, String>{};

      if (parkingId != null && parkingId.isNotEmpty) {
        queryParams['parkingId'] = parkingId;
      }

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final queryString = queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');

      final endpoint = queryString.isNotEmpty
          ? '/flexible?$queryString'
          : '/flexible';

      return await get<dynamic>(
        endpoint: endpoint,
        parser: (json) => parseFlexibleResponse(json, VehicleModel.fromJson),
      );
    } catch (e) {
      debugPrint('Error al obtener vehículos flexible: $e');
      rethrow;
    }
  }

  /// Ejemplo completo de parsing profesional con manejo de casos edge
  /// Este método demuestra todas las técnicas de parsing y validación
  Future<Map<String, dynamic>> getVehiclesWithAdvancedParsing({
    String? parkingId,
    String? search,
    bool includeInactive = false,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      // Construir query parameters de forma profesional
      final queryParams = <String, String>{};

      if (parkingId != null && parkingId.trim().isNotEmpty) {
        queryParams['parkingId'] = parkingId.trim();
      }

      if (search != null && search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
      }

      if (includeInactive) {
        queryParams['includeInactive'] = 'true';
      }

      if (sortBy != null && sortBy.trim().isNotEmpty) {
        queryParams['sortBy'] = sortBy.trim();
      }

      if (sortOrder != null &&
          ['asc', 'desc'].contains(sortOrder.toLowerCase())) {
        queryParams['sortOrder'] = sortOrder.toLowerCase();
      }

      // Construir query string de forma segura
      final queryString = queryParams.entries
          .where((e) => e.value.isNotEmpty)
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');

      final endpoint = queryString.isNotEmpty
          ? '/advanced?$queryString'
          : '/advanced';

      // Usar parsing flexible que maneja múltiples formatos de respuesta
      final result = await get<dynamic>(
        endpoint: endpoint,
        parser: (json) {
          // Validación adicional antes del parsing
          if (json == null) {
            throw ApiException(
              statusCode: 500,
              message: 'Respuesta vacía del servidor',
            );
          }

          // Logging para debugging
          if (kDebugMode) {
            debugPrint('🔍 Parsing response type: ${json.runtimeType}');
            if (json is Map) {
              debugPrint('🔍 Response keys: ${json.keys.toList()}');
            }
          }

          // Usar parsing flexible que maneja todos los casos
          return parseFlexibleResponse(json, VehicleModel.fromJson);
        },
      );

      // Procesar el resultado según su tipo
      if (result is List<VehicleModel>) {
        return {
          'items': result,
          'total': result.length,
          'page': 1,
          'limit': result.length,
          'hasMore': false,
          'type': 'list',
        };
      } else if (result is Map<String, dynamic>) {
        return {...result, 'type': 'paginated'};
      } else if (result is VehicleModel) {
        return {
          'items': [result],
          'total': 1,
          'page': 1,
          'limit': 1,
          'hasMore': false,
          'type': 'single',
        };
      } else {
        throw ApiException(
          statusCode: 500,
          message: 'Formato de respuesta inesperado: ${result.runtimeType}',
        );
      }
    } on ApiException catch (e) {
      // Manejo específico de errores de API
      debugPrint('🚨 API Error: ${e.statusCode} - ${e.message}');

      if (e.isValidationError) {
        debugPrint('🚨 Validation errors: ${e.errors}');
      }

      rethrow;
    } catch (e, stackTrace) {
      // Manejo de errores inesperados
      debugPrint('💥 Unexpected error: $e');
      debugPrint('📚 Stack trace: $stackTrace');

      throw ApiException(
        statusCode: 500,
        message: 'Error inesperado al obtener vehículos: ${e.toString()}',
      );
    }
  }
}
