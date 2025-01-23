
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
  final List<IndicatorModel> indicators;
  final List<OfficeModel> offices;
  final DateTime createdAt;
  final DateTime updatedAt;

  LevelModel({
    required this.id,
    required this.name,
    required this.parkingId,
     this.parking,
    required this.spots,
    required this.indicators,
    required this.offices,
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
  final String name;

  LevelUpdateModel({
    required this.name,
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
  final String? vehicleId;
  final int spotType;
  final int spotLevel;

  SpotModel({
    required this.id,
    required this.name,
    required this.posX,
    required this.posY,
     this.vehicleId,
    required this.spotType,
    required this.spotLevel,
  });

  factory SpotModel.fromJson(Map<String, dynamic> json) =>
      _$SpotModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SpotModelToJson(this);
}


@JsonSerializable()
class IndicatorModel extends JsonConvertible<IndicatorModel> {
  final String id;
  final double posX;
  final double posY;
  final int indicatorType;

  IndicatorModel({
    required this.id,
    required this.posX,
    required this.posY,
    required this.indicatorType,
  });

  factory IndicatorModel.fromJson(Map<String, dynamic> json) =>
      _$IndicatorModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$IndicatorModelToJson(this);
}


@JsonSerializable()
class OfficeModel extends JsonConvertible<OfficeModel> {
  final String id;
  final String name;
  final double posX;
  final double posY;

  OfficeModel({
    required this.id,
    required this.name,
    required this.posX,
    required this.posY,
  });

  factory OfficeModel.fromJson(Map<String, dynamic> json) =>
      _$OfficeModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$OfficeModelToJson(this);
}

