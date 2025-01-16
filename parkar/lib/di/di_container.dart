
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../services/company_service.dart';
import '../services/employee_service.dart';
import '../services/parking_service.dart';
import '../services/level_service.dart';
import '../services/spot_service.dart';
import '../services/vehicle_service.dart';
import '../services/price_service.dart';
import '../services/subscriber_service.dart';
import '../services/subscription_plan_service.dart';
import '../services/entry_service.dart';
import '../services/exit_service.dart';
import '../services/cash_register_service.dart';
import '../services/movement_service.dart';
import '../services/reservation_service.dart';


class DIContainer {
  final Map<Type, Object> _dependencies = {};

  DIContainer() {
    
    _dependencies[UserService] = UserService();
    

    _dependencies[CompanyService] = CompanyService();
    

    _dependencies[EmployeeService] = EmployeeService();
    

    _dependencies[ParkingService] = ParkingService();
    

    _dependencies[LevelService] = LevelService();
    

    _dependencies[SpotService] = SpotService();
    

    _dependencies[VehicleService] = VehicleService();
    

    _dependencies[PriceService] = PriceService();
    

    _dependencies[SubscriberService] = SubscriberService();
    

    _dependencies[SubscriptionPlanService] = SubscriptionPlanService();
    

    _dependencies[EntryService] = EntryService();
    

    _dependencies[ExitService] = ExitService();
    

    _dependencies[CashRegisterService] = CashRegisterService();
    

    _dependencies[MovementService] = MovementService();
    

    _dependencies[ReservationService] = ReservationService();

    _dependencies[AuthService] = AuthService();
    
  }

  T resolve<T>() {
    final dependency = _dependencies[T];
    if (dependency == null) {
      throw Exception('Dependency of type $T not found');
    }
    return dependency as T;
  }
}
