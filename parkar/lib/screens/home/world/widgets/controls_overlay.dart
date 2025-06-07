import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/world_state.dart';
import '../models/parking_spot.dart';
import '../models/enums.dart';
import '../utils/export_utils.dart';
import '../models/world_elements.dart';
import 'parking_status_summary.dart';
import 'vehicle_search.dart';

/// Widget que muestra un overlay con controles para el mundo de estacionamiento
class ControlsOverlay extends StatefulWidget {
  final Function(double, double)? onCameraMove;
  final Function(ParkingSpot)? onSpotLocate;
  final Function(SpotType)? onAddSpot;
  final Function(SignageType)? onAddSignage;
  final Function(FacilityType)? onAddFacility;
  final bool isEditMode;
  final VoidCallback? onToggleEditMode;
  final VoidCallback? onSaveChanges;
  final VoidCallback? onCancelChanges;
  
  const ControlsOverlay({
    Key? key,
    this.onCameraMove,
    this.onSpotLocate,
    this.onAddSpot,
    this.onAddSignage,
    this.onAddFacility,
    this.isEditMode = false,
    this.onToggleEditMode,
    this.onSaveChanges,
    this.onCancelChanges,
  }) : super(key: key);

  @override
  State<ControlsOverlay> createState() => _ControlsOverlayState();
}

class _ControlsOverlayState extends State<ControlsOverlay> with SingleTickerProviderStateMixin {
  bool _showStatusPanel = false;
  bool _showSearchPanel = false;
  late AnimationController _animationController;
  late Animation<double> _panelAnimation;
  int _selectedElementTab = 0;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    
    _panelAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  void _toggleStatusPanel() {
    setState(() {
      _showStatusPanel = !_showStatusPanel;
      _showSearchPanel = false;
      
      if (_showStatusPanel) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }
  
  void _toggleSearchPanel() {
    setState(() {
      _showSearchPanel = !_showSearchPanel;
      _showStatusPanel = false;
      
      if (_showSearchPanel) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }
  
  void _exportData(BuildContext context) async {
    final state = Provider.of<WorldState>(context, listen: false);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Generando reporte CSV...'),
        duration: Duration(seconds: 1),
      ),
    );
    
    await ExportUtils.shareCSVReport(state);
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer<WorldState>(
      builder: (context, state, child) {
        return Stack(
          children: [
            // Panel flotante con resumen (aparece/desaparece con animación)
            if (_showStatusPanel || _showSearchPanel)
              Positioned(
                top: 20,
                right: 20,
                child: FadeTransition(
                  opacity: _panelAnimation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.2, 0),
                      end: Offset.zero,
                    ).animate(_panelAnimation),
                    child: _showStatusPanel 
                      ? const ParkingStatusSummary() 
                      : VehicleSearch(
                          onSpotFound: widget.onSpotLocate,
                        ),
                  ),
                ),
              ),
            
            // Barra de herramientas superior (derecha)
            Positioned(
              top: 20,
              right: 20,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Botón de estadísticas
                    Tooltip(
                      message: 'Estadísticas',
                      child: IconButton(
                        icon: Icon(
                          Icons.analytics_outlined,
                          color: _showStatusPanel 
                            ? Theme.of(context).colorScheme.primary 
                            : null,
                        ),
                        onPressed: _toggleStatusPanel,
                      ),
                    ),
                    
                    // Botón de búsqueda
                    Tooltip(
                      message: 'Buscar vehículo',
                      child: IconButton(
                        icon: Icon(
                          Icons.search,
                          color: _showSearchPanel 
                            ? Theme.of(context).colorScheme.primary 
                            : null,
                        ),
                        onPressed: _toggleSearchPanel,
                      ),
                    ),
                    
                    // Botón de exportar
                    Tooltip(
                      message: 'Exportar datos',
                      child: IconButton(
                        icon: const Icon(Icons.save_alt),
                        onPressed: () => _exportData(context),
                      ),
                    ),
                    
                    // Botón de ayuda
                    Tooltip(
                      message: 'Ayuda',
                      child: IconButton(
                        icon: const Icon(Icons.help_outline),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Ayuda'),
                              content: const Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('• Ver estadísticas de ocupación'),
                                  Text('• Buscar vehículos por placa'),
                                  Text('• Exportar datos en formato CSV'),
                                  Text('• Gestionar espacios de estacionamiento'),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('CERRAR'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Panel de elementos inferiores (tabs) - Solo visible en modo edición
            if (widget.isEditMode)
              _buildEditorBottomBar(state, context),
            
            // Panel de disponibilidad - Solo visible en modo normal
            if (!widget.isEditMode)
              _buildAvailabilityBottomBar(state, context),
          ],
        );
      },
    );
  }
  
  // Construcción de los tabs de categoría de elementos
  Widget _buildElementTab(int index, String title, IconData icon, Color color) {
    final isSelected = _selectedElementTab == index;
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedElementTab = index;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? color : Colors.transparent,
              width: 1.5,
            ),
          ),
          color: isSelected ? color.withOpacity(0.08) : Colors.transparent,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon, 
              color: isSelected ? color : Colors.grey,
              size: 16,
            ),
            const SizedBox(height: 1),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? color : Colors.grey,
                fontSize: 9,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Construcción de los elementos según el tab seleccionado
  Widget _buildElementsForSelectedTab() {
    switch (_selectedElementTab) {
      case 0: // Espacios
        return _buildSpotElements();
      case 1: // Señales
        return _buildSignageElements();
      case 2: // Instalaciones
        return _buildFacilityElements();
      default:
        return const SizedBox();
    }
  }
  
  // Elementos de tipo espacio de estacionamiento
  Widget _buildSpotElements() {
    return ListView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      children: [
        _buildElementButton(
          Icons.directions_car, 
          ElementProperties.spotVisuals[SpotType.vehicle]!.color,
          'Vehículo', 
          () => widget.onAddSpot?.call(SpotType.vehicle),
        ),
        _buildElementButton(
          Icons.motorcycle, 
          ElementProperties.spotVisuals[SpotType.motorcycle]!.color,
          'Moto', 
          () => widget.onAddSpot?.call(SpotType.motorcycle),
        ),
        _buildElementButton(
          Icons.local_shipping, 
          ElementProperties.spotVisuals[SpotType.truck]!.color,
          'Camión', 
          () => widget.onAddSpot?.call(SpotType.truck),
        ),
      ],
    );
  }
  
