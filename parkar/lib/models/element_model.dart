import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart';
import '_base_model.dart';
import 'vehicle_model.dart';
import 'employee_model.dart';

part 'element_model.g.dart';

/// Enum for element types
enum ElementType {
  @JsonValue('spot')
  spot,
  @JsonValue('signage')
  signage,
  @JsonValue('facility')
  facility,
}

/// Enum for element status
enum ElementStatus {
  @JsonValue('available')
  available,
  @JsonValue('occupied')
  occupied,
  @JsonValue('maintenance')
  maintenance,
  @JsonValue('reserved')
  reserved,
  @JsonValue('subscribed')
  subscribed,
}

/// Element Activity Model
@JsonSerializable()
class ElementActivityModel extends JsonConvertible<ElementActivityModel> {
  final String id;
  final String startDate;
  final String? endDate;
  final VehiclePreviewModel vehicle;
  final EmployeePreviewModel employee;
  final double amount;

  ElementActivityModel({
    required this.id,
    required this.startDate,
    this.endDate,
    required this.vehicle,
    required this.employee,
    required this.amount,
  });

  factory ElementActivityModel.fromJson(Map<String, dynamic> json) =>
      _$ElementActivityModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ElementActivityModelToJson(this);
}

/// Element Status Model
@JsonSerializable()
class ElementOccupancyModel extends JsonConvertible<ElementOccupancyModel> {
  final ElementActivityModel? access;
  final ElementActivityModel? reservation;
  final ElementActivityModel? subscription;
  final String status;

  ElementOccupancyModel({
    this.access,
    this.reservation,
    this.subscription,
    required this.status,
  });

  factory ElementOccupancyModel.fromJson(Map<String, dynamic> json) =>
      _$ElementOccupancyModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ElementOccupancyModelToJson(this);
}

