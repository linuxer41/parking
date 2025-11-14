// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookingModel _$BookingModelFromJson(Map<String, dynamic> json) => BookingModel(
  id: json['id'] as String,
  type: $enumDecode(_$BookingTypeEnumMap, json['type']),
  number: (json['number'] as num).toInt(),
  employeeId: json['employeeId'] as String,
  parking: ParkingPreviewModel.fromJson(
    json['parking'] as Map<String, dynamic>,
  ),
  employee: EmployeePreviewModel.fromJson(
    json['employee'] as Map<String, dynamic>,
  ),
  vehicleId: json['vehicleId'] as String,
  vehicle: VehiclePreviewModel.fromJson(
    json['vehicle'] as Map<String, dynamic>,
  ),
  spot: json['spot'] == null
      ? null
      : SpotPreviewModel.fromJson(json['spot'] as Map<String, dynamic>),
  startDate: DateTime.parse(json['startDate'] as String),
  endDate: json['endDate'] == null
      ? null
      : DateTime.parse(json['endDate'] as String),
  status: json['status'] as String,
  amount: (json['amount'] as num).toDouble(),
  parentId: json['parentId'] as String?,
  exitEmployeeId: json['exitEmployeeId'] as String?,
  exitEmployee: json['exitEmployee'] == null
      ? null
      : EmployeePreviewModel.fromJson(
          json['exitEmployee'] as Map<String, dynamic>,
        ),
  isActive: json['isActive'] as bool,
  period: $enumDecodeNullable(_$SubscriptionPeriodEnumMap, json['period']),
);

Map<String, dynamic> _$BookingModelToJson(BookingModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$BookingTypeEnumMap[instance.type]!,
      'number': instance.number,
      'employeeId': instance.employeeId,
      'parking': instance.parking,
      'employee': instance.employee,
      'vehicleId': instance.vehicleId,
      'vehicle': instance.vehicle,
      'spot': instance.spot,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'status': instance.status,
      'amount': instance.amount,
      'parentId': instance.parentId,
      'exitEmployeeId': instance.exitEmployeeId,
      'exitEmployee': instance.exitEmployee,
      'isActive': instance.isActive,
      'period': _$SubscriptionPeriodEnumMap[instance.period],
    };

const _$BookingTypeEnumMap = {
  BookingType.reservation: 'reservation',
  BookingType.subscription: 'subscription',
  BookingType.access: 'access',
};

const _$SubscriptionPeriodEnumMap = {
  SubscriptionPeriod.weekly: 'weekly',
  SubscriptionPeriod.monthly: 'monthly',
  SubscriptionPeriod.yearly: 'yearly',
};

BookingCreateModel _$BookingCreateModelFromJson(Map<String, dynamic> json) =>
    BookingCreateModel(
      type: $enumDecode(_$BookingTypeEnumMap, json['type']),
      employeeId: json['employeeId'] as String,
      vehicleId: json['vehicleId'] as String,
      spotId: json['spotId'] as String?,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      status: json['status'] as String,
      amount: (json['amount'] as num).toDouble(),
      parentId: json['parentId'] as String?,
      exitEmployeeId: json['exitEmployeeId'] as String?,
      isActive: json['isActive'] as bool?,
      period: $enumDecodeNullable(_$SubscriptionPeriodEnumMap, json['period']),
    );

Map<String, dynamic> _$BookingCreateModelToJson(BookingCreateModel instance) =>
    <String, dynamic>{
      'type': _$BookingTypeEnumMap[instance.type]!,
      'employeeId': instance.employeeId,
      'vehicleId': instance.vehicleId,
      'spotId': instance.spotId,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'status': instance.status,
      'amount': instance.amount,
      'parentId': instance.parentId,
      'exitEmployeeId': instance.exitEmployeeId,
      'isActive': instance.isActive,
      'period': _$SubscriptionPeriodEnumMap[instance.period],
    };

BookingUpdateModel _$BookingUpdateModelFromJson(Map<String, dynamic> json) =>
    BookingUpdateModel(
      number: (json['number'] as num?)?.toInt(),
      employeeId: json['employeeId'] as String?,
      vehicleId: json['vehicleId'] as String?,
      spotId: json['spotId'] as String?,
      startDate: json['startDate'] == null
          ? null
          : DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      status: json['status'] as String?,
      amount: (json['amount'] as num?)?.toDouble(),
      parentId: json['parentId'] as String?,
      exitEmployeeId: json['exitEmployeeId'] as String?,
      isActive: json['isActive'] as bool?,
      period: $enumDecodeNullable(_$SubscriptionPeriodEnumMap, json['period']),
    );

