import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:parkar/models/access_model.dart';
import 'package:parkar/models/parking_model.dart';
import 'package:parkar/screens/cash_register/cash_register_screen.dart';
import 'package:parkar/parking_map/widgets/access_list_table.dart';
import 'package:parkar/screens/parking/parking_info_panel.dart';
import 'package:parkar/services/access_service.dart';
import 'package:parkar/services/parking_service.dart';
import 'package:parkar/state/app_state_container.dart';

class ParkingListView extends StatefulWidget {
  final ParkingDetailedModel parking;

  const ParkingListView({super.key, required this.parking});

  @override
  State<ParkingListView> createState() => _ParkingListViewState();
}

class _ParkingListViewState extends State<ParkingListView> {
  late TextEditingController searchController;
  List<AccessModel> accesses = [];
  List<AccessModel> filteredAccesses = [];
  bool isLoading = true;
  AreaModel? currentArea;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    searchController.addListener(_onSearchChanged);
    _loadData();
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

      final accessService = AppStateContainer.di(
        context,
      ).resolve<AccessService>();
      accesses = await accessService.getAccesssByParking(widget.parking.id);
      _applySearchFilter();
    } catch (e) {
      debugPrint('Error loading data: $e');
      accesses = [];
      filteredAccesses = [];
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _onSearchChanged() {
    setState(() {
      searchQuery = searchController.text.toLowerCase();
      _applySearchFilter();
    });
  }

  void _applySearchFilter() {
    if (searchQuery.isEmpty) {
      filteredAccesses = List.from(accesses);
    } else {
      filteredAccesses = accesses.where((access) {
        return access.vehicle.plate.toLowerCase().contains(searchQuery) ||
            (access.vehicle.ownerName?.toLowerCase().contains(searchQuery) ??
                false);
      }).toList();
    }
  }

  Future<void> _onRefresh() async {
    await _loadData();
  }

  void _showVisualEntryDialog(BuildContext context, {String? initialPlate}) {
    // TODO: Implement visual entry dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Visual entry dialog not implemented yet')),
    );
  }

  void _onAccessAction(AccessModel access) {
    // TODO: Implement access action (show details or manage exit)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Access action for ${access.vehicle.plate}')),
    );
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
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          // Contenido principal
          SafeArea(
            child: Column(
              children: [
                // Panel superior con información del estacionamiento (fijo)
                ParkingInfoPanel(
                  parking: widget.parking,
                  selectedAreaId: currentArea?.id ?? '',
                  onAreaChanged: _onAreaChanged,
                  searchController: searchController,
                  onSearchChanged: (String value) => _onSearchChanged(),
                  onEditAreaName: _showEditAreaNameDialog,
                  onAddArea: _showAddAreaDialog,
                  onCashPressed: _navigateToCashRegister,
                ),

                // Panel sticky con botón de entrada
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 12.0,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.login, size: 20),
                      label: const Text(
                        'Registrar Entrada',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 1,
                      ),
                      onPressed: () => _showVisualEntryDialog(
                        context,
                        initialPlate: searchController.text.isNotEmpty
                            ? searchController.text
                            : null,
                      ),
                    ),
                  ),
                ),

                // Tabla de accesos con scroll interno
                Expanded(
                  child: AccessListTable(
                    accesses: filteredAccesses,
                    onRefresh: () async {
                      await _onRefresh();
                    },
                    isLoading: isLoading,
                    onAccessAction: _onAccessAction,
                    isSimpleMode: true,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Clase para pintar el fondo animado
class AnimatedBackgroundPainter extends CustomPainter {
  final double animation;
  final ColorScheme colorScheme;

  AnimatedBackgroundPainter({
    required this.animation,
    required this.colorScheme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Dibujar círculos animados
    for (int i = 0; i < 8; i++) {
      final angle = animation + (i * math.pi / 4);
      final radius = 50 + (i * 20);
      final x = size.width / 2 + math.cos(angle) * radius;
      final y = size.height / 2 + math.sin(angle) * radius;

      final circlePaint = Paint()
        ..color = colorScheme.primary.withValues(alpha: 0.02)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), 30 + (i * 5), circlePaint);
    }

    // Dibujar líneas onduladas
    final path = Path();
    final wavePaint = Paint()
      ..color = colorScheme.secondary.withValues(alpha: 0.02)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (int i = 0; i < 3; i++) {
      path.reset();
      path.moveTo(0, size.height * (0.2 + i * 0.3));

      for (double x = 0; x < size.width; x += 20) {
        final y =
            size.height * (0.2 + i * 0.3) +
            math.sin((x + animation * 50) / 50) * 20;
        path.lineTo(x, y);
      }

      canvas.drawPath(path, wavePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