@JsonSerializable()
class ElementModel extends JsonConvertible<ElementModel> {
  final String id;
  final String areaId;
  final String parkingId;
  final String name;
  final ElementType type;
  final int subType;
  final double posX;
  final double posY;
  final double posZ;
  final double rotation;
  final double scale;
  final String? accessId;
  final ElementOccupancyModel occupancy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  ElementModel({
    required this.id,
    required this.areaId,
    required this.parkingId,
    required this.name,
    required this.type,
    required this.subType,
    required this.posX,
    required this.posY,
    required this.posZ,
    required this.rotation,
    required this.scale,
    this.accessId,
    required this.occupancy,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory ElementModel.fromJson(Map<String, dynamic> json) =>
      _$ElementModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ElementModelToJson(this);

  /// Create a copy of this ElementModel but with the given fields replaced with the new values
  ElementModel copyWith({
    String? id,
    String? areaId,
    String? parkingId,
    String? name,
    ElementType? type,
    int? subType,
    double? posX,
    double? posY,
    double? posZ,
    double? rotation,
    double? scale,
    String? accessId,
    ElementOccupancyModel? occupancy,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return ElementModel(
      id: id ?? this.id,
      areaId: areaId ?? this.areaId,
      parkingId: parkingId ?? this.parkingId,
      name: name ?? this.name,
      type: type ?? this.type,
      subType: subType ?? this.subType,
      posX: posX ?? this.posX,
      posY: posY ?? this.posY,
      posZ: posZ ?? this.posZ,
      rotation: rotation ?? this.rotation,
      scale: scale ?? this.scale,
      accessId: accessId ?? this.accessId,
      occupancy: occupancy ?? this.occupancy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  // Convenience getters for type checking
  bool get isSpot => type == ElementType.spot;
  bool get isSignage => type == ElementType.signage;
  bool get isFacility => type == ElementType.facility;
  
  // Convenience getters for status checking
  bool get isOccupied => occupancy.status == 'occupied';
  bool get isAvailable => occupancy.status == 'available';
  bool get isReserved => occupancy.status == 'reserved';
  bool get isSubscribed => occupancy.status == 'subscribed';
  bool get isMaintenance => occupancy.status == 'maintenance';
  
  // Helper methods for UI display
  String getDisplayTypeName() {
    if (isSpot) {
      return _getSpotTypeName(subType);
    } else if (isSignage) {
      return _getSignageTypeName(subType);
    } else if (isFacility) {
      return _getFacilityTypeName(subType);
    }
    return 'Elemento';
  }
  
  // Get appropriate icon for this element
  IconData getIcon() {
    if (isSpot) {
      return _getSpotTypeIcon(subType);
    } else if (isSignage) {
      return _getSignageTypeIcon(subType);
    } else if (isFacility) {
      return _getFacilityTypeIcon(subType);
    }
    return Icons.category;
  }
  
  // Private helper methods for type names
  String _getSpotTypeName(int type) {
    switch (type) {
      case 1:
        return 'Bicicleta';
      case 2:
        return 'Moto';
      case 3:
        return 'Vehículo';
      case 4:
        return 'Camión';
      default:
        return 'Espacio';
    }
  }
  
  String _getSignageTypeName(int type) {
    switch (type) {
      case 1:
        return 'Entrada';
      case 2:
        return 'Salida';
      case 3:
        return 'Dirección';
      case 4:
        return 'Bidireccional';
      case 5:
        return 'Pare';
      default:
        return 'Señal';
    }
  }
  
  String _getFacilityTypeName(int type) {
    switch (type) {
      case 1:
        return 'Oficina';
      case 2:
        return 'Baño';
      case 3:
        return 'Cafetería';
      case 4:
        return 'Ascensor';
      case 5:
        return 'Escaleras';
      case 6:
        return 'Información';
      default:
        return 'Instalación';
    }
  }
  
  // Private helper methods for icons
  IconData _getSpotTypeIcon(int type) {
    switch (type) {
      case 1:
        return Icons.pedal_bike;
      case 2:
        return Icons.motorcycle;
      case 3:
        return Icons.directions_car;
      case 4:
        return Icons.local_shipping;
      default:
        return Icons.directions_car;
    }
  }
  
  IconData _getSignageTypeIcon(int type) {
    switch (type) {
      case 1:
        return Icons.login;
      case 2:
        return Icons.logout;
      case 3:
        return Icons.trending_flat;
      case 4:
        return Icons.sync_alt;
      case 5:
        return Icons.do_not_disturb;
      default:
        return Icons.sign_language;
    }
  }
  
  IconData _getFacilityTypeIcon(int type) {
    switch (type) {
      case 1:
        return Icons.business;
      case 2:
        return Icons.wc;
      case 3:
        return Icons.local_cafe;
      case 4:
        return Icons.elevator;
      case 5:
        return Icons.stairs;
      case 6:
        return Icons.info_outline;
      default:
        return Icons.business;
    }
  }
}

@JsonSerializable()
class ElementCreateModel extends JsonConvertible<ElementCreateModel> {
  final String areaId;
  final String parkingId;
  final String name;
  final ElementType type;
  final int subType;
  final double posX;
  final double posY;
  final double posZ;
  final double rotation;
  final double scale;
  final String status;
  final Map<String, dynamic>? metadata;

  ElementCreateModel({
    required this.areaId,
    required this.parkingId,
    required this.name,
    required this.type,
    required this.subType,
    required this.posX,
    required this.posY,
    required this.posZ,
    required this.rotation,
    required this.scale,
    required this.status,
    this.metadata,
  });

  factory ElementCreateModel.fromJson(Map<String, dynamic> json) =>
      _$ElementCreateModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ElementCreateModelToJson(this);
}

@JsonSerializable()
class ElementUpdateModel extends JsonConvertible<ElementUpdateModel> {
  final String? name;
  final ElementType? type;
  final int? subType;
  final double? posX;
  final double? posY;
  final double? posZ;
  final double? rotation;
  final double? scale;
  final String? status;
  final Map<String, dynamic>? metadata;

  ElementUpdateModel({
    this.name,
    this.type,
    this.subType,
    this.posX,
    this.posY,
    this.posZ,
    this.rotation,
    this.scale,
    this.status,
    this.metadata,
  });

  factory ElementUpdateModel.fromJson(Map<String, dynamic> json) =>
      _$ElementUpdateModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ElementUpdateModelToJson(this);
} 

@JsonSerializable()
class ElementPreviewModel extends JsonConvertible<ElementPreviewModel> {
  final String id;
  final String name;
  final ElementType type;
  final int subType;

  ElementPreviewModel({
    required this.id,
    required this.name,
    required this.type,
    required this.subType,
  });

  factory ElementPreviewModel.fromJson(Map<String, dynamic> json) =>
      _$ElementPreviewModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ElementPreviewModelToJson(this);
}