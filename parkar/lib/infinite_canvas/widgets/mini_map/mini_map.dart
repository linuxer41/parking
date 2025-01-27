import 'package:flutter/material.dart';
import '../canvas_controller.dart';
import 'mini_map_painter.dart';

class MiniMap extends StatelessWidget {
  final InfiniteCanvasController controller;
  final Size viewportSize;

  const MiniMap(
      {super.key, required this.controller, required this.viewportSize});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 20,
      left: 20,
      child: GestureDetector(
        onTapDown: (details) {
          final localPosition = details.localPosition;
          final canvasPosition = Offset(
            localPosition.dx / 0.4,
            localPosition.dy / 0.4,
          );
          controller.updateCanvasOffset(
            -canvasPosition.dx + viewportSize.width / (2 * controller.zoom),
            -canvasPosition.dy + viewportSize.height / (2 * controller.zoom),
          );
        },
        child: Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(
                color: Theme.of(context).colorScheme.onTertiary, width: 2),
            color: Colors.white.withOpacity(0.2),
          ),
          child: CustomPaint(
            painter: MiniMapPainter(
              objects: controller.objects,
              canvasOffset: controller.canvasOffset,
              zoom: controller.zoom,
              viewportSize: viewportSize,
              gridSize: 10,
            ),
          ),
        ),
      ),
    );
  }
}