Map<String, dynamic> _$BookingUpdateModelToJson(BookingUpdateModel instance) =>
    <String, dynamic>{
      'number': instance.number,
      'employeeId': instance.employeeId,
      'vehicleId': instance.vehicleId,
      'spotId': instance.spotId,
      'startDate': instance.startDate?.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'status': instance.status,
      'amount': instance.amount,
      'parentId': instance.parentId,
      'exitEmployeeId': instance.exitEmployeeId,
      'isActive': instance.isActive,
      'period': _$SubscriptionPeriodEnumMap[instance.period],
    };

BookingPreviewModel _$BookingPreviewModelFromJson(Map<String, dynamic> json) =>
    BookingPreviewModel(
      id: json['id'] as String,
      type: $enumDecode(_$BookingTypeEnumMap, json['type']),
      number: (json['number'] as num).toInt(),
      employeeId: json['employeeId'] as String,
      vehicleId: json['vehicleId'] as String,
      spotId: json['spotId'] as String?,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      status: json['status'] as String,
      amount: (json['amount'] as num).toDouble(),
      isActive: json['isActive'] as bool?,
      period: $enumDecodeNullable(_$SubscriptionPeriodEnumMap, json['period']),
    );

Map<String, dynamic> _$BookingPreviewModelToJson(
  BookingPreviewModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'type': _$BookingTypeEnumMap[instance.type]!,
  'number': instance.number,
  'employeeId': instance.employeeId,
  'vehicleId': instance.vehicleId,
  'spotId': instance.spotId,
  'startDate': instance.startDate.toIso8601String(),
  'endDate': instance.endDate?.toIso8601String(),
  'status': instance.status,
  'amount': instance.amount,
  'isActive': instance.isActive,
  'period': _$SubscriptionPeriodEnumMap[instance.period],
};

BookingForElementModel _$BookingForElementModelFromJson(
  Map<String, dynamic> json,
) => BookingForElementModel(
  id: json['id'] as String,
  type: $enumDecode(_$BookingTypeEnumMap, json['type']),
  number: (json['number'] as num).toInt(),
  employee: EmployeePreviewModel.fromJson(
    json['employee'] as Map<String, dynamic>,
  ),
  vehicle: VehiclePreviewModel.fromJson(
    json['vehicle'] as Map<String, dynamic>,
  ),
  startDate: DateTime.parse(json['startDate'] as String),
  endDate: json['endDate'] == null
      ? null
      : DateTime.parse(json['endDate'] as String),
  amount: (json['amount'] as num).toDouble(),
  isActive: json['isActive'] as bool?,
  period: $enumDecodeNullable(_$SubscriptionPeriodEnumMap, json['period']),
);

Map<String, dynamic> _$BookingForElementModelToJson(
  BookingForElementModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'type': _$BookingTypeEnumMap[instance.type]!,
  'number': instance.number,
  'employee': instance.employee,
  'vehicle': instance.vehicle,
  'startDate': instance.startDate.toIso8601String(),
  'endDate': instance.endDate?.toIso8601String(),
  'amount': instance.amount,
  'isActive': instance.isActive,
  'period': _$SubscriptionPeriodEnumMap[instance.period],
};

BookingCreateFromFormModel _$BookingCreateFromFormModelFromJson(
  Map<String, dynamic> json,
) => BookingCreateFromFormModel(
  type: $enumDecode(_$BookingTypeEnumMap, json['type']),
  ownerName: json['ownerName'] as String?,
  ownerPhone: json['ownerPhone'] as String?,
  vehicleType: json['vehicleType'] as String?,
  vehicleColor: json['vehicleColor'] as String?,
  ownerDocument: json['ownerDocument'] as String?,
  spotId: json['spotId'] as String?,
  areaId: json['areaId'] as String?,
  startDate: json['startDate'] as String,
  amount: (json['amount'] as num).toDouble(),
  vehiclePlate: json['vehiclePlate'] as String,
  durationHours: (json['durationHours'] as num?)?.toInt(),
  period: $enumDecodeNullable(_$SubscriptionPeriodEnumMap, json['period']),
);

