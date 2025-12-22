import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart';
import '_base_model.dart';
import 'employee_model.dart';
import 'user_model.dart';
import 'vehicle_model.dart';

part 'parking_model.g.dart';

/// Enum para los modos de operación del parking
enum ParkingOperationMode {
  @JsonValue('map')
  map,
  @JsonValue('list')
  list,
}

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

extension ParkingOperationModeExtension on ParkingOperationMode {
  String get value {
    switch (this) {
      case ParkingOperationMode.map:
        return 'map';
      case ParkingOperationMode.list:
        return 'list';
    }
  }

  String get displayName {
    switch (this) {
      case ParkingOperationMode.map:
        return 'Mapa';
      case ParkingOperationMode.list:
        return 'Listas';
    }
  }

  String get description {
    switch (this) {
      case ParkingOperationMode.map:
        return 'Mapa interactivo con spots visuales';
      case ParkingOperationMode.list:
        return 'Gestión con tablas y listas';
    }
  }
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

/// Element Occupancy Info Model
@JsonSerializable()
class ElementOccupancyInfoModel
    extends JsonConvertible<ElementOccupancyInfoModel> {
  final String id;
  final String vehiclePlate;
  final String ownerName;
  final String ownerPhone;
  final String startDate;
  final String? endDate;
  final double? amount;

  ElementOccupancyInfoModel({
    required this.id,
    required this.vehiclePlate,
    required this.ownerName,
    required this.ownerPhone,
    required this.startDate,
    this.endDate,
    this.amount,
  });

  factory ElementOccupancyInfoModel.fromJson(Map<String, dynamic> json) =>
      _$ElementOccupancyInfoModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ElementOccupancyInfoModelToJson(this);
}

@JsonSerializable()
class ElementModel extends JsonConvertible<ElementModel> {
  final String id;
  final String name;
  final ElementType type;
  final int subType;
  final double posX;
  final double posY;
  final double posZ;
  final double rotation;
  final double scale;
  final bool isActive;
  final ElementOccupancyInfoModel? entry;
  final ElementOccupancyInfoModel? booking;
  final ElementOccupancyInfoModel? subscription;
  final String status;

  ElementModel({
    required this.id,
    required this.name,
    required this.type,
    required this.subType,
    required this.posX,
    required this.posY,
    required this.posZ,
    required this.rotation,
    required this.scale,
    required this.isActive,
    this.entry,
    this.booking,
    this.subscription,
    required this.status,
  });

  factory ElementModel.fromJson(Map<String, dynamic> json) =>
      _$ElementModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ElementModelToJson(this);

  /// Create a copy of this ElementModel but with the given fields replaced with the new values
  ElementModel copyWith({
    String? id,
    String? name,
    ElementType? type,
    int? subType,
    double? posX,
    double? posY,
    double? posZ,
    double? rotation,
    double? scale,
    bool? isActive,
    ElementOccupancyInfoModel? entry,
    ElementOccupancyInfoModel? booking,
    ElementOccupancyInfoModel? subscription,
    String? status,
  }) {
    return ElementModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      subType: subType ?? this.subType,
      posX: posX ?? this.posX,
      posY: posY ?? this.posY,
      posZ: posZ ?? this.posZ,
      rotation: rotation ?? this.rotation,
      scale: scale ?? this.scale,
      isActive: isActive ?? this.isActive,
      entry: entry ?? this.entry,
      booking: booking ?? this.booking,
      subscription: subscription ?? this.subscription,
      status: status ?? this.status,
    );
  }

  // Convenience getters for type checking
  bool get isSpot => type == ElementType.spot;
  bool get isSignage => type == ElementType.signage;
  bool get isFacility => type == ElementType.facility;

  // Convenience getters for status checking
  bool get isOccupied => status == ElementStatus.occupied.toString();
  bool get isAvailable => status == ElementStatus.available.toString();
  bool get isReserved => status == ElementStatus.reserved.toString();
  bool get isSubscribed => status == ElementStatus.subscribed.toString();
  bool get isMaintenance => status == ElementStatus.maintenance.toString();

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
class SpotPreviewModel extends JsonConvertible<SpotPreviewModel> {
  final String id;
  final String name;
  final ElementType type;
  final int subType;

  SpotPreviewModel({
    required this.id,
    required this.name,
    required this.type,
    required this.subType,
  });

  factory SpotPreviewModel.fromJson(Map<String, dynamic> json) =>
      _$SpotPreviewModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SpotPreviewModelToJson(this);
}

@JsonSerializable()
class AreaModel implements JsonConvertible<AreaModel> {
  final String id;
  final String name;
  final int totalSpots;
  final int availableSpots;
  final int occupiedSpots;
  final List<ElementModel> elements;

  AreaModel({
    required this.id,
    required this.name,
    required this.totalSpots,
    required this.availableSpots,
    required this.occupiedSpots,
    required this.elements,
  });

