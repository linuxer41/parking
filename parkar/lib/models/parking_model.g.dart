// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parking_model.dart';

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

ElementOccupancyInfoModel _$ElementOccupancyInfoModelFromJson(
  Map<String, dynamic> json,
) => ElementOccupancyInfoModel(
  id: json['id'] as String,
  vehiclePlate: json['vehiclePlate'] as String,
  ownerName: json['ownerName'] as String,
  ownerPhone: json['ownerPhone'] as String,
  startDate: json['startDate'] as String,
  endDate: json['endDate'] as String?,
  amount: (json['amount'] as num?)?.toDouble(),
);

Map<String, dynamic> _$ElementOccupancyInfoModelToJson(
  ElementOccupancyInfoModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'vehiclePlate': instance.vehiclePlate,
  'ownerName': instance.ownerName,
  'ownerPhone': instance.ownerPhone,
  'startDate': instance.startDate,
  'endDate': instance.endDate,
  'amount': instance.amount,
};

ElementModel _$ElementModelFromJson(Map<String, dynamic> json) => ElementModel(
  id: json['id'] as String,
  name: json['name'] as String,
  type: $enumDecode(_$ElementTypeEnumMap, json['type']),
  subType: (json['subType'] as num).toInt(),
  posX: (json['posX'] as num).toDouble(),
  posY: (json['posY'] as num).toDouble(),
  posZ: (json['posZ'] as num).toDouble(),
  rotation: (json['rotation'] as num).toDouble(),
  scale: (json['scale'] as num).toDouble(),
  isActive: json['isActive'] as bool,
  entry: json['entry'] == null
      ? null
      : ElementOccupancyInfoModel.fromJson(
          json['entry'] as Map<String, dynamic>,
        ),
  booking: json['booking'] == null
      ? null
      : ElementOccupancyInfoModel.fromJson(
          json['booking'] as Map<String, dynamic>,
        ),
  subscription: json['subscription'] == null
      ? null
      : ElementOccupancyInfoModel.fromJson(
          json['subscription'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$ElementModelToJson(ElementModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': _$ElementTypeEnumMap[instance.type]!,
      'subType': instance.subType,
      'posX': instance.posX,
      'posY': instance.posY,
      'posZ': instance.posZ,
      'rotation': instance.rotation,
      'scale': instance.scale,
      'isActive': instance.isActive,
      'entry': instance.entry,
      'booking': instance.booking,
      'subscription': instance.subscription,
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

SpotPreviewModel _$SpotPreviewModelFromJson(Map<String, dynamic> json) =>
    SpotPreviewModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: $enumDecode(_$ElementTypeEnumMap, json['type']),
      subType: (json['subType'] as num).toInt(),
    );

Map<String, dynamic> _$SpotPreviewModelToJson(SpotPreviewModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': _$ElementTypeEnumMap[instance.type]!,
      'subType': instance.subType,
    };

AreaModel _$AreaModelFromJson(Map<String, dynamic> json) => AreaModel(
  id: json['id'] as String,
  name: json['name'] as String,
  totalSpots: (json['totalSpots'] as num).toInt(),
  availableSpots: (json['availableSpots'] as num).toInt(),
  occupiedSpots: (json['occupiedSpots'] as num).toInt(),
  elements: (json['elements'] as List<dynamic>)
      .map((e) => ElementModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$AreaModelToJson(AreaModel instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'totalSpots': instance.totalSpots,
  'availableSpots': instance.availableSpots,
  'occupiedSpots': instance.occupiedSpots,
  'elements': instance.elements,
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

ParkingModel _$ParkingModelFromJson(Map<String, dynamic> json) => ParkingModel(
  id: json['id'] as String,
  name: json['name'] as String,
  email: json['email'] as String?,
  phone: json['phone'] as String?,
  address: json['address'] as String?,
  location: json['location'] == null
      ? null
      : ParkingLocationModel.fromJson(json['location'] as Map<String, dynamic>),
  logoUrl: json['logoUrl'] as String?,
  status: json['status'] as String,
  params: ParkingParamsModel.fromJson(json['params'] as Map<String, dynamic>),
  rates: (json['rates'] as List<dynamic>)
      .map((e) => RateModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  operationMode: $enumDecode(
    _$ParkingOperationModeEnumMap,
    json['operationMode'],
  ),
  isOwner: json['isOwner'] as bool,
  areaCount: (json['areaCount'] as num).toInt(),
);

Map<String, dynamic> _$ParkingModelToJson(ParkingModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'phone': instance.phone,
      'address': instance.address,
      'location': instance.location,
      'logoUrl': instance.logoUrl,
      'status': instance.status,
      'params': instance.params,
      'rates': instance.rates,
      'operationMode': _$ParkingOperationModeEnumMap[instance.operationMode]!,
      'isOwner': instance.isOwner,
      'areaCount': instance.areaCount,
    };

const _$ParkingOperationModeEnumMap = {
  ParkingOperationMode.map: 'map',
  ParkingOperationMode.list: 'list',
};

ParkingDetailedModel _$ParkingDetailedModelFromJson(
  Map<String, dynamic> json,
) => ParkingDetailedModel(
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
  areas: (json['areas'] as List<dynamic>)
      .map((e) => AreaModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  employees: (json['employees'] as List<dynamic>?)
      ?.map((e) => EmployeeModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  location: json['location'] == null
      ? null
      : ParkingLocationModel.fromJson(json['location'] as Map<String, dynamic>),
  areaCount: (json['areaCount'] as num?)?.toInt(),
  operationMode: $enumDecodeNullable(
    _$ParkingOperationModeEnumMap,
    json['operationMode'],
  ),
);

Map<String, dynamic> _$ParkingDetailedModelToJson(
  ParkingDetailedModel instance,
) => <String, dynamic>{
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
  'location': instance.location,
  'areaCount': instance.areaCount,
  'operationMode': _$ParkingOperationModeEnumMap[instance.operationMode],
};

ParkingLocationModel _$ParkingLocationModelFromJson(
  Map<String, dynamic> json,
) => ParkingLocationModel(
  lat: (json['lat'] as num?)?.toDouble(),
  lng: (json['lng'] as num?)?.toDouble(),
);

Map<String, dynamic> _$ParkingLocationModelToJson(
  ParkingLocationModel instance,
) => <String, dynamic>{'lat': instance.lat, 'lng': instance.lng};

ParkingCreateModel _$ParkingCreateModelFromJson(Map<String, dynamic> json) =>
    ParkingCreateModel(
      name: json['name'] as String,
      companyId: json['companyId'] as String,
      location: json['location'] == null
          ? null
          : ParkingLocationModel.fromJson(
              json['location'] as Map<String, dynamic>,
            ),
      address: json['address'] as String?,
      totalSpots: (json['totalSpots'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ParkingCreateModelToJson(ParkingCreateModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'companyId': instance.companyId,
      'location': instance.location,
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
      location: json['location'] == null
          ? null
          : ParkingLocationModel.fromJson(
              json['location'] as Map<String, dynamic>,
            ),
      address: json['address'] as String?,
      totalSpots: (json['totalSpots'] as num?)?.toInt(),
      availableSpots: (json['availableSpots'] as num?)?.toInt(),
      isOpen: json['isOpen'] as bool?,
      openingHours: json['openingHours'] as String?,
      operationMode: $enumDecodeNullable(
        _$ParkingOperationModeEnumMap,
        json['operationMode'],
      ),
    );

Map<String, dynamic> _$ParkingUpdateModelToJson(ParkingUpdateModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'params': instance.params,
      'rates': instance.rates,
      'location': instance.location,
      'address': instance.address,
      'totalSpots': instance.totalSpots,
      'availableSpots': instance.availableSpots,
      'isOpen': instance.isOpen,
      'openingHours': instance.openingHours,
      'operationMode': _$ParkingOperationModeEnumMap[instance.operationMode],
    };

ParkingPreviewModel _$ParkingPreviewModelFromJson(Map<String, dynamic> json) =>
    ParkingPreviewModel(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String?,
      logoUrl: json['logoUrl'] as String?,
      params: json['params'] == null
          ? null
          : ParkingParamsModel.fromJson(json['params'] as Map<String, dynamic>),
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
