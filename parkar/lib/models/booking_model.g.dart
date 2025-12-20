// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookingModel _$BookingModelFromJson(Map<String, dynamic> json) => BookingModel(
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
  status: $enumDecode(_$ReservationStatusEnumMap, json['status']),
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$BookingModelToJson(BookingModel instance) =>
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
      'status': _$ReservationStatusEnumMap[instance.status]!,
      'notes': instance.notes,
    };

const _$ReservationStatusEnumMap = {
  ReservationStatus.pending: 'pending',
  ReservationStatus.active: 'active',
  ReservationStatus.completed: 'completed',
  ReservationStatus.cancelled: 'cancelled',
  ReservationStatus.expired: 'expired',
};

BookingCreateModel _$BookingCreateModelFromJson(Map<String, dynamic> json) =>
    BookingCreateModel(
      employeeId: json['employeeId'] as String,
      vehicleId: json['vehicleId'] as String,
      spotId: json['spotId'] as String?,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      status: $enumDecode(_$ReservationStatusEnumMap, json['status']),
      amount: (json['amount'] as num).toDouble(),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$BookingCreateModelToJson(BookingCreateModel instance) =>
    <String, dynamic>{
      'employeeId': instance.employeeId,
      'vehicleId': instance.vehicleId,
      'spotId': instance.spotId,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'status': _$ReservationStatusEnumMap[instance.status]!,
      'amount': instance.amount,
      'notes': instance.notes,
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
      status: $enumDecodeNullable(_$ReservationStatusEnumMap, json['status']),
      amount: (json['amount'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$BookingUpdateModelToJson(BookingUpdateModel instance) =>
    <String, dynamic>{
      'number': instance.number,
      'employeeId': instance.employeeId,
      'vehicleId': instance.vehicleId,
      'spotId': instance.spotId,
      'startDate': instance.startDate?.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'status': _$ReservationStatusEnumMap[instance.status],
      'amount': instance.amount,
      'notes': instance.notes,
    };

BookingPreviewModel _$BookingPreviewModelFromJson(Map<String, dynamic> json) =>
    BookingPreviewModel(
      id: json['id'] as String,
      number: (json['number'] as num).toInt(),
      employeeId: json['employeeId'] as String,
      vehicleId: json['vehicleId'] as String,
      spotId: json['spotId'] as String?,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      status: $enumDecode(_$ReservationStatusEnumMap, json['status']),
      amount: (json['amount'] as num).toDouble(),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$BookingPreviewModelToJson(
  BookingPreviewModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'number': instance.number,
  'employeeId': instance.employeeId,
  'vehicleId': instance.vehicleId,
  'spotId': instance.spotId,
  'startDate': instance.startDate.toIso8601String(),
  'endDate': instance.endDate?.toIso8601String(),
  'status': _$ReservationStatusEnumMap[instance.status]!,
  'amount': instance.amount,
  'notes': instance.notes,
};

BookingForElementModel _$BookingForElementModelFromJson(
  Map<String, dynamic> json,
) => BookingForElementModel(
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
  status: $enumDecode(_$ReservationStatusEnumMap, json['status']),
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$BookingForElementModelToJson(
  BookingForElementModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'number': instance.number,
  'employee': instance.employee,
  'vehicle': instance.vehicle,
  'startDate': instance.startDate.toIso8601String(),
  'endDate': instance.endDate?.toIso8601String(),
  'amount': instance.amount,
  'status': _$ReservationStatusEnumMap[instance.status]!,
  'notes': instance.notes,
};

BookingCreateFromFormModel _$BookingCreateFromFormModelFromJson(
  Map<String, dynamic> json,
) => BookingCreateFromFormModel(
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
  duration: (json['duration'] as num).toInt(),
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$BookingCreateFromFormModelToJson(
  BookingCreateFromFormModel instance,
) => <String, dynamic>{
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
  'duration': instance.duration,
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
