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
      spots: (json['spots'] as List<dynamic>)
          .map((e) => SpotModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      indicators: (json['indicators'] as List<dynamic>)
          .map((e) => IndicatorModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      offices: (json['offices'] as List<dynamic>)
          .map((e) => OfficeModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$LevelModelToJson(LevelModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'parkingId': instance.parkingId,
      'parking': instance.parking,
      'spots': instance.spots,
      'indicators': instance.indicators,
      'offices': instance.offices,
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

SpotModel _$SpotModelFromJson(Map<String, dynamic> json) => SpotModel(
      id: json['id'] as String,
      name: json['name'] as String,
      posX: (json['posX'] as num).toDouble(),
      posY: (json['posY'] as num).toDouble(),
      vehicleId: json['vehicleId'] as String?,
      spotType: (json['spotType'] as num).toInt(),
      spotLevel: (json['spotLevel'] as num).toInt(),
    );

Map<String, dynamic> _$SpotModelToJson(SpotModel instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'posX': instance.posX,
      'posY': instance.posY,
      'vehicleId': instance.vehicleId,
      'spotType': instance.spotType,
      'spotLevel': instance.spotLevel,
    };

IndicatorModel _$IndicatorModelFromJson(Map<String, dynamic> json) =>
    IndicatorModel(
      id: json['id'] as String,
      posX: (json['posX'] as num).toDouble(),
      posY: (json['posY'] as num).toDouble(),
      indicatorType: (json['indicatorType'] as num).toInt(),
    );

Map<String, dynamic> _$IndicatorModelToJson(IndicatorModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'posX': instance.posX,
      'posY': instance.posY,
      'indicatorType': instance.indicatorType,
    };

OfficeModel _$OfficeModelFromJson(Map<String, dynamic> json) => OfficeModel(
      id: json['id'] as String,
      name: json['name'] as String,
      posX: (json['posX'] as num).toDouble(),
      posY: (json['posY'] as num).toDouble(),
    );

Map<String, dynamic> _$OfficeModelToJson(OfficeModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'posX': instance.posX,
      'posY': instance.posY,
    };
