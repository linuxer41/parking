import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import '../models/access_model.dart';
import 'base_service.dart';

/// Servicio para gestionar entradas y salidas de vehículos
class AccessService extends BaseService {
  /// Constructor
  AccessService() : super(path: AppConfig.apiEndpoints['access'] ?? '/accesses');

  /// Registra una nueva entrada de vehículo
  Future<AccessModel> registerEntry(AccessCreateModel access) async {
    try {
      // Usar el método post del BaseService
      return post<AccessModel>(
        endpoint: '/',
        body: access.toJson(),
        parser: (json) => AccessModel.fromJson(json),
      );
    } catch (e) {
      debugPrint('Error al registrar entrada: $e');
      rethrow;
    }
  }

  /// Registra la entrada de un vehículo con suscripción
  Future<AccessModel> registerSubscribedEntry(String subscriptionId) async {
    try {
      debugPrint('Registrando entrada con suscripción: $subscriptionId');

      // Usar el método post del BaseService
      return post<AccessModel>(
        endpoint: '/subscribed',
        body: {'subscriptionId': subscriptionId},
        parser: (json) => AccessModel.fromJson(json),
      );
    } catch (e) {
      debugPrint('Error al registrar entrada con suscripción: $e');
      rethrow;
    }
  }

  /// Registra la entrada de un vehículo con reserva
  Future<AccessModel> registerReservedEntry(String reservationId) async {
    try {
      debugPrint('Registrando entrada con reserva: $reservationId');

      // Usar el método post del BaseService
      return post<AccessModel>(
        endpoint: '/reserved',
        body: {'reservationId': reservationId},
        parser: (json) => AccessModel.fromJson(json),
      );
    } catch (e) {
      debugPrint('Error al registrar entrada con reserva: $e');
      rethrow;
    }
  }

  /// Registra la salida de un vehículo
  Future<AccessModel> registerExit({
    required String parkingId,
    required String accessId,
    double? amount,
  }) async {
    try {
      debugPrint('Registrando salida para acceso: $accessId');

      // Preparar los datos para la petición
      final exitData = {
        'accessId': accessId,
        'amount': amount,
        'parkingId': parkingId,
      };

      // Usar el método post del BaseService
      return post<AccessModel>(
        endpoint: '/exit',
        body: exitData,
        parser: (json) => AccessModel.fromJson(json),
      );
    } catch (e) {
      debugPrint('Error al registrar salida: $e');
      rethrow;
    }
  }

  /// Calcula la tarifa para una salida
  Future<double> calculateExitFee(String parkingId, String accessId) async {
    try {
      debugPrint('Calculando tarifa para acceso: $accessId');

      // Usar el método get del BaseService
      final result = await get<Map<String, dynamic>>(
        endpoint: '/$parkingId/accesses/$accessId/fee',
        parser: (json) => json as Map<String, dynamic>,
      );

      final amount = result['amount'] as double;
      debugPrint('Tarifa calculada: $amount');
      return amount;
    } catch (e) {
      debugPrint('Error al calcular tarifa: $e');
      rethrow;
    }
  }

  /// Obtiene los detalles de un acceso específico
  Future<AccessModel> getAccessById(String parkingId, String accessId) async {
    try {
      debugPrint('Obteniendo detalles del acceso: $accessId');

      // Usar el método get del BaseService
      return get<AccessModel>(
        endpoint: '/$parkingId/accesses/$accessId',
        parser: (json) => AccessModel.fromJson(json),
      );
    } catch (e) {
      debugPrint('Error al obtener acceso: $e');
      rethrow;
    }
  }

  /// Obtiene un acceso por ID
  Future<AccessModel> getAccess(String accessId) async {
    try {
      debugPrint('Obteniendo acceso: $accessId');

      return get<AccessModel>(
        endpoint: '/$accessId',
        parser: (json) => AccessModel.fromJson(json),
      );
    } catch (e) {
      debugPrint('Error al obtener acceso: $e');
      rethrow;
    }
  }
}
