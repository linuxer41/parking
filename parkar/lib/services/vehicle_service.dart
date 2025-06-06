import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/vehicle_model.dart';
import '_base_service.dart';

class VehicleService extends ChangeNotifier {
  static final VehicleService _instance = VehicleService._internal();

  // Lista de vehículos en memoria
  List<Vehicle> _vehicles = [];

  // Clave para almacenar en SharedPreferences
  static const String _vehiclesKey = 'vehicles_data';

  // Constructor factory para implementar patrón singleton
  factory VehicleService() {
    return _instance;
  }

  VehicleService._internal() {
    _loadVehicles();
  }

  // Método para obtener un vehículo por su ID
  Future<VehicleModel> getVehicle(String vehicleId) async {
    // En una implementación real, aquí se buscaría el vehículo en la base de datos
    // Por ahora devolvemos un modelo simulado con los campos mínimos necesarios
    return VehicleModel(
      id: vehicleId,
      parkingId: 'parking-1',
      plate: 'ABC-123',
      type: 'Automóvil',
      createdAt: DateTime.now(),
      isSubscriber: false,
    );
  }

  // Getter para acceder a la lista de vehículos (copia para evitar modificaciones directas)
  List<Vehicle> get vehicles => List.from(_vehicles);

  // Getter para obtener solo los vehículos activos (que no han salido)
  List<Vehicle> get activeVehicles =>
      _vehicles.where((vehicle) => vehicle.exitTime == null).toList();

  // Getter para obtener solo los vehículos que ya salieron
  List<Vehicle> get completedVehicles =>
      _vehicles.where((vehicle) => vehicle.exitTime != null).toList();

  // Método para cargar vehículos desde el almacenamiento local
  Future<void> _loadVehicles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final vehiclesJson = prefs.getString(_vehiclesKey);

      if (vehiclesJson != null) {
        final List<dynamic> decodedList = jsonDecode(vehiclesJson);
        _vehicles = decodedList.map((item) => Vehicle.fromJson(item)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error cargando vehículos: $e');
    }
  }

