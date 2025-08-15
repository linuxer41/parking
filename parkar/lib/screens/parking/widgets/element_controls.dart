import 'package:flutter/material.dart';
// Remove unused imports
// import 'package:provider/provider.dart';
// import '../core/parking_state.dart';
import '../models/enums.dart';
import '../models/parking_elements.dart';
import 'dart:math' as math;

/// Widget que muestra un panel inferior con tabs para agregar diferentes tipos de elementos
class ElementControlsPanel extends StatefulWidget {
  final Function(SpotType)? onAddSpot;
  final Function(SignageType)? onAddSignage;
  final Function(FacilityType)? onAddFacility;
  final VoidCallback? onSaveChanges;
  final VoidCallback? onCancelChanges;

  const ElementControlsPanel({
    super.key,
    this.onAddSpot,
    this.onAddSignage,
    this.onAddFacility,
    this.onSaveChanges,
    this.onCancelChanges,
  });

  @override
  State<ElementControlsPanel> createState() => _ElementControlsPanelState();
}

class _ElementControlsPanelState extends State<ElementControlsPanel> {
  int _selectedElementTab = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Determinar si es móvil o tablet
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    // Calcular ancho máximo del contenedor
    final containerWidth = isMobile ? screenWidth : math.min(600.0, screenWidth);

    return Container(
      width: containerWidth,
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 8 : (screenWidth - containerWidth) / 2 + 8,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? colorScheme.surface.withOpacity(0.95)
            : colorScheme.surface.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Tabs superiores para seleccionar tipo de elemento
            SizedBox(
              height: 38,
              child: Row(
                children: [
                  Expanded(
                    child: _buildElementTab(
                      0,
                      'Espacios',
                      Icons.directions_car,
                      colorScheme.primary,
                    ),
                  ),
                  Expanded(
                    child: _buildElementTab(
                      1,
                      'Señales',
                      Icons.signpost,
                      colorScheme.secondary,
                    ),
                  ),
                  Expanded(
                    child: _buildElementTab(
                      2,
                      'Instalaciones',
                      Icons.elevator,
                      colorScheme.tertiary,
                    ),
                  ),
                ],
              ),
            ),

            // Elementos disponibles según el tab seleccionado
            SizedBox(
              height: 60,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                children: _buildElementsForSelectedTab(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Construcción de los tabs de categoría de elementos
  Widget _buildElementTab(int index, String title, IconData icon, Color color) {
    final isSelected = _selectedElementTab == index;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedElementTab = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        margin: const EdgeInsets.only(right: 4),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface.withOpacity(0.7),
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface.withOpacity(0.7),
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Construcción de los elementos según el tab seleccionado
  List<Widget> _buildElementsForSelectedTab() {
    switch (_selectedElementTab) {
      case 0: // Espacios
        return [
          _buildElementButton(
            Icons.pedal_bike,
            ElementProperties.spotVisuals[SpotType.bicycle]!.color,
            'Bicicleta',
            () => widget.onAddSpot?.call(SpotType.bicycle),
          ),
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
        ];
      case 1: // Señales
        return [
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
            ElementProperties.signageVisuals[SignageType.direction]!.color,
            'Dirección',
            () => widget.onAddSignage?.call(SignageType.direction),
          ),
          _buildElementButton(
            Icons.sync_alt,
            ElementProperties.signageVisuals[SignageType.bidirectional]!.color,
            'Bidireccional',
            () => widget.onAddSignage?.call(SignageType.bidirectional),
          ),
          _buildElementButton(
            Icons.do_not_disturb,
            ElementProperties.signageVisuals[SignageType.stop]!.color,
            'Pare',
            () => widget.onAddSignage?.call(SignageType.stop),
          ),
        ];
      case 2: // Instalaciones
        return [
          _buildElementButton(
            Icons.business,
            ElementProperties.facilityVisuals[FacilityType.office]!.color,
            'Caja',
            () => widget.onAddFacility?.call(FacilityType.office),
          ),
          _buildElementButton(
            Icons.wc,
            ElementProperties.facilityVisuals[FacilityType.bathroom]!.color,
            'Baño',
            () => widget.onAddFacility?.call(FacilityType.bathroom),
          ),
          _buildElementButton(
            Icons.local_cafe,
            ElementProperties.facilityVisuals[FacilityType.cafeteria]!.color,
            'Cafetería',
            () => widget.onAddFacility?.call(FacilityType.cafeteria),
          ),
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
            Icons.info_outline,
            ElementProperties.facilityVisuals[FacilityType.information]!.color,
            'Información',
            () => widget.onAddFacility?.call(FacilityType.information),
          ),
        ];
      default:
        return [];
    }
  }

  // Botón para agregar elemento
  Widget _buildElementButton(
      IconData icon, Color color, String label, VoidCallback onTap) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 70,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              border: Border.all(color: color.withOpacity(0.5), width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 10,
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
      ),
    );
  }
}
