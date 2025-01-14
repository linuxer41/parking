
import 'package:json_annotation/json_annotation.dart';
import '_base_model.dart';
import 'parking_model.dart';
import 'level_model.dart';

part 'area_model.g.dart';

@JsonSerializable()
class AreaModel extends JsonConvertible<AreaModel> {
  final String id;
  final String name;
  final String parkingId;
  final ParkingModel? parking;
  final String levelId;
  final LevelModel? level;
  final DateTime createdAt;
  final DateTime updatedAt;

  AreaModel({
    required this.id,
    required this.name,
    required this.parkingId,
     this.parking,
    required this.levelId,
     this.level,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AreaModel.fromJson(Map<String, dynamic> json) =>
      _$AreaModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$AreaModelToJson(this);
}

@JsonSerializable()
class AreaCreateModel extends JsonConvertible<AreaCreateModel> {
  final String name;
  final String parkingId;
  final String levelId;

  AreaCreateModel({
    required this.name,
    required this.parkingId,
    required this.levelId,
  });

  factory AreaCreateModel.fromJson(Map<String, dynamic> json) =>
      _$AreaCreateModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$AreaCreateModelToJson(this);
}

@JsonSerializable()
class AreaUpdateModel extends JsonConvertible<AreaUpdateModel> {
  final String name;

  AreaUpdateModel({
    required this.name,
  });

  factory AreaUpdateModel.fromJson(Map<String, dynamic> json) =>
      _$AreaUpdateModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$AreaUpdateModelToJson(this);
}


