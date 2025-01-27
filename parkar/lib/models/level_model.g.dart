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
      signages: (json['signages'] as List<dynamic>)
          .map((e) => SignageModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      facilities: (json['facilities'] as List<dynamic>)
          .map((e) => FacilityModel.fromJson(e as Map<String, dynamic>))
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
      'signages': instance.signages,
      'facilities': instance.facilities,
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
      posZ: (json['posZ'] as num).toDouble(),
      rotation: (json['rotation'] as num).toDouble(),
      scale: (json['scale'] as num).toDouble(),
      vehicleId: json['vehicleId'] as String?,
      spotType: (json['spotType'] as num).toInt(),
      spotCategory: (json['spotCategory'] as num).toInt(),
    );

Map<String, dynamic> _$SpotModelToJson(SpotModel instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'posX': instance.posX,
      'posY': instance.posY,
      'posZ': instance.posZ,
      'rotation': instance.rotation,
      'scale': instance.scale,
      'vehicleId': instance.vehicleId,
      'spotType': instance.spotType,
      'spotCategory': instance.spotCategory,
    };

SignageModel _$SignageModelFromJson(Map<String, dynamic> json) => SignageModel(
      id: json['id'] as String,
      posX: (json['posX'] as num).toDouble(),
      posY: (json['posY'] as num).toDouble(),
      posZ: (json['posZ'] as num).toDouble(),
      scale: (json['scale'] as num).toDouble(),
      rotation: (json['rotation'] as num).toDouble(),
      signageType: (json['signageType'] as num).toInt(),
    );

Map<String, dynamic> _$SignageModelToJson(SignageModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'posX': instance.posX,
      'posY': instance.posY,
      'posZ': instance.posZ,
      'scale': instance.scale,
      'rotation': instance.rotation,
      'signageType': instance.signageType,
    };

FacilityModel _$FacilityModelFromJson(Map<String, dynamic> json) =>
    FacilityModel(
      id: json['id'] as String,
      name: json['name'] as String,
      posX: (json['posX'] as num).toDouble(),
      posY: (json['posY'] as num).toDouble(),
      posZ: (json['posZ'] as num).toDouble(),
      rotation: (json['rotation'] as num).toDouble(),
      scale: (json['scale'] as num).toDouble(),
      facilityType: (json['facilityType'] as num).toInt(),
    );

Map<String, dynamic> _$FacilityModelToJson(FacilityModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'posX': instance.posX,
      'posY': instance.posY,
      'posZ': instance.posZ,
      'rotation': instance.rotation,
      'scale': instance.scale,
      'facilityType': instance.facilityType,
    };
