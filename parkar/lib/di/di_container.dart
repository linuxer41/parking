import '../services/area_service.dart';
import '../services/auth_service.dart';
import '../services/cash_register_service.dart';
import '../services/employee_service.dart';
import '../services/level_service.dart';
import '../services/movement_service.dart';
import '../services/parking_service.dart';
import '../services/print_service.dart';
import '../services/reservation_service.dart';
import '../services/subscription_service.dart';
import '../services/user_service.dart';
import '../services/vehicle_service.dart';
import '../services/access_service.dart';

/// Dependency injection container
class DIContainer {
  final Map<Type, Object> _dependencies = {};

  DIContainer() {
    // Register core services
    _dependencies[AuthService] = AuthService();
    _dependencies[UserService] = UserService();

    // Register business services
    final parkingService = ParkingService();
    _dependencies[ParkingService] = parkingService;

    _dependencies[LevelService] = LevelService();
    _dependencies[VehicleService] = VehicleService();
    _dependencies[MovementService] = MovementService();
    _dependencies[ReservationService] = ReservationService();

    // Register additional services
    _dependencies[EmployeeService] = EmployeeService();
    _dependencies[SubscriptionService] = SubscriptionService();
    _dependencies[CashRegisterService] = CashRegisterService();
    _dependencies[PrintService] = PrintService();
    _dependencies[AccessService] = AccessService();
    _dependencies[AreaService] = AreaService();
  }

  /// Resolve a dependency by type
  T resolve<T>() {
    final dependency = _dependencies[T];
    if (dependency == null) {
      throw Exception('Dependency of type $T not found');
    }
    return dependency as T;
  }
}
