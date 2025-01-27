import 'package:flutter/material.dart';
import 'package:parkar/infinite_canvas/models/signage_object.dart';
import 'package:parkar/infinite_canvas/models/facility_object.dart';
import 'package:parkar/infinite_canvas/models/spot_object.dart';
import '../canvas_controller.dart';

class GridObjectBar extends StatefulWidget {
  final InfiniteCanvasController controller;
  final Axis orientation; // Orientación de la barra (horizontal o vertical)

  const GridObjectBar({
    super.key,
    required this.controller,
    this.orientation = Axis.vertical, // Por defecto es vertical
  });

  @override
  _GridObjectBarState createState() => _GridObjectBarState();
}

class _GridObjectBarState extends State<GridObjectBar>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = true; // Estado para controlar si está expandido o contraído

  // Mapa de colores para cada tipo de objeto
  final Map<Type, Color> _objectColors = {
    SpotObject: Colors.blue, // Color para SpotObject
    SignageObject: Colors.green, // Color para SignageObject
    FacilityObject: Colors.orange, // Color para FacilityObject
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Obtener el tema actual (Material 3)
    final isHorizontal = widget.orientation == Axis.horizontal;

    return AnimatedSize(
      duration: const Duration(milliseconds: 300), // Duración de la animación
      curve: Curves.easeInOut, // Curva de animación suave
      alignment: isHorizontal ? Alignment.centerLeft : Alignment.topCenter,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface, // Usar color de superficie del tema
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor, // Usar color de sombra del tema
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: IntrinsicWidth(
          child: IntrinsicHeight(
            child: Flex(
              direction: widget.orientation, // Orientación de los botones
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    isHorizontal
                        ? _isExpanded
                            ? Icons.chevron_right
                            : Icons.chevron_left
                        : _isExpanded
                            ? Icons.expand_less
                            : Icons.expand_more,
                    color: theme.colorScheme.primary, // Color primario del tema
                  ),
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded; // Cambiar estado de expansión
                    });
                  },
                  tooltip: _isExpanded ? "Contraer" : "Expandir",
                ),
                if (_isExpanded) ...[
                  _buildIconButton(
                    icon: Icons.local_parking,
                    objectType: SpotObject,
                    tooltip: "Spot",
                    onPressed: () => widget.controller.addGridObjectNode(
                      SpotObject(
                        type: SpotObjectType.car,
                        category: SpotObjectCategory.standart,
                        label: '',
                        vehiclePlate: '',
                      ),
                    ),
                  ),
                  _buildIconButton(
                    icon: Icons.arrow_right,
                    objectType: SignageObject,
                    tooltip: "Via",
                    onPressed: () => widget.controller.addGridObjectNode(
                      SignageObject(
                        type: SignageObjectType.via,
                        direction: SignageObjectDirection.right,
                      ),
                    ),
                  ),
                  _buildIconButton(
                    icon: Icons.login,
                    objectType: SignageObject,
                    tooltip: "Entrada",
                    onPressed: () => widget.controller.addGridObjectNode(
                      SignageObject(
                        type: SignageObjectType.entrance,
                        direction: SignageObjectDirection.right,
                      ),
                    ),
                  ),
                  _buildIconButton(
                    icon: Icons.logout,
                    objectType: SignageObject,
                    tooltip: "Salida",
                    onPressed: () => widget.controller.addGridObjectNode(
                      SignageObject(
                        type: SignageObjectType.exit,
                        direction: SignageObjectDirection.right,
                      ),
                    ),
                  ),
                  _buildIconButton(
                    icon: Icons.work,
                    objectType: FacilityObject,
                    tooltip: "Oficina",
                    onPressed: () => widget.controller.addGridObjectNode(
                      FacilityObject(
                        type: FacilityObjectType.office,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Método para construir botones con estilos personalizados
  Widget _buildIconButton({
    required IconData icon,
    required Type objectType,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    final color = _objectColors[objectType] ?? Colors.grey; // Color por defecto si no se encuentra

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Tooltip(
        message: tooltip,
        child: IconButton(
          icon: Icon(icon, color: color),
          onPressed: onPressed,
          style: IconButton.styleFrom(
            backgroundColor: color.withOpacity(0.2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }
}