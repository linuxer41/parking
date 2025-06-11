import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'base_detail_screen.dart';
import '../../models/parking_area.dart';
import '../../services/parking_service.dart';

/// Pantalla para gestionar las áreas de un estacionamiento
class ParkingAreasScreen extends StatefulWidget {
  final int parkingId;
  final String parkingName;

  const ParkingAreasScreen({
    super.key,
    required this.parkingId,
    required this.parkingName,
  });

  @override
  State<ParkingAreasScreen> createState() => _ParkingAreasScreenState();
}

class _ParkingAreasScreenState extends State<ParkingAreasScreen> {
  final ParkingService _parkingService = ParkingService();
  bool _isLoading = true;
  List<ParkingArea> _areas = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAreas();
  }

  // Cargar áreas del estacionamiento
  Future<void> _loadAreas() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final areas = await _parkingService.getParkingAreas(widget.parkingId);

      if (mounted) {
        setState(() {
          _areas = areas;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error al cargar áreas: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  // Refrescar la lista de áreas
  Future<void> _refreshAreas() async {
    await _loadAreas();
  }

  // Mostrar diálogo para crear o editar un área
  void _showAreaDialog({ParkingArea? area}) {
    final isEditing = area != null;
    final nameController = TextEditingController(text: area?.name ?? '');
    final descriptionController =
        TextEditingController(text: area?.description ?? '');
    final capacityController =
        TextEditingController(text: area?.capacity.toString() ?? '');

    // Opciones para el tipo de área
    final areaTypes = [
      'Cubierta',
      'Descubierta',
      'Mixta',
      'VIP',
      'Discapacitados'
    ];
    String selectedAreaType = area?.areaType ?? areaTypes[0];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Editar área' : 'Nueva área'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del área',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción (opcional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: capacityController,
                decoration: const InputDecoration(
                  labelText: 'Capacidad (espacios)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
              const SizedBox(height: 16),
              StatefulBuilder(
                builder: (context, setState) => DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Tipo de área',
                    border: OutlineInputBorder(),
                  ),
                  value: selectedAreaType,
                  items: areaTypes
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedAreaType = value;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              // Validar campos
              if (nameController.text.isEmpty ||
                  capacityController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Por favor completa los campos requeridos'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                return;
              }

              // Convertir capacidad a entero
              final capacity = int.tryParse(capacityController.text) ?? 0;
              if (capacity <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('La capacidad debe ser mayor a 0'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                return;
              }

              Navigator.of(context).pop();

              // Mostrar indicador de carga
              setState(() {
                _isLoading = true;
              });

              try {
                if (isEditing) {
                  // Actualizar área existente
                  await _parkingService.updateParkingArea(
                    area!.id,
                    name: nameController.text,
                    description: descriptionController.text.isEmpty
                        ? null
                        : descriptionController.text,
                    capacity: capacity,
                    areaType: selectedAreaType,
                  );
                } else {
                  // Crear nueva área
                  await _parkingService.createParkingArea(
                    widget.parkingId,
                    nameController.text,
                    descriptionController.text.isEmpty
                        ? null
                        : descriptionController.text,
                    capacity,
                    selectedAreaType,
                  );
                }

                // Recargar áreas
                await _refreshAreas();

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text(isEditing ? 'Área actualizada' : 'Área creada'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                    _error = 'Error: ${e.toString()}';
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text(isEditing ? 'Actualizar' : 'Crear'),
          ),
        ],
      ),
    );
  }

  // Eliminar un área
  void _deleteArea(ParkingArea area) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar área'),
        content: Text(
            '¿Estás seguro de que deseas eliminar el área "${area.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(context).pop();

              // Mostrar indicador de carga
              setState(() {
                _isLoading = true;
              });

              try {
                await _parkingService.deleteParkingArea(area.id);
                await _refreshAreas();

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Área eliminada'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                    _error = 'Error: ${e.toString()}';
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BaseDetailScreen(
      title: 'Áreas de ${widget.parkingName}',
      body: RefreshIndicator(
        onRefresh: _refreshAreas,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32.0),
                          child: Text(
                            _error!,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _loadAreas,
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  )
                : _areas.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.map_outlined,
                              size: 48,
                              color: colorScheme.outline,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No hay áreas definidas',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 32.0),
                              child: Text(
                                'Crea áreas para organizar tu estacionamiento',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: () => _showAreaDialog(),
                              child: const Text('Crear área'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: _areas.length,
                        itemBuilder: (context, index) {
                          final area = _areas[index];
                          return _buildAreaCard(context, area);
                        },
                      ),
      ),
      floatingActionButton: _areas.isNotEmpty
          ? FloatingActionButton(
              onPressed: () => _showAreaDialog(),
              tooltip: 'Agregar área',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  // Construir tarjeta de área
  Widget _buildAreaCard(BuildContext context, ParkingArea area) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        area.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (area.description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          area.description!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            'Capacidad: ${area.capacity}',
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Tipo: ${area.areaType ?? "Estándar"}',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Botón de editar
                IconButton(
                  onPressed: () => _showAreaDialog(area: area),
                  icon: Icon(
                    Icons.edit_outlined,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                  tooltip: 'Editar',
                ),
                // Botón de eliminar
                IconButton(
                  onPressed: () => _deleteArea(area),
                  icon: Icon(
                    Icons.delete_outline,
                    color: colorScheme.error,
                    size: 20,
                  ),
                  tooltip: 'Eliminar',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
