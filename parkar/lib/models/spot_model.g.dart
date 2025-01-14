// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spot_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SpotModel _$SpotModelFromJson(Map<String, dynamic> json) => SpotModel(
      id: json['id'] as String,
      name: json['name'] as String,
      coordinates: CoordinatesModel.fromJson(
          json['coordinates'] as Map<String, dynamic>),
      status: json['status'] as String,
      parkingId: json['parkingId'] as String,
      parking: json['parking'] == null
          ? null
          : ParkingModel.fromJson(json['parking'] as Map<String, dynamic>),
      areaId: json['areaId'] as String,
      area: json['area'] == null
          ? null
          : AreaModel.fromJson(json['area'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$SpotModelToJson(SpotModel instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'coordinates': instance.coordinates,
      'status': instance.status,
      'parkingId': instance.parkingId,
      'parking': instance.parking,
      'areaId': instance.areaId,
      'area': instance.area,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

SpotCreateModel _$SpotCreateModelFromJson(Map<String, dynamic> json) =>
    SpotCreateModel(
      name: json['name'] as String,
      coordinates: CoordinatesModel.fromJson(
          json['coordinates'] as Map<String, dynamic>),
      status: json['status'] as String,
      parkingId: json['parkingId'] as String,
      areaId: json['areaId'] as String,
    );

Map<String, dynamic> _$SpotCreateModelToJson(SpotCreateModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'coordinates': instance.coordinates,
      'status': instance.status,
      'parkingId': instance.parkingId,
      'areaId': instance.areaId,
    };

SpotUpdateModel _$SpotUpdateModelFromJson(Map<String, dynamic> json) =>
    SpotUpdateModel(
      name: json['name'] as String,
      coordinates: CoordinatesModel.fromJson(
          json['coordinates'] as Map<String, dynamic>),
      status: json['status'] as String,
    );

Map<String, dynamic> _$SpotUpdateModelToJson(SpotUpdateModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'coordinates': instance.coordinates,
      'status': instance.status,
    };

CoordinatesModel _$CoordinatesModelFromJson(Map<String, dynamic> json) =>
    CoordinatesModel(
      x0: (json['x0'] as num).toInt(),
      y0: (json['y0'] as num).toInt(),
      x1: (json['x1'] as num).toInt(),
      y1: (json['y1'] as num).toInt(),
    );

Map<String, dynamic> _$CoordinatesModelToJson(CoordinatesModel instance) =>
    <String, dynamic>{
      'x0': instance.x0,
      'y0': instance.y0,
      'x1': instance.x1,
      'y1': instance.y1,
    };
