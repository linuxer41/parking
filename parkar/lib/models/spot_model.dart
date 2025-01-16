
import 'package:json_annotation/json_annotation.dart';
import '_base_model.dart';
import 'parking_model.dart';
import 'level_model.dart';

part 'spot_model.g.dart';

@JsonSerializable()
class SpotModel extends JsonConvertible<SpotModel> {
  final String id;
  final String name;
  final CoordinatesModel coordinates;
  final String status;
  final String parkingId;
  final ParkingModel? parking;
  final String levelId;
  final LevelModel? level;
  final DateTime createdAt;
  final DateTime updatedAt;

  SpotModel({
    required this.id,
    required this.name,
    required this.coordinates,
    required this.status,
    required this.parkingId,
     this.parking,
    required this.levelId,
     this.level,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SpotModel.fromJson(Map<String, dynamic> json) =>
      _$SpotModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SpotModelToJson(this);
}

@JsonSerializable()
class SpotCreateModel extends JsonConvertible<SpotCreateModel> {
  final String name;
  final CoordinatesModel coordinates;
  final String status;
  final String parkingId;

  SpotCreateModel({
    required this.name,
    required this.coordinates,
    required this.status,
    required this.parkingId,
  });

  factory SpotCreateModel.fromJson(Map<String, dynamic> json) =>
      _$SpotCreateModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SpotCreateModelToJson(this);
}

@JsonSerializable()
class SpotUpdateModel extends JsonConvertible<SpotUpdateModel> {
  final String name;
  final CoordinatesModel coordinates;
  final String status;

  SpotUpdateModel({
    required this.name,
    required this.coordinates,
    required this.status,
  });

  factory SpotUpdateModel.fromJson(Map<String, dynamic> json) =>
      _$SpotUpdateModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SpotUpdateModelToJson(this);
}


@JsonSerializable()
class CoordinatesModel extends JsonConvertible<CoordinatesModel> {
  final int x0;
  final int y0;
  final int x1;
  final int y1;

  CoordinatesModel({
    required this.x0,
    required this.y0,
    required this.x1,
    required this.y1,
  });

  factory CoordinatesModel.fromJson(Map<String, dynamic> json) =>
      _$CoordinatesModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$CoordinatesModelToJson(this);
}

