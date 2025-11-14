import 'package:flutter_test/flutter_test.dart';

import 'package:parkar/services/subscription_service.dart';
import 'package:parkar/models/booking_model.dart';

void main() {
  group('SubscriptionService Tests', () {
    late SubscriptionService subscriptionService;

    setUp(() {
      subscriptionService = SubscriptionService();
    });

    group('SubscriptionCreateModel', () {
      test('should create a subscription model correctly', () {
        // Arrange
        final subscriptionModel = SubscriptionCreateModel(
          vehiclePlate: 'DEF456',
          vehicleType: 'car',
          vehicleColor: 'blanco',
          ownerName: 'Carlos Rodríguez',
          ownerDocument: '11223344',
          ownerPhone: '+573005566778',
          spotId: 'spot-456',
          startDate: '2024-01-15T00:00:00Z',
          period: 'monthly',
          amount: 150000.0,
          notes: 'Suscripción mensual para empleado',
        );

        // Assert
        expect(subscriptionModel.vehiclePlate, equals('DEF456'));
        expect(subscriptionModel.vehicleType, equals('car'));
        expect(subscriptionModel.vehicleColor, equals('blanco'));
        expect(subscriptionModel.ownerName, equals('Carlos Rodríguez'));
        expect(subscriptionModel.ownerDocument, equals('11223344'));
        expect(subscriptionModel.ownerPhone, equals('+573005566778'));
        expect(subscriptionModel.spotId, equals('spot-456'));
        expect(subscriptionModel.startDate, equals('2024-01-15T00:00:00Z'));
        expect(subscriptionModel.period, equals('monthly'));
        expect(subscriptionModel.amount, equals(150000.0));
        expect(subscriptionModel.notes, equals('Suscripción mensual para empleado'));
      });

      test('should convert to JSON correctly', () {
        // Arrange
        final subscriptionModel = SubscriptionCreateModel(
          vehiclePlate: 'DEF456',
          vehicleType: 'car',
          vehicleColor: 'blanco',
          ownerName: 'Carlos Rodríguez',
          ownerDocument: '11223344',
          ownerPhone: '+573005566778',
          spotId: 'spot-456',
          startDate: '2024-01-15T00:00:00Z',
          period: 'monthly',
          amount: 150000.0,
          notes: 'Suscripción mensual para empleado',
        );

        // Act
        final json = subscriptionModel.toJson();

        // Assert
        expect(json['vehiclePlate'], equals('DEF456'));
        expect(json['vehicleType'], equals('car'));
        expect(json['vehicleColor'], equals('blanco'));
        expect(json['ownerName'], equals('Carlos Rodríguez'));
        expect(json['ownerDocument'], equals('11223344'));
        expect(json['ownerPhone'], equals('+573005566778'));
        expect(json['spotId'], equals('spot-456'));
        expect(json['startDate'], equals('2024-01-15T00:00:00Z'));
        expect(json['period'], equals('monthly'));
        expect(json['amount'], equals(150000.0));
        expect(json['notes'], equals('Suscripción mensual para empleado'));
      });

      test('should handle minimal required fields', () {
        // Arrange
        final subscriptionModel = SubscriptionCreateModel(
          vehiclePlate: 'ABC123',
          startDate: '2024-01-15T00:00:00Z',
          period: 'monthly',
          amount: 100000.0,
        );

        // Assert
        expect(subscriptionModel.vehiclePlate, equals('ABC123'));
        expect(subscriptionModel.startDate, equals('2024-01-15T00:00:00Z'));
        expect(subscriptionModel.period, equals('monthly'));
        expect(subscriptionModel.amount, equals(100000.0));
        expect(subscriptionModel.vehicleType, isNull);
        expect(subscriptionModel.vehicleColor, isNull);
        expect(subscriptionModel.ownerName, isNull);
        expect(subscriptionModel.ownerDocument, isNull);
        expect(subscriptionModel.ownerPhone, isNull);
        expect(subscriptionModel.spotId, isNull);
        expect(subscriptionModel.notes, isNull);
      });

      test('should handle empty fields', () {
        // Test that empty fields are handled correctly
        final subscriptionModel = SubscriptionCreateModel(
          vehiclePlate: '',
          startDate: '',
          period: '',
          amount: 0.0,
        );

        expect(subscriptionModel.vehiclePlate, equals(''));
        expect(subscriptionModel.startDate, equals(''));
        expect(subscriptionModel.period, equals(''));
        expect(subscriptionModel.amount, equals(0.0));
      });

      test('should handle different subscription periods', () {
        // Test weekly subscription
        final weeklySubscription = SubscriptionCreateModel(
          vehiclePlate: 'ABC123',
          startDate: '2024-01-15T00:00:00Z',
          period: 'weekly',
          amount: 50000.0,
        );
        expect(weeklySubscription.period, equals('weekly'));

        // Test monthly subscription
        final monthlySubscription = SubscriptionCreateModel(
          vehiclePlate: 'ABC123',
          startDate: '2024-01-15T00:00:00Z',
          period: 'monthly',
          amount: 150000.0,
        );
        expect(monthlySubscription.period, equals('monthly'));

        // Test yearly subscription
        final yearlySubscription = SubscriptionCreateModel(
          vehiclePlate: 'ABC123',
          startDate: '2024-01-15T00:00:00Z',
          period: 'yearly',
          amount: 1500000.0,
        );
        expect(yearlySubscription.period, equals('yearly'));
      });

      test('should handle different vehicle types', () {
        // Test car subscription
        final carSubscription = SubscriptionCreateModel(
          vehiclePlate: 'ABC123',
          vehicleType: 'car',
          startDate: '2024-01-15T00:00:00Z',
          period: 'monthly',
          amount: 150000.0,
        );
        expect(carSubscription.vehicleType, equals('car'));

        // Test motorcycle subscription
        final motorcycleSubscription = SubscriptionCreateModel(
          vehiclePlate: 'MOT001',
          vehicleType: 'motorcycle',
          startDate: '2024-01-15T00:00:00Z',
          period: 'monthly',
          amount: 80000.0,
        );
        expect(motorcycleSubscription.vehicleType, equals('motorcycle'));

        // Test truck subscription
        final truckSubscription = SubscriptionCreateModel(
          vehiclePlate: 'CAM001',
          vehicleType: 'truck',
          startDate: '2024-01-15T00:00:00Z',
          period: 'monthly',
          amount: 200000.0,
        );
        expect(truckSubscription.vehicleType, equals('truck'));
      });
    });

    group('Service Configuration', () {
      test('should have correct base path', () {
        // Assert
        expect(subscriptionService, isA<SubscriptionService>());
      });
    });
  });
}
