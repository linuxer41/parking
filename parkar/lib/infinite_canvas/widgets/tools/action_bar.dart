import 'package:flutter/material.dart';
import 'package:parkar/infinite_canvas/models/signage_object.dart';
import '../../models/grid_object.dart';
import '../canvas_controller.dart';
import '../../models/text_object.dart';
import '../../models/spot_object.dart';

class ActionBar extends StatelessWidget {
  final InfiniteCanvasController controller;

  const ActionBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final selectedObject = controller.selectedObjects.first;
    final zoom = controller.zoom;
    final canvasOffset = controller.canvasOffset;
    final gridSize = controller.gridSize;

    // Obtén el ancho y alto del objeto seleccionado
    final size = selectedObject is GridObject ? selectedObject.size : const Size(0, 0);

    // Calcula la posición del ActionBar teniendo en cuenta el zoom y el desplazamiento
    final position = Offset(
      (selectedObject.position.dx * zoom) + canvasOffset.dx,
      (selectedObject.position.dy * zoom) + canvasOffset.dy,
    );

    return Positioned(
      top: position.dy + (size.height * gridSize),  // Posiciona el ActionBar debajo del objeto + 5 píxeles
      left: position.dx - ((size.width * gridSize) / 2), // Centra el ActionBar respecto al objeto
      child: Container(
        padding: const EdgeInsets.all(6), // Reducir el padding en un 30%
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6), // Reducir el borderRadius en un 30%
          boxShadow: const [
            BoxShadow(
                color: Colors.black26, blurRadius: 5, offset: Offset(0, 3))
          ],
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.rotate_right),
              onPressed: () => controller.rotateSelectedObjects(15.0),
              tooltip: "Rotar 15º",
              iconSize: 20, // Reducir el tamaño del ícono en un 30%
              color: Colors.blue, // Color para la acción de rotar
            ),
            IconButton(
              icon: const Icon(Icons.rotate_left),
              onPressed: () => controller.rotateSelectedObjects(-15.0),
              tooltip: "Rotar -15º",
              iconSize: 20, // Reducir el tamaño del ícono en un 30%
              color: Colors.blue, // Color para la acción de rotar
            ),
            if (selectedObject is SignageObject)
              IconButton(
                icon: const Icon(Icons.swap_horiz),
                onPressed: controller.toggleSignageDirection,
                tooltip: "Cambiar direccion",
                iconSize: 20, // Reducir el tamaño del ícono en un 30%
                color: Colors.orange, // Color para la acción de cambiar dirección
              ),
            if (selectedObject is SpotObject)
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _editSpotLabel(context, selectedObject),
                tooltip: "Editar label",
                iconSize: 20, // Reducir el tamaño del ícono en un 30%
                color: Colors.purple, // Color para la acción de editar label
              ),
            // if (selectedObject is SpotObject)
            //   IconButton(
            //     icon: const Icon(Icons.swap_horiz),
            //     onPressed: controller.toggleSpotStatus,
            //     tooltip: "Ocupado/libre",
            //     iconSize: 20, // Reducir el tamaño del ícono en un 30%
            //     color: Colors.green, // Color para la acción de cambiar estado
            //   ),
            if (selectedObject is TextObject)
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  // Implementar lógica para editar texto
                },
                tooltip: "Editar texto",
                iconSize: 20, // Reducir el tamaño del ícono en un 30%
                color: Colors.purple, // Color para la acción de editar texto
              ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: controller.deleteSelectedObjects,
              tooltip: "Eliminar",
              iconSize: 20, // Reducir el tamaño del ícono en un 30%
              color: Colors.red, // Color para la acción de eliminar
            ),
          ],
        ),
      ),
    );
  }

  // Método para mostrar un diálogo y editar el label del SpotObject
  void _editSpotLabel(BuildContext context, SpotObject spotObject) {
    final textController = TextEditingController(text: spotObject.label);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Editar label"),
          content: TextField(
            controller: textController,
            decoration: const InputDecoration(hintText: "Nuevo label..."),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                controller.updateSpotLabel(textController.text);
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
              child: const Text("Guardar"),
            ),
          ],
        );
      },
    );
  }
}