import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as vector_math;

import 'world_elements.dart';
import 'index.dart';

/// Fábrica para crear elementos del mundo
class WorldElementFactory {
  /// Crear un espacio de estacionamiento
  static ParkingSpot createSpot({
    required vector_math.Vector2 position,
    String? id,
    SpotType type = SpotType.vehicle,
    SpotCategory category = SpotCategory.normal,
    bool isOccupied = false,
    String? vehiclePlate,
    String? label,
    double rotation = 0.0,
    Size3D? size,
  }) {
    // Generar ID único si no se proporciona
    final spotId = id ?? DateTime.now().millisecondsSinceEpoch.toString();
    
    // Determinar tamaño según el tipo
    final spotSize = size ?? _getDefaultSizeForSpot(type);
    
    // Determinar color según el tipo y categoría
    final spotColor = ElementProperties.spotVisuals[type]?.color ?? Colors.blue;
    
    // Crear el espacio
    return ParkingSpot(
      id: spotId,
      position: position,
      type: type,
      category: category,
      isOccupied: isOccupied,
      vehiclePlate: vehiclePlate,
      label: label ?? _generateLabelForSpot(type),
      rotation: rotation,
      size: spotSize,
      color: spotColor,
      icon: ElementProperties.spotVisuals[type]?.icon,
    );
  }
  
  /// Crear una señalización
  static ParkingSignage createSignage({
    required vector_math.Vector2 position,
    String? id,
    SignageType type = SignageType.info,
    int direction = 0,
    String? label,
    double rotation = 0.0,
    Size3D? size,
  }) {
    // Generar ID único si no se proporciona
    final signageId = id ?? DateTime.now().millisecondsSinceEpoch.toString();
    
    // Determinar tamaño según el tipo
    final signageSize = size ?? _getDefaultSizeForSignage(type);
    
    // Determinar color según el tipo
    final signageColor = ElementProperties.signageVisuals[type]?.color ?? Colors.blue;
    
    // Crear la señalización
    return ParkingSignage(
      id: signageId,
      position: position,
      type: type,
      direction: direction,
      label: label ?? ElementProperties.signageVisuals[type]?.label ?? 'Info',
      rotation: rotation,
      size: signageSize,
      color: signageColor,
      icon: ElementProperties.signageVisuals[type]?.icon,
    );
  }
  
  /// Crear una instalación
  static ParkingFacility createFacility({
    required vector_math.Vector2 position,
    String? id,
    FacilityType type = FacilityType.elevator,
    String? label,
    double rotation = 0.0,
    Size3D? size,
  }) {
    // Generar ID único si no se proporciona
    final facilityId = id ?? DateTime.now().millisecondsSinceEpoch.toString();
    
    // Determinar tamaño según el tipo
    final facilitySize = size ?? _getDefaultSizeForFacility(type);
    
    // Determinar color según el tipo
    final facilityColor = ElementProperties.facilityVisuals[type]?.color ?? Colors.blue;
    
    // Crear la instalación
    return ParkingFacility(
      id: facilityId,
      position: position,
      type: type,
      label: label ?? ElementProperties.facilityVisuals[type]?.label ?? 'Instalación',
      rotation: rotation,
      size: facilitySize,
      color: facilityColor,
      icon: ElementProperties.facilityVisuals[type]?.icon,
    );
  }
  
  /// Obtener tamaño predeterminado para un espacio según su tipo
  static Size3D _getDefaultSizeForSpot(SpotType type) {
    switch (type) {
      case SpotType.vehicle:
        return Size3D(width: 40, height: 80, depth: 0);
      case SpotType.motorcycle:
        return Size3D(width: 20, height: 40, depth: 0);
      case SpotType.truck:
        return Size3D(width: 60, height: 120, depth: 0);
    }
  }
  
  /// Obtener tamaño predeterminado para una señalización según su tipo
  static Size3D _getDefaultSizeForSignage(SignageType type) {
    switch (type) {
      case SignageType.entrance:
      case SignageType.exit:
        return Size3D(width: 30, height: 30, depth: 0);
      case SignageType.oneWay:
      case SignageType.twoWay:
        return Size3D(width: 25, height: 25, depth: 0);
      case SignageType.noParking:
      case SignageType.info:
      default:
        return Size3D(width: 20, height: 20, depth: 0);
    }
  }
  
  /// Obtener tamaño predeterminado para una instalación según su tipo
  static Size3D _getDefaultSizeForFacility(FacilityType type) {
    switch (type) {
      case FacilityType.elevator:
        return Size3D(width: 40, height: 40, depth: 0);
      case FacilityType.bathroom:
        return Size3D(width: 50, height: 40, depth: 0);
      case FacilityType.payStation:
        return Size3D(width: 30, height: 30, depth: 0);
      case FacilityType.securityOffice:
        return Size3D(width: 60, height: 40, depth: 0);
      default:
        return Size3D(width: 40, height: 40, depth: 0);
    }
  }
  
  /// Generar etiqueta predeterminada para un espacio según su tipo
  static String _generateLabelForSpot(SpotType type) {
    // Prefijo según el tipo
    String prefix = '';
    
    switch (type) {
      case SpotType.vehicle:
        prefix = 'V-';
        break;
      case SpotType.motorcycle:
        prefix = 'M-';
        break;
      case SpotType.truck:
        prefix = 'C-';
        break;
    }
    
    // Número aleatorio para simular un contador
    final count = DateTime.now().millisecondsSinceEpoch % 1000;
    
    // Formatear el número con ceros a la izquierda (001, 002, etc.)
    String formattedCount = count.toString().padLeft(3, '0');
    
    return '$prefix$formattedCount';
  }
} 