// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'level_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LevelModel _$LevelModelFromJson(Map<String, dynamic> json) => LevelModel(
      id: json['id'] as String,
      name: json['name'] as String,
      parkingId: json['parkingId'] as String,
      parking: json['parking'] == null
          ? null
          : ParkingModel.fromJson(json['parking'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$LevelModelToJson(LevelModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'parkingId': instance.parkingId,
      'parking': instance.parking,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

LevelCreateModel _$LevelCreateModelFromJson(Map<String, dynamic> json) =>
    LevelCreateModel(
      name: json['name'] as String,
      parkingId: json['parkingId'] as String,
    );

Map<String, dynamic> _$LevelCreateModelToJson(LevelCreateModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'parkingId': instance.parkingId,
    };

LevelUpdateModel _$LevelUpdateModelFromJson(Map<String, dynamic> json) =>
    LevelUpdateModel(
      name: json['name'] as String,
    );

Map<String, dynamic> _$LevelUpdateModelToJson(LevelUpdateModel instance) =>
    <String, dynamic>{
      'name': instance.name,
    };
