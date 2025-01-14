
import '_base_service.dart';
import '../models/reservation_model.dart';

class ReservationService extends BaseService<ReservationModel, ReservationCreateModel, ReservationUpdateModel> {
  ReservationService() : super(path: '/reservation', fromJsonFactory: ReservationModel.fromJson);
}
