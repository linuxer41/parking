// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import '../canvas_controller.dart';

class Modebar extends StatelessWidget {
  final InfiniteCanvasController controller;

  const Modebar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 10,
      right: 10,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            const BoxShadow(
                color: Colors.black26, blurRadius: 5, offset: Offset(0, 3))
          ],
        ),
        child: Column(
          children: [
            IconButton(
              icon: const Icon(Icons.directions_car),
              onPressed: () =>
                  controller.setCanvasMode(DrawingMode.gridObject),
              color:
                  controller.canvasMode == DrawingMode.gridObject
                      ? Colors.blue
                      : Colors.grey,
              tooltip: "Agregar vehículo",
            ),
            IconButton(
              icon: const Icon(Icons.text_fields),
              onPressed: () =>
                  controller.setCanvasMode(DrawingMode.text),
              color: controller.canvasMode == DrawingMode.text
                  ? Colors.blue
                  : Colors.grey,
              tooltip: "Agregar texto",
            ),
          ],
        ),
      ),
    );
  }
}
