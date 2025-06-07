import 'package:flutter/material.dart';
import '../game_objects/parking_spot.dart';
import '../game_objects/signage.dart';
import '../game_objects/facility.dart';
import '../parking_screen.dart';

/// Editor controls widget for the parking system
class EditorControls extends StatelessWidget {
  // Current editor mode
  final EditorMode editorMode;
  
  // Callbacks
  final Function(EditorMode) onModeChanged;
  final Function(SpotType, {SpotCategory? category}) onAddSpot;
  final Function(SignageType) onAddSignage;
  final Function(FacilityType) onAddFacility;
  final VoidCallback? onDelete;
  final VoidCallback? onRotate;
  final VoidCallback? onDuplicate;
  
  const EditorControls({
    Key? key,
    required this.editorMode,
    required this.onModeChanged,
    required this.onAddSpot,
    required this.onAddSignage,
    required this.onAddFacility,
    this.onDelete,
    this.onRotate,
    this.onDuplicate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Material(
        elevation: 4,
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildModeToggle(),
            
            // Show appropriate tools based on mode
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: editorMode == EditorMode.free
                  ? _buildCreationTools()
                  : _buildSelectionTools(),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Build the mode toggle buttons
  Widget _buildModeToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        children: [
          const Text(
            'Modo:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 16),
          
          // Free placement mode
          _buildModeButton(
            icon: Icons.add_box,
            label: 'Crear',
            isSelected: editorMode == EditorMode.free,
            onPressed: () => onModeChanged(EditorMode.free),
          ),
          
          const SizedBox(width: 8),
          
          // Selection mode
          _buildModeButton(
            icon: Icons.select_all,
            label: 'Seleccionar',
            isSelected: editorMode == EditorMode.selection,
            onPressed: () => onModeChanged(EditorMode.selection),
          ),
        ],
      ),
    );
  }
  
  /// Build a mode toggle button
  Widget _buildModeButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      icon: Icon(
        icon,
        size: 18,
        color: isSelected ? Colors.white : Colors.grey[700],
      ),
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.grey[700],
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.blue : Colors.grey[200],
        foregroundColor: isSelected ? Colors.white : Colors.grey[700],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: onPressed,
    );
  }
  
  /// Build creation tools for free placement mode
  Widget _buildCreationTools() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Parking spots creation section
          _buildSectionHeader('Espacios de estacionamiento'),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                _buildSpotButton(
                  icon: Icons.directions_car,
                  label: 'Auto',
                  color: Colors.blue,
                  onPressed: () => onAddSpot(SpotType.vehicle),
                ),
                _buildSpotButton(
                  icon: Icons.motorcycle,
                  label: 'Moto',
                  color: Colors.green,
                  onPressed: () => onAddSpot(SpotType.motorcycle),
                ),
                _buildSpotButton(
                  icon: Icons.local_shipping,
                  label: 'Camión',
                  color: Colors.orange,
                  onPressed: () => onAddSpot(SpotType.truck),
                ),
                
                // Category variants
                const SizedBox(width: 16),
                const VerticalDivider(),
                const SizedBox(width: 16),
                
                _buildSpotButton(
                  icon: Icons.accessible,
                  label: 'Discapacitados',
                  color: Colors.blue,
                  onPressed: () => onAddSpot(SpotType.vehicle, category: SpotCategory.disabled),
                ),
                _buildSpotButton(
                  icon: Icons.star,
                  label: 'VIP',
                  color: Colors.purple,
                  onPressed: () => onAddSpot(SpotType.vehicle, category: SpotCategory.vip),
                ),
              ],
            ),
          ),
          
          const Divider(),
          
          // Signage creation section
          _buildSectionHeader('Señalización'),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                _buildSpotButton(
                  icon: Icons.info,
                  label: 'Info',
                  color: Colors.blue,
                  onPressed: () => onAddSignage(SignageType.info),
                ),
                _buildSpotButton(
                  icon: Icons.input,
                  label: 'Entrada',
                  color: Colors.green,
                  onPressed: () => onAddSignage(SignageType.entrance),
                ),
                _buildSpotButton(
                  icon: Icons.logout,
                  label: 'Salida',
                  color: Colors.red,
                  onPressed: () => onAddSignage(SignageType.exit),
                ),
                _buildSpotButton(
                  icon: Icons.local_parking,
                  iconModifier: Icons.block,
                  label: 'No Estacionar',
                  color: Colors.red,
                  onPressed: () => onAddSignage(SignageType.noParking),
                ),
                _buildSpotButton(
                  icon: Icons.arrow_forward,
                  label: 'Una vía',
                  color: Colors.blue,
                  onPressed: () => onAddSignage(SignageType.oneWay),
                ),
                _buildSpotButton(
                  icon: Icons.sync_alt,
                  label: 'Doble vía',
                  color: Colors.blue,
                  onPressed: () => onAddSignage(SignageType.twoWay),
                ),
              ],
            ),
          ),
          
          const Divider(),
          
          // Facilities creation section
          _buildSectionHeader('Instalaciones'),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                _buildSpotButton(
                  icon: Icons.elevator,
                  label: 'Ascensor',
                  color: Colors.blue,
                  onPressed: () => onAddFacility(FacilityType.elevator),
                ),
                _buildSpotButton(
                  icon: Icons.wc,
                  label: 'Baño',
                  color: Colors.teal,
                  onPressed: () => onAddFacility(FacilityType.bathroom),
                ),
                _buildSpotButton(
                  icon: Icons.payment,
                  label: 'Pago',
                  color: Colors.green,
                  onPressed: () => onAddFacility(FacilityType.payStation),
                ),
                _buildSpotButton(
                  icon: Icons.security,
                  label: 'Seguridad',
                  color: Colors.purple,
                  onPressed: () => onAddFacility(FacilityType.securityOffice),
                ),
                _buildSpotButton(
                  icon: Icons.stairs,
                  label: 'Escaleras',
                  color: Colors.orange,
                  onPressed: () => onAddFacility(FacilityType.staircase),
                ),
                _buildSpotButton(
                  icon: Icons.accessible,
                  label: 'Acceso',
                  color: Colors.blue,
                  onPressed: () => onAddFacility(FacilityType.handicapAccess),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  /// Build selection tools for selection mode
  Widget _buildSelectionTools() {
    final bool hasSelection = onDelete != null;
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Herramientas de selección'),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                _buildActionButton(
                  icon: Icons.content_copy,
                  label: 'Duplicar',
                  enabled: hasSelection,
                  onPressed: onDuplicate,
                ),
                _buildActionButton(
                  icon: Icons.delete,
                  label: 'Eliminar',
                  enabled: hasSelection,
                  onPressed: onDelete,
                ),
                _buildActionButton(
                  icon: Icons.rotate_right,
                  label: 'Rotar',
                  enabled: hasSelection,
                  onPressed: onRotate,
                ),
                const SizedBox(width: 16),
                const VerticalDivider(),
                const SizedBox(width: 16),
                _buildActionButton(
                  icon: Icons.align_horizontal_left,
                  label: 'Alinear izquierda',
                  enabled: hasSelection,
                  onPressed: hasSelection ? () => {} : null,
                ),
                _buildActionButton(
                  icon: Icons.align_horizontal_center,
                  label: 'Centrar',
                  enabled: hasSelection,
                  onPressed: hasSelection ? () => {} : null,
                ),
                _buildActionButton(
                  icon: Icons.align_horizontal_right,
                  label: 'Alinear derecha',
                  enabled: hasSelection,
                  onPressed: hasSelection ? () => {} : null,
                ),
              ],
            ),
          ),
          
          // Keyboard shortcuts help
          const SizedBox(height: 8),
          Text(
            'Atajos: Ctrl+A (Seleccionar todo), Ctrl+C (Copiar), Ctrl+V (Pegar), '
            'Ctrl+D (Duplicar), Delete (Eliminar), R (Rotar)',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
  
  /// Build a section header
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }
  
  /// Build a spot placement button
  Widget _buildSpotButton({
    required IconData icon,
    IconData? iconModifier,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: color,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: color.withOpacity(0.5)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        onPressed: onPressed,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Icon(icon, color: color),
                if (iconModifier != null)
                  Positioned(
                    bottom: -2,
                    right: -2,
                    child: Icon(
                      iconModifier,
                      size: 12,
                      color: color,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Build an action button for the selection tools
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required bool enabled,
    VoidCallback? onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: enabled ? Colors.blue : Colors.grey,
          elevation: enabled ? 2 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: enabled ? Colors.blue.withOpacity(0.5) : Colors.grey.withOpacity(0.3),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        onPressed: enabled ? onPressed : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: enabled ? Colors.blue : Colors.grey,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: enabled ? Colors.blue : Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 