import 'dart:convert';

import 'package:parkar/models/composite_models.dart';

import '_base_service.dart';
import '../models/parking_model.dart';

class ParkingService
    extends BaseService<ParkingModel, ParkingCreateModel, ParkingUpdateModel> {
  ParkingService()
      : super(path: '/parking', fromJsonFactory: ParkingModel.fromJson);

  Future<ParkingCompositeModel> getDetailed(String parkingId) async {
    final uri = Uri.parse('$baseUrl$path/$parkingId/detailed');
    final response = await httpClient.get(
      uri,
      headers: buildHeaders(),
    );
    handleResponse(response);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return ParkingCompositeModel.fromJson(data);
  }
}
