
import 'package:json_annotation/json_annotation.dart';
import '_base_model.dart';
import 'user_model.dart';

part 'company_model.g.dart';

@JsonSerializable()
class CompanyModel extends JsonConvertible<CompanyModel> {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? logoUrl;
  final String userId;
  final UserModel? owner;
  final CompanyParamsModel? params;
  final DateTime createdAt;
  final DateTime updatedAt;

  CompanyModel({
    required this.id,
    required this.name,
    required this.email,
     this.phone,
     this.logoUrl,
    required this.userId,
     this.owner,
     this.params,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) =>
      _$CompanyModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$CompanyModelToJson(this);
}

@JsonSerializable()
class CompanyCreateModel extends JsonConvertible<CompanyCreateModel> {
  final String name;
  final String email;
  final String? phone;
  final String? logoUrl;
  final String userId;

  CompanyCreateModel({
    required this.name,
    required this.email,
     this.phone,
     this.logoUrl,
    required this.userId,
  });

  factory CompanyCreateModel.fromJson(Map<String, dynamic> json) =>
      _$CompanyCreateModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$CompanyCreateModelToJson(this);
}

@JsonSerializable()
class CompanyUpdateModel extends JsonConvertible<CompanyUpdateModel> {
  final String name;
  final String email;
  final String? phone;
  final String? logoUrl;
  final String userId;

  CompanyUpdateModel({
    required this.name,
    required this.email,
     this.phone,
     this.logoUrl,
    required this.userId,
  });

  factory CompanyUpdateModel.fromJson(Map<String, dynamic> json) =>
      _$CompanyUpdateModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$CompanyUpdateModelToJson(this);
}


@JsonSerializable()
class CompanyParamsModel extends JsonConvertible<CompanyParamsModel> {
  final String slogan;

  CompanyParamsModel({
    required this.slogan,
  });

  factory CompanyParamsModel.fromJson(Map<String, dynamic> json) =>
      _$CompanyParamsModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$CompanyParamsModelToJson(this);
}

