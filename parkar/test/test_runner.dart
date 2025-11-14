import 'package:flutter_test/flutter_test.dart';

// Import all test files
import 'services/booking_service_test.dart' as booking_service_test;
import 'services/access_service_test.dart' as access_service_test;
import 'services/subscription_service_test.dart' as subscription_service_test;
import 'integration/api_integration_test.dart' as api_integration_test;

void main() {
  group('🚀 Parkar API Tests Suite', () {
    group('📋 Unit Tests', () {
      group('🔧 Booking Service Tests', () {
        booking_service_test.main();
      });

      group('🚗 Entry/Exit Service Tests', () {
        access_service_test.main();
      });

      group('📅 Subscription Service Tests', () {
        subscription_service_test.main();
      });
    });

    group('🔗 Integration Tests', () {
      group('🌐 API Integration Tests', () {
        api_integration_test.main();
      });
    });
  });
}