  // Elementos de tipo señalización
  Widget _buildSignageElements() {
    return ListView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      children: [
        _buildElementButton(
          Icons.login, 
          ElementProperties.signageVisuals[SignageType.entrance]!.color,
          'Entrada', 
          () => widget.onAddSignage?.call(SignageType.entrance),
        ),
        _buildElementButton(
          Icons.logout, 
          ElementProperties.signageVisuals[SignageType.exit]!.color,
          'Salida', 
          () => widget.onAddSignage?.call(SignageType.exit),
        ),
        _buildElementButton(
          Icons.do_not_disturb, 
          ElementProperties.signageVisuals[SignageType.noParking]!.color,
          'No Est.', 
          () => widget.onAddSignage?.call(SignageType.noParking),
        ),
        _buildElementButton(
          Icons.trending_flat, 
          ElementProperties.signageVisuals[SignageType.oneWay]!.color,
          'Una Vía', 
          () => widget.onAddSignage?.call(SignageType.oneWay),
        ),
        _buildElementButton(
          Icons.sync_alt, 
          ElementProperties.signageVisuals[SignageType.twoWay]!.color,
          'Doble Vía', 
          () => widget.onAddSignage?.call(SignageType.twoWay),
        ),
      ],
    );
  }
  
  // Elementos de tipo instalación
  Widget _buildFacilityElements() {
    return ListView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      children: [
        _buildElementButton(
          Icons.elevator, 
          ElementProperties.facilityVisuals[FacilityType.elevator]!.color,
          'Ascensor', 
          () => widget.onAddFacility?.call(FacilityType.elevator),
        ),
        _buildElementButton(
          Icons.stairs, 
          ElementProperties.facilityVisuals[FacilityType.stairs]!.color,
          'Escalera', 
          () => widget.onAddFacility?.call(FacilityType.stairs),
        ),
        _buildElementButton(
          Icons.wc, 
          ElementProperties.facilityVisuals[FacilityType.bathroom]!.color,
          'Baño', 
          () => widget.onAddFacility?.call(FacilityType.bathroom),
        ),
        _buildElementButton(
          Icons.point_of_sale, 
          ElementProperties.facilityVisuals[FacilityType.payStation]!.color,
          'Caja', 
          () => widget.onAddFacility?.call(FacilityType.payStation),
        ),
        _buildElementButton(
          Icons.security, 
          ElementProperties.facilityVisuals[FacilityType.securityOffice]!.color,
          'Seguridad', 
          () => widget.onAddFacility?.call(FacilityType.securityOffice),
        ),
      ],
    );
  }
  
  // Botón para agregar elemento
  Widget _buildElementButton(IconData icon, Color color, String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          width: 60, // Aún más reducido
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
          decoration: BoxDecoration(
            border: Border.all(color: color.withOpacity(0.5), width: 0.5),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(height: 1),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 8,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Barra inferior para modo edición
  Widget _buildEditorBottomBar(WorldState state, BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 650),
          height: 85, // Ajustado para coincidir con la barra de disponibilidad
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Sección de tabs (70% del ancho)
              Expanded(
                flex: 70,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    children: [
                      // Tabs superiores para seleccionar tipo de elemento
                      SizedBox(
                        height: 32, // Más compacto
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildElementTab(
                                0, 'Espacios', Icons.directions_car, 
                                ElementProperties.spacesTabColor,
                              ),
                            ),
                            Expanded(
                              child: _buildElementTab(
                                1, 'Señales', Icons.signpost, 
                                ElementProperties.signsTabColor,
                              ),
                            ),
                            Expanded(
                              child: _buildElementTab(
                                2, 'Instalaciones', Icons.elevator, 
                                ElementProperties.facilitiesTabColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Separador
                      const Divider(height: 6, thickness: 0.5),
                      
                      // Elementos disponibles según el tab seleccionado
                      SizedBox(
                        height: 40, // Ajustado para evitar overflow
                        child: _buildElementsForSelectedTab(),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Separador vertical
              const VerticalDivider(width: 1, thickness: 0.5, indent: 10, endIndent: 10),
              
              // Sección de acciones (30% del ancho)
              Expanded(
                flex: 30,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Botón de guardar (arriba)
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        height: 32,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Material(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(5),
                          child: InkWell(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Cambios guardados'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                              // Salir del modo edición
                              if (widget.onSaveChanges != null) {
                                widget.onSaveChanges!();
                              }
                            },
                            borderRadius: BorderRadius.circular(5),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.save,
                                    size: 14,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Guardar',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      // Botón de cancelar (abajo)
                      Container(
                        height: 32,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.red.withOpacity(0.5),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Material(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(5),
                          child: InkWell(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Cambios descartados'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                              // Salir del modo edición sin guardar
                              if (widget.onCancelChanges != null) {
                                widget.onCancelChanges!();
                              }
                            },
                            borderRadius: BorderRadius.circular(5),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.cancel,
                                    size: 14,
                                    color: Colors.red,
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    'Cancelar',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Panel de disponibilidad - Solo visible en modo normal (versión minimalista)
  Widget _buildAvailabilityBottomBar(WorldState state, BuildContext context) {
    // Calcular estadísticas por tipo de spot
    final spots = state.spots;
    
    // Totales generales
    final int totalSpots = spots.length;
    final int occupiedSpots = spots.where((spot) => spot.isOccupied).length;
    final int availableSpots = totalSpots - occupiedSpots;
    
    // Calcular por tipo
    final Map<SpotType, int> totalByType = {};
    final Map<SpotType, int> availableByType = {};
    
    for (final type in SpotType.values) {
      final typeSpots = spots.where((spot) => spot.type == type).length;
      final typeOccupied = spots.where((spot) => 
          spot.type == type && spot.isOccupied).length;
      
      totalByType[type] = typeSpots;
      availableByType[type] = typeSpots - typeOccupied;
    }
    
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 650),
          height: 85,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fila superior: Solo título y botón editar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Título a la izquierda
                  Text(
                    'Disponibilidad',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  // Botón editar a la derecha
                  ElevatedButton.icon(
                    onPressed: widget.onToggleEditMode,
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text(
                      'Editar',
                      style: TextStyle(fontSize: 11),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Fila inferior: Resumen total y desglose por tipo en el mismo nivel
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Resumen total de espacios
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, size: 12, color: Colors.green),
                            const SizedBox(width: 4),
                            Text(
                              '$availableSpots/$totalSpots libres',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.cancel, size: 12, color: Colors.red),
                            const SizedBox(width: 4),
                            Text(
                              '$occupiedSpots ocupados',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Separador vertical
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: SizedBox(
                          height: 24,
                          child: VerticalDivider(
                            width: 1,
                            thickness: 1,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      
                      // Desglose por tipo de vehículo
                      _buildSpotTypeIndicator(
                        context,
                        'Vehículos',
                        Icons.directions_car,
                        availableByType[SpotType.vehicle] ?? 0,
                        totalByType[SpotType.vehicle] ?? 0,
                        ElementProperties.spotVisuals[SpotType.vehicle]!.color,
                      ),
                      const SizedBox(width: 8),
                      _buildSpotTypeIndicator(
                        context,
                        'Motos',
                        Icons.motorcycle,
                        availableByType[SpotType.motorcycle] ?? 0,
                        totalByType[SpotType.motorcycle] ?? 0,
                        ElementProperties.spotVisuals[SpotType.motorcycle]!.color,
                      ),
                      const SizedBox(width: 8),
                      _buildSpotTypeIndicator(
                        context,
                        'Camiones',
                        Icons.local_shipping,
                        availableByType[SpotType.truck] ?? 0,
                        totalByType[SpotType.truck] ?? 0,
                        ElementProperties.spotVisuals[SpotType.truck]!.color,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Indicador minimalista para tipo de spot
  Widget _buildSpotTypeIndicator(
    BuildContext context,
    String label,
    IconData icon,
    int available,
    int total,
    Color color
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(16),
        color: color.withOpacity(0.05),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Row(
                children: [
                  Text(
                    '$available',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  Text(
                    '/$total',
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
} 