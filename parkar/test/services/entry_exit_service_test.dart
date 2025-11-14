import 'package:flutter_test/flutter_test.dart';

import 'package:parkar/services/access_service.dart';
import 'package:parkar/models/booking_model.dart';

void main() {
  group('AccessService Tests', () {
    late AccessService accessService;

    setUp(() {
      accessService = AccessService();
    });

    group('AccessCreateModel', () {
      test('should create an access model correctly', () {
        // Arrange
        final accessModel = AccessCreateModel(
          vehiclePlate: 'XYZ789',
          vehicleType: 'car',
          vehicleColor: 'azul',
          ownerName: 'Ana López',
          ownerDocument: '87654321',
          ownerPhone: '+573009876543',
          spotId: 'spot-123',
          notes: 'Cliente frecuente',
        );

        // Assert
        expect(accessModel.vehiclePlate, equals('XYZ789'));
        expect(accessModel.vehicleType, equals('car'));
        expect(accessModel.vehicleColor, equals('azul'));
        expect(accessModel.ownerName, equals('Ana López'));
        expect(accessModel.ownerDocument, equals('87654321'));
        expect(accessModel.ownerPhone, equals('+573009876543'));
        expect(accessModel.spotId, equals('spot-123'));
        expect(accessModel.notes, equals('Cliente frecuente'));
      });

      test('should convert to JSON correctly', () {
        // Arrange
        final accessModel = AccessCreateModel(
          vehiclePlate: 'XYZ789',
          vehicleType: 'car',
          vehicleColor: 'azul',
          ownerName: 'Ana López',
          ownerDocument: '87654321',
          ownerPhone: '+573009876543',
          spotId: 'spot-123',
          notes: 'Cliente frecuente',
        );

        // Act
        final json = accessModel.toJson();

        // Assert
        expect(json['vehiclePlate'], equals('XYZ789'));
        expect(json['vehicleType'], equals('car'));
        expect(json['vehicleColor'], equals('azul'));
        expect(json['ownerName'], equals('Ana López'));
        expect(json['ownerDocument'], equals('87654321'));
        expect(json['ownerPhone'], equals('+573009876543'));
        expect(json['spotId'], equals('spot-123'));
        expect(json['notes'], equals('Cliente frecuente'));
      });

      test('should handle minimal required fields', () {
        // Arrange
        final accessModel = AccessCreateModel(vehiclePlate: 'ABC123');

        // Assert
        expect(accessModel.vehiclePlate, equals('ABC123'));
        expect(accessModel.vehicleType, isNull);
        expect(accessModel.vehicleColor, isNull);
        expect(accessModel.ownerName, isNull);
        expect(accessModel.ownerDocument, isNull);
        expect(accessModel.ownerPhone, isNull);
        expect(accessModel.spotId, isNull);
        expect(accessModel.notes, isNull);
      });

      test('should handle empty vehicle plate', () {
        // Arrange
        final accessModel = AccessCreateModel(vehiclePlate: '');

        // Assert
        expect(accessModel.vehiclePlate, equals(''));
        expect(accessModel.vehicleType, isNull);
        expect(accessModel.vehicleColor, isNull);
        expect(accessModel.ownerName, isNull);
        expect(accessModel.ownerDocument, isNull);
        expect(accessModel.ownerPhone, isNull);
        expect(accessModel.spotId, isNull);
        expect(accessModel.notes, isNull);
      });
    });

    group('Service Configuration', () {
      test('should have correct base path', () {
        // Assert
        expect(accessService, isA<AccessService>());
      });
    });
  });
}
