import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vector_math/vector_math.dart' as vector_math;
import 'package:flame/components.dart';

import '../state/flame_state.dart';
import '../models/parking_spot.dart';
import '../models/parking_signage.dart';
import '../models/parking_facility.dart';

/// Widget de la barra de herramientas para el editor con Flame
class FlameToolbarWidget extends StatelessWidget {
  const FlameToolbarWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<FlameState>(
      builder: (context, state, _) {
        return Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Archivo
                  _buildMenuButton(
                    context,
                    'Archivo',
                    Icons.file_open,
                    [
                      _buildMenuItem(context, 'Nuevo', Icons.add, () {
                        // Crear nuevo proyecto
                      }),
                      _buildMenuItem(context, 'Abrir', Icons.folder_open, () {
                        // Abrir proyecto existente
                      }),
                      _buildMenuItem(context, 'Guardar', Icons.save, () {
                        // Guardar proyecto actual
                      }),
                      _buildMenuItem(context, 'Exportar', Icons.file_download, () {
                        // Exportar proyecto
                      }),
                    ],
                  ),

                  // Edición
                  _buildMenuButton(
                    context,
                    'Edición',
                    Icons.edit,
                    [
                      _buildMenuItem(context, 'Copiar', Icons.content_copy, () {
                        state.copySelectedElements();
                      }),
                      _buildMenuItem(context, 'Pegar', Icons.content_paste, () {
                        // Pegar en el centro de la pantalla
                        final centerPos = vector_math.Vector2(0, 0);
                        state.pasteElements(centerPos);
                      }),
                      _buildMenuItem(context, 'Eliminar', Icons.delete, () {
                        state.deleteSelectedElements();
                      }),
                      _buildMenuItem(context, 'Seleccionar todo', Icons.select_all, () {
                        for (final element in state.allElements) {
                          element.isSelected = true;
                          if (!state.selectedElements.contains(element)) {
                            state.selectedElements.add(element);
                          }
                        }
                        state.notifyListeners();
                      }),
                    ],
                  ),

                  // Ver
                  _buildMenuButton(
                    context,
                    'Ver',
                    Icons.visibility,
                    [
                      _buildMenuItem(context, 'Zoom +', Icons.zoom_in, () {
                        state.setZoom(state.zoom * 1.2);
                      }),
                      _buildMenuItem(context, 'Zoom -', Icons.zoom_out, () {
                        state.setZoom(state.zoom / 1.2);
                      }),
                      _buildMenuItem(context, 'Resetear vista', Icons.center_focus_strong, () {
                        state.setZoom(1.0);
                        state.moveCamera(vector_math.Vector2(-state.cameraPosition.x, -state.cameraPosition.y));
                      }),
                    ],
                  ),

                  const Spacer(),

                  // Información de selección
                  if (state.selectedElements.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: Text(
                        '${state.selectedElements.length} elemento${state.selectedElements.length > 1 ? 's' : ''} seleccionado${state.selectedElements.length > 1 ? 's' : ''}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              _buildElementsToolbar(context, state),
            ],
          ),
        );
      },
    );
  }

  /// Construye un botón de menú desplegable
  Widget _buildMenuButton(
    BuildContext context,
    String title,
    IconData icon,
    List<Widget> menuItems,
  ) {
    return PopupMenuButton<void>(
      offset: const Offset(0, 40),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 4),
            Text(title),
          ],
        ),
      ),
      itemBuilder: (context) {
        return [
          for (final item in menuItems)
            PopupMenuItem<void>(
              padding: EdgeInsets.zero,
              child: item,
            ),
        ];
      },
    );
  }

  /// Construye un elemento de menú
  Widget _buildMenuItem(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return ListTile(
      leading: Icon(icon, size: 20),
      title: Text(title),
      dense: true,
      onTap: () {
        Navigator.pop(context);
        onPressed();
      },
    );
  }

  /// Construye la barra de herramientas de elementos
  Widget _buildElementsToolbar(BuildContext context, FlameState state) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Sección de espacios de estacionamiento
          _buildToolbarSection(
            context,
            'Espacios',
            [
              _buildSpotButton(
                context,
                'Estándar',
                FlameSpotType.standard,
                Colors.blue.shade700,
                state,
              ),
              _buildSpotButton(
                context,
                'Discapacitados',
                FlameSpotType.disabled,
                Colors.indigo,
                state,
              ),
              _buildSpotButton(
                context,
                'Eléctrico',
                FlameSpotType.electric,
                Colors.green,
                state,
              ),
              _buildSpotButton(
                context,
                'Premium',
                FlameSpotType.premium,
                Colors.amber.shade700,
                state,
              ),
              _buildSpotButton(
                context,
                'Compacto',
                FlameSpotType.compact,
                Colors.cyan,
                state,
              ),
              _buildSpotButton(
                context,
                'Motocicleta',
                FlameSpotType.motorcycle,
                Colors.teal,
                state,
              ),
              _buildSpotButton(
                context,
                'Carga/Descarga',
                FlameSpotType.loading,
                Colors.deepOrange,
                state,
              ),
            ],
          ),

          const SizedBox(width: 16),

          // Sección de señalizaciones
          _buildToolbarSection(
            context,
            'Señales',
            [
              _buildSignageButton(
                context,
                'No Estacionar',
                FlameSignageType.noParking,
                Colors.red.shade700,
                state,
              ),
              _buildSignageButton(
                context,
                'Reservado',
                FlameSignageType.reserved,
                Colors.blue.shade700,
                state,
              ),
              _buildSignageButton(
                context,
                'Salida',
                FlameSignageType.exit,
                Colors.green,
                state,
              ),
              _buildSignageButton(
                context,
                'Entrada',
                FlameSignageType.entrance,
                Colors.green.shade700,
                state,
              ),
              _buildSignageButton(
                context,
                'Stop',
                FlameSignageType.stop,
                Colors.red,
                state,
              ),
              _buildSignageButton(
                context,
                'Ceda',
                FlameSignageType.yield,
                Colors.amber.shade700,
                state,
              ),
            ],
          ),

          const SizedBox(width: 16),

          // Sección de instalaciones
          _buildToolbarSection(
            context,
            'Instalaciones',
            [
              _buildFacilityButton(
                context,
                'Pago',
                FlameFacilityType.payment,
                Colors.green.shade700,
                state,
              ),
              _buildFacilityButton(
                context,
                'Ascensor',
                FlameFacilityType.elevator,
                Colors.blue.shade700,
                state,
              ),
              _buildFacilityButton(
                context,
                'Escaleras',
                FlameFacilityType.stairs,
                Colors.orange,
                state,
              ),
              _buildFacilityButton(
                context,
                'Baños',
                FlameFacilityType.restroom,
                Colors.indigo,
                state,
              ),
              _buildFacilityButton(
                context,
                'Oficina',
                FlameFacilityType.office,
                Colors.brown,
                state,
              ),
              _buildFacilityButton(
                context,
                'Carga',
                FlameFacilityType.charging,
                Colors.teal,
                state,
              ),
              _buildFacilityButton(
                context,
                'Seguridad',
                FlameFacilityType.security,
                Colors.red.shade700,
                state,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Construye una sección de la barra de herramientas
  Widget _buildToolbarSection(
    BuildContext context,
    String title,
    List<Widget> buttons,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Row(
          children: buttons,
        ),
      ],
    );
  }

  /// Construye un botón para añadir un espacio de estacionamiento
  Widget _buildSpotButton(
    BuildContext context,
    String tooltip,
    FlameSpotType type,
    Color color,
    FlameState state,
  ) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: () {
          _addParkingSpot(state, type);
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.8),
            borderRadius: BorderRadius.circular(4),
          ),
          width: 40,
          height: 40,
          child: const Icon(
            Icons.local_parking,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }

  /// Construye un botón para añadir una señalización
  Widget _buildSignageButton(
    BuildContext context,
    String tooltip,
    FlameSignageType type,
    Color color,
    FlameState state,
  ) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: () {
          _addSignage(state, type);
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.8),
            borderRadius: BorderRadius.circular(4),
          ),
          width: 40,
          height: 40,
          child: const Icon(
            Icons.traffic,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }

  /// Construye un botón para añadir una instalación
  Widget _buildFacilityButton(
    BuildContext context,
    String tooltip,
    FlameFacilityType type,
    Color color,
    FlameState state,
  ) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: () {
          _addFacility(state, type);
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.8),
            borderRadius: BorderRadius.circular(4),
          ),
          width: 40,
          height: 40,
          child: const Icon(
            Icons.business,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }

  /// Añade un nuevo espacio de estacionamiento
  void _addParkingSpot(FlameState state, FlameSpotType type) {
    // Generar un ID único para el nuevo elemento
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    
    // Crear el elemento en el centro de la vista
    final spot = FlameSpot(
      id: id,
      position: vector_math.Vector2(0, 0), // Posición inicial
      size: Vector2(60, 100), // Tamaño predeterminado
      spotType: type,
      label: 'Spot-$id', // Etiqueta predeterminada
    );
    
    // Añadir el elemento al estado
    state.addSpot(spot);
  }

  /// Añade una nueva señalización
  void _addSignage(FlameState state, FlameSignageType type) {
    // Generar un ID único para el nuevo elemento
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    
    // Crear el elemento en el centro de la vista
    final signage = FlameSignage(
      id: id,
      position: vector_math.Vector2(0, 0), // Posición inicial
      size: Vector2(40, 40), // Tamaño predeterminado
      signageType: type,
      label: 'Sign-$id', // Etiqueta predeterminada
    );
    
    // Añadir el elemento al estado
    state.addSignage(signage);
  }

  /// Añade una nueva instalación
  void _addFacility(FlameState state, FlameFacilityType type) {
    // Generar un ID único para el nuevo elemento
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    
    // Crear el elemento en el centro de la vista
    final facility = FlameFacility(
      id: id,
      position: vector_math.Vector2(0, 0), // Posición inicial
      size: Vector2(70, 70), // Tamaño predeterminado
      facilityType: type,
      label: 'Facility-$id', // Etiqueta predeterminada
    );
    
    // Añadir el elemento al estado
    state.addFacility(facility);
  }
} 