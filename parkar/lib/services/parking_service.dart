import 'dart:convert';

import 'package:parkar/models/composite_models.dart';

import '_base_service.dart';
import '../models/parking_model.dart';
import '../models/level_model.dart';
import '../models/parking.dart';
import '../models/parking_area.dart';

class ParkingService
    extends BaseService<ParkingModel, ParkingCreateModel, ParkingUpdateModel> {
  ParkingService()
      : super(path: '/parking', fromJsonFactory: ParkingModel.fromJson);

  Future<ParkingCompositeModel> getDetailed(String parkingId) async {
    final uri = Uri.parse('$baseUrl$path/$parkingId/detailed');
    final response = await httpClient.get(
      uri,
      headers: buildHeaders(),
    );
    handleResponse(response);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return ParkingCompositeModel.fromJson(data);
  }

  Future<List<LevelModel>> getLevels(String parkingId) async {
    final uri = Uri.parse('$baseUrl$path/$parkingId/levels');
    final response = await httpClient.get(
      uri,
      headers: buildHeaders(),
    );
    handleResponse(response);
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((item) => LevelModel.fromJson(item)).toList();
  }

  Future<LevelModel> createLevel(
      String parkingId, LevelCreateModel model) async {
    final uri = Uri.parse('$baseUrl$path/$parkingId/levels');
    final response = await httpClient.post(
      uri,
      headers: buildHeaders(),
      body: jsonEncode(model.toJson()),
    );
    handleResponse(response);
    final data = jsonDecode(response.body);
    return LevelModel.fromJson(data);
  }

  /// Obtener estacionamientos del usuario actual
  Future<List<Parking>> getUserParkings() async {
    // Simulación de datos
    await Future.delayed(const Duration(milliseconds: 800));

    return [
      Parking(
        id: 1,
        name: 'Estacionamiento Central',
        address: 'Av. Principal 123',
        availableSpots: 45,
        occupiedSpots: 15,
        isOpen: true,
      ),
      Parking(
        id: 2,
        name: 'Plaza Norte',
        address: 'Calle Norte 456',
        availableSpots: 20,
        occupiedSpots: 30,
        isOpen: true,
      ),
      Parking(
        id: 3,
        name: 'Estacionamiento Sur',
        address: 'Av. Sur 789',
        availableSpots: 0,
        occupiedSpots: 25,
        isOpen: false,
      ),
    ];
  }

  /// Obtener un estacionamiento por su ID
  Future<Parking> getParkingById(int id) async {
    // Simulación de datos
    await Future.delayed(const Duration(milliseconds: 500));

    final parkings = await getUserParkings();
    final parking = parkings.firstWhere(
      (parking) => parking.id == id,
      orElse: () => throw Exception('Estacionamiento no encontrado'),
    );

    return parking;
  }

  /// Crear un nuevo estacionamiento
  Future<Parking> createParking(String name, String address) async {
    // Simulación de datos
    await Future.delayed(const Duration(milliseconds: 800));

    return Parking(
      id: DateTime.now().millisecondsSinceEpoch,
      name: name,
      address: address,
      availableSpots: 0,
      occupiedSpots: 0,
      isOpen: true,
    );
  }

  /// Actualizar información de un estacionamiento
  Future<Parking> updateParking(int id,
      {String? name, String? address, bool? isOpen}) async {
    // Simulación de datos
    await Future.delayed(const Duration(milliseconds: 500));

    final parking = await getParkingById(id);

    return Parking(
      id: parking.id,
      name: name ?? parking.name,
      address: address ?? parking.address,
      availableSpots: parking.availableSpots,
      occupiedSpots: parking.occupiedSpots,
      isOpen: isOpen ?? parking.isOpen,
    );
  }

  /// Obtener áreas de un estacionamiento
  Future<List<ParkingArea>> getParkingAreas(int parkingId) async {
    // Simulación de datos
    await Future.delayed(const Duration(milliseconds: 600));

    if (parkingId == 1) {
      return [
        ParkingArea(
          id: 1,
          parkingId: 1,
          name: 'Nivel 1',
          description: 'Planta baja',
          capacity: 30,
          occupiedSpots: 10,
          areaType: 'Cubierta',
        ),
        ParkingArea(
          id: 2,
          parkingId: 1,
          name: 'Nivel 2',
          description: 'Primera planta',
          capacity: 30,
          occupiedSpots: 5,
          areaType: 'Cubierta',
        ),
      ];
    } else if (parkingId == 2) {
      return [
        ParkingArea(
          id: 3,
          parkingId: 2,
          name: 'Zona A',
          description: 'Entrada principal',
          capacity: 25,
          occupiedSpots: 20,
          areaType: 'Descubierta',
        ),
        ParkingArea(
          id: 4,
          parkingId: 2,
          name: 'Zona B',
          description: 'Lateral',
          capacity: 25,
          occupiedSpots: 10,
          areaType: 'Descubierta',
        ),
      ];
    } else if (parkingId == 3) {
      return [
        ParkingArea(
          id: 5,
          parkingId: 3,
          name: 'Única',
          description: 'Todo el estacionamiento',
          capacity: 25,
          occupiedSpots: 25,
          areaType: 'Mixta',
        ),
      ];
    }

    return [];
  }

  /// Crear un área de estacionamiento
  Future<ParkingArea> createParkingArea(int parkingId, String name,
      String? description, int capacity, String? areaType) async {
    // Simulación de datos
    await Future.delayed(const Duration(milliseconds: 700));

    return ParkingArea(
      id: DateTime.now().millisecondsSinceEpoch,
      parkingId: parkingId,
      name: name,
      description: description,
      capacity: capacity,
      occupiedSpots: 0,
      areaType: areaType,
    );
  }

  /// Actualizar un área de estacionamiento
  Future<ParkingArea> updateParkingArea(int id,
      {String? name,
      String? description,
      int? capacity,
      String? areaType}) async {
    // Simulación de datos
    await Future.delayed(const Duration(milliseconds: 500));

    // Simulamos obtener el área actual
    final areas = await getParkingAreas(1);
    final area = areas.firstWhere(
      (area) => area.id == id,
      orElse: () => throw Exception('Área no encontrada'),
    );

    return ParkingArea(
      id: area.id,
      parkingId: area.parkingId,
      name: name ?? area.name,
      description: description ?? area.description,
      capacity: capacity ?? area.capacity,
      occupiedSpots: area.occupiedSpots,
      areaType: areaType ?? area.areaType,
    );
  }

  /// Eliminar un área de estacionamiento
  Future<bool> deleteParkingArea(int id) async {
    // Simulación de datos
    await Future.delayed(const Duration(milliseconds: 500));

    return true;
  }
}
