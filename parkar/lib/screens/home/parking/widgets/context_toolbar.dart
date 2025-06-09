import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/parking_state.dart';
import '../models/parking_elements.dart';

/// Widget que muestra una barra de herramientas contextual 
/// para elementos seleccionados en el sistema de parkeo
class ContextToolbar extends StatelessWidget {
  final ParkingState parkingState;
  final VoidCallback onRotateClockwise;
  final VoidCallback onRotateCounterClockwise;
  final VoidCallback onCopy;
  final VoidCallback onDelete;
  final VoidCallback onEditLabel;
  final VoidCallback onAlignTop;
  final VoidCallback onAlignBottom;
  final VoidCallback onAlignLeft;
  final VoidCallback onAlignRight;
  final VoidCallback onAlignCenter;
  final VoidCallback onDistributeHorizontal;
  final VoidCallback onDistributeVertical;
  
  const ContextToolbar({
    Key? key,
    required this.parkingState,
    required this.onRotateClockwise,
    required this.onRotateCounterClockwise,
    required this.onCopy,
    required this.onDelete,
    required this.onEditLabel,
    required this.onAlignTop,
    required this.onAlignBottom,
    required this.onAlignLeft,
    required this.onAlignRight,
    required this.onAlignCenter,
    required this.onDistributeHorizontal,
    required this.onDistributeVertical,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    if (parkingState.selectedElements.isEmpty) {
      return const SizedBox.shrink();
    }
    
    // Calcular posición para la barra de herramientas
    Offset position = _calculateToolbarPosition();
    
    // Si hay múltiples elementos seleccionados, mostrar barra de herramientas para grupo
    if (parkingState.selectedElements.length > 1) {
      return Positioned(
        left: position.dx,
        top: position.dy,
        child: _buildMultipleElementsToolbar(context),
      );
    }
    
    // Si hay un solo elemento seleccionado, mostrar barra de herramientas individual
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: _buildSingleElementToolbar(context),
    );
  }
  
  /// Construye la barra de herramientas para un solo elemento
  Widget _buildSingleElementToolbar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToolbarButton(
            icon: Icons.rotate_right,
            tooltip: 'Rotar a la derecha',
            onPressed: onRotateClockwise,
          ),
          _buildToolbarButton(
            icon: Icons.rotate_left,
            tooltip: 'Rotar a la izquierda',
            onPressed: onRotateCounterClockwise,
          ),
          _buildToolbarButton(
            icon: Icons.content_copy,
            tooltip: 'Copiar',
            onPressed: onCopy,
          ),
          _buildToolbarButton(
            icon: Icons.delete_outline,
            tooltip: 'Eliminar',
            onPressed: onDelete,
            color: Colors.red,
          ),
          _buildToolbarButton(
            icon: Icons.edit,
            tooltip: 'Editar etiqueta',
            onPressed: onEditLabel,
          ),
        ],
      ),
    );
  }
  
  /// Construye la barra de herramientas para múltiples elementos
  Widget _buildMultipleElementsToolbar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Primera fila: Copiar, eliminar, etc.
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildToolbarButton(
                icon: Icons.content_copy,
                tooltip: 'Copiar selección',
                onPressed: onCopy,
              ),
              _buildToolbarButton(
                icon: Icons.delete_outline,
                tooltip: 'Eliminar selección',
                onPressed: onDelete,
                color: Colors.red,
              ),
              const SizedBox(width: 8),
              Container(
                height: 20,
                width: 1,
                color: Colors.grey.withOpacity(0.3),
              ),
              const SizedBox(width: 8),
            ],
          ),
          
          // Separador horizontal
          Container(
            height: 1,
            color: Colors.grey.withOpacity(0.2),
            margin: const EdgeInsets.symmetric(vertical: 4),
          ),
          
          // Segunda fila: Alineación
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildGroupLabel('Alinear:'),
              _buildToolbarButton(
                icon: Icons.vertical_align_top,
                tooltip: 'Alinear arriba',
                onPressed: onAlignTop,
              ),
              _buildToolbarButton(
                icon: Icons.vertical_align_bottom,
                tooltip: 'Alinear abajo',
                onPressed: onAlignBottom,
              ),
              _buildToolbarButton(
                icon: Icons.align_horizontal_left,
                tooltip: 'Alinear izquierda',
                onPressed: onAlignLeft,
              ),
              _buildToolbarButton(
                icon: Icons.align_horizontal_right,
                tooltip: 'Alinear derecha',
                onPressed: onAlignRight,
              ),
              _buildToolbarButton(
                icon: Icons.filter_center_focus,
                tooltip: 'Centrar',
                onPressed: onAlignCenter,
              ),
            ],
          ),
          
          // Tercera fila: Distribución (si hay más de 2 elementos)
          if (parkingState.selectedElements.length > 2)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildGroupLabel('Distribuir:'),
                _buildToolbarButton(
                  icon: Icons.space_bar,
                  tooltip: 'Distribuir horizontalmente',
                  onPressed: onDistributeHorizontal,
                ),
                _buildToolbarButton(
                  icon: Icons.view_week, // Rotated looks like horizontal spacing
                  tooltip: 'Distribuir verticalmente',
                  onPressed: onDistributeVertical,
                ),
              ],
            ),
        ],
      ),
    );
  }
  
  /// Construye una etiqueta de grupo para la barra de herramientas
  Widget _buildGroupLabel(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }
  
  /// Construye un botón para la barra de herramientas
  Widget _buildToolbarButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(4),
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Icon(
              icon,
              size: 18,
              color: color ?? Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
  
  /// Calcula la posición de la barra de herramientas basado en los elementos seleccionados
  Offset _calculateToolbarPosition() {
    // Si no hay elementos seleccionados, posición por defecto
    if (parkingState.selectedElements.isEmpty) {
      return const Offset(100, 100);
    }
    
    // Calcular el centro de los elementos seleccionados
    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;
    
    for (final element in parkingState.selectedElements) {
      final screenPos = element.getScreenPosition(parkingState.zoom, parkingState.cameraPosition);
      final size = element.getSize();
      final halfWidth = (size.width * element.scale * parkingState.zoom) / 2;
      final halfHeight = (size.height * element.scale * parkingState.zoom) / 2;
      
      minX = math.min(minX, screenPos.x - halfWidth);
      minY = math.min(minY, screenPos.y - halfHeight);
      maxX = math.max(maxX, screenPos.x + halfWidth);
      maxY = math.max(maxY, screenPos.y + halfHeight);
    }
    
    // Colocar la barra de herramientas debajo del centro del grupo
    final centerX = (minX + maxX) / 2;
    final bottomY = maxY + 20; // 20 píxeles debajo del borde inferior
    
    return Offset(centerX, bottomY);
  }
} 