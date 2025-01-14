import 'dart:convert';

import 'package:parkar/models/composite_models.dart';

import '_base_service.dart';
import '../models/user_model.dart';

class UserService
    extends BaseService<UserModel, UserCreateModel, UserUpdateModel> {
  UserService() : super(path: '/user', fromJsonFactory: UserModel.fromJson);

  Future<List<CompanyCompositeModel>> getCompanies(String userId) async {
    final uri = Uri.parse('$baseUrl$path/$userId/companies');
    final response = await httpClient.get(
      uri,
      headers: buildHeaders(),
    );
    handleResponse(response);
    final data = jsonDecode(response.body) as List<dynamic>;
    return data.map((e) => CompanyCompositeModel.fromJson(e)).toList();
  }
}
