import 'package:json_annotation/json_annotation.dart';
import '_base_model.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel extends JsonConvertible<UserModel> {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? avatarUrl;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.avatarUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}

@JsonSerializable()
class UserCreateModel extends JsonConvertible<UserCreateModel> {
  final String name;
  final String email;
  final String password;

  UserCreateModel({
    required this.name,
    required this.email,
    required this.password,
  });

  factory UserCreateModel.fromJson(Map<String, dynamic> json) =>
      _$UserCreateModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$UserCreateModelToJson(this);
}

@JsonSerializable()
class UserUpdateModel extends JsonConvertible<UserUpdateModel> {
  final String? name;
  final String? email;

  UserUpdateModel({this.name, this.email});

  factory UserUpdateModel.fromJson(Map<String, dynamic> json) =>
      _$UserUpdateModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$UserUpdateModelToJson(this);
}
