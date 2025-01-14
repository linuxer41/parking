
import 'package:json_annotation/json_annotation.dart';
import '_base_model.dart';
import 'company_model.dart';

part 'parking_model.g.dart';

@JsonSerializable()
class ParkingModel extends JsonConvertible<ParkingModel> {
  final String id;
  final String name;
  final String companyId;
  final CompanyModel? company;
  final List<VehicleTypeModel> vehicleTypes;
  final ParkingParamsModel params;
  final DateTime createdAt;
  final DateTime updatedAt;

  ParkingModel({
    required this.id,
    required this.name,
    required this.companyId,
     this.company,
    required this.vehicleTypes,
    required this.params,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ParkingModel.fromJson(Map<String, dynamic> json) =>
      _$ParkingModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ParkingModelToJson(this);
}

@JsonSerializable()
class ParkingCreateModel extends JsonConvertible<ParkingCreateModel> {
  final String name;
  final String companyId;

  ParkingCreateModel({
    required this.name,
    required this.companyId,
  });

  factory ParkingCreateModel.fromJson(Map<String, dynamic> json) =>
      _$ParkingCreateModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ParkingCreateModelToJson(this);
}

@JsonSerializable()
class ParkingUpdateModel extends JsonConvertible<ParkingUpdateModel> {
  final String name;

  ParkingUpdateModel({
    required this.name,
  });

  factory ParkingUpdateModel.fromJson(Map<String, dynamic> json) =>
      _$ParkingUpdateModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ParkingUpdateModelToJson(this);
}


@JsonSerializable()
class VehicleTypeModel extends JsonConvertible<VehicleTypeModel> {
  final int id;
  final String name;
  final String? description;

  VehicleTypeModel({
    required this.id,
    required this.name,
     this.description,
  });

  factory VehicleTypeModel.fromJson(Map<String, dynamic> json) =>
      _$VehicleTypeModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$VehicleTypeModelToJson(this);
}


@JsonSerializable()
class ParkingParamsModel extends JsonConvertible<ParkingParamsModel> {
  final int baseTime;
  final double pasePrice;
  final String currency;
  final String timeZone;
  final int decimalPlaces;
  final String theme;

  ParkingParamsModel({
    required this.baseTime,
    required this.pasePrice,
    required this.currency,
    required this.timeZone,
    required this.decimalPlaces,
    required this.theme,
  });

  factory ParkingParamsModel.fromJson(Map<String, dynamic> json) =>
      _$ParkingParamsModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ParkingParamsModelToJson(this);
}

