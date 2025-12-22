import 'package:json_annotation/json_annotation.dart';
import '_base_model.dart';
import 'cash_register_model.dart';

part 'movement_model.g.dart';

@JsonSerializable()
class MovementModel extends JsonConvertible<MovementModel> {
  final String id;
  final String cashRegisterId;
  final CashRegisterPreviewModel cashRegister;
  final String type;
  final String originId;
  final String originType;
  final double amount;
  final String description;
  final DateTime createdAt;
  final DateTime? updatedAt;

  MovementModel({
    required this.id,
    required this.cashRegisterId,
    required this.cashRegister,
    required this.type,
    required this.originId,
    required this.originType,
    required this.amount,
    required this.description,
    required this.createdAt,
    this.updatedAt,
  });

  factory MovementModel.fromJson(Map<String, dynamic> json) =>
      _$MovementModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$MovementModelToJson(this);
}

@JsonSerializable()
class MovementCreateModel extends JsonConvertible<MovementCreateModel> {
  final String cashRegisterId;
  final String type;
  final double amount;
  final String description;

  MovementCreateModel({
    required this.cashRegisterId,
    required this.type,
    required this.amount,
    required this.description,
  });

  factory MovementCreateModel.fromJson(Map<String, dynamic> json) =>
      _$MovementCreateModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$MovementCreateModelToJson(this);
}

@JsonSerializable()
class MovementUpdateModel extends JsonConvertible<MovementUpdateModel> {
  final String? type;
  final double? amount;
  final String? description;

  MovementUpdateModel({this.type, this.amount, this.description});

  factory MovementUpdateModel.fromJson(Map<String, dynamic> json) =>
      _$MovementUpdateModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$MovementUpdateModelToJson(this);
}
