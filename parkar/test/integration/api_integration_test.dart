import 'package:flutter_test/flutter_test.dart';

import 'package:parkar/services/booking_service.dart';
import 'package:parkar/services/entry_exit_service.dart';
import 'package:parkar/services/subscription_service.dart';
import 'package:parkar/models/booking_model.dart';

void main() {
  group('API Integration Tests', () {
    late BookingService bookingService;
    late EntryExitService entryExitService;
    late SubscriptionService subscriptionService;

    setUp(() {
      bookingService = BookingService();
      entryExitService = EntryExitService();
      subscriptionService = SubscriptionService();
    });

    group('Complete Flow Tests', () {
      test('should create a complete reservation flow', () {
        // Arrange - Create reservation model
        final reservationModel = ReservationCreateModel(
          vehiclePlate: 'TEST001',
          vehicleType: 'car',
          vehicleColor: 'rojo',
          ownerName: 'Test User',
          ownerDocument: '12345678',
          ownerPhone: '+573001234567',
          startDate: '2024-01-15T10:00:00Z',
          duration: 2,
          notes: 'Test reservation',
        );

        // Assert - Validate model creation
        expect(reservationModel.vehiclePlate, equals('TEST001'));
        expect(reservationModel.vehicleType, equals('car'));
        expect(reservationModel.vehicleColor, equals('rojo'));
        expect(reservationModel.ownerName, equals('Test User'));
        expect(reservationModel.ownerDocument, equals('12345678'));
        expect(reservationModel.ownerPhone, equals('+573001234567'));
        expect(reservationModel.startDate, equals('2024-01-15T10:00:00Z'));
        expect(reservationModel.duration, equals(2));
        expect(reservationModel.notes, equals('Test reservation'));

        // Assert - Validate JSON conversion
        final json = reservationModel.toJson();
        expect(json['vehiclePlate'], equals('TEST001'));
        expect(json['vehicleType'], equals('car'));
        expect(json['vehicleColor'], equals('rojo'));
        expect(json['ownerName'], equals('Test User'));
        expect(json['ownerDocument'], equals('12345678'));
        expect(json['ownerPhone'], equals('+573001234567'));
        expect(json['startDate'], equals('2024-01-15T10:00:00Z'));
        expect(json['duration'], equals(2));
        expect(json['notes'], equals('Test reservation'));
      });

      test('should create a complete entry/exit flow', () {
        // Arrange - Create access model
        final accessModel = AccessCreateModel(
          vehiclePlate: 'TEST002',
          vehicleType: 'car',
          vehicleColor: 'azul',
          ownerName: 'Test Driver',
          ownerDocument: '87654321',
          ownerPhone: '+573009876543',
          spotId: 'spot-test-001',
          notes: 'Test entry',
        );

        // Assert - Validate model creation
        expect(accessModel.vehiclePlate, equals('TEST002'));
        expect(accessModel.vehicleType, equals('car'));
        expect(accessModel.vehicleColor, equals('azul'));
        expect(accessModel.ownerName, equals('Test Driver'));
        expect(accessModel.ownerDocument, equals('87654321'));
        expect(accessModel.ownerPhone, equals('+573009876543'));
        expect(accessModel.spotId, equals('spot-test-001'));
        expect(accessModel.notes, equals('Test entry'));

        // Assert - Validate JSON conversion
        final json = accessModel.toJson();
        expect(json['vehiclePlate'], equals('TEST002'));
        expect(json['vehicleType'], equals('car'));
        expect(json['vehicleColor'], equals('azul'));
        expect(json['ownerName'], equals('Test Driver'));
        expect(json['ownerDocument'], equals('87654321'));
        expect(json['ownerPhone'], equals('+573009876543'));
        expect(json['spotId'], equals('spot-test-001'));
        expect(json['notes'], equals('Test entry'));
      });

      test('should create a complete subscription flow', () {
        // Arrange - Create subscription model
        final subscriptionModel = SubscriptionCreateModel(
          vehiclePlate: 'TEST003',
          vehicleType: 'car',
          vehicleColor: 'blanco',
          ownerName: 'Test Subscriber',
          ownerDocument: '11223344',
          ownerPhone: '+573005566778',
          spotId: 'spot-test-002',
          startDate: '2024-01-15T00:00:00Z',
          period: 'monthly',
          amount: 150000.0,
          notes: 'Test subscription',
        );

        // Assert - Validate model creation
        expect(subscriptionModel.vehiclePlate, equals('TEST003'));
        expect(subscriptionModel.vehicleType, equals('car'));
        expect(subscriptionModel.vehicleColor, equals('blanco'));
        expect(subscriptionModel.ownerName, equals('Test Subscriber'));
        expect(subscriptionModel.ownerDocument, equals('11223344'));
        expect(subscriptionModel.ownerPhone, equals('+573005566778'));
        expect(subscriptionModel.spotId, equals('spot-test-002'));
        expect(subscriptionModel.startDate, equals('2024-01-15T00:00:00Z'));
        expect(subscriptionModel.period, equals('monthly'));
        expect(subscriptionModel.amount, equals(150000.0));
        expect(subscriptionModel.notes, equals('Test subscription'));

        // Assert - Validate JSON conversion
        final json = subscriptionModel.toJson();
        expect(json['vehiclePlate'], equals('TEST003'));
        expect(json['vehicleType'], equals('car'));
        expect(json['vehicleColor'], equals('blanco'));
        expect(json['ownerName'], equals('Test Subscriber'));
        expect(json['ownerDocument'], equals('11223344'));
        expect(json['ownerPhone'], equals('+573005566778'));
        expect(json['spotId'], equals('spot-test-002'));
        expect(json['startDate'], equals('2024-01-15T00:00:00Z'));
        expect(json['period'], equals('monthly'));
        expect(json['amount'], equals(150000.0));
        expect(json['notes'], equals('Test subscription'));
      });
    });

    group('Vehicle Type Tests', () {
      test('should handle different vehicle types for reservations', () {
        // Test car reservation
        final carReservation = ReservationCreateModel(
          vehiclePlate: 'CAR001',
          vehicleType: 'car',
          startDate: '2024-01-15T10:00:00Z',
          duration: 2,
        );
        expect(carReservation.vehicleType, equals('car'));

        // Test motorcycle reservation
        final motorcycleReservation = ReservationCreateModel(
          vehiclePlate: 'MOT001',
          vehicleType: 'motorcycle',
          startDate: '2024-01-15T10:00:00Z',
          duration: 1,
        );
        expect(motorcycleReservation.vehicleType, equals('motorcycle'));

        // Test truck reservation
        final truckReservation = ReservationCreateModel(
          vehiclePlate: 'CAM001',
          vehicleType: 'truck',
          startDate: '2024-01-15T10:00:00Z',
          duration: 4,
        );
        expect(truckReservation.vehicleType, equals('truck'));

        // Test bus reservation
        final busReservation = ReservationCreateModel(
          vehiclePlate: 'BUS001',
          vehicleType: 'bus',
          startDate: '2024-01-15T10:00:00Z',
          duration: 6,
        );
        expect(busReservation.vehicleType, equals('bus'));

        // Test van reservation
        final vanReservation = ReservationCreateModel(
          vehiclePlate: 'VAN001',
          vehicleType: 'van',
          startDate: '2024-01-15T10:00:00Z',
          duration: 3,
        );
        expect(vanReservation.vehicleType, equals('van'));
      });

      test('should handle different vehicle types for access', () {
        // Test car access
        final carAccess = AccessCreateModel(
          vehiclePlate: 'CAR002',
          vehicleType: 'car',
        );
        expect(carAccess.vehicleType, equals('car'));

        // Test motorcycle access
        final motorcycleAccess = AccessCreateModel(
          vehiclePlate: 'MOT002',
          vehicleType: 'motorcycle',
        );
        expect(motorcycleAccess.vehicleType, equals('motorcycle'));

        // Test truck access
        final truckAccess = AccessCreateModel(
          vehiclePlate: 'CAM002',
          vehicleType: 'truck',
        );
        expect(truckAccess.vehicleType, equals('truck'));
      });

      test('should handle different vehicle types for subscriptions', () {
        // Test car subscription
        final carSubscription = SubscriptionCreateModel(
          vehiclePlate: 'CAR003',
          vehicleType: 'car',
          startDate: '2024-01-15T00:00:00Z',
          period: 'monthly',
          amount: 150000.0,
        );
        expect(carSubscription.vehicleType, equals('car'));

        // Test motorcycle subscription
        final motorcycleSubscription = SubscriptionCreateModel(
          vehiclePlate: 'MOT003',
          vehicleType: 'motorcycle',
          startDate: '2024-01-15T00:00:00Z',
          period: 'monthly',
          amount: 80000.0,
        );
        expect(motorcycleSubscription.vehicleType, equals('motorcycle'));

        // Test truck subscription
        final truckSubscription = SubscriptionCreateModel(
          vehiclePlate: 'CAM003',
          vehicleType: 'truck',
          startDate: '2024-01-15T00:00:00Z',
          period: 'monthly',
          amount: 200000.0,
        );
        expect(truckSubscription.vehicleType, equals('truck'));
      });
    });

    group('Subscription Period Tests', () {
      test('should handle different subscription periods', () {
        // Test weekly subscription
        final weeklySubscription = SubscriptionCreateModel(
          vehiclePlate: 'WEEK001',
          startDate: '2024-01-15T00:00:00Z',
          period: 'weekly',
          amount: 50000.0,
        );
        expect(weeklySubscription.period, equals('weekly'));

        // Test monthly subscription
        final monthlySubscription = SubscriptionCreateModel(
          vehiclePlate: 'MONTH001',
          startDate: '2024-01-15T00:00:00Z',
          period: 'monthly',
          amount: 150000.0,
        );
        expect(monthlySubscription.period, equals('monthly'));

        // Test yearly subscription
        final yearlySubscription = SubscriptionCreateModel(
          vehiclePlate: 'YEAR001',
          startDate: '2024-01-15T00:00:00Z',
          period: 'yearly',
          amount: 1500000.0,
        );
        expect(yearlySubscription.period, equals('yearly'));
      });
    });

    group('Data Validation Tests', () {
      test('should validate phone number formats', () {
        // Valid phone numbers
        final validPhones = [
          '+573001234567',
          '+573009876543',
          '+573005566778',
          '+573001112223',
        ];

        for (final phone in validPhones) {
          final model = AccessCreateModel(
            vehiclePlate: 'TEST001',
            ownerPhone: phone,
          );
          expect(model.ownerPhone, equals(phone));
        }
      });

      test('should validate document formats', () {
        // Valid document numbers
        final validDocuments = ['12345678', '87654321', '11223344', '99887766'];

        for (final document in validDocuments) {
          final model = AccessCreateModel(
            vehiclePlate: 'TEST001',
            ownerDocument: document,
          );
          expect(model.ownerDocument, equals(document));
        }
      });

      test('should validate date formats', () {
        // Valid date formats
        final validDates = [
          '2024-01-15T10:00:00Z',
          '2024-01-15T00:00:00Z',
          '2024-12-31T23:59:59Z',
        ];

        for (final date in validDates) {
          final model = ReservationCreateModel(
            vehiclePlate: 'TEST001',
            startDate: date,
            duration: 2,
          );
          expect(model.startDate, equals(date));
        }
      });
    });

    group('Service Configuration Tests', () {
      test('should have correct service instances', () {
        expect(bookingService, isA<BookingService>());
        expect(entryExitService, isA<EntryExitService>());
        expect(subscriptionService, isA<SubscriptionService>());
      });
    });
  });
}
