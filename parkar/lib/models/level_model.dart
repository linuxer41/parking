
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
  final DateTime createdAt;
  final DateTime updatedAt;

  LevelModel({
    required this.id,
    required this.name,
    required this.parkingId,
     this.parking,
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


