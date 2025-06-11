import '_base_service.dart';
import '../models/reservation_model.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'notification_service.dart';
import '../models/level_model.dart';
import 'package:http/http.dart' as http;

class ReservationService extends BaseService<ReservationModel,
    ReservationCreateModel, ReservationUpdateModel> {
  ReservationService()
      : super(path: '/reservation', fromJsonFactory: ReservationModel.fromJson);

  final NotificationService _notificationService = NotificationService();

  // Obtener todas las reservas
  Future<List<ReservationModel>> getReservations() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$path'),
        headers: buildHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ReservationModel.fromJson(json)).toList();
      } else {
        throw Exception(
            'Error al obtener las reservas: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al obtener las reservas: $e');
    }
  }

  // Crear una nueva reserva
  Future<ReservationModel> createReservation(
      ReservationModel reservation) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$path'),
        headers: buildHeaders(),
        body: json.encode(reservation.toJson()),
      );

      if (response.statusCode == 201) {
        final ReservationModel createdReservation =
            ReservationModel.fromJson(json.decode(response.body));

        // Enviar notificación de confirmación
        await _notificationService.showLocalNotification(
          title: 'Reserva Confirmada',
          body: 'Tu reserva ha sido confirmada para ${reservation.startTime}',
        );

        // Programar recordatorio para 30 minutos antes
        final reminderTime =
            reservation.startTime.subtract(const Duration(minutes: 30));
        final now = DateTime.now();
        if (reminderTime.isAfter(now)) {
          // En una implementación real, esto podría usar un servicio de programación de tareas
          Future.delayed(reminderTime.difference(now), () {
            _notificationService.showLocalNotification(
              title: 'Recordatorio de Reserva',
              body:
                  'Tu reserva comienza en 30 minutos (${reservation.startTime})',
            );
          });
        }

        return createdReservation;
      } else {
        throw Exception('Error al crear la reserva: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al crear la reserva: $e');
    }
  }

  // Actualizar una reserva existente
  Future<ReservationModel> updateReservation(
      String id, ReservationModel reservation) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$path/$id'),
        headers: buildHeaders(),
        body: json.encode(reservation.toJson()),
      );

      if (response.statusCode == 200) {
        final ReservationModel updatedReservation =
            ReservationModel.fromJson(json.decode(response.body));
        return updatedReservation;
      } else {
        throw Exception(
            'Error al actualizar la reserva: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al actualizar la reserva: $e');
    }
  }

  // Cancelar una reserva
  Future<bool> cancelReservation(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$path/$id'),
        headers: buildHeaders(),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Error al cancelar la reserva: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al cancelar la reserva: $e');
    }
  }

  // Obtener una reserva por ID
  Future<ReservationModel> getReservation(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$path/$id'),
        headers: buildHeaders(),
      );

      if (response.statusCode == 200) {
        return ReservationModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Error al obtener la reserva: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al obtener la reserva: $e');
    }
  }

  // Obtener reservas por usuario
  Future<List<ReservationModel>> getReservationsByUser(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$path/user/$userId'),
        headers: buildHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ReservationModel.fromJson(json)).toList();
      } else {
        throw Exception(
            'Error al obtener las reservas del usuario: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al obtener las reservas del usuario: $e');
    }
  }

  // Obtener reservas por estacionamiento
  Future<List<ReservationModel>> getReservationsByParking(
      String parkingId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$path/parking/$parkingId'),
        headers: buildHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ReservationModel.fromJson(json)).toList();
      } else {
        throw Exception(
            'Error al obtener las reservas del estacionamiento: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al obtener las reservas del estacionamiento: $e');
    }
  }

  // Método para verificar disponibilidad de un espacio
  Future<bool> checkSpotAvailability(
      String spotId, DateTime startDate, DateTime endDate) async {
    try {
      final response = await httpClient.get(
        Uri.parse(
            '$baseUrl$path/check-availability?spotId=$spotId&startDate=${startDate.toIso8601String()}&endDate=${endDate.toIso8601String()}'),
        headers: buildHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['available'] == true;
      }

      return false;
    } catch (e) {
      debugPrint('Error checking spot availability: $e');
      return false;
    }
  }

  // Método para obtener espacios disponibles en un rango de fechas
  Future<List<SpotModel>> getAvailableSpots(
    String parkingId,
    String levelId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final response = await httpClient.get(
        Uri.parse(
            '$baseUrl$path/available-spots?parkingId=$parkingId&levelId=$levelId&startDate=${startDate.toIso8601String()}&endDate=${endDate.toIso8601String()}'),
        headers: buildHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => SpotModel.fromJson(item)).toList();
      }

      return [];
    } catch (e) {
      debugPrint('Error getting available spots: $e');
      return [];
    }
  }

  // Método para obtener estadísticas de reservas
  Future<Map<String, dynamic>> getReservationStats(String parkingId) async {
    try {
      final response = await httpClient.get(
        Uri.parse('$baseUrl$path/stats/$parkingId'),
        headers: buildHeaders(),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return {};
    } catch (e) {
      debugPrint('Error getting reservation stats: $e');
      return {};
    }
  }

  // Método para extender una reserva
  Future<ReservationModel?> extendReservation(
    String reservationId,
    DateTime newEndDate,
  ) async {
    try {
      final response = await httpClient.put(
        Uri.parse('$baseUrl$path/$reservationId/extend'),
        headers: buildHeaders(),
        body: jsonEncode({'endDate': newEndDate.toIso8601String()}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ReservationModel.fromJson(data);
      }

      return null;
    } catch (e) {
      debugPrint('Error extending reservation: $e');
      return null;
    }
  }
}