Map<String, dynamic> _$BookingCreateFromFormModelToJson(
  BookingCreateFromFormModel instance,
) => <String, dynamic>{
  'type': _$BookingTypeEnumMap[instance.type]!,
  'ownerName': instance.ownerName,
  'ownerPhone': instance.ownerPhone,
  'vehicleType': instance.vehicleType,
  'vehicleColor': instance.vehicleColor,
  'ownerDocument': instance.ownerDocument,
  'spotId': instance.spotId,
  'areaId': instance.areaId,
  'startDate': instance.startDate,
  'amount': instance.amount,
  'vehiclePlate': instance.vehiclePlate,
  'durationHours': instance.durationHours,
  'period': _$SubscriptionPeriodEnumMap[instance.period],
};

AccessCreateModel _$AccessCreateModelFromJson(Map<String, dynamic> json) =>
    AccessCreateModel(
      vehiclePlate: json['vehiclePlate'] as String,
      vehicleType: json['vehicleType'] as String?,
      vehicleColor: json['vehicleColor'] as String?,
      ownerName: json['ownerName'] as String?,
      ownerDocument: json['ownerDocument'] as String?,
      ownerPhone: json['ownerPhone'] as String?,
      spotId: json['spotId'] as String?,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$AccessCreateModelToJson(AccessCreateModel instance) =>
    <String, dynamic>{
      'vehiclePlate': instance.vehiclePlate,
      'vehicleType': instance.vehicleType,
      'vehicleColor': instance.vehicleColor,
      'ownerName': instance.ownerName,
      'ownerDocument': instance.ownerDocument,
      'ownerPhone': instance.ownerPhone,
      'spotId': instance.spotId,
      'notes': instance.notes,
    };

ReservationCreateModel _$ReservationCreateModelFromJson(
  Map<String, dynamic> json,
) => ReservationCreateModel(
  vehiclePlate: json['vehiclePlate'] as String,
  vehicleType: json['vehicleType'] as String?,
  vehicleColor: json['vehicleColor'] as String?,
  ownerName: json['ownerName'] as String?,
  ownerDocument: json['ownerDocument'] as String?,
  ownerPhone: json['ownerPhone'] as String?,
  spotId: json['spotId'] as String?,
  startDate: json['startDate'] as String,
  duration: (json['duration'] as num).toInt(),
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$ReservationCreateModelToJson(
  ReservationCreateModel instance,
) => <String, dynamic>{
  'vehiclePlate': instance.vehiclePlate,
  'vehicleType': instance.vehicleType,
  'vehicleColor': instance.vehicleColor,
  'ownerName': instance.ownerName,
  'ownerDocument': instance.ownerDocument,
  'ownerPhone': instance.ownerPhone,
  'spotId': instance.spotId,
  'startDate': instance.startDate,
  'duration': instance.duration,
  'notes': instance.notes,
};

SubscriptionCreateModel _$SubscriptionCreateModelFromJson(
  Map<String, dynamic> json,
) => SubscriptionCreateModel(
  vehiclePlate: json['vehiclePlate'] as String,
  vehicleType: json['vehicleType'] as String?,
  vehicleColor: json['vehicleColor'] as String?,
  ownerName: json['ownerName'] as String?,
  ownerDocument: json['ownerDocument'] as String?,
  ownerPhone: json['ownerPhone'] as String?,
  spotId: json['spotId'] as String?,
  startDate: json['startDate'] as String,
  period: json['period'] as String,
  amount: (json['amount'] as num).toDouble(),
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$SubscriptionCreateModelToJson(
  SubscriptionCreateModel instance,
) => <String, dynamic>{
  'vehiclePlate': instance.vehiclePlate,
  'vehicleType': instance.vehicleType,
  'vehicleColor': instance.vehicleColor,
  'ownerName': instance.ownerName,
  'ownerDocument': instance.ownerDocument,
  'ownerPhone': instance.ownerPhone,
  'spotId': instance.spotId,
  'startDate': instance.startDate,
  'period': instance.period,
  'amount': instance.amount,
  'notes': instance.notes,
};
