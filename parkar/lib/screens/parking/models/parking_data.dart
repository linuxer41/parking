import 'dart:convert';
import 'package:vector_math/vector_math.dart' as vector_math;
import 'parking_elements.dart';
import 'parking_spot.dart';
import 'parking_signage.dart';
import 'parking_facility.dart';
import 'enums.dart';
import 'element_factory.dart';

/// Modelo de datos para el estacionamiento
class ParkingData {
  final List<ParkingSpotData> spots;
  final List<ParkingSignageData> signages;
  final List<ParkingFacilityData> facilities;

  ParkingData({
    required this.spots,
    required this.signages,
    required this.facilities,
  });

  /// Crear a partir de un mapa JSON
  factory ParkingData.fromJson(Map<String, dynamic> json) {
    return ParkingData(
      spots: (json['spots'] as List)
          .map((spot) => ParkingSpotData.fromJson(spot))
          .toList(),
      signages: (json['signages'] as List)
          .map((signage) => ParkingSignageData.fromJson(signage))
          .toList(),
      facilities: (json['facilities'] as List)
          .map((facility) => ParkingFacilityData.fromJson(facility))
          .toList(),
    );
  }

  /// Convertir a objetos del modelo de dominio
  List<ParkingElement> toElements() {
    final elements = <ParkingElement>[];

    // Convertir spots
    for (final spotData in spots) {
      elements.add(spotData.toElement());
    }

    // Convertir señalizaciones
    for (final signageData in signages) {
      elements.add(signageData.toElement());
    }

    // Convertir instalaciones
    for (final facilityData in facilities) {
      elements.add(facilityData.toElement());
    }

    return elements;
  }

  /// Obtener solo los spots
  List<ParkingSpot> toSpots() {
    return spots.map((spotData) => spotData.toElement()).toList();
  }

  /// Obtener solo las señalizaciones
  List<ParkingSignage> toSignages() {
    return signages.map((signageData) => signageData.toElement()).toList();
  }

  /// Obtener solo las instalaciones
  List<ParkingFacility> toFacilities() {
    return facilities.map((facilityData) => facilityData.toElement()).toList();
  }

  /// Carga de datos desde un string JSON
  static Future<ParkingData> fromJsonString(String jsonString) async {
    final Map<String, dynamic> data = json.decode(jsonString);
    return ParkingData.fromJson(data);
  }
}

/// Clase para datos de spots de estacionamiento
class ParkingSpotData {
  final double x;
  final double y;
  final String label;
  final String type;
  final String category;
  final double rotation;
  final double scale;
  final bool isOccupied;
  final String? vehiclePlate;
  final String? vehicleColor;
  final String? entryTime;

  ParkingSpotData({
    required this.x,
    required this.y,
    required this.label,
    required this.type,
    required this.category,
    required this.rotation,
    required this.scale,
    this.isOccupied = false,
    this.vehiclePlate,
    this.vehicleColor,
    this.entryTime,
  });

  factory ParkingSpotData.fromJson(Map<String, dynamic> json) {
    return ParkingSpotData(
      x: json['x'].toDouble(),
      y: json['y'].toDouble(),
      label: json['label'],
      type: json['type'],
      category: json['category'],
      rotation: json['rotation'].toDouble(),
      scale: json['scale'].toDouble(),
      isOccupied: json['isOccupied'] ?? false,
      vehiclePlate: json['vehiclePlate'],
      vehicleColor: json['vehicleColor'],
      entryTime: json['entryTime'],
    );
  }