  // Método para guardar los vehículos en el almacenamiento local
  Future<void> _saveVehicles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final vehiclesJson =
          jsonEncode(_vehicles.map((v) => v.toJson()).toList());
      await prefs.setString(_vehiclesKey, vehiclesJson);
    } catch (e) {
      debugPrint('Error guardando vehículos: $e');
    }
  }

  // Método para registrar la entrada de un vehículo
  Future<Vehicle> registerEntry({
    required String licensePlate,
    required String spotId,
    required String type,
    String? ownerName,
  }) async {
    // Verificar si ya existe un vehículo activo con la misma placa
    final existingVehicle = _vehicles
        .where((v) => v.licensePlate == licensePlate && v.exitTime == null)
        .firstOrNull;

    if (existingVehicle != null) {
      throw Exception('Ya existe un vehículo activo con esta placa');
    }

    // Crear un nuevo vehículo
    final newVehicle = Vehicle(
      id: 'VEH-${DateTime.now().millisecondsSinceEpoch}',
      licensePlate: licensePlate,
      entryTime: DateTime.now(),
      spotId: spotId,
      type: type,
      ownerName: ownerName,
    );

    // Añadirlo a la lista
    _vehicles.add(newVehicle);
    notifyListeners();

    // Guardar en almacenamiento
    await _saveVehicles();

    return newVehicle;
  }

  // Método para registrar la salida de un vehículo
  Future<Vehicle> registerExit({
    required String vehicleId,
    required double cost,
  }) async {
    // Buscar el vehículo
    final index = _vehicles.indexWhere((v) => v.id == vehicleId);

    if (index == -1) {
      throw Exception('Vehículo no encontrado');
    }

    if (_vehicles[index].exitTime != null) {
      throw Exception('Este vehículo ya registró su salida');
    }

    // Actualizar el vehículo con la hora de salida y el costo
    final updatedVehicle = _vehicles[index].copyWith(
      exitTime: DateTime.now(),
      cost: cost,
    );

    // Reemplazar en la lista
    _vehicles[index] = updatedVehicle;
    notifyListeners();

    // Guardar en almacenamiento
    await _saveVehicles();

    return updatedVehicle;
  }

  // Método para buscar un vehículo por su ID
  Vehicle? getVehicleById(String id) {
    try {
      return _vehicles.firstWhere((v) => v.id == id);
    } catch (e) {
      return null;
    }
  }

  // Método para buscar un vehículo activo por su placa
  Vehicle? getActiveVehicleByPlate(String plate) {
    try {
      return _vehicles
          .firstWhere((v) => v.licensePlate == plate && v.exitTime == null);
    } catch (e) {
      return null;
    }
  }

  // Método para calcular el costo del estacionamiento
  double calculateParkingCost(Vehicle vehicle) {
    if (vehicle.exitTime == null) {
      // Vehículo aún estacionado, calcular hasta ahora
      final now = DateTime.now();
      final duration = now.difference(vehicle.entryTime);
      return _calculateCostFromDuration(duration, vehicle.type);
    } else {
      // Vehículo ya salió, calcular con la hora de salida registrada
      final duration = vehicle.exitTime!.difference(vehicle.entryTime);
      return _calculateCostFromDuration(duration, vehicle.type);
    }
  }

  // Método auxiliar para calcular el costo basado en la duración
  double _calculateCostFromDuration(Duration duration, String vehicleType) {
    // Tarifas base por hora según tipo de vehículo
    final hourlyRate = _getHourlyRateByType(vehicleType);

    // Calcular horas (redondeando hacia arriba)
    final hours = (duration.inMinutes / 60).ceil();

    // Tarifa mínima de 1 hora
    final cost = hourlyRate * (hours < 1 ? 1 : hours);

    return cost;
  }

  // Obtener tarifa por hora según tipo de vehículo
  double _getHourlyRateByType(String vehicleType) {
    switch (vehicleType) {
      case 'Automóvil':
        return 5.0;
      case 'Motocicleta':
        return 3.0;
      case 'Camión':
        return 8.0;
      default:
        return 5.0;
    }
  }

  // Método para eliminar un vehículo (solo para propósitos administrativos)
  Future<void> deleteVehicle(String id) async {
    _vehicles.removeWhere((v) => v.id == id);
    notifyListeners();
    await _saveVehicles();
  }

  // Método para eliminar todos los vehículos (solo para propósitos administrativos)
  Future<void> clearAllVehicles() async {
    _vehicles.clear();
    notifyListeners();
    await _saveVehicles();
  }

  // Método para asignar un vehículo a un espacio de estacionamiento
  Future<void> assignToSpot(String vehicleId, String spotId) async {
    // Buscar el vehículo por ID
    final vehicle = getVehicleById(vehicleId);
    if (vehicle == null) {
      throw Exception('Vehículo no encontrado');
    }

    // En una implementación real, aquí se actualizaría la asignación en la base de datos
    // Por ahora simplemente notificamos el cambio
    notifyListeners();
    await _saveVehicles();

    return;
  }

  // Método para crear un nuevo vehículo a partir de un modelo
  Future<VehicleModel> create(VehicleCreateModel model) async {
    // En una implementación real, aquí se crearía el vehículo en la base de datos
    // Por ahora creamos un modelo simulado
    final newVehicle = VehicleModel(
      id: 'VEH-${DateTime.now().millisecondsSinceEpoch}',
      parkingId: model.parkingId,
      plate: model.plate,
      createdAt: DateTime.now(),
      typeId: model.typeId,
      isSubscriber: model.isSubscriber,
      spotNumber: model.spotNumber,
      fee: model.fee,
      entryTime: DateTime.now(),
    );

    // Notificar cambios
    notifyListeners();

    // En una implementación real, aquí se guardaría en la base de datos

    return newVehicle;
  }
}
