// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'element_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ElementActivityModel _$ElementActivityModelFromJson(
  Map<String, dynamic> json,
) => ElementActivityModel(
  id: json['id'] as String,
  startDate: json['startDate'] as String,
  endDate: json['endDate'] as String?,
  vehicle: VehiclePreviewModel.fromJson(
    json['vehicle'] as Map<String, dynamic>,
  ),
  employee: EmployeePreviewModel.fromJson(
    json['employee'] as Map<String, dynamic>,
  ),
  amount: (json['amount'] as num).toDouble(),
);

Map<String, dynamic> _$ElementActivityModelToJson(
  ElementActivityModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'startDate': instance.startDate,
  'endDate': instance.endDate,
  'vehicle': instance.vehicle,
  'employee': instance.employee,
  'amount': instance.amount,
};

ElementOccupancyModel _$ElementOccupancyModelFromJson(
  Map<String, dynamic> json,
) => ElementOccupancyModel(
  access: json['access'] == null
      ? null
      : ElementActivityModel.fromJson(json['access'] as Map<String, dynamic>),
  reservation: json['reservation'] == null
      ? null
      : ElementActivityModel.fromJson(
          json['reservation'] as Map<String, dynamic>,
        ),
  subscription: json['subscription'] == null
      ? null
      : ElementActivityModel.fromJson(
          json['subscription'] as Map<String, dynamic>,
        ),
  status: json['status'] as String,
);

Map<String, dynamic> _$ElementOccupancyModelToJson(
  ElementOccupancyModel instance,
) => <String, dynamic>{
  'access': instance.access,
  'reservation': instance.reservation,
  'subscription': instance.subscription,
  'status': instance.status,
};

ElementModel _$ElementModelFromJson(Map<String, dynamic> json) => ElementModel(
  id: json['id'] as String,
  areaId: json['areaId'] as String,
  parkingId: json['parkingId'] as String,
  name: json['name'] as String,
  type: $enumDecode(_$ElementTypeEnumMap, json['type']),
  subType: (json['subType'] as num).toInt(),
  posX: (json['posX'] as num).toDouble(),
  posY: (json['posY'] as num).toDouble(),
  posZ: (json['posZ'] as num).toDouble(),
  rotation: (json['rotation'] as num).toDouble(),
  scale: (json['scale'] as num).toDouble(),
  accessId: json['accessId'] as String?,
  occupancy: ElementOccupancyModel.fromJson(
    json['occupancy'] as Map<String, dynamic>,
  ),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  deletedAt: json['deletedAt'] == null
      ? null
      : DateTime.parse(json['deletedAt'] as String),
);

Map<String, dynamic> _$ElementModelToJson(ElementModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'areaId': instance.areaId,
      'parkingId': instance.parkingId,
      'name': instance.name,
      'type': _$ElementTypeEnumMap[instance.type]!,
      'subType': instance.subType,
      'posX': instance.posX,
      'posY': instance.posY,
      'posZ': instance.posZ,
      'rotation': instance.rotation,
      'scale': instance.scale,
      'accessId': instance.accessId,
      'occupancy': instance.occupancy,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'deletedAt': instance.deletedAt?.toIso8601String(),
    };

const _$ElementTypeEnumMap = {
  ElementType.spot: 'spot',
  ElementType.signage: 'signage',
  ElementType.facility: 'facility',
};

ElementCreateModel _$ElementCreateModelFromJson(Map<String, dynamic> json) =>
    ElementCreateModel(
      areaId: json['areaId'] as String,
      parkingId: json['parkingId'] as String,
      name: json['name'] as String,
      type: $enumDecode(_$ElementTypeEnumMap, json['type']),
      subType: (json['subType'] as num).toInt(),
      posX: (json['posX'] as num).toDouble(),
      posY: (json['posY'] as num).toDouble(),
      posZ: (json['posZ'] as num).toDouble(),
      rotation: (json['rotation'] as num).toDouble(),
      scale: (json['scale'] as num).toDouble(),
      status: json['status'] as String,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ElementCreateModelToJson(ElementCreateModel instance) =>
    <String, dynamic>{
      'areaId': instance.areaId,
      'parkingId': instance.parkingId,
      'name': instance.name,
      'type': _$ElementTypeEnumMap[instance.type]!,
      'subType': instance.subType,
      'posX': instance.posX,
      'posY': instance.posY,
      'posZ': instance.posZ,
      'rotation': instance.rotation,
      'scale': instance.scale,
      'status': instance.status,
      'metadata': instance.metadata,
    };

ElementUpdateModel _$ElementUpdateModelFromJson(Map<String, dynamic> json) =>
    ElementUpdateModel(
      name: json['name'] as String?,
      type: $enumDecodeNullable(_$ElementTypeEnumMap, json['type']),
      subType: (json['subType'] as num?)?.toInt(),
      posX: (json['posX'] as num?)?.toDouble(),
      posY: (json['posY'] as num?)?.toDouble(),
      posZ: (json['posZ'] as num?)?.toDouble(),
      rotation: (json['rotation'] as num?)?.toDouble(),
      scale: (json['scale'] as num?)?.toDouble(),
      status: json['status'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ElementUpdateModelToJson(ElementUpdateModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'type': _$ElementTypeEnumMap[instance.type],
      'subType': instance.subType,
      'posX': instance.posX,
      'posY': instance.posY,
      'posZ': instance.posZ,
      'rotation': instance.rotation,
      'scale': instance.scale,
      'status': instance.status,
      'metadata': instance.metadata,
    };

ElementPreviewModel _$ElementPreviewModelFromJson(Map<String, dynamic> json) =>
    ElementPreviewModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: $enumDecode(_$ElementTypeEnumMap, json['type']),
      subType: (json['subType'] as num).toInt(),
    );

Map<String, dynamic> _$ElementPreviewModelToJson(
  ElementPreviewModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'type': _$ElementTypeEnumMap[instance.type]!,
  'subType': instance.subType,
};
