import 'package:json_annotation/json_annotation.dart';

import '_base_model.dart';

part 'employee_model.g.dart';

@JsonSerializable()
class EmployeeModel extends JsonConvertible<EmployeeModel> {
  final String id;
  final String role;
  final String name;
  final String? email;
  final String? phone;

  EmployeeModel({
    required this.id,
    required this.role,
    required this.name,
    this.email,
    this.phone,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) =>
      _$EmployeeModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$EmployeeModelToJson(this);
}

@JsonSerializable()
class EmployeeCreateModel extends JsonConvertible<EmployeeCreateModel> {
  final String userId;
  final String parkingId;
  final String role;

  EmployeeCreateModel({
    required this.userId,
    required this.parkingId,
    required this.role,
  });

  factory EmployeeCreateModel.fromJson(Map<String, dynamic> json) =>
      _$EmployeeCreateModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$EmployeeCreateModelToJson(this);
}

@JsonSerializable()
class EmployeeUpdateModel extends JsonConvertible<EmployeeUpdateModel> {
  final String? role;

  EmployeeUpdateModel({this.role});

  factory EmployeeUpdateModel.fromJson(Map<String, dynamic> json) =>
      _$EmployeeUpdateModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$EmployeeUpdateModelToJson(this);
}

@JsonSerializable()
class EmployeePreviewModel extends JsonConvertible<EmployeePreviewModel> {
  final String id;
  final String name;
  final String? role;
  final String? email;
  final String? phone;

  EmployeePreviewModel({
    required this.id,
    required this.name,
    this.role,
    this.email,
    this.phone,
  });

  factory EmployeePreviewModel.fromJson(Map<String, dynamic> json) =>
      _$EmployeePreviewModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$EmployeePreviewModelToJson(this);
}
