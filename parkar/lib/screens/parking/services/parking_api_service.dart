import 'package:flutter/services.dart';
import '../models/parking_data.dart';

/// Servicio para cargar datos del estacionamiento desde una API
/// Actualmente simula la carga desde un archivo JSON local
class ParkingApiService {
  static const String _parkingLayoutPath =
      'lib/assets/data/parking_layout.json';

  /// Carga los datos del estacionamiento (simulando una API)
  Future<ParkingData> loadParkingData() async {
    try {
      // En una implementación real, esto sería una llamada HTTP a un endpoint API
      // Por ahora, simulamos cargando desde un archivo local
      final String jsonData = await _loadJsonFromAsset();

      // Simular delay de red
      await Future.delayed(const Duration(milliseconds: 800));

      // Parsear los datos JSON
      final ParkingData parkingData =
          await ParkingData.fromJsonString(jsonData);

      print(
          'Datos de estacionamiento cargados: ${parkingData.spots.length} espacios, '
          '${parkingData.signages.length} señales, ${parkingData.facilities.length} instalaciones');

      return parkingData;
    } catch (e) {
      print('Error al cargar datos del estacionamiento: $e');
      // En caso de error, retornar un estacionamiento vacío
      return ParkingData(spots: [], signages: [], facilities: []);
    }
  }

  /// Simula actualización de estado de un espacio
  Future<bool> updateSpotStatus(String spotId, bool isOccupied) async {
    // Simular delay de red
    await Future.delayed(const Duration(milliseconds: 500));

    // En una implementación real, esto enviaría los datos al servidor
    print(
        'API: Actualizando estado del espacio $spotId a ${isOccupied ? "ocupado" : "libre"}');

    // Simular éxito (95% probabilidad)
    final success = (DateTime.now().millisecondsSinceEpoch % 100) < 95;
    if (!success) {
      print('API: Error al actualizar estado (simulado)');
    }

    return success;
  }

  /// Carga el archivo JSON desde los assets
  Future<String> _loadJsonFromAsset() async {
    try {
      final String jsonString = await rootBundle.loadString(_parkingLayoutPath);
      return jsonString;
    } catch (e) {
      // Si falla la carga, crear un JSON vacío
      return '{"spots":[],"signages":[],"facilities":[]}';
    }
  }
}
