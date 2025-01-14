// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'area_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AreaModel _$AreaModelFromJson(Map<String, dynamic> json) => AreaModel(
      id: json['id'] as String,
      name: json['name'] as String,
      parkingId: json['parkingId'] as String,
      parking: json['parking'] == null
          ? null
          : ParkingModel.fromJson(json['parking'] as Map<String, dynamic>),
      levelId: json['levelId'] as String,
      level: json['level'] == null
          ? null
          : LevelModel.fromJson(json['level'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$AreaModelToJson(AreaModel instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'parkingId': instance.parkingId,
      'parking': instance.parking,
      'levelId': instance.levelId,
      'level': instance.level,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

AreaCreateModel _$AreaCreateModelFromJson(Map<String, dynamic> json) =>
    AreaCreateModel(
      name: json['name'] as String,
      parkingId: json['parkingId'] as String,
      levelId: json['levelId'] as String,
    );

Map<String, dynamic> _$AreaCreateModelToJson(AreaCreateModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'parkingId': instance.parkingId,
      'levelId': instance.levelId,
    };

AreaUpdateModel _$AreaUpdateModelFromJson(Map<String, dynamic> json) =>
    AreaUpdateModel(
      name: json['name'] as String,
    );

Map<String, dynamic> _$AreaUpdateModelToJson(AreaUpdateModel instance) =>
    <String, dynamic>{
      'name': instance.name,
    };