  factory AreaModel.fromJson(Map<String, dynamic> json) =>
      _$AreaModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$AreaModelToJson(this);

  // Convenience getters for filtered elements
  List<ElementModel> get spots => elements.where((e) => e.isSpot).toList();
  List<ElementModel> get signages =>
      elements.where((e) => e.isSignage).toList();
  List<ElementModel> get facilities =>
      elements.where((e) => e.isFacility).toList();

  // Convenience getters for available/occupied spots
  List<ElementModel> get availableSpotsList =>
      spots.where((s) => s.isAvailable).toList();
  List<ElementModel> get occupiedSpotsList =>
      spots.where((s) => s.isOccupied).toList();
}

@JsonSerializable()
class AreaCreateModel implements JsonConvertible<AreaCreateModel> {
  final String name;
  final String? description;
  final String parkingId;

  AreaCreateModel({
    required this.name,
    this.description,
    required this.parkingId,
  });

  factory AreaCreateModel.fromJson(Map<String, dynamic> json) =>
      _$AreaCreateModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$AreaCreateModelToJson(this);
}

@JsonSerializable()
class AreaUpdateModel implements JsonConvertible<AreaUpdateModel> {
  final String? name;
  final String? description;
  final List<ElementModel>? elements;

  AreaUpdateModel({this.name, this.description, this.elements});

  factory AreaUpdateModel.fromJson(Map<String, dynamic> json) =>
      _$AreaUpdateModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$AreaUpdateModelToJson(this);
}

@JsonSerializable()
class AreaDetailModel implements JsonConvertible<AreaDetailModel> {
  final String id;
  final String name;
  final String? description;
  final int capacity;
  final int occupiedSpots;
  final String parkingId;
  final List<ElementModel> elements;
  final DateTime createdAt;
  final DateTime updatedAt;

  AreaDetailModel({
    required this.id,
    required this.name,
    this.description,
    required this.capacity,
    required this.occupiedSpots,
    required this.parkingId,
    required this.elements,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AreaDetailModel.fromJson(Map<String, dynamic> json) =>
      _$AreaDetailModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$AreaDetailModelToJson(this);
}

@JsonSerializable()
class ParkingModel extends JsonConvertible<ParkingModel> {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final String? address;
  final ParkingLocationModel? location;
  final String? logoUrl;
  final String status;
  final ParkingParamsModel params;
  final List<RateModel> rates;
  final ParkingOperationMode operationMode;
  final bool isOwner;
  final int areaCount;

  ParkingModel({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.address,
    this.location,
    this.logoUrl,
    required this.status,
    required this.params,
    required this.rates,
    required this.operationMode,
    required this.isOwner,
    required this.areaCount,
  });

  factory ParkingModel.fromParkingModel(ParkingModelDetailed parking) =>
      ParkingModel(
        id: parking.id,
        name: parking.name,
        email: parking.email,
        phone: parking.phone,
        address: parking.address,
        location: parking.location,
        logoUrl: parking.logoUrl,
        status: parking.status ?? '',
        params: parking.params,
        rates: parking.rates,
        operationMode: parking.operationMode ?? ParkingOperationMode.map,
        isOwner: parking.isOwner ?? false,
        areaCount: parking.areaCount ?? 0,
      );

  factory ParkingModel.fromJson(Map<String, dynamic> json) =>
      _$ParkingSimpleModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ParkingSimpleModelToJson(this);
}

@JsonSerializable()
class ParkingModelDetailed extends JsonConvertible<ParkingModelDetailed> {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final String? address;
  final String? logoUrl;
  final String? status;
  final String? ownerId;
  final bool? isOwner;
  final bool? isActive;
  final String? companyId;
  final UserModel? owner;
  final List<RateModel> rates;
  final ParkingParamsModel params;
  final List<AreaModel> areas;
  final List<EmployeeModel>? employees;
  final ParkingLocationModel? location;
  final int? areaCount;
  final ParkingOperationMode? operationMode;

  ParkingModelDetailed({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.address,
    this.logoUrl,
    this.status,
    this.ownerId,
    this.isOwner,
    this.isActive,
    this.companyId,
    this.owner,
    required this.rates,
    required this.params,
    required this.areas,
    this.employees,
    this.location,
    this.areaCount,
    this.operationMode,
  });

  /// Create a copy of this ParkingModelDetailed but with the given fields replaced with the new values
  ParkingModelDetailed copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? logoUrl,
    String? status,
    String? ownerId,
    bool? isOwner,
    bool? isActive,
    String? companyId,
    UserModel? owner,
    required List<RateModel> rates,
    required ParkingParamsModel params,
    List<AreaModel>? areas,
    List<EmployeeModel>? employees,
    ParkingLocationModel? location,
    int? totalSpots,
    int? availableSpots,
    int? occupiedSpots,
    int? areaCount,
    String? operationMode,
    double? capacity,
  }) {
    return ParkingModelDetailed(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      logoUrl: logoUrl ?? this.logoUrl,
      status: status ?? this.status,
      ownerId: ownerId ?? this.ownerId,
      isOwner: isOwner ?? this.isOwner,
      isActive: isActive ?? this.isActive,
      companyId: companyId ?? this.companyId,
      owner: owner ?? this.owner,
      rates: rates,
      params: params,
      areas: areas ?? this.areas,
      employees: employees ?? this.employees,
      location: location ?? this.location,
      areaCount: areaCount ?? this.areaCount,
      operationMode:
          operationMode as ParkingOperationMode? ?? this.operationMode,
    );
  }

