import 'package:flutter_test/flutter_test.dart';

import 'package:parkar/services/booking_service.dart';
import 'package:parkar/models/booking_model.dart';

void main() {
  group('BookingService Tests', () {
    late BookingService bookingService;

    setUp(() {
      bookingService = BookingService();
    });

    group('ReservationCreateModel', () {
      test('should create a reservation model correctly', () {
        // Arrange
        final reservationModel = ReservationCreateModel(
          vehiclePlate: 'ABC123',
          vehicleType: 'car',
          vehicleColor: 'rojo',
          ownerName: 'Juan Pérez',
          ownerDocument: '12345678',
          ownerPhone: '+573001234567',
          startDate: '2024-01-15T10:00:00Z',
          duration: 2,
          notes: 'Reserva para reunión de trabajo',
        );

        // Assert
        expect(reservationModel.vehiclePlate, equals('ABC123'));
        expect(reservationModel.vehicleType, equals('car'));
        expect(reservationModel.vehicleColor, equals('rojo'));
        expect(reservationModel.ownerName, equals('Juan Pérez'));
        expect(reservationModel.ownerDocument, equals('12345678'));
        expect(reservationModel.ownerPhone, equals('+573001234567'));
        expect(reservationModel.startDate, equals('2024-01-15T10:00:00Z'));
        expect(reservationModel.duration, equals(2));
        expect(reservationModel.notes, equals('Reserva para reunión de trabajo'));
      });

      test('should convert to JSON correctly', () {
        // Arrange
        final reservationModel = ReservationCreateModel(
          vehiclePlate: 'ABC123',
          vehicleType: 'car',
          vehicleColor: 'rojo',
          ownerName: 'Juan Pérez',
          ownerDocument: '12345678',
          ownerPhone: '+573001234567',
          startDate: '2024-01-15T10:00:00Z',
          duration: 2,
          notes: 'Reserva para reunión de trabajo',
        );

        // Act
        final json = reservationModel.toJson();

        // Assert
        expect(json['vehiclePlate'], equals('ABC123'));
        expect(json['vehicleType'], equals('car'));
        expect(json['vehicleColor'], equals('rojo'));
        expect(json['ownerName'], equals('Juan Pérez'));
        expect(json['ownerDocument'], equals('12345678'));
        expect(json['ownerPhone'], equals('+573001234567'));
        expect(json['startDate'], equals('2024-01-15T10:00:00Z'));
        expect(json['duration'], equals(2));
        expect(json['notes'], equals('Reserva para reunión de trabajo'));
      });

      test('should handle minimal required fields', () {
        // Arrange
        final reservationModel = ReservationCreateModel(
          vehiclePlate: 'ABC123',
          startDate: '2024-01-15T10:00:00Z',
          duration: 2,
        );

        // Assert
        expect(reservationModel.vehiclePlate, equals('ABC123'));
        expect(reservationModel.startDate, equals('2024-01-15T10:00:00Z'));
        expect(reservationModel.duration, equals(2));
        expect(reservationModel.vehicleType, isNull);
        expect(reservationModel.vehicleColor, isNull);
        expect(reservationModel.ownerName, isNull);
        expect(reservationModel.ownerDocument, isNull);
        expect(reservationModel.ownerPhone, isNull);
        expect(reservationModel.spotId, isNull);
        expect(reservationModel.notes, isNull);
      });
    });

    group('Service Configuration', () {
      test('should have correct service instance', () {
        // Assert
        expect(bookingService, isA<BookingService>());
      });
    });
  });
}
