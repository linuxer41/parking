// import 'dart:convert';
import '../config/app_config.dart';
import 'base_service.dart';
import '../models/reservation_model.dart';

/// Servicio para gestionar las reservas de espacios de estacionamiento
class ReservationService extends BaseService {
  ReservationService()
      : super(path: AppConfig.apiEndpoints['reservation'] ?? '/reservation');
  /// Registrar una nueva reserva
  Future<ReservationModel> registerReservation(ReservationCreateModel reservation) async {
    return post<ReservationModel>(
      endpoint: '/',
      body: reservation.toJson(),
      parser: (json) => ReservationModel.fromJson(json),
    );
  }

  /// Cancela una reserva
  Future<ReservationModel> cancelReservation(String id) async {
    return post<ReservationModel>(
      endpoint: '/$id/cancel',
      body: <String, dynamic>{},
      parser: (json) => ReservationModel.fromJson(json),
    );
  }
}