  factory ParkingModelDetailed.fromJson(Map<String, dynamic> json) =>
      _$ParkingModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ParkingModelToJson(this);
}

@JsonSerializable()
class ParkingLocationModel extends JsonConvertible<ParkingLocationModel> {
  final double? lat;
  final double? lng;

  ParkingLocationModel({this.lat, this.lng});

  factory ParkingLocationModel.fromJson(Map<String, dynamic> json) =>
      _$ParkingLocationModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ParkingLocationModelToJson(this);
}

@JsonSerializable()
class ParkingCreateModel extends JsonConvertible<ParkingCreateModel> {
  final String name;
  final String companyId;
  final ParkingLocationModel? location;
  final String? address;
  final int? totalSpots;

  ParkingCreateModel({
    required this.name,
    required this.companyId,
    this.location,
    this.address,
    this.totalSpots,
  });

  factory ParkingCreateModel.fromJson(Map<String, dynamic> json) =>
      _$ParkingCreateModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ParkingCreateModelToJson(this);
}

@JsonSerializable()
class ParkingUpdateModel extends JsonConvertible<ParkingUpdateModel> {
  final String? name;
  final ParkingParamsModel? params;
  final List<RateModel>? rates;
  final ParkingLocationModel? location;
  final String? address;
  final int? totalSpots;
  final int? availableSpots;
  final bool? isOpen;
  final String? openingHours;
  final ParkingOperationMode? operationMode;
  final double? capacity;

  ParkingUpdateModel({
    this.name,
    this.params,
    this.rates,
    this.location,
    this.address,
    this.totalSpots,
    this.availableSpots,
    this.isOpen,
    this.openingHours,
    this.operationMode,
    this.capacity,
  });

  factory ParkingUpdateModel.fromJson(Map<String, dynamic> json) =>
      _$ParkingUpdateModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ParkingUpdateModelToJson(this);
}

@JsonSerializable()
class ParkingPreviewModel extends JsonConvertible<ParkingPreviewModel> {
  final String id;
  final String name;
  final String? address;
  final String? logoUrl;
  final ParkingParamsModel? params;

  ParkingPreviewModel({
    required this.id,
    required this.name,
    this.address,
    this.logoUrl,
    this.params,
  });

  factory ParkingPreviewModel.fromJson(Map<String, dynamic> json) =>
      _$ParkingPreviewModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ParkingPreviewModelToJson(this);
}

@JsonSerializable()
class ParkingParamsModel extends JsonConvertible<ParkingParamsModel> {
  final String theme;
  final String? slogan;
  final String currency;
  final String timeZone;
  final String countryCode;
  final int decimalPlaces;

  ParkingParamsModel({
    required this.theme,
    this.slogan,
    required this.currency,
    required this.timeZone,
    required this.countryCode,
    required this.decimalPlaces,
  });

  factory ParkingParamsModel.fromJson(Map<String, dynamic> json) =>
      _$ParkingParamsModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ParkingParamsModelToJson(this);
}

@JsonSerializable()
class BusinessHourModel extends JsonConvertible<BusinessHourModel> {
  final String open;
  final String close;
  final bool is24h;

  BusinessHourModel({
    required this.open,
    required this.close,
    required this.is24h,
  });

  factory BusinessHourModel.fromJson(Map<String, dynamic> json) =>
      _$BusinessHourModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$BusinessHourModelToJson(this);
}

/// Rate model for parking prices
@JsonSerializable()
class RateModel extends JsonConvertible<RateModel> {
  final String id;
  final String name;
  final int vehicleCategory;
  final int tolerance;
  final double hourly;
  final double daily;
  final double weekly;
  final double monthly;
  final double yearly;
  final bool isActive;

  RateModel({
    required this.id,
    required this.name,
    required this.vehicleCategory,
    required this.tolerance,
    required this.hourly,
    required this.daily,
    required this.weekly,
    required this.monthly,
    required this.yearly,
    required this.isActive,
  });

  factory RateModel.fromJson(Map<String, dynamic> json) =>
      _$RateModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$RateModelToJson(this);
}
