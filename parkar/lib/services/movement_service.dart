// import 'dart:convert';
import '../config/app_config.dart';
import 'base_service.dart';

/// Servicio para gestionar los movimientos de vehículos
class MovementService extends BaseService {
  MovementService()
      : super(path: AppConfig.apiEndpoints['movement'] ?? '/movement');

  /// Registra un nuevo movimiento
  Future<Map<String, dynamic>> registerMovement(
      Map<String, dynamic> movementData) async {
    // In a real implementation using BaseService, this would be:
    // return post<Map<String, dynamic>>(
    //   endpoint: '',
    //   body: movementData,
    //   parser: (json) => json as Map<String, dynamic>,
    // );

    // En una implementación real, esto sería una llamada a la API
    // Simulamos un retraso de red
    await Future.delayed(const Duration(milliseconds: 800));

    // Simulamos una respuesta exitosa
    return {
      'id': 'mov_${DateTime.now().millisecondsSinceEpoch}',
      ...movementData,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Obtiene los movimientos de un vehículo
  Future<List<Map<String, dynamic>>> getVehicleMovements(
      String licensePlate) async {
    // In a real implementation using BaseService, this would be:
    // return get<List<Map<String, dynamic>>>(
    //   endpoint: '/vehicle/$licensePlate',
    //   parser: (data) => (data as List<dynamic>)
    //       .map((item) => item as Map<String, dynamic>)
    //       .toList(),
    // );

    // En una implementación real, esto sería una llamada a la API
    // Simulamos un retraso de red
    await Future.delayed(const Duration(milliseconds: 700));

    // Simulamos una respuesta exitosa
    return [
      {
        'id': 'mov_1',
        'type': 'entry',
        'licensePlate': licensePlate,
        'parkingId': 'parking123',
        'levelId': 'level1',
        'spotId': 'spot1',
        'timestamp':
            DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
      },
      {
        'id': 'mov_2',
        'type': 'exit',
        'licensePlate': licensePlate,
        'parkingId': 'parking123',
        'levelId': 'level1',
        'spotId': 'spot1',
        'timestamp': DateTime.now()
            .subtract(const Duration(minutes: 30))
            .toIso8601String(),
      },
    ];
  }

  /// Obtiene los movimientos de un estacionamiento
  Future<List<Map<String, dynamic>>> getParkingMovements(String parkingId,
      {DateTime? startDate, DateTime? endDate}) async {
    // In a real implementation using BaseService, this would be:
    // Map<String, String> queryParams = {'parkingId': parkingId};
    // if (startDate != null) {
    //   queryParams['startDate'] = startDate.toIso8601String();
    // }
    // if (endDate != null) {
    //   queryParams['endDate'] = endDate.toIso8601String();
    // }
    //
    // return get<List<Map<String, dynamic>>>(
    //   endpoint: '/parking',
    //   additionalHeaders: queryParams,
    //   parser: (data) => (data as List<dynamic>)
    //       .map((item) => item as Map<String, dynamic>)
    //       .toList(),
    // );

    // En una implementación real, esto sería una llamada a la API
    // Simulamos un retraso de red
    await Future.delayed(const Duration(milliseconds: 900));

    // Simulamos una respuesta exitosa
    final now = DateTime.now();
    return [
      {
        'id': 'mov_1',
        'type': 'entry',
        'licensePlate': 'ABC123',
        'parkingId': parkingId,
        'levelId': 'level1',
        'spotId': 'spot1',
        'timestamp': now.subtract(const Duration(hours: 3)).toIso8601String(),
      },
      {
        'id': 'mov_2',
        'type': 'entry',
        'licensePlate': 'XYZ789',
        'parkingId': parkingId,
        'levelId': 'level2',
        'spotId': 'spot5',
        'timestamp': now.subtract(const Duration(hours: 2)).toIso8601String(),
      },
      {
        'id': 'mov_3',
        'type': 'exit',
        'licensePlate': 'ABC123',
        'parkingId': parkingId,
        'levelId': 'level1',
        'spotId': 'spot1',
        'timestamp': now.subtract(const Duration(hours: 1)).toIso8601String(),
      },
    ];
  }

  /// Obtiene estadísticas de movimientos
  Future<Map<String, dynamic>> getMovementStats(String parkingId) async {
    // In a real implementation using BaseService, this would be:
    // return get<Map<String, dynamic>>(
    //   endpoint: '/stats/$parkingId',
    //   parser: (json) => json as Map<String, dynamic>,
    // );

    // En una implementación real, esto sería una llamada a la API
    // Simulamos un retraso de red
    await Future.delayed(const Duration(milliseconds: 1000));

    // Simulamos una respuesta exitosa
    return {
      'totalEntries': 150,
      'totalExits': 145,
      'averageStayTime': 120, // minutos
      'peakHour': 18, // 6 PM
      'dailyStats': [
        {'day': 'Lunes', 'entries': 25, 'exits': 23},
        {'day': 'Martes', 'entries': 30, 'exits': 28},
        {'day': 'Miércoles', 'entries': 35, 'exits': 34},
        {'day': 'Jueves', 'entries': 28, 'exits': 27},
        {'day': 'Viernes', 'entries': 32, 'exits': 33},
      ],
    };
  }
}
