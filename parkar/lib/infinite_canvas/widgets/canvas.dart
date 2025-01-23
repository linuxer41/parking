// ignore_for_file: avoid_single_cascade_in_expression_statements

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:parkar/infinite_canvas/widgets/tools/mode_bar.dart';
import '../models/spot_object.dart';
import 'canvas_controller.dart';
import 'canvas_painter.dart';
import 'tools/grid_object_bar.dart';
import 'tools/action_bar.dart';
import 'mini_map/mini_map.dart';
import 'tools/floating_buttons.dart';

class InfiniteCanvas extends StatefulWidget {
  final InfiniteCanvasController? controller;
  final double gridSize; // Tamaño de la cuadrícula en píxeles
  final bool isEditable;

  const InfiniteCanvas({
    super.key,
    this.controller,
    this.gridSize = 15, // Tamaño de la cuadrícula en píxeles
    this.isEditable = true,
  });

  @override
  _InfiniteCanvasState createState() => _InfiniteCanvasState();
}

class _InfiniteCanvasState extends State<InfiniteCanvas> {
  late InfiniteCanvasController controller;
  late Size viewportSize;

  @override
  void initState() {
    super.initState();
    SpotObject.loadImages().then((_) {
      setState(() {}); // Actualizar el estado cuando las imágenes estén cargadas
    });
    controller = widget.controller ?? InfiniteCanvasController();
    controller.setGridSize(widget.gridSize);
    controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    controller.removeListener(_onControllerChanged);
    super.dispose();
  }

    @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    viewportSize = MediaQuery.of(context).size;
    controller.updateViewportSize(viewportSize);
  }

  void _onControllerChanged() {
    setState(() {});
  }

  Map<Type, GestureRecognizerFactory> _buildGestures() {
    return {
      PanGestureRecognizer:
          GestureRecognizerFactoryWithHandlers<PanGestureRecognizer>(
        () => PanGestureRecognizer(),
        (PanGestureRecognizer instance) {
          instance
            ..onStart = controller.onPanStart
            ..onUpdate = controller.onPanUpdate
            ..onEnd = controller.onPanEnd;
        },
      ),
      ScaleGestureRecognizer:
          GestureRecognizerFactoryWithHandlers<ScaleGestureRecognizer>(
        () => ScaleGestureRecognizer(),
        (ScaleGestureRecognizer instance) {
          instance
            ..onStart = controller.onScaleStart
            ..onUpdate = controller.onScaleUpdate
            ..onEnd = controller.onScaleEnd;
        },
      ),
      TapGestureRecognizer:
          GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
        () => TapGestureRecognizer(),
        (TapGestureRecognizer instance) {
          instance
            ..onTapDown = (details) {
              final position =
                  (details.localPosition - controller.canvasOffset) /
                      controller.zoom;
              if (controller.canvasMode == InfiniteCanvasMode.text) {
                _showEditTextDialog(position);
              } else {
                controller.selectObject(position);
              }
            };
        },
      ),
    };
  }

  void _showEditTextDialog(Offset position) {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Agregar texto"),
          content: TextField(
            controller: textController,
            decoration: const InputDecoration(hintText: "Escribe algo..."),
          ),
          actions: [
            TextButton(
              onPressed: () {
                controller.addText(position, textController.text);
                Navigator.of(context).pop();
              },
              child: const Text("Agregar"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyC):
            CopyCommand(),
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyV):
            PasteCommand(),
        LogicalKeySet(LogicalKeyboardKey.delete): DeleteCommand(),
      },
      child: Actions(
        actions: {
          CopyCommand: CallbackAction<CopyCommand>(
              onInvoke: (_) => controller.copySelectedObjects()),
          PasteCommand: CallbackAction<PasteCommand>(
              onInvoke: (_) => controller.pasteObjects()),
          DeleteCommand: CallbackAction<DeleteCommand>(
              onInvoke: (_) => controller.deleteSelectedObjects()),
        },
        child: Scaffold(
          body: Stack(
            children: [
              Listener(
                onPointerSignal: (pointerSignal) {
                  if (pointerSignal is PointerScrollEvent) {
                    controller.adjustZoom(pointerSignal.scrollDelta.dy < 0);
                  }
                },
                child: RawGestureDetector(
                  gestures: _buildGestures(),
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: InfiniteCanvasPainter(
                      objects: controller.objects,
                      selectedObjects: controller.selectedObjects,
                      gridSize: controller.gridSize,
                      zoom: controller.zoom,
                      canvasOffset: controller.canvasOffset,
                      viewportSize: MediaQuery.of(context).size,
                      gridColor: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.2),
                      freeFormPoints: controller.freeFormPoints,
                    ),
                  ),
                ),
              ),
              // MiniMap(
              //   controller: controller,
              //   viewportSize: MediaQuery.of(context).size,
              // ),
              Modebar(controller: controller),
              if (controller.canvasMode == InfiniteCanvasMode.gridObject)
                GridObjectBar(controller: controller),
              if (controller.selectedObjects.isNotEmpty && widget.isEditable)
                ActionBar(controller: controller),
              FloatingButtons(controller: controller),
              Positioned(
                bottom: 20,
                left: 20,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "Escala: ${controller.gridSize.toStringAsFixed(2)} m/cuadrado",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class CopyCommand extends Intent {}

class PasteCommand extends Intent {}

class DeleteCommand extends Intent {}
