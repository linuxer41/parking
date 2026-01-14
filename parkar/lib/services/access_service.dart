import '../config/app_config.dart';
import '../models/access_model.dart';
import 'base_service.dart';

class AccessFilter {
  final String? vehicleId;
  final String? employeeId;
  final String? parkingId;
  final String? status;
  final String? dateFrom;
  final String? dateTo;
  final bool? inParking;
  final String? search;

  AccessFilter({
    this.vehicleId,
    this.employeeId,
    this.parkingId,
    this.status,
    this.dateFrom,
    this.dateTo,
    this.inParking,
    this.search,
  });

// quei only set the values that are not null
  String toQuery() =>this.toMap().entries
          .where((e) => e.value != null)
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value.toString())}')
          .join('&');

  Map<String, dynamic> toMap() {
    return {
      'vehicleId': vehicleId,
      'employeeId': employeeId,
      'parkingId': parkingId,
      'status': status,
      'dateFrom': dateFrom,
      'dateTo': dateTo,
      'inParking': inParking,
      'search': search,
    };
  }
}

class AccessService extends BaseService {
  AccessService() : super(path: AppConfig.apiEndpoints['access'] ?? '/access');

  Future<AccessModel> createEntry(AccessCreateModel access) async {
    return post<AccessModel>(
      endpoint: '/entry',
      body: access.toJson(),
      parser: (json) => parseModel(json, AccessModel.fromJson),
    );
  }

  Future<AccessModel> registerEntry(String entryId) async {
    return post<AccessModel>(
      endpoint: '/$entryId/entry',
      body: <String, dynamic>{},
      parser: (json) => parseModel(json, AccessModel.fromJson),
    );
  }

  Future<AccessModel> registerExit({
    required String entryId,
    required double amount,
    String? notes,
  }) async {
    final data = <String, dynamic>{'amount': amount};

    if (notes != null) {
      data['notes'] = notes;
    }

    return post<AccessModel>(
      endpoint: '/$entryId/exit',
      body: data,
      parser: (json) => parseModel(json, AccessModel.fromJson),
    );
  }

  Future<AccessModel> getAccess(String id) async {
    return get<AccessModel>(
      endpoint: '/$id',
      parser: (json) => parseModel(json, AccessModel.fromJson),
    );
  }

  Future<AccessModel> updateAccess(String id, Map<String, dynamic> data) async {
    return patch<AccessModel>(
      endpoint: '/$id',
      body: data,
      parser: (json) => parseModel(json, AccessModel.fromJson),
    );
  }

  Future<void> deleteAccess(String id) async {
    return delete<void>(endpoint: '/$id', parser: (_) => null);
  }

  Future<List<AccessModel>> list(AccessFilter filter,) async {
    return get<List<AccessModel>>(
      endpoint: '/?${filter.toQuery()}',
      parser: (json) => parseModelList(json, AccessModel.fromJson),
    );
  }

  Future<double> calculateExitFee(String entryId) async {
    final response = await get<Map<String, dynamic>>(
      endpoint: '/$entryId/fee',
      parser: (json) => json as Map<String, dynamic>,
    );

    return (response['amount'] as num).toDouble();
  }
}
