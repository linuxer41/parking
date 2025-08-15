// import 'dart:convert';
// import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import '../models/vehicle_model.dart';
import 'base_service.dart';

/// Service for managing vehicles
class VehicleService extends BaseService {
  /// Constructor
  VehicleService() : super(path: AppConfig.apiEndpoints['vehicle'] ?? '/vehicles');

  /// Obtiene la lista de vehículos
  Future<List<VehicleModel>> getVehicles() async {
    try {
      final response = await get<List<VehicleModel>>(
        endpoint: '/',
        parser: (json) => (json as List)
            .map((e) => VehicleModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
      return response;
    } catch (e) {
      debugPrint('Error al obtener vehículos: $e');
      return [];
    }
  }
  
  /// Obtiene información detallada de un vehículo por placa
  /// Incluye información sobre reservas, suscripciones o accesos activos
  Future<VehicleModel> getVehicleByPlate(String parkingId, String plate) async {
    try {
      debugPrint('Obteniendo información del vehículo con placa: $plate');
      
      // Usar el método get del BaseService con query parameter para la placa
      return get<VehicleModel>(
        endpoint: '/status?plate=$plate&parkingId=$parkingId',
        parser: (json) => json as VehicleModel,
      );
    } catch (e) {
      debugPrint('Error al obtener información del vehículo: $e');
      rethrow;
    }
  }
}
