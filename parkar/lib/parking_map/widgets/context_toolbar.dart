// import 'dart:math';
import 'package:flutter/material.dart';
import '../core/parking_state.dart';
import '../models/parking_signage.dart';
// import '../models/enums.dart';
import 'dart:developer' as developer;

/// Widget que muestra una barra de herramientas contextual
/// para elementos seleccionados en el sistema de parkeo
class ContextToolbar extends StatelessWidget {
  final ParkingMapState parkingMapState;
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

  // Añadir la posición del elemento seleccionado
  final Offset? selectedElementPosition;

  // Añadir parámetro para centrar horizontalmente
  final bool centerHorizontally;

  const ContextToolbar({
    super.key,
    required this.parkingMapState,
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
    required this.selectedElementPosition,
    this.centerHorizontally = true,
  });

  @override
  Widget build(BuildContext context) {
    if (parkingMapState.selectedElements.isEmpty ||
        selectedElementPosition == null) {
      return const SizedBox.shrink();
    }

    // Obtener elemento seleccionado
    final element = parkingMapState.selectedElements.first;

    // Usar la posición proporcionada desde fuera
    final position = selectedElementPosition!;

    // Construir la barra de herramientas adecuada
    final toolbar = parkingMapState.selectedElements.length > 1
        ? _buildMultipleElementsToolbar(context)
        : _buildSingleElementToolbar(context);

    // Debug: Imprimir información de posiciones
    developer.log(
      'DEBUG: Elemento seleccionado - Tipo: ${element.runtimeType}',
    );
    developer.log(
      'DEBUG: Posición elemento (proporcionada) - X: ${position.dx}, Y: ${position.dy}',
    );

    // Posicionar la barra exactamente en la posición indicada
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: centerHorizontally
          ? FractionalTranslation(
              translation: const Offset(-0.5, 0), // Centrar horizontalmente
              child: toolbar,
            )
          : toolbar,
    );
  }

  /// Construye la barra de herramientas para un solo elemento
  Widget _buildSingleElementToolbar(BuildContext context) {
    // Verificar si el elemento seleccionado es una señal
    final isSignage =
        parkingMapState.selectedElements.isNotEmpty &&
        parkingMapState.selectedElements.first is ParkingSignage;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            spreadRadius: 0,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.1), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToolbarButton(
            icon: Icons.rotate_left,
            tooltip: 'Rotar a la izquierda',
            onPressed: onRotateCounterClockwise,
          ),
          _buildToolbarButton(
            icon: Icons.rotate_right,
            tooltip: 'Rotar a la derecha',
            onPressed: onRotateClockwise,
          ),
          _buildToolbarButton(
            icon: Icons.content_copy,
            tooltip: 'Copiar',
            onPressed: onCopy,
          ),
          // Mostrar botón de editar solo si NO es una señal
          if (!isSignage)
            _buildToolbarButton(
              icon: Icons.edit,
              tooltip: 'Editar etiqueta',
              onPressed: onEditLabel,
            ),
          _buildToolbarButton(
            icon: Icons.delete_outline,
            tooltip: 'Eliminar',
            onPressed: onDelete,
            color: Colors.red,
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
            color: Colors.black.withOpacity(0.15),
            spreadRadius: 0,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.1), width: 0.5),
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
          if (parkingMapState.selectedElements.length > 2)
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
                  icon:
                      Icons.view_week, // Rotated looks like horizontal spacing
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
          onTap: () {
            print("Botón de la barra de herramientas presionado: $tooltip");
            onPressed();
          },
          borderRadius: BorderRadius.circular(4),
          child: Container(
            padding: const EdgeInsets.all(6),
            child: Icon(icon, size: 20, color: color ?? Colors.black54),
          ),
        ),
      ),
    );
  }
}
