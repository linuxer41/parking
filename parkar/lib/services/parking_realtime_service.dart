import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/level_model.dart';
import '../state/app_state.dart';
import 'service_locator.dart';

class ParkingRealtimeService {
  static final ParkingRealtimeService _instance =
      ParkingRealtimeService._internal();
  factory ParkingRealtimeService() => _instance;
  ParkingRealtimeService._internal();

  final String baseUrl = 'http://192.168.100.8:3001';
  final http.Client _httpClient = http.Client();

  Timer? _pollingTimer;
  final _parkingSpotsController = StreamController<List<SpotModel>>.broadcast();

  // Getters
  Stream<List<SpotModel>> get parkingSpots => _parkingSpotsController.stream;

  // Obtener el AppState desde el ServiceLocator
  AppState get _state => ServiceLocator().getAppState();

  // Construir encabezados para API
  Map<String, String> _buildHeaders() {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${_state.authToken}',
      'Access-Code': '${_state.employee?.id}:${_state.currentParking?.id}',
    };
  }

  // Iniciar actualización en tiempo real
  void startRealtimeUpdates({Duration interval = const Duration(seconds: 5)}) {
    // Detener cualquier timer existente
    stopRealtimeUpdates();

    // Verificar si tenemos la información necesaria
    if (_state.currentLevel == null || _state.currentParking == null) {
      print('No hay nivel o estacionamiento seleccionado');
      return;
    }

    // Hacer una primera actualización inmediata
    _fetchParkingStatus();

    // Iniciar el timer para actualizaciones periódicas
    _pollingTimer = Timer.periodic(interval, (_) => _fetchParkingStatus());
  }

  // Detener actualizaciones en tiempo real
  void stopRealtimeUpdates() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  // Actualizar ocupación de un espacio de estacionamiento
  Future<bool> updateSpotOccupancy(String spotId, bool isOccupied,
      String? vehiclePlate, String? vehicleColor) async {
    try {
      if (_state.currentLevel == null) return false;

      final uri = Uri.parse(
          '$baseUrl/level/${_state.currentLevel!.id}/spot/$spotId/status');

      final response = await _httpClient.patch(
        uri,
        headers: _buildHeaders(),
        body: jsonEncode({
          'isOccupied': isOccupied,
          'vehiclePlate': vehiclePlate,
          'vehicleColor': vehicleColor,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Actualización exitosa, refrescar datos
        _fetchParkingStatus();
        return true;
      }

      return false;
    } catch (e) {
      print('Error al actualizar spot: $e');
      return false;
    }
  }

  // Obtener estado actualizado del estacionamiento
  void _fetchParkingStatus() async {
    try {
      if (_state.currentLevel == null) return;

      final uri = Uri.parse('$baseUrl/level/${_state.currentLevel!.id}/spots');

      final response = await _httpClient.get(
        uri,
        headers: _buildHeaders(),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final List<dynamic> data = jsonDecode(response.body);
        final spots = data.map((item) => SpotModel.fromJson(item)).toList();

        // Enviar datos al stream
        if (!_parkingSpotsController.isClosed) {
          _parkingSpotsController.add(spots);
        }
      }
    } catch (e) {
      print('Error al obtener estado del estacionamiento: $e');
    }
  }

  // Método para simular actualizaciones (para desarrollo)
  void simulateRealtimeUpdates() {
    if (_state.currentLevel == null || _state.currentLevel!.spots.isEmpty) {
      return;
    }

    // Crear una copia de los spots actuales
    final spots = List<SpotModel>.from(_state.currentLevel!.spots);

    // Simular cambios aleatorios en la ocupación
    if (spots.isNotEmpty) {
      final random = DateTime.now().millisecondsSinceEpoch % spots.length;
      // Invertir el estado de ocupación del spot aleatorio
      final updatedSpots = spots.map((spot) {
        if (spots.indexOf(spot) == random) {
          return SpotModel(
            id: spot.id,
            name: spot.name,
            posX: spot.posX,
            posY: spot.posY,
            posZ: spot.posZ,
            rotation: spot.rotation,
            scale: spot.scale,
            vehicleId: spot.vehicleId == null ? 'simulated-vehicle' : null,
            spotType: spot.spotType,
            spotCategory: spot.spotCategory,
          );
        }
        return spot;
      }).toList();

      // Enviar al stream
      if (!_parkingSpotsController.isClosed) {
        _parkingSpotsController.add(updatedSpots);
      }
    }
  }

  // Liberar recursos
  void dispose() {
    stopRealtimeUpdates();
    _parkingSpotsController.close();
    _httpClient.close();
  }
}
