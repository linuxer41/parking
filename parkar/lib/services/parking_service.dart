import '../config/app_config.dart';
import '../models/dashboard_model.dart';
import '../models/parking_model.dart';
import 'access_service.dart';
import 'base_service.dart';
import 'dart:math';

class ParkingService extends BaseService {
  ParkingService() : super(path: AppConfig.apiEndpoints['parking']!);

  Future<ParkingModel> getParkingById(String id) async {
    return get<ParkingModel>(
      endpoint: '/$id',
      parser: (json) => parseModel(json, ParkingModel.fromJson),
    );
  }

  Future<ParkingDetailedModel> getParkingDetailed(String id) async {
    return get<ParkingDetailedModel>(
      endpoint: '/$id/detailed',
      parser: (json) => parseModel(json, ParkingDetailedModel.fromJson),
    );
  }

  Future<ParkingModel> createParking(ParkingCreateModel model) async {
    return post<ParkingModel>(
      endpoint: '',
      body: model,
      parser: (json) => parseModel(json, ParkingModel.fromJson),
    );
  }

  Future<ParkingModel> updateParking(
    String id,
    ParkingUpdateModel model,
  ) async {
    return patch<ParkingModel>(
      endpoint: '/$id',
      body: model,
      parser: (json) => parseModel(json, ParkingModel.fromJson),
    );
  }

  Future<List<ParkingModel>> getUserParkings() async {
    return get<List<ParkingModel>>(
      endpoint: '',
      parser: (json) => parseModelList(json, ParkingModel.fromJson),
    );
  }

  Future<void> deleteParking(String id) async {
    return delete<void>(endpoint: '/$id', parser: (_) => null);
  }
  Future<DashboardModel> getDashboard(String parkingId) async {
    try {
      return await get<DashboardModel>(
        endpoint: '/$parkingId/dashboard',
        parser: (json) => parseModel(json, DashboardModel.fromJson),
      );
    } catch (e) {
      rethrow;
    }
  }


  Future<void> saveParkingLayout(Map<String, dynamic> layoutData) async {
    return post<void>(
      endpoint: '/layout',
      body: layoutData,
      parser: (_) => null,
    );
  }

  Future<Map<String, dynamic>> getParkingLayout(String layoutId) async {
    return get<Map<String, dynamic>>(
      endpoint: '/layout/$layoutId',
      parser: (json) => json as Map<String, dynamic>,
    );
  }

  DashboardModel _generateMockDashboardData() {
    final random = Random();

    return DashboardModel(
      today: TodayStats(
        vehiclesAttended: random.nextInt(10),
        collection: 2450.0 + random.nextDouble() * 200,
        currentVehiclesInParking: 1 + random.nextInt(5),
      ),
      weekly: DashboardStats(
        vehiclesAttended: random.nextInt(50),
        collection: 14850.0 + random.nextDouble() * 500,
      ),
      monthly: DashboardStats(
        vehiclesAttended: random.nextInt(200),
        collection: 58320.0 + random.nextDouble() * 1000,
      ),
    );
  }
}
