// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parking_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ParkingSimpleModel _$ParkingSimpleModelFromJson(Map<String, dynamic> json) =>
    ParkingSimpleModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      address: json['address'] as String?,
      status: json['status'] as String,
      isOwner: json['isOwner'] as bool,
      isActive: json['isActive'] as bool,
      logoUrl: json['logoUrl'] as String?,
      areaCount: (json['areaCount'] as num?)?.toInt(),
      totalSpots: (json['totalSpots'] as num?)?.toInt(),
      occupiedSpots: (json['occupiedSpots'] as num?)?.toInt(),
      availableSpots: (json['availableSpots'] as num?)?.toInt(),
      operationMode: $enumDecodeNullable(
        _$ParkingOperationModeEnumMap,
        json['operationMode'],
      ),
      capacity: (json['capacity'] as num?)?.toDouble(),
      rates: (json['rates'] as List<dynamic>)
          .map((e) => RateModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      params: ParkingParamsModel.fromJson(
        json['params'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$ParkingSimpleModelToJson(ParkingSimpleModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'phone': instance.phone,
      'address': instance.address,
      'status': instance.status,
      'isOwner': instance.isOwner,
      'isActive': instance.isActive,
      'rates': instance.rates,
      'params': instance.params,
      'logoUrl': instance.logoUrl,
      'areaCount': instance.areaCount,
      'totalSpots': instance.totalSpots,
      'occupiedSpots': instance.occupiedSpots,
      'availableSpots': instance.availableSpots,
      'operationMode': _$ParkingOperationModeEnumMap[instance.operationMode],
      'capacity': instance.capacity,
    };

const _$ParkingOperationModeEnumMap = {
  ParkingOperationMode.visual: 'visual',
  ParkingOperationMode.simple: 'simple',
};

ParkingModel _$ParkingModelFromJson(Map<String, dynamic> json) => ParkingModel(
  id: json['id'] as String,
  name: json['name'] as String,
  email: json['email'] as String?,
  phone: json['phone'] as String?,
  address: json['address'] as String?,
  logoUrl: json['logoUrl'] as String?,
  status: json['status'] as String?,
  ownerId: json['ownerId'] as String?,
  isOwner: json['isOwner'] as bool?,
  isActive: json['isActive'] as bool?,
  companyId: json['companyId'] as String?,
  owner: json['owner'] == null
      ? null
      : UserModel.fromJson(json['owner'] as Map<String, dynamic>),
  rates: (json['rates'] as List<dynamic>)
      .map((e) => RateModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  params: ParkingParamsModel.fromJson(json['params'] as Map<String, dynamic>),
  areas: (json['areas'] as List<dynamic>?)
      ?.map((e) => AreaModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  employees: (json['employees'] as List<dynamic>?)
      ?.map((e) => EmployeeModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  deletedAt: json['deletedAt'] == null
      ? null
      : DateTime.parse(json['deletedAt'] as String),
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  totalSpots: (json['totalSpots'] as num?)?.toInt(),
  availableSpots: (json['availableSpots'] as num?)?.toInt(),
  occupiedSpots: (json['occupiedSpots'] as num?)?.toInt(),
  areaCount: (json['areaCount'] as num?)?.toInt(),
  operationMode: $enumDecodeNullable(
    _$ParkingOperationModeEnumMap,
    json['operationMode'],
  ),
  capacity: (json['capacity'] as num?)?.toDouble(),
);

Map<String, dynamic> _$ParkingModelToJson(ParkingModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'phone': instance.phone,
      'address': instance.address,
      'logoUrl': instance.logoUrl,
      'status': instance.status,
      'ownerId': instance.ownerId,
      'isOwner': instance.isOwner,
      'isActive': instance.isActive,
      'companyId': instance.companyId,
      'owner': instance.owner,
      'rates': instance.rates,
      'params': instance.params,
      'areas': instance.areas,
      'employees': instance.employees,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'deletedAt': instance.deletedAt?.toIso8601String(),
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'totalSpots': instance.totalSpots,
      'availableSpots': instance.availableSpots,
      'occupiedSpots': instance.occupiedSpots,
      'areaCount': instance.areaCount,
      'operationMode': _$ParkingOperationModeEnumMap[instance.operationMode],
      'capacity': instance.capacity,
    };

ParkingCreateModel _$ParkingCreateModelFromJson(Map<String, dynamic> json) =>
    ParkingCreateModel(
      name: json['name'] as String,
      companyId: json['companyId'] as String,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      address: json['address'] as String?,
      totalSpots: (json['totalSpots'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ParkingCreateModelToJson(ParkingCreateModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'companyId': instance.companyId,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'address': instance.address,
      'totalSpots': instance.totalSpots,
    };

ParkingUpdateModel _$ParkingUpdateModelFromJson(Map<String, dynamic> json) =>
    ParkingUpdateModel(
      name: json['name'] as String?,
      params: json['params'] == null
          ? null
          : ParkingParamsModel.fromJson(json['params'] as Map<String, dynamic>),
      rates: (json['rates'] as List<dynamic>?)
          ?.map((e) => RateModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      address: json['address'] as String?,
      totalSpots: (json['totalSpots'] as num?)?.toInt(),
      availableSpots: (json['availableSpots'] as num?)?.toInt(),
      isOpen: json['isOpen'] as bool?,
      openingHours: json['openingHours'] as String?,
      operationMode: $enumDecodeNullable(
        _$ParkingOperationModeEnumMap,
        json['operationMode'],
      ),
      capacity: (json['capacity'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$ParkingUpdateModelToJson(ParkingUpdateModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'params': instance.params,
      'rates': instance.rates,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'address': instance.address,
      'totalSpots': instance.totalSpots,
      'availableSpots': instance.availableSpots,
      'isOpen': instance.isOpen,
      'openingHours': instance.openingHours,
      'operationMode': _$ParkingOperationModeEnumMap[instance.operationMode],
      'capacity': instance.capacity,
    };

ParkingPreviewModel _$ParkingPreviewModelFromJson(Map<String, dynamic> json) =>
    ParkingPreviewModel(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      logoUrl: json['logoUrl'] as String,
      params: ParkingParamsModel.fromJson(
        json['params'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$ParkingPreviewModelToJson(
  ParkingPreviewModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'address': instance.address,
  'logoUrl': instance.logoUrl,
  'params': instance.params,
};

ParkingParamsModel _$ParkingParamsModelFromJson(Map<String, dynamic> json) =>
    ParkingParamsModel(
      theme: json['theme'] as String,
      slogan: json['slogan'] as String?,
      currency: json['currency'] as String,
      timeZone: json['timeZone'] as String,
      countryCode: json['countryCode'] as String,
      decimalPlaces: (json['decimalPlaces'] as num).toInt(),
    );

Map<String, dynamic> _$ParkingParamsModelToJson(ParkingParamsModel instance) =>
    <String, dynamic>{
      'theme': instance.theme,
      'slogan': instance.slogan,
      'currency': instance.currency,
      'timeZone': instance.timeZone,
      'countryCode': instance.countryCode,
      'decimalPlaces': instance.decimalPlaces,
    };

BusinessHourModel _$BusinessHourModelFromJson(Map<String, dynamic> json) =>
    BusinessHourModel(
      open: json['open'] as String,
      close: json['close'] as String,
      is24h: json['is24h'] as bool,
    );

Map<String, dynamic> _$BusinessHourModelToJson(BusinessHourModel instance) =>
    <String, dynamic>{
      'open': instance.open,
      'close': instance.close,
      'is24h': instance.is24h,
    };

RateModel _$RateModelFromJson(Map<String, dynamic> json) => RateModel(
  id: json['id'] as String,
  name: json['name'] as String,
  vehicleCategory: (json['vehicleCategory'] as num).toInt(),
  tolerance: (json['tolerance'] as num).toInt(),
  hourly: (json['hourly'] as num).toDouble(),
  daily: (json['daily'] as num).toDouble(),
  weekly: (json['weekly'] as num).toDouble(),
  monthly: (json['monthly'] as num).toDouble(),
  yearly: (json['yearly'] as num).toDouble(),
  isActive: json['isActive'] as bool,
);

Map<String, dynamic> _$RateModelToJson(RateModel instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'vehicleCategory': instance.vehicleCategory,
  'tolerance': instance.tolerance,
  'hourly': instance.hourly,
  'daily': instance.daily,
  'weekly': instance.weekly,
  'monthly': instance.monthly,
  'yearly': instance.yearly,
  'isActive': instance.isActive,
};
