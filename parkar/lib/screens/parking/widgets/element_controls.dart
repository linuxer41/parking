import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/parking_state.dart';
import '../models/enums.dart';
import '../models/parking_elements.dart';
import '../../../services/parking_api_service.dart';

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
  final ParkingApiService _apiService = ParkingApiService();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Usar colores completamente sólidos
    final backgroundColor = theme.brightness == Brightness.dark
        ? Colors.grey[850]! // Color oscuro sólido
        : Colors.white; // Color claro sólido

    return Container(
      constraints: const BoxConstraints(maxWidth: 500),
      height: 95, // Ajustado a 95
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Column(
          children: [
            // Tabs superiores para seleccionar tipo de elemento
            SizedBox(
              height: 38, // Reducido de 40 a 38
              child: Row(
                children: [
                  Expanded(
                    child: _buildElementTab(
                      0,
                      'Espacios',
                      Icons.directions_car,
                      ElementProperties.spacesTabColor,
                    ),
                  ),
                  Expanded(
                    child: _buildElementTab(
                      1,
                      'Señales',
                      Icons.signpost,
                      ElementProperties.signsTabColor,
                    ),
                  ),
                  Expanded(
                    child: _buildElementTab(
                      2,
                      'Instalaciones',
                      Icons.elevator,
                      ElementProperties.facilitiesTabColor,
                    ),
                  ),
                ],
              ),
            ),

            // Elementos disponibles según el tab seleccionado (sin separador)
            Expanded(
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                    horizontal: 4, vertical: 4), // Reducido de 6 a 4
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

    // Colores completamente sólidos para los tabs
    final backgroundColor = isSelected
        ? (theme.brightness == Brightness.dark
            ? Colors.grey[800]! // Color oscuro sólido para tab seleccionado
            : Color.alphaBlend(color.withOpacity(0.2),
                Colors.white)) // Mezcla sólida para tema claro
        : (theme.brightness == Brightness.dark
            ? Colors.grey[900]! // Color oscuro sólido para tab no seleccionado
            : Colors.grey[50]!); // Color claro sólido para tab no seleccionado

    // Color del texto y el icono más visible cuando no está activo
    final textIconColor = isSelected
        ? color
        : theme.brightness == Brightness.dark
            ? Colors.grey[300]! // Gris más claro en modo oscuro
            : Colors.grey[800]!; // Gris más oscuro en modo claro

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
              width: 2.0,
            ),
          ),
          color: backgroundColor,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: textIconColor,
              size: 18,
            ),
            const SizedBox(height: 3), // Aumentado de 2 a 3
            Text(
              title,
              style: TextStyle(
                color: textIconColor,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
        ];
      case 2: // Instalaciones
        return [
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
            ElementProperties
                .facilityVisuals[FacilityType.paymentStation]!.color,
            'Caja',
            () => widget.onAddFacility?.call(FacilityType.paymentStation),
          ),
          _buildElementButton(
            Icons.electric_car,
            ElementProperties
                .facilityVisuals[FacilityType.chargingStation]!.color,
            'Carga EV',
            () => widget.onAddFacility?.call(FacilityType.chargingStation),
          ),
          _buildElementButton(
            Icons.security,
            ElementProperties.facilityVisuals[FacilityType.securityPost]!.color,
            'Seguridad',
            () => widget.onAddFacility?.call(FacilityType.securityPost),
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

    // Usar colores completamente sólidos para los botones
    final backgroundColor = theme.brightness == Brightness.dark
        ? Colors.grey[800]! // Color oscuro sólido
        : Color.alphaBlend(
            color.withOpacity(0.15), Colors.white); // Mezcla sólida

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(5),
        child: Container(
          width: 58, // Reducido de 60 a 58
          padding: const EdgeInsets.symmetric(
              horizontal: 4, vertical: 3), // Reducido el vertical de 4 a 3
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(color: color, width: 0.5),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 15), // Reducido de 16 a 15
              const SizedBox(height: 1),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 9,
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
}
