import 'package:flutter/material.dart';
import '../canvas_controller.dart';

class FloatingButtons extends StatelessWidget {
  final InfiniteCanvasController controller;

  const FloatingButtons({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20,
      right: 20,
      child: Column(
        children: [
          FloatingActionButton(
            onPressed: controller.centerCanvas,
            tooltip: "Centrar lienzo",
            child: const Icon(Icons.center_focus_strong),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: controller.resetZoom,
            tooltip: "Zoom predeterminado",
            child: const Icon(Icons.zoom_out_map),
          ),
        ],
      ),
    );
  }
}
