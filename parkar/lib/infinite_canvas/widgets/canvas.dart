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
  State<InfiniteCanvas> createState() => _InfiniteCanvasState();
}

class _InfiniteCanvasState extends State<InfiniteCanvas> {
  late InfiniteCanvasController controller;
  late Size viewportSize;

  @override
  void initState() {
    super.initState();
    SpotObject.loadImages().then((_) {
      setState(
          () {}); // Actualizar el estado cuando las imágenes estén cargadas
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
              if (controller.canvasMode == DrawingMode.text) {
                // _showEditTextDialog(position);
              } else {
                controller.selectObject(position);
              }
            };
        },
      ),
    };
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
                      controller: controller,
                      gridColor: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withAlpha(128),
                    ),
                  ),
                ),
              ),
              // Listener(
              //   onPointerMove: (PointerMoveEvent event) {
              //     // Actualiza la posición del mouse en el controlador
              //     controller.updateMousePosition(event.localPosition);
              //   },
              //   child: CustomPaint(
              //     size: Size.infinite,
              //     painter: InfiniteCanvasPainter(
              //       controller: controller,
              //       gridColor: Theme.of(context)
              //           .colorScheme
              //           .onSurface
              //           .withAlpha(128),
              //     ),
              //   ),
              // ),
              // MiniMap(
              //   controller: controller,
              //   viewportSize: MediaQuery.of(context).size,
              // ),
              Positioned(
                bottom: 10,
                right: 10,
                child: ValueListenableBuilder<Offset>(
                  valueListenable: ValueNotifier(controller.mousePosition),
                  builder: (context, position, child) {
                    // Convertir la posición del mouse a coordenadas del lienzo
                    final canvasPosition = (position - controller.canvasOffset) / controller.zoom;
                    final x = (canvasPosition.dx / controller.gridSize).toStringAsFixed(2);
                    final y = (canvasPosition.dy / controller.gridSize).toStringAsFixed(2);

                    return Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Text(
                        "X: $x, Y: $y",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (controller.editMode)
              Positioned(
                top: 100,
                right: 10,
                child: GridObjectBar(
                  controller: controller,
                  orientation: Axis.vertical,
                ),
              ),
              if (controller.editMode && controller.selectedObjects.isNotEmpty && widget.isEditable)
                ActionBar(controller: controller),
              FloatingButtons(controller: controller),
              Positioned(
                bottom: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: const Text(
                    "Escala: 0.5m/cuadro",
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
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
