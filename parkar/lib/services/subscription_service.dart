import '../config/app_config.dart';
import '../models/subscription_model.dart';
import 'base_service.dart';

class SubscriptionService extends BaseService {
  SubscriptionService()
     : super(path: AppConfig.apiEndpoints['subscription'] ?? '/subscription');

  Future<SubscriptionModel> createSubscription(
    SubscriptionCreateModel subscription,
  ) async {
    return post<SubscriptionModel>(
      endpoint: '',
      body: subscription.toJson(),
      parser: (json) => parseModel(json, SubscriptionModel.fromJson),
    );
  }

  Future<SubscriptionModel> renewSubscription(
    String subscriptionId, {
    SubscriptionPeriod? period,
    double? amount,
    String? notes,
  }) async {
    final data = <String, dynamic>{};

    if (period != null) data['period'] = period.name;
    if (amount != null) data['amount'] = amount;
    if (notes != null) data['notes'] = notes;

    return post<SubscriptionModel>(
      endpoint: '/$subscriptionId/renew',
      body: data,
      parser: (json) => parseModel(json, SubscriptionModel.fromJson),
    );
  }

  Future<SubscriptionModel> getSubscription(String id) async {
    return get<SubscriptionModel>(
      endpoint: '/$id',
      parser: (json) => parseModel(json, SubscriptionModel.fromJson),
    );
  }

  Future<SubscriptionModel> updateSubscription(
    String id,
    Map<String, dynamic> data,
  ) async {
    return patch<SubscriptionModel>(
      endpoint: '/$id',
      body: data,
      parser: (json) => parseModel(json, SubscriptionModel.fromJson),
    );
  }

  Future<void> deleteSubscription(String id) async {
    return delete<void>(endpoint: '/$id', parser: (_) => null);
  }

  Future<List<SubscriptionModel>> getSubscriptionsByParking(String parkingId) async {
    return get<List<SubscriptionModel>>(
      endpoint: '',
      additionalHeaders: {'parkingId': parkingId},
      parser: (json) => parseModelList(json, SubscriptionModel.fromJson),
    );
  }

  Future<List<SubscriptionModel>> getSubscriptionsByVehicle(String vehicleId) async {
    return get<List<SubscriptionModel>>(
      endpoint: '',
      additionalHeaders: {'vehicleId': vehicleId},
      parser: (json) => parseModelList(json, SubscriptionModel.fromJson),
    );
  }

  Future<Map<String, dynamic>> getSubscriptionStats(
    String parkingId, {
    String? startDate,
    String? endDate,
  }) async {
    final queryParams = <String, String>{};

    if (startDate != null) queryParams['startDate'] = startDate;
    if (endDate != null) queryParams['endDate'] = endDate;

    final queryString = queryParams.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');

    return get<Map<String, dynamic>>(
      endpoint: '/stats/$parkingId${queryString.isNotEmpty ? '?$queryString' : ''}',
      parser: (json) => json as Map<String, dynamic>,
    );
  }
}
