
import '_base_service.dart';
import '../models/subscriber_model.dart';

class SubscriberService extends BaseService<SubscriberModel, SubscriberCreateModel, SubscriberUpdateModel> {
  SubscriberService() : super(path: '/subscriber', fromJsonFactory: SubscriberModel.fromJson);
}
