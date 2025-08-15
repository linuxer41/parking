import '../config/app_config.dart';
import 'base_service.dart';
import '../models/subscription_model.dart';

class SubscriptionService extends BaseService {
  SubscriptionService() : super(path: AppConfig.apiEndpoints['subscription']!);

  /// Get a subscription by ID
  Future<SubscriptionModel> getSubscription(String id) async {
    return get<SubscriptionModel>(
      endpoint: '/$id',
      parser: (json) => SubscriptionModel.fromJson(json),
    );
  }

  /// Get subscriptions by parking
  Future<List<SubscriptionModel>> getSubscriptionsByParking(
      String parkingId) async {
    return get<List<SubscriptionModel>>(
      endpoint: '',
      additionalHeaders: {'parkingId': parkingId},
      parser: (data) => (data as List<dynamic>)
          .map((item) => SubscriptionModel.fromJson(item))
          .toList(),
    );
  }

  /// Registrar una nueva suscripción
  Future<SubscriptionModel> registerSubscription(SubscriptionCreateModel subscription) async {
    return post<SubscriptionModel>(
      endpoint: '/',
      body: subscription.toJson(),
      parser: (json) => SubscriptionModel.fromJson(json),
    );
  }

  /// Cancelar una suscripción
  Future<SubscriptionModel> cancelSubscription(String subscriptionId) async {
    return post<SubscriptionModel>(
      endpoint: '/$subscriptionId/cancel',
      body: <String, dynamic>{},
      parser: (json) => SubscriptionModel.fromJson(json),
    );
  }
}
