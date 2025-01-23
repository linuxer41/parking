import 'package:flutter/material.dart';
import '../canvas_controller.dart';
import '../../models/text_object.dart';
import '../../models/spot_object.dart';

class ActionBar extends StatelessWidget {
  final InfiniteCanvasController controller;

  const ActionBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final selectedObject = controller.selectedObjects.first;
    final position =
        selectedObject.position * controller.zoom + controller.canvasOffset;

    return Positioned(
      top: position.dy + 50,
      left: position.dx,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
                color: Colors.black26, blurRadius: 5, offset: Offset(0, 3))
          ],
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.rotate_right),
              onPressed: controller.rotateSelectedObjects,
              tooltip: "Rotar",
            ),
            if (selectedObject is SpotObject)
              IconButton(
                icon: const Icon(Icons.swap_horiz),
                onPressed: controller.toggleSelectedObjectStatus,
                tooltip: "Cambiar estado",
              ),
            if (selectedObject is TextObject)
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  // Implementar lógica para editar texto
                },
                tooltip: "Editar texto",
              ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: controller.deleteSelectedObjects,
              tooltip: "Eliminar",
            ),
          ],
        ),
      ),
    );
  }
}
