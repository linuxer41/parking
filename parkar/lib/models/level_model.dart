
import 'package:json_annotation/json_annotation.dart';
import '_base_model.dart';
import 'parking_model.dart';

part 'level_model.g.dart';

@JsonSerializable()
class LevelModel extends JsonConvertible<LevelModel> {
  final String id;
  final String name;
  final String parkingId;
  final ParkingModel? parking;
  final List<SpotModel> spots;
  final List<SignageModel> signages;
  final List<FacilityModel> facilities;
  final DateTime createdAt;
  final DateTime updatedAt;

  LevelModel({
    required this.id,
    required this.name,
    required this.parkingId,
    this.parking,
    required this.spots,
    required this.signages,
    required this.facilities,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LevelModel.fromJson(Map<String, dynamic> json) =>
      _$LevelModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$LevelModelToJson(this);
}

@JsonSerializable()
class LevelCreateModel extends JsonConvertible<LevelCreateModel> {
  final String name;
  final String parkingId;

  LevelCreateModel({
    required this.name,
    required this.parkingId,
  });

  factory LevelCreateModel.fromJson(Map<String, dynamic> json) =>
      _$LevelCreateModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$LevelCreateModelToJson(this);
}

@JsonSerializable()
class LevelUpdateModel extends JsonConvertible<LevelUpdateModel> {
  final String? name;
  final List<SpotModel>? spots;
  final List<SignageModel>? signages;
  final List<FacilityModel>? facilities;

  LevelUpdateModel({
    this.name,
    this.spots,
    this.signages,
    this.facilities,
  });

  factory LevelUpdateModel.fromJson(Map<String, dynamic> json) =>
      _$LevelUpdateModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$LevelUpdateModelToJson(this);
}


@JsonSerializable()
class SpotModel extends JsonConvertible<SpotModel> {
  final String id;
  final String name;
  final double posX;
  final double posY;
  final double posZ;
  final double rotation;
  final double scale;
  final String? vehicleId;
  final int spotType;
  final int spotCategory;

  SpotModel({
    required this.id,
    required this.name,
    required this.posX,
    required this.posY,
    required this.posZ,
    required this.rotation,
    required this.scale,
     this.vehicleId,
    required this.spotType,
    required this.spotCategory,
  });

  factory SpotModel.fromJson(Map<String, dynamic> json) =>
      _$SpotModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SpotModelToJson(this);
}


@JsonSerializable()
class SignageModel extends JsonConvertible<SignageModel> {
  final String id;
  final double posX;
  final double posY;
  final double posZ;
  final double scale;
  final double rotation;
  final double direction;
  final int signageType;

  SignageModel({
    required this.id,
    required this.posX,
    required this.posY,
    required this.posZ,
    required this.scale,
    required this.rotation,
    required this.direction,
    required this.signageType,
  });

  factory SignageModel.fromJson(Map<String, dynamic> json) =>
      _$SignageModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SignageModelToJson(this);
}


@JsonSerializable()
class FacilityModel extends JsonConvertible<FacilityModel> {
  final String id;
  final String name;
  final double posX;
  final double posY;
  final double posZ;
  final double rotation;
  final double scale;
  final int facilityType;

  FacilityModel({
    required this.id,
    required this.name,
    required this.posX,
    required this.posY,
    required this.posZ,
    required this.rotation,
    required this.scale,
    required this.facilityType,
  });

  factory FacilityModel.fromJson(Map<String, dynamic> json) =>
      _$FacilityModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$FacilityModelToJson(this);
}

