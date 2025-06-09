import 'package:vector_math/vector_math.dart' as vector_math;

import '../models/index.dart';

/// Clase para crear elementos del mundo
class WorldElementFactory {
  /// Contador para generar IDs únicos
  static int _idCounter = 0;

  /// Generar un ID único
  static String _generateId() {
    _idCounter++;
    return 'element_$_idCounter';
  }

  /// Crear un espacio de estacionamiento
  static ParkingSpot createSpot({
    required vector_math.Vector2 position,
    SpotType type = SpotType.vehicle,
    SpotCategory category = SpotCategory.normal,
    String? label,
    bool isOccupied = false,
    String? vehiclePlate,
    double rotation = 0.0,
  }) {
    Size3D size = Size3D(width: ElementProperties.spotVisuals[type]?.width ?? 80.0, height: ElementProperties.spotVisuals[type]?.height ?? 160.0, depth: 10.0);
    return ParkingSpot(
      id: _generateId(),
      position: position,
      type: type,
      category: category,
      label: label,
      isOccupied: isOccupied,
      vehiclePlate: vehiclePlate,
      rotation: rotation,
      size: size,
    );
  }

  /// Crear una señalización
  static ParkingSignage createSignage({
    required vector_math.Vector2 position,
    SignageType type = SignageType.entrance,
    String? label,
    int direction = 0,
    double rotation = 0.0,
  }) {
    Size3D size = Size3D(width: ElementProperties.signageVisuals[type]?.width ?? 60.0, height: ElementProperties.signageVisuals[type]?.height ?? 30.0, depth: 5.0) ;
    return ParkingSignage(
      id: _generateId(),
      position: position,
      type: type,
      label: label,
      direction: direction,
      rotation: rotation,
      size: size,
    );
  }

  /// Crear una instalación
  static ParkingFacility createFacility({
    required vector_math.Vector2 position,
    FacilityType type = FacilityType.elevator,
    String? label,
    double rotation = 0.0,
  }) {
    Size3D size = Size3D(width: ElementProperties.facilityVisuals[type]?.width ?? 80.0, height: ElementProperties.facilityVisuals[type]?.height ?? 80.0, depth: 20.0);

    return ParkingFacility(
      id: _generateId(),
      position: position,
      type: type,
      label: label,
      rotation: rotation,
      size: size,
    );
  }

  /// Crear un elemento desde un JSON
  static WorldElement? fromJson(Map<String, dynamic> json) {
    // Determinar el tipo de elemento
    if (json.containsKey('spotType')) {
      // Es un espacio de estacionamiento
      return ParkingSpot.fromJson(json);
    } else if (json.containsKey('signageType')) {
      // Es una señalización
      return ParkingSignage.fromJson(json);
    } else if (json.containsKey('facilityType')) {
      // Es una instalación
      return ParkingFacility.fromJson(json);
    }

    return null;
  }
}
