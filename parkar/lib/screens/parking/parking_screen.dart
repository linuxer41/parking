import 'package:flutter/material.dart';
import 'package:parkar/models/parking_model.dart';
import 'package:parkar/parking_map/core/parking_state.dart';
import 'package:parkar/parking_map/core/parking_state_container.dart';
import 'package:parkar/services/parking_service.dart';
import 'package:parkar/state/app_state_container.dart';

import 'parking_list_view.dart';
import 'parking_map_view.dart';

/// Pantalla principal del sistema de parkeo
class ParkingScreen extends StatefulWidget {
  /// Flag para iniciar en modo edición automáticamente
  final bool startInEditMode;

  const ParkingScreen({super.key, this.startInEditMode = false});

  @override
  State<ParkingScreen> createState() => _ParkingScreenState();
}

class _ParkingScreenState extends State<ParkingScreen> {
   late ParkingService _parkingService;
  bool _isLoading = true;
  ParkingDetailedModel? _parking;
  String? _error;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _parkingService = AppStateContainer.di(context).resolve<ParkingService>();
    _loadParkingDetails();
  }


  Future<void> _loadParkingDetails() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final appState = AppStateContainer.of(context);
      final currentParking = appState.currentParking;

      if (currentParking == null) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _error = 'No hay estacionamiento seleccionado';
          });
        }
        return;
      }

      // Load full parking data like parking detail screen does
      final parking = await _parkingService
          .getParkingDetailed(currentParking.id)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('Tiempo de espera agotado'),
          );

      if (mounted) {
        setState(() {
          _parking = parking;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error al cargar datos del estacionamiento: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingPlaceholder();
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Text(_error!),
        ),
      );
    }

    if (_parking == null) {
      return _buildLoadingPlaceholder();
    }

    final appState = AppStateContainer.of(context);

    print(
      'parking: $_parking; selectedAreaId: ${appState.selectedAreaId}',
    );

    if (appState.selectedAreaId == null) {
      final areas = _parking!.areas;
      if (areas != null && areas.isNotEmpty) {
        appState.setCurrentArea(areas.first.id);
      }
    }

    return Builder(
      builder: (context) {
        if (_parking!.operationMode == ParkingOperationMode.list) {
          return ParkingListView(parking: _parking!);
        } else {
          return ParkingMapStateContainer(
            state: ParkingMapState(),
            child: ParkingMapView(parking: _parking!),
          );
        }
      },
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Cargando parqueo...',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

}
