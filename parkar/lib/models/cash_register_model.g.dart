// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cash_register_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CashRegisterModel _$CashRegisterModelFromJson(Map<String, dynamic> json) =>
    CashRegisterModel(
      id: json['id'] as String,
      number: (json['number'] as num).toInt(),
      employee: EmployeeModel.fromJson(
        json['employee'] as Map<String, dynamic>,
      ),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      status: json['status'] as String,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      initialAmount: (json['initialAmount'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      comment: json['comment'] as String?,
      observation: json['observation'] as String?,
    );

Map<String, dynamic> _$CashRegisterModelToJson(CashRegisterModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'number': instance.number,
      'employee': instance.employee,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'status': instance.status,
      'totalAmount': instance.totalAmount,
      'initialAmount': instance.initialAmount,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'comment': instance.comment,
      'observation': instance.observation,
    };

CashRegisterCreateModel _$CashRegisterCreateModelFromJson(
  Map<String, dynamic> json,
) => CashRegisterCreateModel(
  startDate: DateTime.parse(json['startDate'] as String),
  initialAmount: (json['initialAmount'] as num).toDouble(),
);

Map<String, dynamic> _$CashRegisterCreateModelToJson(
  CashRegisterCreateModel instance,
) => <String, dynamic>{
  'startDate': instance.startDate.toIso8601String(),
  'initialAmount': instance.initialAmount,
};

CashRegisterUpdateModel _$CashRegisterUpdateModelFromJson(
  Map<String, dynamic> json,
) => CashRegisterUpdateModel(
  endDate: json['endDate'] == null
      ? null
      : DateTime.parse(json['endDate'] as String),
  status: json['status'] as String?,
);

Map<String, dynamic> _$CashRegisterUpdateModelToJson(
  CashRegisterUpdateModel instance,
) => <String, dynamic>{
  'endDate': instance.endDate?.toIso8601String(),
  'status': instance.status,
};

CashRegisterCloseModel _$CashRegisterCloseModelFromJson(
  Map<String, dynamic> json,
) => CashRegisterCloseModel(
  comment: json['comment'] as String?,
  endDate: json['endDate'] == null
      ? null
      : DateTime.parse(json['endDate'] as String),
);

Map<String, dynamic> _$CashRegisterCloseModelToJson(
  CashRegisterCloseModel instance,
) => <String, dynamic>{
  'comment': instance.comment,
  'endDate': instance.endDate?.toIso8601String(),
};
