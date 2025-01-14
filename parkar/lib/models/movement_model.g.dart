// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movement_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MovementModel _$MovementModelFromJson(Map<String, dynamic> json) =>
    MovementModel(
      id: json['id'] as String,
      cashRegisterId: json['cashRegisterId'] as String,
      cashRegister: CashRegisterModel.fromJson(
          json['cashRegister'] as Map<String, dynamic>),
      type: json['type'] as String,
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$MovementModelToJson(MovementModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'cashRegisterId': instance.cashRegisterId,
      'cashRegister': instance.cashRegister,
      'type': instance.type,
      'amount': instance.amount,
      'description': instance.description,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

MovementCreateModel _$MovementCreateModelFromJson(Map<String, dynamic> json) =>
    MovementCreateModel(
      cashRegisterId: json['cashRegisterId'] as String,
      type: json['type'] as String,
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String,
    );

Map<String, dynamic> _$MovementCreateModelToJson(
        MovementCreateModel instance) =>
    <String, dynamic>{
      'cashRegisterId': instance.cashRegisterId,
      'type': instance.type,
      'amount': instance.amount,
      'description': instance.description,
    };

MovementUpdateModel _$MovementUpdateModelFromJson(Map<String, dynamic> json) =>
    MovementUpdateModel(
      type: json['type'] as String,
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String,
    );

Map<String, dynamic> _$MovementUpdateModelToJson(
        MovementUpdateModel instance) =>
    <String, dynamic>{
      'type': instance.type,
      'amount': instance.amount,
      'description': instance.description,
    };
