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


// enum LevelDataActionType { add, update, delete }

// @JsonSerializable()
// class LevelDataGroupModel {
//   final List<SpotModel> spots;
//   final List<FacilityModel> facilities;
//   final List<SignageModel> signages;

//   LevelDataGroupModel(
//       {
//         required this.spots,
//       required this.facilities,
//       required this.signages});

//   factory LevelDataGroupModel.fromJson(Map<String, dynamic> json) =>
//       _$LevelDataGroupModelFromJson(json);

//   @override
//   Map<String, dynamic> toJson() => _$LevelDataGroupModelToJson(this);
// }

// @JsonSerializable()
// class LevelDataHandleModel {
//   final LevelDataGroupModel toAdd;
//   final List<LevelDataGroupModel> toUpdate;
//   final List<LevelDataGroupModel> toDelete;

//   LevelDataHandleModel(
//       {required this.toAdd,
//       required this.toUpdate,
//       required this.toDelete});

//   factory LevelDataHandleModel.fromJson(Map<String, dynamic> json) =>
//       _$LevelDataHandleModelFromJson(json);

//   @override
//   Map<String, dynamic> toJson() => _$LevelDataHandleModelToJson(this);
// }