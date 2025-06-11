import 'package:vector_math/vector_math.dart' as vector_math;
import 'dart:math' as math;

import 'enums.dart';
import 'parking_elements.dart';
import 'parking_spot.dart';
import 'parking_signage.dart';
import 'parking_facility.dart';

/// Factory para crear elementos del sistema de parkeo
class ElementFactory {
  // Generador de IDs únicos
  static int _nextId = 1;

  /// Genera un ID único
  static String generateId(String prefix) {
    final id = '$prefix-${_nextId.toString().padLeft(4, '0')}';
    _nextId++;
    return id;
  }

  /// Crea un espacio de estacionamiento
  static ParkingSpot createSpot({
    required vector_math.Vector2 position,
    required SpotType type,
    required String label,
    SpotCategory category = SpotCategory.normal,
    double rotation = 0.0,
    double scale = 1.0,
  }) {
    return ParkingSpot(
      id: generateId('spot'),
      position: position,
      type: type,
      label: label,
      category: category,
      rotation: rotation,
      scale: scale,
    );
  }

  /// Crea una señalización
  static ParkingSignage createSignage({
    required vector_math.Vector2 position,
    required SignageType type,
    String? text,
    double rotation = 0.0,
    double scale = 1.0,
  }) {
    return ParkingSignage(
      id: generateId('sign'),
      position: position,
      type: type,
      text: text,
      rotation: rotation,
      scale: scale,
    );
  }

  /// Crea una instalación
  static ParkingFacility createFacility({
    required vector_math.Vector2 position,
    required FacilityType type,
    required String name,
    bool isAvailable = true,
    double rotation = 0.0,
    double scale = 1.0,
  }) {
    return ParkingFacility(
      id: generateId('fac'),
      position: position,
      type: type,
      name: name,
      isAvailable: isAvailable,
      rotation: rotation,
      scale: scale,
    );
  }

  /// Crea un elemento desde un JSON genérico
  static ParkingElement? fromJson(Map<String, dynamic> json) {
    final String type = json['type'] as String;

    switch (type) {
      case 'spot':
        return ParkingSpot.fromJson(json);
      case 'signage':
        return ParkingSignage.fromJson(json);
      case 'facility':
        return ParkingFacility.fromJson(json);
      default:
        return null;
    }
  }

  /// Genera una fila de espacios de estacionamiento
  static List<ParkingSpot> generateSpotRow({
    required vector_math.Vector2 startPosition,
    required int count,
    required SpotType type,
    required String labelPrefix,
    double spacing = 10.0,
    SpotCategory category = SpotCategory.normal,
    double rotation = 0.0,
  }) {
    final List<ParkingSpot> spots = [];
    final ElementVisuals visuals = ElementProperties.spotVisuals[type]!;
    final double width = visuals.width + spacing;

    for (int i = 0; i < count; i++) {
      final label = '$labelPrefix-${(i + 1).toString().padLeft(2, '0')}';
      final position = vector_math.Vector2(
        startPosition.x + i * width * math.cos(rotation),
        startPosition.y + i * width * math.sin(rotation),
      );

      spots.add(
        createSpot(
          position: position,
          type: type,
          label: label,
          category: category,
          rotation: rotation,
        ),
      );
    }

    return spots;
  }

  /// Reinicia el generador de IDs
  static void resetIdGenerator() {
    _nextId = 1;
  }
}
