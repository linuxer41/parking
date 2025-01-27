
import '_base_service.dart';
import '../models/vehicle_model.dart';

class VehicleService extends BaseService<VehicleModel, VehicleCreateModel, VehicleUpdateModel> {
  VehicleService() : super(path: '/vehicle', fromJsonFactory: VehicleModel.fromJson);

  getVehicleDetails(String s) {}
}
