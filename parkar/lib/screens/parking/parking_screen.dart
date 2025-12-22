import 'package:flutter/material.dart';
import 'package:parkar/models/parking_model.dart';
import 'package:parkar/screens/parking_map/core/parking_state.dart';
import 'package:parkar/screens/parking_map/core/parking_state_container.dart';
import 'package:parkar/services/parking_service.dart';
import 'package:parkar/state/app_state_container.dart';
import 'package:uuid/uuid.dart';

import 'parking_list_view.dart';
import 'parking_map_view.dart';

const uuid = Uuid();

/// Pantalla principal del sistema de parkeo
class ParkingScreen extends StatefulWidget {
  /// Flag para iniciar en modo edición automáticamente
  final bool startInEditMode;

  const ParkingScreen({super.key, this.startInEditMode = false});

  @override
  State<ParkingScreen> createState() => _ParkingScreenState();
}

class _ParkingScreenState extends State<ParkingScreen> {
  @override
  Widget build(BuildContext context) {
    final appState = AppStateContainer.of(context);
    final currentParking = appState.currentParking;

    print(
      'currentParking: $currentParking; selectedAreaId: ${appState.selectedAreaId}',
    );
    if (currentParking == null) return _buildLoadingPlaceholder();

    if (appState.selectedAreaId == null)
      appState.setCurrentArea(currentParking.areas!.first.id);
    return Builder(
      builder: (context) {
        if (currentParking.operationMode == ParkingOperationMode.list) {
          return ParkingListView(parking: currentParking);
        } else {
          return ParkingMapStateContainer(
            state: ParkingMapState(),
            child: ParkingMapView(parking: currentParking),
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

  Future<ParkingModelDetailed> _loadParking() async {
    final parkingService = AppStateContainer.di(
      context,
    ).resolve<ParkingService>();
    return await parkingService.getParkingById(uuid.v4());
  }
}
