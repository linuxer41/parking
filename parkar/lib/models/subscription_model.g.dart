// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubscriptionModel _$SubscriptionModelFromJson(Map<String, dynamic> json) =>
    SubscriptionModel(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      number: (json['number'] as num).toInt(),
      parkingId: json['parkingId'] as String,
      parking: ParkingPreviewModel.fromJson(
        json['parking'] as Map<String, dynamic>,
      ),
      employeeId: json['employeeId'] as String,
      employee: EmployeePreviewModel.fromJson(
        json['employee'] as Map<String, dynamic>,
      ),
      vehicleId: json['vehicleId'] as String,
      vehicle: VehiclePreviewModel.fromJson(
        json['vehicle'] as Map<String, dynamic>,
      ),
      spotId: json['spotId'] as String?,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      amount: (json['amount'] as num).toDouble(),
      status: $enumDecode(_$SubscriptionStatusEnumMap, json['status']),
      period: $enumDecode(_$SubscriptionPeriodEnumMap, json['period']),
      isActive: json['isActive'] as bool,
      parentId: json['parentId'] as String?,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$SubscriptionModelToJson(SubscriptionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'number': instance.number,
      'parkingId': instance.parkingId,
      'parking': instance.parking,
      'employeeId': instance.employeeId,
      'employee': instance.employee,
      'vehicleId': instance.vehicleId,
      'vehicle': instance.vehicle,
      'spotId': instance.spotId,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'amount': instance.amount,
      'status': _$SubscriptionStatusEnumMap[instance.status]!,
      'period': _$SubscriptionPeriodEnumMap[instance.period]!,
      'isActive': instance.isActive,
      'parentId': instance.parentId,
      'notes': instance.notes,
    };

const _$SubscriptionStatusEnumMap = {
  SubscriptionStatus.active: 'active',
  SubscriptionStatus.suspended: 'suspended',
  SubscriptionStatus.expired: 'expired',
  SubscriptionStatus.cancelled: 'cancelled',
  SubscriptionStatus.renewed: 'renewed',
};

const _$SubscriptionPeriodEnumMap = {
  SubscriptionPeriod.weekly: 'weekly',
  SubscriptionPeriod.monthly: 'monthly',
  SubscriptionPeriod.yearly: 'yearly',
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
  period: $enumDecode(_$SubscriptionPeriodEnumMap, json['period']),
  amount: (json['amount'] as num?)?.toDouble(),
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
  'period': _$SubscriptionPeriodEnumMap[instance.period]!,
  'amount': instance.amount,
  'notes': instance.notes,
};

SubscriptionUpdateModel _$SubscriptionUpdateModelFromJson(
  Map<String, dynamic> json,
) => SubscriptionUpdateModel(
  spotId: json['spotId'] as String?,
  endDate: json['endDate'] == null
      ? null
      : DateTime.parse(json['endDate'] as String),
  amount: (json['amount'] as num?)?.toDouble(),
  status: $enumDecodeNullable(_$SubscriptionStatusEnumMap, json['status']),
  isActive: json['isActive'] as bool?,
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$SubscriptionUpdateModelToJson(
  SubscriptionUpdateModel instance,
) => <String, dynamic>{
  'spotId': instance.spotId,
  'endDate': instance.endDate?.toIso8601String(),
  'amount': instance.amount,
  'status': _$SubscriptionStatusEnumMap[instance.status],
  'isActive': instance.isActive,
  'notes': instance.notes,
};

SubscriptionRenewalModel _$SubscriptionRenewalModelFromJson(
  Map<String, dynamic> json,
) => SubscriptionRenewalModel(
  period: $enumDecode(_$SubscriptionPeriodEnumMap, json['period']),
  amount: (json['amount'] as num?)?.toDouble(),
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$SubscriptionRenewalModelToJson(
  SubscriptionRenewalModel instance,
) => <String, dynamic>{
  'period': _$SubscriptionPeriodEnumMap[instance.period]!,
  'amount': instance.amount,
  'notes': instance.notes,
};

SubscriptionPreviewModel _$SubscriptionPreviewModelFromJson(
  Map<String, dynamic> json,
) => SubscriptionPreviewModel(
  id: json['id'] as String,
  number: (json['number'] as num).toInt(),
  parkingId: json['parkingId'] as String,
  employeeId: json['employeeId'] as String,
  vehicleId: json['vehicleId'] as String,
  spotId: json['spotId'] as String?,
  startDate: DateTime.parse(json['startDate'] as String),
  endDate: json['endDate'] == null
      ? null
      : DateTime.parse(json['endDate'] as String),
  amount: (json['amount'] as num).toDouble(),
  status: $enumDecode(_$SubscriptionStatusEnumMap, json['status']),
  period: $enumDecode(_$SubscriptionPeriodEnumMap, json['period']),
  isActive: json['isActive'] as bool,
  parentId: json['parentId'] as String?,
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$SubscriptionPreviewModelToJson(
  SubscriptionPreviewModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'number': instance.number,
  'parkingId': instance.parkingId,
  'employeeId': instance.employeeId,
  'vehicleId': instance.vehicleId,
  'spotId': instance.spotId,
  'startDate': instance.startDate.toIso8601String(),
  'endDate': instance.endDate?.toIso8601String(),
  'amount': instance.amount,
  'status': _$SubscriptionStatusEnumMap[instance.status]!,
  'period': _$SubscriptionPeriodEnumMap[instance.period]!,
  'isActive': instance.isActive,
  'parentId': instance.parentId,
  'notes': instance.notes,
};

SubscriptionForElementModel _$SubscriptionForElementModelFromJson(
  Map<String, dynamic> json,
) => SubscriptionForElementModel(
  id: json['id'] as String,
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
  status: $enumDecode(_$SubscriptionStatusEnumMap, json['status']),
  period: $enumDecode(_$SubscriptionPeriodEnumMap, json['period']),
  isActive: json['isActive'] as bool,
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$SubscriptionForElementModelToJson(
  SubscriptionForElementModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'number': instance.number,
  'employee': instance.employee,
  'vehicle': instance.vehicle,
  'startDate': instance.startDate.toIso8601String(),
  'endDate': instance.endDate?.toIso8601String(),
  'amount': instance.amount,
  'status': _$SubscriptionStatusEnumMap[instance.status]!,
  'period': _$SubscriptionPeriodEnumMap[instance.period]!,
  'isActive': instance.isActive,
  'notes': instance.notes,
};
