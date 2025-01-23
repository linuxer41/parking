import 'package:json_annotation/json_annotation.dart';
import 'package:parkar/models/company_model.dart';
import 'package:parkar/models/level_model.dart';

import 'parking_model.dart';

part 'composite_models.g.dart';

@JsonSerializable()
class CompanyCompositeModel extends CompanyModel {
  final List<ParkingModel> parkings;

  CompanyCompositeModel(
      {required super.id,
      required super.name,
      required super.email,
      required super.phone,
      required super.logoUrl,
      required super.userId,
      required super.createdAt,
      required super.updatedAt,
      required super.params,
      required this.parkings});

  factory CompanyCompositeModel.fromJson(Map<String, dynamic> json) =>
      _$CompanyCompositeModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$CompanyCompositeModelToJson(this);
}


@JsonSerializable()
class ParkingCompositeModel extends ParkingModel {
  final List<LevelModel> levels;

  ParkingCompositeModel(
      {required this.levels,
      required super.id,
      required super.name,
      required super.companyId,
      required super.vehicleTypes,
      required super.params,
      required super.createdAt,
      required super.updatedAt, required super.prices, required super.subscriptionPlans});

  factory ParkingCompositeModel.fromJson(Map<String, dynamic> json) =>
      _$ParkingCompositeModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ParkingCompositeModelToJson(this);
}
