// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'area_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AreaModel _$AreaModelFromJson(Map<String, dynamic> json) => AreaModel(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  totalSpots: (json['totalSpots'] as num).toInt(),
  availableSpots: (json['availableSpots'] as num).toInt(),
  occupiedSpots: (json['occupiedSpots'] as num).toInt(),
  parkingId: json['parkingId'] as String,
  elements:
      (json['elements'] as List<dynamic>?)
          ?.map((e) => ElementModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$AreaModelToJson(AreaModel instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'totalSpots': instance.totalSpots,
  'availableSpots': instance.availableSpots,
  'occupiedSpots': instance.occupiedSpots,
  'parkingId': instance.parkingId,
  'elements': instance.elements,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

AreaCreateModel _$AreaCreateModelFromJson(Map<String, dynamic> json) =>
    AreaCreateModel(
      name: json['name'] as String,
      description: json['description'] as String?,
      parkingId: json['parkingId'] as String,
    );

Map<String, dynamic> _$AreaCreateModelToJson(AreaCreateModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'parkingId': instance.parkingId,
    };

AreaUpdateModel _$AreaUpdateModelFromJson(Map<String, dynamic> json) =>
    AreaUpdateModel(
      name: json['name'] as String?,
      description: json['description'] as String?,
      elements: (json['elements'] as List<dynamic>?)
          ?.map((e) => ElementModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AreaUpdateModelToJson(AreaUpdateModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'elements': instance.elements,
    };

AreaDetailModel _$AreaDetailModelFromJson(Map<String, dynamic> json) =>
    AreaDetailModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      capacity: (json['capacity'] as num).toInt(),
      occupiedSpots: (json['occupiedSpots'] as num).toInt(),
      parkingId: json['parkingId'] as String,
      elements: (json['elements'] as List<dynamic>)
          .map((e) => ElementModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$AreaDetailModelToJson(AreaDetailModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'capacity': instance.capacity,
      'occupiedSpots': instance.occupiedSpots,
      'parkingId': instance.parkingId,
      'elements': instance.elements,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
