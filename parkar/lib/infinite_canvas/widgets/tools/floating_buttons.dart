import 'package:flutter/material.dart';
import '../canvas_controller.dart';

class FloatingButtons extends StatelessWidget {
  final InfiniteCanvasController controller;

  const FloatingButtons({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20,
      right: 20,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              // Muestra un menú emergente con las opciones
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.center_focus_strong),
                        title: const Text('Centrar lienzo'),
                        onTap: () {
                          controller.centerCanvas();
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.zoom_out_map),
                        title: const Text('Zoom predeterminado'),
                        onTap: () {
                          controller.resetZoom();
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        leading: Icon(controller.showGrid ? Icons.check_box : Icons.check_box_outline_blank),
                        title: const Text('Mostrar cuadrícula'),
                        onTap: () {
                          controller.setShowGrid(!controller.showGrid);
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  );
                },
              );
            },
            tooltip: "Opciones",
            child: const Icon(Icons.more_vert),
            mini: true, // Reduce el tamaño del botón
          ),
        ],
      ),
    );
  }
}