import 'package:json_annotation/json_annotation.dart';
import '_base_model.dart';
import 'area_model.dart';
import 'employee_model.dart';
import 'user_model.dart';

part 'parking_model.g.dart';

/// Enum para los modos de operación del parking
enum ParkingOperationMode {
  @JsonValue('visual')
  visual,
  @JsonValue('simple')
  simple,
}

extension ParkingOperationModeExtension on ParkingOperationMode {
  String get value {
    switch (this) {
      case ParkingOperationMode.visual:
        return 'visual';
      case ParkingOperationMode.simple:
        return 'simple';
    }
  }

  String get displayName {
    switch (this) {
      case ParkingOperationMode.visual:
        return 'Visual';
      case ParkingOperationMode.simple:
        return 'Simple';
    }
  }

  String get description {
    switch (this) {
      case ParkingOperationMode.visual:
        return 'Canvas interactivo con herramientas completas';
      case ParkingOperationMode.simple:
        return 'Indicadores básicos y controles esenciales';
    }
  }
}

@JsonSerializable()
class ParkingSimpleModel extends JsonConvertible<ParkingSimpleModel> {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? address;
  final String status;
  final bool isOwner;
  final bool isActive;
  final List<RateModel> rates;
  final ParkingParamsModel params;
  final String? logoUrl;
  final int? areaCount;
  final int? totalSpots;
  final int? occupiedSpots;
  final int? availableSpots;
  final ParkingOperationMode? operationMode;
  final double? capacity;

  ParkingSimpleModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.status,
    required this.isOwner,
    required this.isActive,
    this.logoUrl,
    this.areaCount,
    this.totalSpots,
    this.occupiedSpots,
    this.availableSpots,
    this.operationMode,
    this.capacity,
    required this.rates,
    required this.params,
  });

  factory ParkingSimpleModel.fromParkingModel(ParkingModel parking) =>
      ParkingSimpleModel(
        id: parking.id,
        name: parking.name,
        email: parking.email ?? '',
        phone: parking.phone ?? '',
        address: parking.address ?? '',
        status: parking.status ?? '',
        isOwner: parking.isOwner ?? false,
        isActive: parking.isActive ?? false,
        logoUrl: parking.logoUrl,
        rates: parking.rates ?? [],
        params: parking.params,
        operationMode: parking.operationMode,
        capacity: parking.capacity,
      );

  factory ParkingSimpleModel.fromJson(Map<String, dynamic> json) =>
      _$ParkingSimpleModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ParkingSimpleModelToJson(this);
}

@JsonSerializable()
class ParkingModel extends JsonConvertible<ParkingModel> {
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
  final List<AreaModel>? areas;
  final List<EmployeeModel>? employees;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  // Additional fields for maps and availability
  final double? latitude;
  final double? longitude;
  final int? totalSpots;
  final int? availableSpots;
  final int? occupiedSpots;
  final int? areaCount;
  final ParkingOperationMode? operationMode;
  final double? capacity;

  ParkingModel({
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
    this.areas,
    this.employees,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.latitude,
    this.longitude,
    this.totalSpots,
    this.availableSpots,
    this.occupiedSpots,
    this.areaCount,
    this.operationMode,
    this.capacity,
  });

  /// Create a copy of this ParkingModel but with the given fields replaced with the new values
  ParkingModel copyWith({
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
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    double? latitude,
    double? longitude,
    int? totalSpots,
    int? availableSpots,
    int? occupiedSpots,
    int? areaCount,
    String? operationMode,
    double? capacity,
  }) {
    return ParkingModel(
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
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      totalSpots: totalSpots ?? this.totalSpots,
      availableSpots: availableSpots ?? this.availableSpots,
      occupiedSpots: occupiedSpots ?? this.occupiedSpots,
      areaCount: areaCount ?? this.areaCount,
      operationMode:
          operationMode as ParkingOperationMode? ?? this.operationMode,
      capacity: capacity ?? this.capacity,
    );
  }

  factory ParkingModel.fromJson(Map<String, dynamic> json) =>
      _$ParkingModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ParkingModelToJson(this);
}

@JsonSerializable()
class ParkingCreateModel extends JsonConvertible<ParkingCreateModel> {
  final String name;
  final String companyId;
  final double? latitude;
  final double? longitude;
  final String? address;
  final int? totalSpots;

  ParkingCreateModel({
    required this.name,
    required this.companyId,
    this.latitude,
    this.longitude,
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
  final double? latitude;
  final double? longitude;
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
    this.latitude,
    this.longitude,
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
  final String address;
  final String logoUrl;
  final ParkingParamsModel params;

  ParkingPreviewModel({
    required this.id,
    required this.name,
    required this.address,
    required this.logoUrl,
    required this.params,
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
