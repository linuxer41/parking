// AreaService eliminado - ahora está unificado en ParkingService
import '../services/auth_service.dart';
import '../services/booking_service.dart';
import '../services/cash_register_service.dart';
import '../services/employee_service.dart';
import '../services/entry_exit_service.dart';
import '../services/level_service.dart';
import '../services/movement_service.dart';
import '../services/parking_service.dart';
import '../services/print_service.dart';
import '../services/subscription_service.dart';
import '../services/user_service.dart';
import '../services/vehicle_service.dart';

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
    _dependencies[BookingService] = BookingService();
    _dependencies[EntryExitService] = EntryExitService();
    _dependencies[SubscriptionService] = SubscriptionService();

    // Register additional services
    _dependencies[EmployeeService] = EmployeeService();
    _dependencies[CashRegisterService] = CashRegisterService();
    _dependencies[PrintService] = PrintService();
    // AreaService eliminado - ahora está unificado en ParkingService
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
