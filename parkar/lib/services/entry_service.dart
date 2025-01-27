
import 'dart:convert';

import '_base_service.dart';
import '../models/entry_model.dart';

class EntryService extends BaseService<EntryModel, EntryCreateModel, EntryUpdateModel> {
  EntryService() : super(path: '/entry', fromJsonFactory: EntryModel.fromJson);


  Future<EntryModel> getDetailed(String plate, String spotId) async {
    final uri = Uri.parse('$baseUrl$path/$plate/$spotId');
    final response = await httpClient.get(
      uri,
      headers: buildHeaders(),
    );
    handleResponse(response);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return EntryModel.fromJson(data);
  }
}
