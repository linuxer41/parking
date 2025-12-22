import 'package:flutter/material.dart';
import 'package:parkar/models/parking_model.dart';
import 'package:parkar/screens/cash_register/cash_register_screen.dart';
import 'package:parkar/screens/parking/parking_info_panel.dart';
import 'package:parkar/parking_map/core/parking_state.dart';
import 'package:parkar/parking_map/core/parking_state_container.dart';
import 'package:parkar/parking_map/models/element_factory.dart';
import 'package:parkar/parking_map/models/enums.dart';
import 'package:parkar/parking_map/widgets/element_controls.dart';
import 'package:parkar/parking_map/widgets/parking_canvas.dart';
import 'package:parkar/parking_map/widgets/toolbar.dart';
import 'package:parkar/services/parking_service.dart';
import 'package:parkar/state/app_state_container.dart';

class ParkingMapView extends StatefulWidget {
  final ParkingDetailedModel parking;

  const ParkingMapView({super.key, required this.parking});

  @override
  State<ParkingMapView> createState() => _ParkingMapViewState();
}

class _ParkingMapViewState extends State<ParkingMapView> {
  late TextEditingController searchController;
  bool isLoading = true;
  AreaModel? currentArea;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (currentArea == null) {
      _loadData();
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final appState = AppStateContainer.of(context);
      final selectedAreaId = appState.selectedAreaId;

      currentArea = widget.parking.areas.firstWhere(
        (area) => area.id == selectedAreaId,
        orElse: () => widget.parking.areas.first,
      );
      final state = ParkingMapStateContainer.of(context);
      state.clear();
      
      for (final elementModel in currentArea!.elements) {
        final parkingElement = ElementFactory.createFromModel(elementModel);
        if (parkingElement != null) {
          state.addElement(parkingElement);
        }
      }
      print('currentArea: $currentArea; elements: ${currentArea!.elements}');
    } catch (e) {
      debugPrint('Error loading data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _onSearchChanged() {
    setState(() {
      searchQuery = searchController.text.toLowerCase();
      // TODO: Implement search filtering for map elements if needed
    });
  }


  void _showEditAreaNameDialog(AreaModel area) {
    final TextEditingController nameController = TextEditingController(
      text: area.name,
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar nombre del área'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Nombre del área'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                final newName = nameController.text.trim();
                if (newName.isNotEmpty && newName != area.name) {
                  // TODO: Implement area update
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Area update not implemented yet'),
                    ),
                  );
                }
                Navigator.of(context).pop();
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _showAddAreaDialog() {
    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Agregar nueva área'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Nombre del área'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isNotEmpty) {
                  // TODO: Implement area creation
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Area creation not implemented yet'),
                    ),
                  );
                }
                Navigator.of(context).pop();
              },
              child: const Text('Crear'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToCashRegister() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const CashRegisterScreen()));
  }

  void _onAreaChanged(String id) {
    final appState = AppStateContainer.of(context);
    appState.setCurrentArea(id);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _onAddSpot(SpotType type) {
    // TODO: Implement add spot
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Add spot $type not implemented yet')),
    );
  }

  void _onAddSignage(SignageType type) {
    // TODO: Implement add signage
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Add signage $type not implemented yet')),
    );
  }

  void _onAddFacility(FacilityType type) {
    // TODO: Implement add facility
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Add facility $type not implemented yet')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDarkMode = theme.brightness == Brightness.dark;

    final state = ParkingMapStateContainer.of(context);

    Widget buildParkingStatusPanel(
      ParkingMapState state,
      ThemeData theme,
      ColorScheme colorScheme,
    ) {
      return Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Estado del Parqueo',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatusItem(
                  'Total',
                  '${currentArea?.totalSpots ?? 0}',
                  colorScheme.primary,
                ),
                _buildStatusItem(
                  'Disponible',
                  '${currentArea?.availableSpots ?? 0}',
                  Colors.green,
                ),
                _buildStatusItem(
                  'Ocupado',
                  '${currentArea?.occupiedSpots ?? 0}',
                  Colors.red,
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Lienzo principal de dibujo del parkeo
            Builder(
              builder: (context) {
                return Stack(
                  children: [
                    // Canvas principal para dibujo
                    const ParkingCanvas(),

                    // Panel de información en la parte superior
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: SafeArea(
                        child: ParkingInfoPanel(
                          parking: widget.parking,
                          selectedAreaId: currentArea?.id ?? '',
                          onAreaChanged: _onAreaChanged,
                          searchController: searchController,
                          onSearchChanged: (String value) => _onSearchChanged(),
                          onCashPressed: _navigateToCashRegister,
                        ),
                      ),
                    ),
                    // Panel con información del estado del parking en la parte inferior
                    if (!state.isEditMode)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: SafeArea(
                          bottom: true,
                          child: buildParkingStatusPanel(
                            state,
                            theme,
                            colorScheme,
                          ),
                        ),
                      ),

                    // Panel de control de elementos en modo edición
                    if (state.isEditMode)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: SafeArea(
                          bottom: true,
                          child: Center(
                            child: ElementControlsPanel(
                              onAddSpot: _onAddSpot,
                              onAddSignage: _onAddSignage,
                              onAddFacility: _onAddFacility,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),

            // Pantalla de carga simplificada
            if (isLoading)
              Container(
                color: isDarkMode ? Colors.black87 : Colors.black54,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: colorScheme.primary),
                      const SizedBox(height: 16),
                      const Text(
                        'Cargando estacionamiento...',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Barra de herramientas vertical siempre al final para que esté por encima de todo
            const ParkingToolbar(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: color)),
      ],
    );
  }
}
