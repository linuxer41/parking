import 'dart:convert';
import 'package:flutter/services.dart';
import '../screens/parking/models/parking_data.dart';

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

  /// Guarda el layout actual del estacionamiento (simulando API)
  Future<bool> saveParkingLayout(ParkingData parkingData) async {
    try {
      // Simular delay de red
      await Future.delayed(const Duration(milliseconds: 800));

      // En una implementación real, aquí se enviaría el JSON al servidor
      // mediante una petición HTTP PUT o POST
      print('API: Guardando layout del estacionamiento...');
      print('Datos guardados: ${parkingData.spots.length} espacios, '
          '${parkingData.signages.length} señales, ${parkingData.facilities.length} instalaciones');

      // Simular éxito (95% probabilidad)
      final success = (DateTime.now().millisecondsSinceEpoch % 100) < 95;

      if (!success) {
        print('API: Error al guardar layout (simulado)');
      } else {
        print('API: Layout guardado exitosamente');
      }

      return success;
    } catch (e) {
      print('Error al guardar layout: $e');
      return false;
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
      // Intentar cargar desde asset
      try {
        final String jsonString =
            await rootBundle.loadString(_parkingLayoutPath);
        // Verifica si es JSON válido
        json.decode(
            jsonString); // Esto lanzará una excepción si no es JSON válido
        return jsonString;
      } catch (e) {
        print('Error al cargar desde lib/assets/: $e');
        // Intentar cargar desde assets/data/
        return await rootBundle.loadString('assets/data/parking_layout.json');
      }
    } catch (e) {
      print('Error al cargar JSON: $e');
      // Si falla la carga, crear un JSON válido básico
      return _getDefaultParkingData();
    }
  }

  // Crear datos de estacionamiento por defecto en caso de error
  String _getDefaultParkingData() {
    // Crear un JSON mínimo pero válido
    final defaultData = {
      "spots": [
        {
          "x": 0.0,
          "y": -150.0,
          "label": "A-1",
          "type": "vehicle",
          "category": "normal",
          "rotation": 0.0,
          "scale": 1.0,
          "isOccupied": false
        },
        {
          "x": -100.0,
          "y": -150.0,
          "label": "A-2",
          "type": "vehicle",
          "category": "disabled",
          "rotation": 0.0,
          "scale": 1.0,
          "isOccupied": false
        },
        {
          "x": 100.0,
          "y": -150.0,
          "label": "A-3",
          "type": "vehicle",
          "category": "vip",
          "rotation": 0.0,
          "scale": 1.0,
          "isOccupied": false
        }
      ],
      "signages": [
        {"x": 0.0, "y": 0.0, "type": "path", "rotation": 0.0, "scale": 1.0},
        {
          "x": -250.0,
          "y": 0.0,
          "type": "entrance",
          "rotation": 0.0,
          "scale": 1.0
        },
        {"x": 250.0, "y": 0.0, "type": "exit", "rotation": 0.0, "scale": 1.0}
      ],
      "facilities": [
        {
          "x": 0.0,
          "y": 100.0,
          "type": "paymentstation",
          "name": "Centro de Pago",
          "scale": 1.0
        }
      ]
    };

    return json.encode(defaultData);
  }
}