  ParkingSpot toElement() {
    final position = vector_math.Vector2(x, y);

    // Convertir strings a enums
    final spotType = _parseSpotType(type);
    final spotCategory = _parseSpotCategory(category);

    // Crear spot con ElementFactory
    final spot = ElementFactory.createSpot(
      position: position,
      type: spotType,
      category: spotCategory,
      label: label,
      rotation: rotation,
      scale: scale,
    );

    // Establecer estado de ocupación
    if (isOccupied) {
      spot.isOccupied = true;
      spot.vehiclePlate = vehiclePlate ?? '';
      spot.vehicleColor = vehicleColor ?? '';

      if (entryTime != null) {
        spot.entryTime = DateTime.parse(entryTime!);
      } else {
        spot.entryTime = DateTime.now().subtract(const Duration(minutes: 30));
      }
    }

    return spot;
  }

  // Convertir string a SpotType
  SpotType _parseSpotType(String typeStr) {
    switch (typeStr.toLowerCase()) {
      case 'vehicle':
        return SpotType.vehicle;
      case 'motorcycle':
        return SpotType.motorcycle;
      default:
        return SpotType.vehicle;
    }
  }

  // Convertir string a SpotCategory
  SpotCategory _parseSpotCategory(String categoryStr) {
    switch (categoryStr.toLowerCase()) {
      case 'disabled':
        return SpotCategory.disabled;
      case 'vip':
        return SpotCategory.vip;
      case 'reserved':
        return SpotCategory.reserved;
      case 'normal':
      default:
        return SpotCategory.normal;
    }
  }
}

/// Clase para datos de señalización
class ParkingSignageData {
  final double x;
  final double y;
  final String type;
  final double rotation;
  final double scale;

  ParkingSignageData({
    required this.x,
    required this.y,
    required this.type,
    required this.rotation,
    required this.scale,
  });

  factory ParkingSignageData.fromJson(Map<String, dynamic> json) {
    return ParkingSignageData(
      x: json['x'].toDouble(),
      y: json['y'].toDouble(),
      type: json['type'],
      rotation: json['rotation'].toDouble(),
      scale: json['scale'].toDouble(),
    );
  }

  ParkingSignage toElement() {
    final position = vector_math.Vector2(x, y);

    // Convertir string a enum
    final signageType = _parseSignageType(type);

    // Crear señalización con ElementFactory
    return ElementFactory.createSignage(
      position: position,
      type: signageType,
      rotation: rotation,
      scale: scale,
    );
  }

  // Convertir string a SignageType
  SignageType _parseSignageType(String typeStr) {
    switch (typeStr.toLowerCase()) {
      case 'entrance':
        return SignageType.entrance;
      case 'exit':
        return SignageType.exit;
      case 'path':
        return SignageType.path;
      case 'info':
        return SignageType.info;
      case 'oneway':
        return SignageType.oneWay;
      case 'noparking':
        return SignageType.noParking;
      default:
        return SignageType.info;
    }
  }
}

/// Clase para datos de instalaciones
class ParkingFacilityData {
  final double x;
  final double y;
  final String type;
  final String name;
  final double scale;

  ParkingFacilityData({
    required this.x,
    required this.y,
    required this.type,
    required this.name,
    required this.scale,
  });

  factory ParkingFacilityData.fromJson(Map<String, dynamic> json) {
    return ParkingFacilityData(
      x: json['x'].toDouble(),
      y: json['y'].toDouble(),
      type: json['type'],
      name: json['name'],
      scale: json['scale'].toDouble(),
    );
  }

  ParkingFacility toElement() {
    final position = vector_math.Vector2(x, y);

    // Convertir string a enum
    final facilityType = _parseFacilityType(type);

    // Crear instalación con ElementFactory
    return ElementFactory.createFacility(
      position: position,
      type: facilityType,
      name: name,
      scale: scale,
    );
  }

  // Convertir string a FacilityType
  FacilityType _parseFacilityType(String typeStr) {
    switch (typeStr.toLowerCase()) {
      case 'paymentstation':
        return FacilityType.paymentStation;
      case 'securitypost':
        return FacilityType.securityPost;
      case 'bathroom':
        return FacilityType.bathroom;
      case 'elevator':
        return FacilityType.elevator;
      default:
        return FacilityType.paymentStation;
    }
  }
}
