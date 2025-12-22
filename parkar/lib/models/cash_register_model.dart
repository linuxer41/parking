import 'package:json_annotation/json_annotation.dart';
import '_base_model.dart';
import 'employee_model.dart';

part 'cash_register_model.g.dart';

@JsonSerializable()
class CashRegisterModel extends JsonConvertible<CashRegisterModel> {
  final String id;
  final int number;
  final EmployeeModel employee;
  final DateTime startDate;
  final DateTime? endDate;
  final String status;
  final double totalAmount;
  final double initialAmount;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? comment;
  final String? observation;

  CashRegisterModel({
    required this.id,
    required this.number,
    required this.employee,
    required this.startDate,
    this.endDate,
    required this.status,
    required this.totalAmount,
    required this.initialAmount,
    required this.createdAt,
    required this.updatedAt,
    this.comment,
    this.observation,
  });

  factory CashRegisterModel.fromJson(Map<String, dynamic> json) =>
      _$CashRegisterModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$CashRegisterModelToJson(this);
}

@JsonSerializable()
class CashRegisterCreateModel extends JsonConvertible<CashRegisterCreateModel> {
  final DateTime startDate;
  final double initialAmount;
  CashRegisterCreateModel({required this.startDate, required this.initialAmount});

  factory CashRegisterCreateModel.fromJson(Map<String, dynamic> json) =>
      _$CashRegisterCreateModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$CashRegisterCreateModelToJson(this);
}

@JsonSerializable()
class CashRegisterUpdateModel extends JsonConvertible<CashRegisterUpdateModel> {
  final DateTime? endDate;
  final String? status;

  CashRegisterUpdateModel({this.endDate, this.status});

  factory CashRegisterUpdateModel.fromJson(Map<String, dynamic> json) =>
      _$CashRegisterUpdateModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$CashRegisterUpdateModelToJson(this);
}

@JsonSerializable()
class CashRegisterCloseModel extends JsonConvertible<CashRegisterCloseModel> {
  final String? comment;
  final DateTime? endDate;

  CashRegisterCloseModel({this.comment, this.endDate});

  factory CashRegisterCloseModel.fromJson(Map<String, dynamic> json) =>
      _$CashRegisterCloseModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$CashRegisterCloseModelToJson(this);
}

@JsonSerializable()
class CashRegisterPreviewModel extends JsonConvertible<CashRegisterPreviewModel> {
  final String id;
  final int number;

  CashRegisterPreviewModel({required this.id, required this.number});

  factory CashRegisterPreviewModel.fromJson(Map<String, dynamic> json) =>
      _$CashRegisterPreviewModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$CashRegisterPreviewModelToJson(this);
}
