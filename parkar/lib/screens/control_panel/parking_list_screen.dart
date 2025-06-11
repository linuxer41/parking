import 'package:flutter/material.dart';
import 'responsive_detail_screen.dart';
import '../../models/parking.dart';
import '../../services/parking_service.dart';
import 'parking_design_screen.dart';
import 'parking_rates_screen.dart';
import 'parking_areas_screen.dart';

/// Pantalla para mostrar la lista de estacionamientos del usuario
class ParkingListScreen extends StatefulWidget {
  /// Constructor
  const ParkingListScreen({super.key});

  @override
  State<ParkingListScreen> createState() => _ParkingListScreenState();
}

class _ParkingListScreenState extends State<ParkingListScreen> {
  final ParkingService _parkingService = ParkingService();
  bool _isLoading = true;
  List<Parking> _parkings = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadParkings();
  }

  // Cargar la lista de estacionamientos
  Future<void> _loadParkings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final parkings = await _parkingService.getUserParkings();

      if (mounted) {
        setState(() {
          _parkings = parkings;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error al cargar estacionamientos: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  // Refrescar la lista de estacionamientos
  Future<void> _refreshParkings() async {
    await _loadParkings();
  }

  // Mostrar diálogo para crear o editar estacionamiento
  void _showParkingDialog({Parking? parking}) {
    final isEditing = parking != null;
    final nameController = TextEditingController(text: parking?.name ?? '');
    final addressController =
        TextEditingController(text: parking?.address ?? '');
    bool isOpen = parking?.isOpen ?? true;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
            isEditing ? 'Editar estacionamiento' : 'Nuevo estacionamiento'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del estacionamiento',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: 'Dirección',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              if (isEditing) ...[
                const SizedBox(height: 16),
                StatefulBuilder(
                  builder: (context, setState) => SwitchListTile(
                    title: const Text('Abierto'),
                    value: isOpen,
                    onChanged: (value) {
                      setState(() {
                        isOpen = value;
                      });
                    },
                  ),
                ),
              ],
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
                  addressController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Por favor completa todos los campos'),
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
                  // Actualizar estacionamiento existente
                  await _parkingService.updateParking(
                    parking!.id,
                    name: nameController.text,
                    address: addressController.text,
                    isOpen: isOpen,
                  );
                } else {
                  // Crear nuevo estacionamiento
                  await _parkingService.createParking(
                    nameController.text,
                    addressController.text,
                  );
                }

                // Recargar estacionamientos
                await _refreshParkings();

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isEditing
                          ? 'Estacionamiento actualizado'
                          : 'Estacionamiento creado'),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Contenido principal con la lista de estacionamientos
    final parkingListContent = RefreshIndicator(
      onRefresh: _refreshParkings,
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
                        onPressed: _loadParkings,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : _parkings.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.local_parking_outlined,
                            size: 48,
                            color: colorScheme.outline,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No tienes estacionamientos',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 32.0),
                            child: Text(
                              'Crea tu primer estacionamiento',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () => _showParkingDialog(),
                            child: const Text('Crear estacionamiento'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: _parkings.length,
                      itemBuilder: (context, index) {
                        final parking = _parkings[index];
                        return _buildParkingCard(context, parking);
                      },
                    ),
    );

    return ResponsiveDetailScreen(
      title: 'Mis Estacionamientos',
      body: parkingListContent,
      floatingActionButton: _parkings.isNotEmpty
          ? FloatingActionButton(
              onPressed: () => _showParkingDialog(),
              tooltip: 'Crear estacionamiento',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  // Construir tarjeta de estacionamiento
  Widget _buildParkingCard(BuildContext context, Parking parking) {
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
          // Encabezado del estacionamiento
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        parking.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        parking.address,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  parking.isOpen ? 'Abierto' : 'Cerrado',
                  style: TextStyle(
                    color: parking.isOpen
                        ? colorScheme.primary
                        : colorScheme.error,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Opciones de gestión
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Opción: Editar estacionamiento
                _buildActionButton(
                  context,
                  icon: Icons.edit_outlined,
                  label: 'Editar',
                  onTap: () => _showParkingDialog(parking: parking),
                ),

                // Opción: Áreas
                _buildActionButton(
                  context,
                  icon: Icons.map_outlined,
                  label: 'Áreas',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ParkingAreasScreen(
                          parkingId: parking.id,
                          parkingName: parking.name,
                        ),
                      ),
                    );
                  },
                ),

                // Opción: Tarifas
                _buildActionButton(
                  context,
                  icon: Icons.attach_money,
                  label: 'Tarifas',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ParkingRatesScreen(
                          parkingId: parking.id,
                          parkingName: parking.name,
                        ),
                      ),
                    );
                  },
                ),

                // Opción: Diseño
                _buildActionButton(
                  context,
                  icon: Icons.grid_on_outlined,
                  label: 'Diseño',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ParkingDesignScreen(
                          parkingId: parking.id,
                          parkingName: parking.name,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Construir botón de acción
  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: colorScheme.primary,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
