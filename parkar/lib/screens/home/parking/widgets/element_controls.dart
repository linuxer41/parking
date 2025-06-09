import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/parking_state.dart';
import '../models/enums.dart';
import '../models/parking_elements.dart';

/// Widget que muestra un panel inferior con tabs para agregar diferentes tipos de elementos
class ElementControlsPanel extends StatefulWidget {
  final Function(SpotType)? onAddSpot;
  final Function(SignageType)? onAddSignage;
  final Function(FacilityType)? onAddFacility;
  final VoidCallback? onSaveChanges;
  final VoidCallback? onCancelChanges;
  
  const ElementControlsPanel({
    Key? key,
    this.onAddSpot,
    this.onAddSignage,
    this.onAddFacility,
    this.onSaveChanges,
    this.onCancelChanges,
  }) : super(key: key);

  @override
  State<ElementControlsPanel> createState() => _ElementControlsPanelState();
}

class _ElementControlsPanelState extends State<ElementControlsPanel> {
  int _selectedElementTab = 0;
  
  @override
  Widget build(BuildContext context) {
    final parkingState = Provider.of<ParkingState>(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      constraints: const BoxConstraints(maxWidth: 650),
      height: 85,
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
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
                    height: 32,
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
                    height: 40,
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
                  // Botón de deshacer
                  _buildActionButton(
                    context, 
                    Icons.undo, 
                    'Deshacer', 
                    parkingState.historyManager.canUndo, 
                    () => parkingState.undoLastAction(),
                    colorScheme,
                  ),
                  
                  const SizedBox(width: 8),
                  
                  // Botón de rehacer
                  _buildActionButton(
                    context, 
                    Icons.redo, 
                    'Rehacer', 
                    parkingState.historyManager.canRedo, 
                    () => parkingState.redoLastAction(),
                    colorScheme,
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Botones de eliminar
                  _buildActionButton(
                    context, 
                    Icons.delete_outline, 
                    'Eliminar', 
                    parkingState.selectedElements.isNotEmpty, 
                    () => parkingState.removeSelectedElements(),
                    colorScheme,
                  ),
                  
                  const SizedBox(width: 32),
                  
                  // Botón de guardar (arriba)
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    height: 32,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: colorScheme.primary.withOpacity(0.5),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Material(
                      color: colorScheme.primary.withOpacity(0.1),
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
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.save,
                                size: 14,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  'Guardar',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: colorScheme.primary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
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
                        color: colorScheme.error.withOpacity(0.5),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Material(
                      color: colorScheme.error.withOpacity(0.1),
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
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.cancel,
                                size: 14,
                                color: colorScheme.error,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  'Cancelar',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: colorScheme.error,
                                  ),
                                  overflow: TextOverflow.ellipsis,
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
  Widget _buildElementsForSelectedTab([ColorScheme? colorScheme]) {
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
  Widget _buildSpotElements([ColorScheme? colorScheme]) {
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
  Widget _buildSignageElements([ColorScheme? colorScheme]) {
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
          Icons.trending_flat, 
          ElementProperties.signageVisuals[SignageType.path]!.color,
          'Vía', 
          () => widget.onAddSignage?.call(SignageType.path),
        ),
        _buildElementButton(
          Icons.info_outline, 
          ElementProperties.signageVisuals[SignageType.info]!.color,
          'Info', 
          () => widget.onAddSignage?.call(SignageType.info),
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
  Widget _buildFacilityElements([ColorScheme? colorScheme]) {
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
          Icons.payments_outlined, 
          ElementProperties.facilityVisuals[FacilityType.paymentStation]!.color,
          'Caja', 
          () => widget.onAddFacility?.call(FacilityType.paymentStation),
        ),
        _buildElementButton(
          Icons.electric_car, 
          ElementProperties.facilityVisuals[FacilityType.chargingStation]!.color,
          'Carga EV', 
          () => widget.onAddFacility?.call(FacilityType.chargingStation),
        ),
        _buildElementButton(
          Icons.security, 
          ElementProperties.facilityVisuals[FacilityType.securityPost]!.color,
          'Seguridad', 
          () => widget.onAddFacility?.call(FacilityType.securityPost),
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
          width: 60,
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
  
  /// Construye el botón de acción
  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    String tooltip,
    bool isEnabled,
    VoidCallback onPressed,
    [ColorScheme? colorScheme]
  ) {
    final iconColor = colorScheme?.onSurface ?? Colors.white;
    
    return Tooltip(
      message: tooltip,
      child: IconButton(
        icon: Icon(icon),
        color: iconColor.withOpacity(isEnabled ? 1.0 : 0.5),
        onPressed: isEnabled ? onPressed : null,
      ),
    );
  }
} 