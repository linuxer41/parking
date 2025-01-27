
import 'package:json_annotation/json_annotation.dart';
import '_base_model.dart';
import 'user_model.dart';
import 'company_model.dart';

part 'employee_model.g.dart';

@JsonSerializable()
class EmployeeModel extends JsonConvertible<EmployeeModel> {
  final String id;
  final String userId;
  final UserModel? user;
  final String companyId;
  final CompanyModel? company;
  final String role;
  final List<String> assignedParkings;
  final DateTime createdAt;
  final DateTime updatedAt;

  EmployeeModel({
    required this.id,
    required this.userId,
    this.user,
    required this.companyId,
    this.company,
    required this.role,
    required this.assignedParkings,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) =>
      _$EmployeeModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$EmployeeModelToJson(this);
}

@JsonSerializable()
class EmployeeCreateModel extends JsonConvertible<EmployeeCreateModel> {
  final String userId;
  final String companyId;
  final String role;
  final List<String> assignedParkings;

  EmployeeCreateModel({
    required this.userId,
    required this.companyId,
    required this.role,
    required this.assignedParkings,
  });

  factory EmployeeCreateModel.fromJson(Map<String, dynamic> json) =>
      _$EmployeeCreateModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$EmployeeCreateModelToJson(this);
}

@JsonSerializable()
class EmployeeUpdateModel extends JsonConvertible<EmployeeUpdateModel> {
  final String? role;
  final List<String>? assignedParkings;

  EmployeeUpdateModel({
    this.role,
    this.assignedParkings,
  });

  factory EmployeeUpdateModel.fromJson(Map<String, dynamic> json) =>
      _$EmployeeUpdateModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$EmployeeUpdateModelToJson(this);
}


