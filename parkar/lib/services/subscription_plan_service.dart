
import '_base_service.dart';
import '../models/subscription_plan_model.dart';

class SubscriptionPlanService extends BaseService<SubscriptionPlanModel, SubscriptionPlanCreateModel, SubscriptionPlanUpdateModel> {
  SubscriptionPlanService() : super(path: '/subscription_plan', fromJsonFactory: SubscriptionPlanModel.fromJson);
}
