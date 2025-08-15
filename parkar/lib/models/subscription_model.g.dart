// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubscriptionModel _$SubscriptionModelFromJson(Map<String, dynamic> json) =>
    SubscriptionModel(
      id: json['id'] as String,
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
      spotId: json['spotId'] as String,
      spot: ElementPreviewModel.fromJson(json['spot'] as Map<String, dynamic>),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      amount: (json['amount'] as num).toDouble(),
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$SubscriptionModelToJson(SubscriptionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'parkingId': instance.parkingId,
      'parking': instance.parking,
      'employeeId': instance.employeeId,
      'employee': instance.employee,
      'vehicleId': instance.vehicleId,
      'vehicle': instance.vehicle,
      'spotId': instance.spotId,
      'spot': instance.spot,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'amount': instance.amount,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

SubscriptionCreateModel _$SubscriptionCreateModelFromJson(
  Map<String, dynamic> json,
) => SubscriptionCreateModel(
  ownerName: json['ownerName'] as String?,
  ownerPhone: json['ownerPhone'] as String?,
  vehicleType: json['vehicleType'] as String?,
  vehicleColor: json['vehicleColor'] as String?,
  parkingId: json['parkingId'] as String,
  ownerDocument: json['ownerDocument'] as String?,
  areaId: json['areaId'] as String,
  spotId: json['spotId'] as String,
  startDate: json['startDate'] as String,
  amount: (json['amount'] as num).toDouble(),
  vehiclePlate: json['vehiclePlate'] as String,
  period: $enumDecode(_$SubscriptionPeriodEnumMap, json['period']),
);

Map<String, dynamic> _$SubscriptionCreateModelToJson(
  SubscriptionCreateModel instance,
) => <String, dynamic>{
  'ownerName': instance.ownerName,
  'ownerPhone': instance.ownerPhone,
  'vehicleType': instance.vehicleType,
  'vehicleColor': instance.vehicleColor,
  'parkingId': instance.parkingId,
  'ownerDocument': instance.ownerDocument,
  'areaId': instance.areaId,
  'spotId': instance.spotId,
  'startDate': instance.startDate,
  'amount': instance.amount,
  'vehiclePlate': instance.vehiclePlate,
  'period': _$SubscriptionPeriodEnumMap[instance.period]!,
};

const _$SubscriptionPeriodEnumMap = {
  SubscriptionPeriod.weekly: 'weekly',
  SubscriptionPeriod.monthly: 'monthly',
  SubscriptionPeriod.yearly: 'yearly',
};

SubscriptionUpdateModel _$SubscriptionUpdateModelFromJson(
  Map<String, dynamic> json,
) => SubscriptionUpdateModel(
  startDate: json['startDate'] == null
      ? null
      : DateTime.parse(json['startDate'] as String),
  endDate: json['endDate'] == null
      ? null
      : DateTime.parse(json['endDate'] as String),
  amount: (json['amount'] as num?)?.toDouble(),
);

Map<String, dynamic> _$SubscriptionUpdateModelToJson(
  SubscriptionUpdateModel instance,
) => <String, dynamic>{
  'startDate': instance.startDate?.toIso8601String(),
  'endDate': instance.endDate?.toIso8601String(),
  'amount': instance.amount,
};

SubscriptionPreviewModel _$SubscriptionPreviewModelFromJson(
  Map<String, dynamic> json,
) => SubscriptionPreviewModel(
  id: json['id'] as String,
  parking: ParkingPreviewModel.fromJson(
    json['parking'] as Map<String, dynamic>,
  ),
  employee: EmployeePreviewModel.fromJson(
    json['employee'] as Map<String, dynamic>,
  ),
  vehicle: VehiclePreviewModel.fromJson(
    json['vehicle'] as Map<String, dynamic>,
  ),
  startDate: DateTime.parse(json['startDate'] as String),
  endDate: DateTime.parse(json['endDate'] as String),
  amount: (json['amount'] as num).toDouble(),
);

Map<String, dynamic> _$SubscriptionPreviewModelToJson(
  SubscriptionPreviewModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'parking': instance.parking,
  'employee': instance.employee,
  'vehicle': instance.vehicle,
  'startDate': instance.startDate.toIso8601String(),
  'endDate': instance.endDate.toIso8601String(),
  'amount': instance.amount,
};

SubscriptionForElementModel _$SubscriptionForElementModelFromJson(
  Map<String, dynamic> json,
) => SubscriptionForElementModel(
  id: json['id'] as String,
  employee: EmployeePreviewModel.fromJson(
    json['employee'] as Map<String, dynamic>,
  ),
  vehicle: VehiclePreviewModel.fromJson(
    json['vehicle'] as Map<String, dynamic>,
  ),
  startDate: DateTime.parse(json['startDate'] as String),
  endDate: DateTime.parse(json['endDate'] as String),
  amount: (json['amount'] as num).toDouble(),
);

Map<String, dynamic> _$SubscriptionForElementModelToJson(
  SubscriptionForElementModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'employee': instance.employee,
  'vehicle': instance.vehicle,
  'startDate': instance.startDate.toIso8601String(),
  'endDate': instance.endDate.toIso8601String(),
  'amount': instance.amount,
};
