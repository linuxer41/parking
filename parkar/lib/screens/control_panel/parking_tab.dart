import 'package:flutter/material.dart';
import '../../state/app_state.dart';
import '../../services/service_locator.dart';

class ParkingManagementTab extends StatelessWidget {
  final AppState _appState = ServiceLocator().getAppState();

  ParkingManagementTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final textTheme = theme.textTheme;

    return SingleChildScrollView(
      physics:
          const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sección de Mis Estacionamientos
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'Gestión de Estacionamientos',
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Lista de estacionamientos
          _buildParkingList(context, colorScheme, isDark, textTheme),

          const SizedBox(height: 24),

          // Botón para registrar nuevo estacionamiento
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => _showAddParkingDialog(context),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Registrar nuevo estacionamiento'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Sección de Administración
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'Administración',
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Opciones de administración
          _buildAdminOptionCard(
            context,
            icon: Icons.edit_note_rounded,
            title: 'Editar estacionamientos',
            subtitle: 'Modificar información y configuración',
            onTap: () => _showEditParkingDialog(context),
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),

          const SizedBox(height: 8),

          _buildAdminOptionCard(
            context,
            icon: Icons.monetization_on_outlined,
            title: 'Configurar tarifas',
            subtitle: 'Gestionar precios por tipo de vehículo',
            onTap: () => _showRatesConfigDialog(context),
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),

          const SizedBox(height: 8),

          _buildAdminOptionCard(
            context,
            icon: Icons.layers_outlined,
            title: 'Administrar áreas',
            subtitle: 'Añadir o modificar áreas del estacionamiento',
            onTap: () => _showManageLevelsDialog(context),
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
        ],
      ),
    );
  }

  // Widget para construir la lista de estacionamientos
  Widget _buildParkingList(BuildContext context, ColorScheme colorScheme,
      bool isDark, TextTheme textTheme) {
    // Estacionamientos de ejemplo (en una implementación real vendrían de la API)
    final parkings = [
      {
        'name': 'Parqueo Central',
        'address': 'Calle Principal #123',
        'isActive': true,
        'areas': [
          {'name': 'Área A - Planta principal', 'capacity': 120},
          {'name': 'Área B - Planta 1', 'capacity': 80},
          {'name': 'Área C - Sótano', 'capacity': 50},
        ],
        'rates': {
          'vehicle': 10.0,
          'motorcycle': 5.0,
          'truck': 20.0,
        }
      },
      {
        'name': 'Plaza Norte',
        'address': 'Av. Norte #456',
        'isActive': true,
        'areas': [
          {'name': 'Área Única', 'capacity': 200},
        ],
        'rates': {
          'vehicle': 8.0,
          'motorcycle': 4.0,
          'truck': 15.0,
        }
      },
      {
        'name': 'Estacionamiento Sur',
        'address': 'Calle Sur #789',
        'isActive': false,
        'areas': [
          {'name': 'Área Baja', 'capacity': 60},
          {'name': 'Área Alta', 'capacity': 40},
        ],
        'rates': {
          'vehicle': 12.0,
          'motorcycle': 6.0,
          'truck': 25.0,
        }
      },
    ];

    if (parkings.isEmpty) {
      return Card(
        elevation: 0,
        color: isDark ? colorScheme.surfaceContainerHighest : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: isDark ? Colors.white10 : Colors.black12,
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.local_parking_outlined,
                  size: 48,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  'No tienes estacionamientos registrados',
                  style: textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Registra tu primer estacionamiento con el botón de abajo',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: parkings.length,
      itemBuilder: (context, index) {
        final parking = parkings[index];
        final isActive = parking['isActive'] as bool;

        return Card(
          elevation: 0,
          color: isDark ? colorScheme.surfaceContainerHighest : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: isDark ? Colors.white10 : Colors.black12,
              width: 1,
            ),
          ),
          margin: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: () => _selectParking(context, parking),
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isActive
                          ? colorScheme.primary.withOpacity(0.1)
                          : colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.local_parking_rounded,
                        color: isActive
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          parking['name'] as String,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          parking['address'] as String,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Widget para construir tarjetas de opciones administrativas
  Widget _buildAdminOptionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    final isDark = colorScheme.brightness == Brightness.dark;

    return Card(
      elevation: 0,
      color: isDark ? colorScheme.surfaceContainerHighest : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isDark ? Colors.white10 : Colors.black12,
          width: 1,
        ),
      ),
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Método para seleccionar un estacionamiento
  void _selectParking(BuildContext context, Map<String, dynamic> parking) {
    // En una implementación real, se cargaría el estacionamiento seleccionado
    // _appState.setCurrentParking(parking);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Seleccionado: ${parking['name']}'),
        duration: const Duration(seconds: 1),
      ),
    );

    // Navegar de vuelta a la pantalla de estacionamiento
    Navigator.pop(context);
  }

  // Diálogo para añadir un nuevo estacionamiento
  void _showAddParkingDialog(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Controladores para los campos de texto
    final nameController = TextEditingController();
    final addressController = TextEditingController();
    final descriptionController = TextEditingController();

    // Controladores para las tarifas
    final vehicleRateController = TextEditingController(text: '10.0');
    final motorcycleRateController = TextEditingController(text: '5.0');
    final truckRateController = TextEditingController(text: '20.0');

    // Lista de áreas (inicialmente vacía)
    final List<Map<String, dynamic>> areas = [];

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            top: 16.0,
            left: 16.0,
            right: 16.0,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Registrar Nuevo Estacionamiento',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const Divider(),

                // Formulario para nuevo estacionamiento
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Información básica',
                    style: theme.textTheme.titleMedium,
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Nombre del estacionamiento',
                      prefixIcon: const Icon(Icons.local_parking),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: TextField(
                    controller: addressController,
                    decoration: InputDecoration(
                      labelText: 'Dirección',
                      prefixIcon: const Icon(Icons.location_on),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: TextField(
                    controller: descriptionController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Descripción',
                      prefixIcon: const Icon(Icons.description),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),

                // Sección de tarifas
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Tarifas por hora',
                    style: theme.textTheme.titleMedium,
                  ),
                ),

                // Tarifas en formato de grid
                Row(
                  children: [
                    // Vehículos
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.directions_car,
                                  size: 16,
                                  color: colorScheme.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Vehículos',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            TextField(
                              controller: vehicleRateController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                prefixText: '\$ ',
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 8,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Motocicletas
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.motorcycle,
                                  size: 16,
                                  color: colorScheme.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Motos',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            TextField(
                              controller: motorcycleRateController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                prefixText: '\$ ',
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 8,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Camiones
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.local_shipping,
                                  size: 16,
                                  color: colorScheme.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Camiones',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            TextField(
                              controller: truckRateController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                prefixText: '\$ ',
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 8,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Sección de áreas
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Áreas',
                        style: theme.textTheme.titleMedium,
                      ),
                      TextButton.icon(
                        onPressed: () {
                          _showAddAreaDialog(context, (newArea) {
                            setState(() {
                              areas.add(newArea);
                            });
                          });
                        },
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Agregar área'),
                      ),
                    ],
                  ),
                ),

                // Lista de áreas
                if (areas.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Center(
                      child: Text(
                        'No hay áreas registradas. Agrega al menos una área.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: areas.length,
                    itemBuilder: (context, index) {
                      final area = areas[index];
                      return Card(
                        elevation: 0,
                        color: theme.brightness == Brightness.dark
                            ? colorScheme.surfaceContainerLow
                            : colorScheme.surfaceContainerLowest,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: theme.brightness == Brightness.dark
                                ? Colors.white10
                                : Colors.black12,
                            width: 0.5,
                          ),
                        ),
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: colorScheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.grid_view_rounded,
                                    color: colorScheme.primary,
                                    size: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      area['name'] as String,
                                      style:
                                          theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      'Capacidad: ${area['capacity']} espacios',
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.delete_outline,
                                  size: 18,
                                  color: colorScheme.error,
                                ),
                                onPressed: () {
                                  setState(() {
                                    areas.removeAt(index);
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                const SizedBox(height: 24),

                FilledButton(
                  onPressed: () {
                    // Validar campos
                    if (nameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Ingrese un nombre para el estacionamiento'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      return;
                    }

                    if (addressController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Ingrese una dirección'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      return;
                    }

                    if (areas.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Agregue al menos un área'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      return;
                    }

                    try {
                      // Crear objeto de estacionamiento
                      final newParking = {
                        'name': nameController.text.trim(),
                        'address': addressController.text.trim(),
                        'description': descriptionController.text.trim(),
                        'isActive': true,
                        'areas': areas,
                        'rates': {
                          'vehicle': double.parse(vehicleRateController.text),
                          'motorcycle':
                              double.parse(motorcycleRateController.text),
                          'truck': double.parse(truckRateController.text),
                        }
                      };

                      // En una implementación real, guardar en la base de datos
                      // _appState.addParking(newParking);

                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Estacionamiento registrado correctamente'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: ${e.toString()}'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Registrar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Diálogo para añadir una nueva área
  void _showAddAreaDialog(
      BuildContext context, Function(Map<String, dynamic>) onAreaAdded) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Controladores
    final nameController = TextEditingController();
    final capacityController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar nueva área'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre del área',
                hintText: 'Ej: Área A - Planta principal',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: capacityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Capacidad (espacios)',
                hintText: 'Ej: 120',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ),
          FilledButton(
            onPressed: () {
              // Validar
              if (nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ingrese un nombre para el área'),
                    duration: Duration(seconds: 2),
                  ),
                );
                return;
              }

              int? capacity;
              try {
                capacity = int.parse(capacityController.text);
                if (capacity <= 0)
                  throw Exception('La capacidad debe ser mayor a 0');
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ingrese una capacidad válida'),
                    duration: Duration(seconds: 2),
                  ),
                );
                return;
              }

              // Crear objeto de área
              final newArea = {
                'name': nameController.text.trim(),
                'capacity': capacity,
              };

              // Llamar al callback
              onAreaAdded(newArea);

              Navigator.pop(context);
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  // Diálogo para editar estacionamientos
  void _showEditParkingDialog(BuildContext context) {
    // Implementación similar a _showAddParkingDialog pero con datos precargados
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Función en desarrollo'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  // Diálogo para configurar tarifas
  void _showRatesConfigDialog(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    // Estacionamientos para seleccionar
    final parkings = [
      {
        'name': 'Parqueo Central',
        'rates': {
          'vehicle': 10.0,
          'motorcycle': 5.0,
          'truck': 20.0,
        }
      },
      {
        'name': 'Plaza Norte',
        'rates': {
          'vehicle': 8.0,
          'motorcycle': 4.0,
          'truck': 15.0,
        }
      },
    ];

    // Estacionamiento seleccionado inicialmente
    Map<String, dynamic> selectedParking = parkings[0];

    // Controladores para los campos de texto
    final vehicleController = TextEditingController(
        text: (selectedParking['rates'] as Map)['vehicle'].toString());
    final motorcycleController = TextEditingController(
        text: (selectedParking['rates'] as Map)['motorcycle'].toString());
    final truckController = TextEditingController(
        text: (selectedParking['rates'] as Map)['truck'].toString());

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            top: 16.0,
            left: 16.0,
            right: 16.0,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Configurar Tarifas',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const Divider(),

                // Selector de estacionamiento
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Estacionamiento',
                    style: theme.textTheme.titleMedium,
                  ),
                ),

                // Dropdown para seleccionar estacionamiento
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: colorScheme.outline.withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<Map<String, dynamic>>(
                    value: selectedParking,
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: parkings.map((parking) {
                      return DropdownMenuItem<Map<String, dynamic>>(
                        value: parking,
                        child: Text(parking['name'] as String),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedParking = value;
                          // Actualizar controladores
                          vehicleController.text =
                              (selectedParking['rates'] as Map)['vehicle']
                                  .toString();
                          motorcycleController.text =
                              (selectedParking['rates'] as Map)['motorcycle']
                                  .toString();
                          truckController.text =
                              (selectedParking['rates'] as Map)['truck']
                                  .toString();
                        });
                      }
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // Configuración de tarifas
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Tarifas por hora',
                    style: theme.textTheme.titleMedium,
                  ),
                ),

                // Tarifa para vehículos
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.directions_car,
                            color: colorScheme.primary,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Vehículos',
                              style: textTheme.titleSmall,
                            ),
                            const SizedBox(height: 4),
                            TextField(
                              controller: vehicleController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                prefixText: '\$ ',
                                suffixText: ' / hora',
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Tarifa para motocicletas
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.motorcycle,
                            color: colorScheme.primary,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Motocicletas',
                              style: textTheme.titleSmall,
                            ),
                            const SizedBox(height: 4),
                            TextField(
                              controller: motorcycleController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                prefixText: '\$ ',
                                suffixText: ' / hora',
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Tarifa para camiones
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.local_shipping,
                            color: colorScheme.primary,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Camiones',
                              style: textTheme.titleSmall,
                            ),
                            const SizedBox(height: 4),
                            TextField(
                              controller: truckController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                prefixText: '\$ ',
                                suffixText: ' / hora',
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Botón para guardar
                FilledButton(
                  onPressed: () {
                    // Guardar cambios
                    try {
                      final rates = {
                        'vehicle': double.parse(vehicleController.text),
                        'motorcycle': double.parse(motorcycleController.text),
                        'truck': double.parse(truckController.text),
                      };

                      // En una implementación real, se guardarían las tarifas
                      // selectedParking['rates'] = rates;

                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tarifas actualizadas correctamente'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Error: Verifique los valores ingresados'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Guardar cambios'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Diálogo para administrar áreas
  void _showManageLevelsDialog(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    // Estacionamientos para seleccionar
    final parkings = [
      {
        'name': 'Parqueo Central',
        'areas': [
          {'name': 'Área A - Planta principal', 'capacity': 120},
          {'name': 'Área B - Planta 1', 'capacity': 80},
          {'name': 'Área C - Sótano', 'capacity': 50},
        ]
      },
      {
        'name': 'Plaza Norte',
        'areas': [
          {'name': 'Área Única', 'capacity': 200},
        ]
      },
    ];

    // Estacionamiento seleccionado inicialmente
    Map<String, dynamic> selectedParking = parkings[0];

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            top: 16.0,
            left: 16.0,
            right: 16.0,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Administrar Áreas',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const Divider(),

                // Selector de estacionamiento
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Estacionamiento',
                    style: theme.textTheme.titleMedium,
                  ),
                ),

                // Dropdown para seleccionar estacionamiento
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: colorScheme.outline.withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<Map<String, dynamic>>(
                    value: selectedParking,
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: parkings.map((parking) {
                      return DropdownMenuItem<Map<String, dynamic>>(
                        value: parking,
                        child: Text(parking['name'] as String),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedParking = value;
                        });
                      }
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // Lista de áreas del estacionamiento seleccionado
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Áreas',
                    style: theme.textTheme.titleMedium,
                  ),
                ),

                // Lista de áreas
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: (selectedParking['areas'] as List).length,
                  itemBuilder: (context, index) {
                    final area = (selectedParking['areas'] as List)[index]
                        as Map<String, dynamic>;

                    return Card(
                      elevation: 0,
                      color: theme.brightness == Brightness.dark
                          ? colorScheme.surfaceContainerHighest
                          : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: theme.brightness == Brightness.dark
                              ? Colors.white10
                              : Colors.black12,
                          width: 1,
                        ),
                      ),
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.grid_view_rounded,
                                  color: colorScheme.primary,
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    area['name'] as String,
                                    style: textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Capacidad: ${area['capacity']} espacios',
                                    style: textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 18),
                              onPressed: () {
                                // Implementar edición de área
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Función en desarrollo'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Botón para agregar nueva área
                OutlinedButton.icon(
                  onPressed: () {
                    // Implementar agregado de área
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Función en desarrollo'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Agregar nueva área'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Botón para cerrar
                FilledButton(
                  onPressed: () => Navigator.pop(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Cerrar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
