import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:parkar/infinite_canvas/models/facility_object.dart';
import 'package:parkar/infinite_canvas/models/grid_object.dart';
import 'package:parkar/infinite_canvas/models/signage_object.dart';
import 'package:parkar/infinite_canvas/models/spot_object.dart';
import 'package:parkar/infinite_canvas/widgets/canvas.dart';
import 'package:parkar/infinite_canvas/widgets/canvas_controller.dart';
import 'package:parkar/models/entry_model.dart';
import 'package:parkar/services/level_service.dart';
import 'package:parkar/services/vehicle_service.dart';
import 'package:parkar/state/app_state_container.dart';

import '../../models/level_model.dart';
import '../../services/parking_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final InfiniteCanvasController controller = InfiniteCanvasController();
  bool _showFreeSpots = false;
  bool _is3DView = false;
  bool _isEditMode = false;
  final TextEditingController _searchSpotController = TextEditingController();
  final TextEditingController _searchPlateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller.onSelect = (object) {
      if (!controller.editMode && object is SpotObject) {
        _showSpotActionsBottomSheet(context, object);
      }
    };

    controller.onChanged = (changedObject) {};
  }

  // @override 
  // void didUpdateWidget(covariant DashboardScreen oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  //   if (oldWidget.level != level) {
  //     controller.clear();
  //     _addObjectsToCanvas(controller, level);
  //   }
  // }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appSate = AppStateContainer.of(context);
    final level = appSate.currentLevel;
    final currentParking = appSate.currentParking;
    final parkinService =
        AppStateContainer.di(context).resolve<ParkingService>();
    if (level == null) {
      return Scaffold(
        body: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Selecciona un parqueo'),
              const SizedBox(width: 16),
              TextButton(
                onPressed: () {
                  context.go('/init');
                },
                child: const Text('Seleccionar Parqueo'),
              ),
            ],
          ),
        ),
      );
    }

    // Agregar objetos al canvas
    _addObjectsToCanvas(controller, level);

    return Scaffold(
      body: Stack(
        children: [
          InfiniteCanvas(
            controller: controller,
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Container(
                margin: const EdgeInsets.only(top: 15),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          if (!_isEditMode) _buildFloorSelector(),
                          if (!_isEditMode) ...[
                            _buildToolButton(
                              icon: Icons.view_in_ar,
                              label: 'Vista 3D',
                              shortcut: 'Ctrl+3',
                              onPressed: _toggle3DView,
                            ),
                          ],
                          _buildToolButton(
                            icon: _isEditMode ? Icons.edit_off : Icons.edit,
                            label:
                                _isEditMode ? 'Salir edición' : 'Modo edición',
                            shortcut: 'Ctrl+E',
                            onPressed: _toggleEditMode,
                          ),
                          if (_isEditMode)
                            _buildToolButton(
                                icon: Icons.save,
                                label: 'Guardar',
                                shortcut: 'Ctrl+S',
                                onPressed: () async {
                                  final newLevel = await _saveChanges(level);
                                  appSate.setLevel(newLevel);
                                  setState(() {
                                    _isEditMode = false;
                                    controller.setEditMode(_isEditMode);
                                  });
                                  parkinService
                                      .getDetailed(currentParking!.id)
                                      .then((parking) {
                                    appSate.setParking(parking);
                                  });
                                }),
                        ],
                      ),
                    ),
                    if (!_isEditMode) ...[
                      TextField(
                        controller: _searchPlateController,
                        decoration: InputDecoration(
                          hintText: 'Buscar por placa...',
                          prefixIcon: const Icon(Icons.directions_car),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                        ),
                        onChanged: (value) {
                          // Lógica para buscar por placa
                        },
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (_isEditMode)
                      ValueListenableBuilder<int>(
                        valueListenable: controller.changesCountNotifier,
                        builder: (context, count, child) {
                          return Text(
                            'Objetos cambiados: $count',
                            style: const TextStyle(fontSize: 14),
                          );
                        },
                      ),
                    if (!_isEditMode)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Libres: ${_countFreeSpots(level.spots)}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Ocupados: ${_countOccupiedSpots(level.spots)}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Agregar objetos al canvas
  void _addObjectsToCanvas(
      InfiniteCanvasController controller, LevelModel level) {
    // Limpiar objetos existentes
    controller.clear();

    // Agregar spots
    for (var spot in level.spots) {
      controller.addGridObjectNode(SpotObject(
        id: spot.id,
        label: spot.name,
        position: Offset(spot.posX, spot.posY),
        isFree: spot.vehicleId == null,
        type: SpotObjectType.values[spot.spotType],
        category: SpotObjectCategory.values[spot.spotCategory],
      ));
    }

    // Agregar facilities
    for (var facility in level.facilities) {
      controller.addGridObjectNode(FacilityObject(
        id: facility.id,
        position: Offset(facility.posX, facility.posY),
        type: FacilityObjectType.values[facility.facilityType],
      ));
    }

    // Agregar señalizaciones
    for (var signage in level.signages) {
      controller.addGridObjectNode(SignageObject(
        id: signage.id,
        position: Offset(signage.posX, signage.posY),
        type: SignageObjectType.values[signage.signageType],
        direction: SignageObjectDirection.right,
      ));
    }
  }

  // Guardar cambios
  Future<LevelModel> _saveChanges(LevelModel level) async {
    final levelService = AppStateContainer.di(context).resolve<LevelService>();
    final objects = controller.objects;
    final spots = objects
        .whereType<SpotObject>()
        .map((object) => object)
        .map(
          (spot) => SpotModel(
            id: spot.id,
            name: spot.label,
            posX: spot.position.dx,
            posY: spot.position.dy,
            posZ: 0,
            rotation: spot.rotation,
            scale: spot.scale,
            vehicleId: spot.vehiclePlate ?? "",
            spotType: spot.type.index,
            spotCategory: spot.category.index,
          ),
        )
        .toList();
    final facilities = objects
        .whereType<FacilityObject>()
        .map((object) => object)
        .map(
          (facility) => FacilityModel(
            id: facility.id,
            name: facility.label,
            posX: facility.position.dx,
            posY: facility.position.dy,
            posZ: 0,
            rotation: facility.rotation,
            scale: facility.scale,
            facilityType: facility.type.index,
          ),
        )
        .toList();
    final signages = objects
        .whereType<SignageObject>()
        .map((object) => object)
        .map(
          (signage) => SignageModel(
            id: signage.id,
            posX: signage.position.dx,
            posY: signage.position.dy,
            posZ: 0,
            scale: signage.scale,
            rotation: signage.rotation,
            direction: signage.direction.index.toDouble(),
            signageType: signage.type.index,
          ),
        )
        .toList();

    final newLevel = LevelUpdateModel(
      name: DateTime.now().toIso8601String(),
      spots: spots,
      signages: signages,
      facilities: facilities,
    );
    return await levelService.update(level.id, newLevel);
  }

  void _handleAddChange(GridObject object) {
    // Lógica para manejar la adición de un objeto
    print("Objeto añadido: ${object.id}");
  }

  void _handleUpdateChange(GridObject object) {
    // Lógica para manejar la actualización de un objeto
    print("Objeto actualizado: ${object.id}");
  }

  void _handleDeleteChange(GridObject object) {
    // Lógica para manejar la eliminación de un objeto
    print("Objeto eliminado: ${object.id}");
  }

  // Contar spots libres
  int _countFreeSpots(List<SpotModel> spots) {
    return spots.where((spot) => spot.vehicleId == null).length;
  }

  // Contar spots ocupados
  int _countOccupiedSpots(List<SpotModel> spots) {
    return spots.where((spot) => spot.vehicleId != null).length;
  }

  // Alternar vista 3D
  void _toggle3DView() {
    setState(() {
      _is3DView = !_is3DView;
    });
    print('Cambiar a vista 3D: $_is3DView');
  }

  // Alternar modo edición
  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
    });
    controller.setEditMode(_isEditMode);
  }

  // Construir botón de herramientas
  Widget _buildToolButton({
    required IconData icon,
    required String label,
    required String shortcut,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      tooltip: shortcut,
    );
  }

  // Selector de piso
Widget _buildFloorSelector() {
  final appState = AppStateContainer.of(context);
  final currentParking = appState.currentParking!;
  final currentLevel = appState.currentLevel!;

  return ConstrainedBox(
    constraints: BoxConstraints(maxWidth: 200), // Establece el ancho máximo
    child: DropdownButton<String>(
      value: currentLevel.id,
      isExpanded: true, // Hace que el DropdownButton ocupe todo el ancho disponible
      menuMaxHeight: 300, // Establece una altura máxima para el menú desplegable
      items: currentParking.levels.map((level) {
        return DropdownMenuItem(
          value: level.id,
          child: Text(
            level.name,
            overflow: TextOverflow.ellipsis, // Agrega ellipsis en caso de overflow
            style: TextStyle(
              fontSize: 14, // Ajusta el tamaño de la fuente si es necesario
            ),
          ),
        );
      }).toList(),
      onChanged: (value) {
        final selectedLevel =
            currentParking.levels.firstWhere((level) => level.id == value);
        appState.setLevel(selectedLevel);
      },
    ),
  );
}
  // Mostrar acciones del spot
  void _showSpotActionsBottomSheet(
      BuildContext context, SpotObject spotObject) {
    final apiService = AppStateContainer.di(context).resolve<VehicleService>();
    if (spotObject.vehiclePlate != null) {
      apiService.getVehicleDetails(spotObject.vehiclePlate!).then((entry) {
        showModalBottomSheet(
          context: context,
          builder: (context) {
            return _buildBottomSheetWithVehicle(context, spotObject, entry);
          },
        );
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error al obtener detalles del vehículo: $error')),
        );
      });
    } else {
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return _buildBottomSheetWithoutVehicle(context, spotObject);
        },
      );
    }
  }

  // Bottom Sheet con vehículo
  Widget _buildBottomSheetWithVehicle(
      BuildContext context, SpotObject spotObject, EntryModel entry) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Vehículo: ${entry.vehicle.plate}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.print),
            title: const Text('Imprimir salida'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.calculate),
            title: const Text('Calcular costo'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.close),
            title: const Text('Cerrar'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  // Bottom Sheet sin vehículo
  Widget _buildBottomSheetWithoutVehicle(
      BuildContext context, SpotObject spotObject) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Asignar vehículo',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.directions_car),
            title: const Text('Asignar vehículo'),
            onTap: () {
              Navigator.pop(context);
              _showAssignVehicleDialog(context, spotObject);
            },
          ),
          ListTile(
            leading: const Icon(Icons.close),
            title: const Text('Cerrar'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  // Diálogo para asignar vehículo
  void _showAssignVehicleDialog(BuildContext context, SpotObject spotObject) {
    final plateController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Asignar vehículo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: plateController,
                decoration: const InputDecoration(
                  labelText: 'Placa del vehículo',
                  hintText: 'Ej: ABC123',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                final plate = plateController.text;
                if (plate.isNotEmpty) {
                  _assignVehicleToSpot(spotObject, plate);
                  Navigator.pop(context);
                }
              },
              child: const Text('Asignar'),
            ),
          ],
        );
      },
    );
  }

  // Asignar vehículo a un spot
  void _assignVehicleToSpot(SpotObject spotObject, String plate) {
    print('Vehículo $plate asignado al spot ${spotObject.label}');
  }
}
