import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:vector_math/vector_math.dart' as vector_math;

import '../core/parking_state.dart';
import '../models/enums.dart';
import '../models/parking_elements.dart';
import '../models/parking_spot.dart';
import 'context_toolbar.dart';

/// Widget que renderiza el canvas del sistema de parkeo
class ParkingCanvas extends StatefulWidget {
  const ParkingCanvas({super.key});

  @override
  State<ParkingCanvas> createState() => _ParkingCanvasState();
}

class _ParkingCanvasState extends State<ParkingCanvas>
    with TickerProviderStateMixin {
  // Control del gesto de arrastre
  Offset? _dragStartPosition;
  vector_math.Vector2? _cameraStartPosition;
  ParkingElement? _draggedElement;
  vector_math.Vector2? _elementStartPosition;

  // Variable para almacenar la posición del último clic
  Offset _lastTapPosition = Offset.zero;

  // Soporte para arrastrar múltiples elementos
  bool _draggingMultiple = false;
  final Map<String, vector_math.Vector2> _selectedElementsStartPositions = {};

  // Control de selección múltiple
  Offset? _selectionStartPosition;
  Rect? _selectionRect;

  // Estado del zoom
  double _baseScaleFactor = 1.0;
  double _previousScaleFactor = 1.0;

  // Mostrar mensaje de colisión
  bool _collisionDetected = false;
  Offset _collisionPosition = Offset.zero;

  // GlobalKey para obtener el tamaño del widget
  final GlobalKey _canvasKey = GlobalKey();

  // Añadir variable para tracking del último tap (para detectar doble tap)
  DateTime? _lastTapTime;

  // Estado para teclas
  bool _isShiftPressed = false;

  @override
  void initState() {
    super.initState();
    // Programar la centralización después de que el widget esté construido
    WidgetsBinding.instance.addPostFrameCallback((_) => _centerViewOnOrigin());

    // Inicializar gestor de atajos de teclado después del primer frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final parkingState = Provider.of<ParkingState>(context, listen: false);
      parkingState.initKeyboardShortcutsManager(_showActionMessage);
    });
  }

  // Método para centrar la vista en el origen
  void _centerViewOnOrigin() {
    final RenderBox? renderBox =
        _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final Size size = renderBox.size;
      final parkingState = Provider.of<ParkingState>(context, listen: false);
      parkingState.centerViewOnOrigin(size);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode()..requestFocus(),
      onKey: _handleKeyEvent,
      child: Consumer<ParkingState>(
        builder: (context, parkingState, child) {
          final theme = Theme.of(context);
          final colorScheme = theme.colorScheme;

          return Listener(
            onPointerSignal: (PointerSignalEvent signal) {
              if (signal is PointerScrollEvent) {
                // Manejo del zoom con el scroll del mouse
                final double scrollDelta = signal.scrollDelta.dy;

                // Determinar el factor de zoom basado en la dirección del scroll
                // Valores negativos aumentan el zoom, positivos lo disminuyen
                // Usar un factor más suave para un zoom más gradual
                final double zoomFactor = scrollDelta > 0 ? 0.95 : 1.05;

                // Actualizar la posición del cursor para asegurar un zoom centrado
                final cursorWorldPos = parkingState.camera.screenToWorld(
                  signal.position,
                );
                parkingState.cursorPosition = cursorWorldPos;

                // Aplicar zoom centrado en la posición actual del cursor
                parkingState.zoomCamera(
                  zoomFactor,
                  signal.position,
                );
              }
            },
            child: GestureDetector(
              // Manejar tanto arrastre como zoom con el reconocedor de escala
              onScaleStart: (details) =>
                  _handleScaleStart(details, parkingState),
              onScaleUpdate: (details) =>
                  _handleScaleUpdate(details, parkingState),
              onScaleEnd: (details) => _handleScaleEnd(details, parkingState),

              // Manejar tap para selección o elemento en modo de creación
              onTapDown: (details) => _handleTapDown(details, parkingState),

              child: SizedBox(
                key: _canvasKey,
                width: double.infinity,
                height: double.infinity,
                child: Stack(
                  children: [
                    // Canvas principal
                    CustomPaint(
                      painter: _ParkingCanvasPainter(
                        parkingState: parkingState,
                        colorScheme: colorScheme,
                        selectionRect: _selectionRect,
                      ),
                      size: Size.infinite,
                    ),

                    // Barra de herramientas contextual
                    if (parkingState.isEditMode &&
                        parkingState.selectedElements.isNotEmpty)
                      ContextToolbar(
                        parkingState: parkingState,
                        onRotateClockwise: () =>
                            _rotateSelectedElement(parkingState, 30),
                        onRotateCounterClockwise: () =>
                            _rotateSelectedElement(parkingState, -30),
                        onCopy: () => _copySelectedElements(parkingState),
                        onDelete: () => _deleteSelectedElements(parkingState),
                        onEditLabel: () => _editElementLabel(parkingState),
                        onAlignTop: () =>
                            _alignElements(parkingState, Alignment.topCenter),
                        onAlignBottom: () => _alignElements(
                            parkingState, Alignment.bottomCenter),
                        onAlignLeft: () =>
                            _alignElements(parkingState, Alignment.centerLeft),
                        onAlignRight: () =>
                            _alignElements(parkingState, Alignment.centerRight),
                        onAlignCenter: () =>
                            _alignElements(parkingState, Alignment.center),
                        onDistributeHorizontal: () => _distributeElementsEvenly(
                            parkingState,
                            horizontal: true),
                        onDistributeVertical: () => _distributeElementsEvenly(
                            parkingState,
                            horizontal: false),
                        selectedElementPosition: () {
                          // Obtener el elemento seleccionado
                          final element = parkingState.selectedElements.first;

                          // Obtener la posición actual en pantalla
                          final screenPos = parkingState.camera
                              .worldToScreen(element.position);

                          // Obtener dimensiones del elemento
                          final size = element.getSize();
                          final scaledHeight =
                              size.height * element.scale * parkingState.zoom;

                          // Calcular posición para la barra (exactamente debajo del elemento)
                          return Offset(
                            screenPos.dx, // Centrado en X
                            screenPos.dy +
                                (scaledHeight / 2) +
                                10, // 10px debajo del elemento
                          );
                        }(),
                        centerHorizontally: true,
                      ),

                    // Mostrar mensaje de colisión si existe
                    if (_collisionDetected)
                      Positioned(
                        left: _collisionPosition.dx,
                        top: _collisionPosition.dy - 60,
                        child: Material(
                          elevation: 8,
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.red.withOpacity(0.9),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            child: const Row(
                              children: [
                                Icon(Icons.warning_amber_rounded,
                                    color: Colors.white, size: 16),
                                SizedBox(width: 4),
                                Text(
                                  "¡Colisión detectada!",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleScaleStart(ScaleStartDetails details, ParkingState parkingState) {
    _dragStartPosition = details.localFocalPoint;
    _cameraStartPosition = vector_math.Vector2(
      parkingState.cameraPosition.x,
      parkingState.cameraPosition.y,
    );
    _previousScaleFactor = 1.0;
    _baseScaleFactor = parkingState.zoom;

    // Modo de selección: iniciar un rectángulo de selección o arrastrar elementos seleccionados
    if (parkingState.isEditMode &&
        parkingState.editorMode == EditorMode.select &&
        details.pointerCount == 1) {
      // Comprobar si ya hay elementos seleccionados y si el clic es dentro del área de selección
      if (parkingState.selectedElements.isNotEmpty) {
        // Convertir la posición del clic a coordenadas del mundo
        final worldPos = parkingState.camera.screenToWorld(
          details.localFocalPoint,
        );

        // Verificar si hay algún elemento seleccionado en la posición del clic
        final elementAtPos = parkingState.findElementAt(worldPos);

        // Si se hace clic en un elemento seleccionado, iniciar arrastre grupal
        if (elementAtPos != null &&
            parkingState.selectedElements.contains(elementAtPos)) {
          _draggingMultiple = true;

          // Guardar las posiciones iniciales de todos los elementos seleccionados
          _selectedElementsStartPositions.clear();
          for (final selectedElement in parkingState.selectedElements) {
            if (!selectedElement.isLocked) {
              _selectedElementsStartPositions[selectedElement.id] =
                  vector_math.Vector2(
                selectedElement.position.x,
                selectedElement.position.y,
              );
            }
          }
          return;
        }
      }

      // Si no hay elementos seleccionados o el clic no es sobre un elemento seleccionado,
      // iniciar una nueva selección rectangular
      _selectionStartPosition = details.localFocalPoint;
      _selectionRect =
          Rect.fromPoints(_selectionStartPosition!, _selectionStartPosition!);
      return;
    }

    // Modo de edición libre: verificar si estamos arrastrando elementos
    if (parkingState.isEditMode &&
        parkingState.editorMode == EditorMode.free &&
        details.pointerCount == 1) {
      final worldPos = parkingState.camera.screenToWorld(
        details.localFocalPoint,
      );

      final element = parkingState.findElementAt(worldPos);

      // Si hay un elemento en la posición y está seleccionado, preparar para arrastrarlo
      if (element != null && parkingState.selectedElements.contains(element)) {
        // Si hay múltiples elementos seleccionados, activar el modo de arrastre múltiple
        if (parkingState.selectedElements.length > 1) {
          _draggingMultiple = true;

          // Guardar las posiciones iniciales de todos los elementos seleccionados
          _selectedElementsStartPositions.clear();
          for (final selectedElement in parkingState.selectedElements) {
            if (!selectedElement.isLocked) {
              _selectedElementsStartPositions[selectedElement.id] =
                  vector_math.Vector2(
                selectedElement.position.x,
                selectedElement.position.y,
              );
            }
          }
          return;
        }
        // Si solo hay un elemento seleccionado, preparar para arrastrarlo
        else {
          _draggingMultiple = false;
          _draggedElement = element;
          _elementStartPosition = vector_math.Vector2(
            element.position.x,
            element.position.y,
          );
          return;
        }
      }
      // Si hay un elemento pero no está seleccionado, no hacemos nada aquí
      // ya que la selección se maneja en _handleTapDown
    }
  }

  void _handleScaleUpdate(
      ScaleUpdateDetails details, ParkingState parkingState) {
    // Actualizar la posición del cursor
    final cursorWorldPos = parkingState.camera.screenToWorld(
      details.localFocalPoint,
    );
    parkingState.cursorPosition = cursorWorldPos;

    // Reiniciar el estado de colisión
    setState(() {
      _collisionDetected = false;
    });

    // Modo de selección: actualizar el rectángulo de selección o arrastrar el grupo seleccionado
    if (parkingState.isEditMode &&
        parkingState.editorMode == EditorMode.select) {
      // Si estamos arrastrando múltiples elementos en modo de selección
      if (_draggingMultiple && _selectedElementsStartPositions.isNotEmpty) {
        final delta = details.localFocalPoint - _dragStartPosition!;

        // Convertir el delta de pantalla a delta de mundo
        final worldDelta = vector_math.Vector2(
          delta.dx / parkingState.zoom,
          delta.dy / parkingState.zoom,
        );

        // Verificar colisiones para cada elemento seleccionado
        bool anyCollision = false;

        for (final selectedElement in parkingState.selectedElements) {
          if (_selectedElementsStartPositions.containsKey(selectedElement.id) &&
              !selectedElement.isLocked) {
            final startPos =
                _selectedElementsStartPositions[selectedElement.id]!;

            // Calcular la nueva posición propuesta
            final proposedPosition = vector_math.Vector2(
              startPos.x + worldDelta.x,
              startPos.y + worldDelta.y,
            );

            // Aplicar guías inteligentes
            final adjustedPosition = parkingState.applySmartGuides(
              selectedElement,
              proposedPosition,
            );

            if (_checkCollision(
                parkingState, selectedElement, adjustedPosition)) {
              anyCollision = true;
              setState(() {
                _collisionDetected = true;
                _collisionPosition = details.localFocalPoint;
              });
              break;
            }
          }
        }

        // Si no hay colisiones, actualizar las posiciones
        if (!anyCollision) {
          setState(() {
            for (final selectedElement in parkingState.selectedElements) {
              if (_selectedElementsStartPositions
                      .containsKey(selectedElement.id) &&
                  !selectedElement.isLocked) {
                final startPos =
                    _selectedElementsStartPositions[selectedElement.id]!;

                // Calcular la nueva posición propuesta
                final proposedPosition = vector_math.Vector2(
                  startPos.x + worldDelta.x,
                  startPos.y + worldDelta.y,
                );

                // Aplicar guías inteligentes
                final adjustedPosition = parkingState.applySmartGuides(
                  selectedElement,
                  proposedPosition,
                );

                selectedElement.position = adjustedPosition;

                // Asegurar que el elemento permanezca visible durante el arrastre
                selectedElement.isVisible = true;
              }
            }
          });
        }
        return;
      }

      // Si estamos dibujando un rectángulo de selección
      if (_selectionStartPosition != null) {
        setState(() {
          _selectionRect = Rect.fromPoints(
              _selectionStartPosition!, details.localFocalPoint);
        });
        return;
      }
    }

    // Si es un gesto de escala (zoom)
    if (details.scale != 1.0) {
      final scaleFactor = details.scale / _previousScaleFactor;
      _previousScaleFactor = details.scale;

      // Aplicar zoom con foco en el punto de escala
      parkingState.zoomCamera(
        scaleFactor,
        details.localFocalPoint,
      );
    }
    // Si es un gesto de arrastre (pan) - solo un dedo
    else if (details.pointerCount == 1 && _dragStartPosition != null) {
      final delta = details.localFocalPoint - _dragStartPosition!;

      // Si estamos arrastrando un elemento en modo edición
      if (parkingState.isEditMode && _draggedElement != null) {
        // Convertir delta de pantalla a delta de mundo
        final worldDelta = vector_math.Vector2(
          delta.dx / parkingState.zoom,
          delta.dy / parkingState.zoom,
        );

        // Calcular la nueva posición propuesta
        final proposedPosition = vector_math.Vector2(
          _elementStartPosition!.x + worldDelta.x,
          _elementStartPosition!.y + worldDelta.y,
        );

        // Aplicar guías inteligentes para obtener la posición final
        final adjustedPosition = parkingState.applySmartGuides(
          _draggedElement!,
          proposedPosition,
        );

        // Verificar colisión
        if (_checkCollision(parkingState, _draggedElement!, adjustedPosition)) {
          setState(() {
            _collisionDetected = true;
            _collisionPosition = details.localFocalPoint;
          });
        } else {
          // No hay colisión, actualizar posición
          setState(() {
            _draggedElement!.position = adjustedPosition;
            _collisionDetected = false;
          });

          // Asegurar que el elemento permanezca visible durante el arrastre
          _draggedElement!.isVisible = true;
        }
      }
      // Si no estamos arrastrando elementos, hacer pan de cámara (tanto en modo normal como edición)
      else if (_cameraStartPosition != null) {
        parkingState.cameraPosition = vector_math.Vector2(
          _cameraStartPosition!.x - delta.dx,
          _cameraStartPosition!.y - delta.dy,
        );
      }
    }
  }

  void _handleScaleEnd(ScaleEndDetails details, ParkingState parkingState) {
    // Finalizar selección por rectángulo
    if (_selectionRect != null &&
        parkingState.editorMode == EditorMode.select) {
      // Convertir el rectángulo de selección a coordenadas del mundo
      final worldTopLeft = parkingState.camera.screenToWorld(
        Offset(_selectionRect!.left, _selectionRect!.top),
      );

      final worldBottomRight = parkingState.camera.screenToWorld(
        Offset(_selectionRect!.right, _selectionRect!.bottom),
      );

      final worldSelectionRect = Rect.fromPoints(
        Offset(worldTopLeft.x, worldTopLeft.y),
        Offset(worldBottomRight.x, worldBottomRight.y),
      );

      // Encontrar todos los elementos dentro del rectángulo de selección
      final elementsInRect = parkingState.allElements.where((element) {
        final elementPos = Offset(element.position.x, element.position.y);
        return worldSelectionRect.contains(elementPos);
      }).toList();

      // Si no estamos manteniendo Shift, limpiar la selección actual
      if (!isShiftPressed) {
        parkingState.clearSelection();
      }

      // Seleccionar todos los elementos encontrados
      if (elementsInRect.isNotEmpty) {
        parkingState.selectMultipleElements(elementsInRect);
      }
    }

    // Mostrar mensaje cuando se arrastraron múltiples elementos
    if (_draggingMultiple && _selectedElementsStartPositions.isNotEmpty) {
      final count = _selectedElementsStartPositions.length;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Movidos $count elementos'),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    // Reiniciar todos los estados de gestos
    _dragStartPosition = null;
    _cameraStartPosition = null;
    _draggedElement = null;
    _elementStartPosition = null;
    _draggingMultiple = false;
    _selectedElementsStartPositions.clear();

    setState(() {
      _selectionStartPosition = null;
      _selectionRect = null;
    });
  }

  void _handleTapDown(TapDownDetails details, ParkingState parkingState) {
    // Detección de doble tap
    final currentTime = DateTime.now();
    final isDoubleTap = _lastTapTime != null &&
        currentTime.difference(_lastTapTime!).inMilliseconds < 300;
    _lastTapTime = currentTime;

    // Guardar la posición del último tap
    _lastTapPosition = details.localPosition;

    if (isDoubleTap) {
      _handleDoubleTap(details, parkingState);
      return;
    }

    // Convertir punto de pantalla a mundo
    final worldPoint = parkingState.camera.screenToWorld(
      details.localPosition,
    );

    // En modo edición, manejar la selección de elementos para cualquier modo
    if (parkingState.isEditMode) {
      // Actualizar la posición del cursor
      parkingState.cursorPosition = worldPoint;

      // Encontrar el elemento en la posición del tap
      final element = parkingState.findElementAt(worldPoint);

      if (element != null) {
        // Verificar si el elemento ya está en un grupo seleccionado
        // Si está en un grupo, no hacer nada para mantener la selección grupal
        if (parkingState.selectedElements.contains(element) &&
            parkingState.selectedElements.length > 1) {
          // No hacer nada, mantener la selección múltiple intacta
          return;
        }

        // Si estamos manteniendo Shift, alternar la selección del elemento
        if (isShiftPressed) {
          parkingState.toggleElementSelection(element);
        }
        // De lo contrario, seleccionar solo este elemento
        else {
          parkingState.clearSelection();
          parkingState.selectElement(element);
        }
      } else if (!isShiftPressed) {
        // Si no hemos hecho clic en un elemento y no estamos manteniendo Shift,
        // deseleccionar todo
        parkingState.clearSelection();
      }
    }
    // En modo normal, si hacemos clic en un spot, mostrar modal
    else if (!parkingState.isEditMode) {
      final element = parkingState.findElementAt(worldPoint);
      if (element != null && element is ParkingSpot) {
        if (element.isOccupied) {
          _showVehicleExitModal(context, element);
        } else {
          _showVehicleEntryModal(context, element);
        }
      }
    }
  }

  // Método para manejar eventos de teclado
  bool _handleKeyEvent(RawKeyEvent event) {
    // Actualizar estado de teclas modificadoras
    if (event is RawKeyDownEvent) {
      setState(() {
        _isShiftPressed = event.isShiftPressed;
      });
    } else if (event is RawKeyUpEvent) {
      setState(() {
        _isShiftPressed = event.isShiftPressed;
      });
    }

    final parkingState = Provider.of<ParkingState>(context, listen: false);
    final keyboardManager = parkingState.keyboardShortcutsManager;
    if (keyboardManager != null) {
      return keyboardManager.handleKeyEvent(event);
    }
    return false;
  }

  // Getter para saber si Shift está pulsado
  bool get isShiftPressed => _isShiftPressed;

  /// Rota el elemento seleccionado en X grados
  void _rotateSelectedElement(ParkingState parkingState, double degrees) {
    if (parkingState.selectedElements.length != 1) return;

    final element = parkingState.selectedElements.first;
    if (element.isLocked) return;

    final newRotation = element.rotation + degrees;
    setState(() {
      element.rotation = newRotation;
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Elemento rotado ${degrees > 0 ? 'a la derecha' : 'a la izquierda'}'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Copia los elementos seleccionados
  void _copySelectedElements(ParkingState parkingState) {
    if (parkingState.selectedElements.isEmpty) return;

    final copiedElements = <ParkingElement>[];

    for (final element in parkingState.selectedElements) {
      // Crear una copia del elemento con un offset para que sea visible
      final copy = element.clone();
      copy.position = vector_math.Vector2(
        element.position.x + 20,
        element.position.y + 20,
      );

      parkingState.addElement(copy);
      copiedElements.add(copy);
    }

    // Seleccionar los nuevos elementos copiados
    parkingState.clearSelection();
    parkingState.selectMultipleElements(copiedElements);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${copiedElements.length} elementos copiados'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Elimina los elementos seleccionados
  void _deleteSelectedElements(ParkingState parkingState) {
    if (parkingState.selectedElements.isEmpty) return;

    final count = parkingState.selectedElements.length;

    // Eliminar elementos seleccionados
    for (final element in List.from(parkingState.selectedElements)) {
      parkingState.removeElement(element);
    }

    // Limpiar selección después de eliminar
    parkingState.clearSelection();

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$count elementos eliminados'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Muestra un diálogo para editar la etiqueta del elemento
  void _editElementLabel(ParkingState parkingState) {
    if (parkingState.selectedElements.length != 1) return;

    final element = parkingState.selectedElements.first;

    // Obtener la etiqueta actual
    String currentLabel = element.label ?? '';

    // Mostrar diálogo para editar
    showDialog(
      context: context,
      builder: (context) {
        final textController = TextEditingController(text: currentLabel);

        return AlertDialog(
          title: const Text('Editar etiqueta'),
          content: TextField(
            controller: textController,
            decoration: const InputDecoration(
              labelText: 'Etiqueta',
              hintText: 'Ingrese una etiqueta para el elemento',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                // Actualizar la etiqueta del elemento
                element.label = textController.text.trim();
                Navigator.pop(context);

                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Etiqueta actualizada'),
                    duration: Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  /// Alinea los elementos seleccionados según la alineación especificada
  void _alignElements(ParkingState parkingState, Alignment alignment) {
    if (parkingState.selectedElements.length <= 1) return;

    // Calcular los límites del grupo seleccionado
    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;

    // Ordenar elementos según su posición para alinear al elemento más externo
    final List<ParkingElement> sortedElementsX =
        List.from(parkingState.selectedElements)
          ..sort((a, b) => a.position.x.compareTo(b.position.x));

    final List<ParkingElement> sortedElementsY =
        List.from(parkingState.selectedElements)
          ..sort((a, b) => a.position.y.compareTo(b.position.y));

    // Obtener el elemento más a la izquierda, derecha, arriba y abajo
    final ParkingElement leftmostElement = sortedElementsX.first;
    final ParkingElement rightmostElement = sortedElementsX.last;
    final ParkingElement topmostElement = sortedElementsY.first;
    final ParkingElement bottommostElement = sortedElementsY.last;

    // También calcular los límites generales para el centrado
    for (final element in parkingState.selectedElements) {
      minX = math.min(minX, element.position.x);
      minY = math.min(minY, element.position.y);
      maxX = math.max(maxX, element.position.x);
      maxY = math.max(maxY, element.position.y);
    }

    // Para evitar sobreposiciones, ordenamos los elementos en el eje perpendicular
    // al de la alineación y aplicamos un espaciado mínimo
    const double minSpacing = 10.0; // Espaciado mínimo entre elementos

    if (alignment == Alignment.topCenter ||
        alignment == Alignment.bottomCenter) {
      // Para alineaciones verticales, ordenar por X para evitar sobreposiciones horizontales
      sortedElementsX.sort((a, b) => a.position.x.compareTo(b.position.x));

      // Obtener tamaños aproximados para calcular espaciado
      final Map<String, double> elementWidths = {};
      for (final element in parkingState.selectedElements) {
        elementWidths[element.id] = element.getSize().width * element.scale;
      }

      // Alinear elementos
      double nextX = sortedElementsX.first.position.x;
      for (int i = 0; i < sortedElementsX.length; i++) {
        final element = sortedElementsX[i];
        if (element.isLocked) continue;

        double targetY;
        if (alignment == Alignment.topCenter) {
          // Alinear con el elemento más alto
          targetY = topmostElement.position.y;
        } else {
          // Alinear con el elemento más bajo
          targetY = bottommostElement.position.y;
        }

        // Actualizar posición manteniendo la X o aplicando espaciado si es necesario
        if (i == 0) {
          element.position = vector_math.Vector2(element.position.x, targetY);
        } else {
          // Calcular nueva posición X para evitar sobreposiciones
          final prevElement = sortedElementsX[i - 1];
          final prevWidth = elementWidths[prevElement.id] ?? 0;
          final currWidth = elementWidths[element.id] ?? 0;

          // Calcular posición X mínima para evitar sobreposición
          final minX =
              prevElement.position.x + (prevWidth + currWidth) / 2 + minSpacing;

          // Si la posición actual ya cumple con el espaciado mínimo, mantenerla
          if (element.position.x >= minX) {
            element.position = vector_math.Vector2(element.position.x, targetY);
          } else {
            // De lo contrario, ajustar la posición X
            element.position = vector_math.Vector2(minX, targetY);
          }
        }
      }
    } else if (alignment == Alignment.centerLeft ||
        alignment == Alignment.centerRight) {
      // Para alineaciones horizontales, ordenar por Y para evitar sobreposiciones verticales
      sortedElementsY.sort((a, b) => a.position.y.compareTo(b.position.y));

      // Obtener tamaños aproximados para calcular espaciado
      final Map<String, double> elementHeights = {};
      for (final element in parkingState.selectedElements) {
        elementHeights[element.id] = element.getSize().height * element.scale;
      }

      // Alinear elementos
      double nextY = sortedElementsY.first.position.y;
      for (int i = 0; i < sortedElementsY.length; i++) {
        final element = sortedElementsY[i];
        if (element.isLocked) continue;

        double targetX;
        if (alignment == Alignment.centerLeft) {
          // Alinear con el elemento más a la izquierda
          targetX = leftmostElement.position.x;
        } else {
          // Alinear con el elemento más a la derecha
          targetX = rightmostElement.position.x;
        }

        // Actualizar posición manteniendo la Y o aplicando espaciado si es necesario
        if (i == 0) {
          element.position = vector_math.Vector2(targetX, element.position.y);
        } else {
          // Calcular nueva posición Y para evitar sobreposiciones
          final prevElement = sortedElementsY[i - 1];
          final prevHeight = elementHeights[prevElement.id] ?? 0;
          final currHeight = elementHeights[element.id] ?? 0;

          // Calcular posición Y mínima para evitar sobreposición
          final minY = prevElement.position.y +
              (prevHeight + currHeight) / 2 +
              minSpacing;

          // Si la posición actual ya cumple con el espaciado mínimo, mantenerla
          if (element.position.y >= minY) {
            element.position = vector_math.Vector2(targetX, element.position.y);
          } else {
            // De lo contrario, ajustar la posición Y
            element.position = vector_math.Vector2(targetX, minY);
          }
        }
      }
    } else if (alignment == Alignment.center) {
      // Para alineación central, mantener el comportamiento original
      // pero aún así evitar sobreposiciones
      final centerX = (minX + maxX) / 2;
      final centerY = (minY + maxY) / 2;

      // Reordenar elementos para minimizar sobreposiciones
      for (final element in parkingState.selectedElements) {
        if (element.isLocked) continue;
        element.position = vector_math.Vector2(centerX, centerY);
      }

      // Aplicar un ligero desplazamiento radial para evitar sobreposición total
      double angleStep = 2 * math.pi / parkingState.selectedElements.length;
      double radius = 10.0; // Radio de separación

      for (int i = 0; i < parkingState.selectedElements.length; i++) {
        final element = parkingState.selectedElements[i];
        if (element.isLocked) continue;

        double angle = i * angleStep;
        double offsetX = radius * math.cos(angle);
        double offsetY = radius * math.sin(angle);

        element.position =
            vector_math.Vector2(centerX + offsetX, centerY + offsetY);
      }
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Elementos alineados'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Distribuye uniformemente los elementos seleccionados con un espaciado mínimo
  void _distributeElementsEvenly(ParkingState parkingState,
      {required bool horizontal, double minSpacing = 20.0}) {
    final elements = parkingState.selectedElements;

    // Necesitamos al menos 3 elementos para distribuir
    if (elements.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Se necesitan al menos 3 elementos para distribuir'),
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Ordenar elementos según la dirección (horizontal o vertical)
    final List<ParkingElement> sortedElements = List.from(elements);
    if (horizontal) {
      sortedElements.sort((a, b) => a.position.x.compareTo(b.position.x));
    } else {
      sortedElements.sort((a, b) => a.position.y.compareTo(b.position.y));
    }

    // Determinar el primer y último elemento que no se moverán
    final ParkingElement firstElement = sortedElements.first;
    final ParkingElement lastElement = sortedElements.last;

    // Obtener la distancia total y calcular el espaciado uniforme
    final double totalDistance = horizontal
        ? (lastElement.position.x - firstElement.position.x)
        : (lastElement.position.y - firstElement.position.y);

    // Si no hay suficiente espacio para el espaciado mínimo, ajustar la posición del último elemento
    final double requiredSpace = minSpacing * (sortedElements.length - 1);

    if (totalDistance < requiredSpace) {
      // Necesitamos más espacio, ajustar la posición del último elemento
      if (horizontal) {
        lastElement.position = vector_math.Vector2(
            firstElement.position.x + requiredSpace, lastElement.position.y);
      } else {
        lastElement.position = vector_math.Vector2(
            lastElement.position.x, firstElement.position.y + requiredSpace);
      }
    }

    // Recalcular la distancia total después del posible ajuste
    final double adjustedTotalDistance = horizontal
        ? (lastElement.position.x - firstElement.position.x)
        : (lastElement.position.y - firstElement.position.y);

    // Calcular el espacio entre elementos
    final double spacing = adjustedTotalDistance / (sortedElements.length - 1);

    // Distribuir los elementos del medio uniformemente
    for (int i = 1; i < sortedElements.length - 1; i++) {
      final element = sortedElements[i];
      if (element.isLocked) continue;

      if (horizontal) {
        final newX = firstElement.position.x + (spacing * i);
        element.position = vector_math.Vector2(newX, element.position.y);
      } else {
        final newY = firstElement.position.y + (spacing * i);
        element.position = vector_math.Vector2(element.position.x, newY);
      }
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Elementos distribuidos uniformemente (espacio: ${spacing.toStringAsFixed(1)})'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Verifica si hay colisión entre elementos
  bool _checkCollision(ParkingState parkingState, ParkingElement element,
      vector_math.Vector2 newPosition) {
    // Guardar la posición actual
    final originalPosition =
        vector_math.Vector2(element.position.x, element.position.y);

    // Mover temporalmente el elemento a la nueva posición para verificar colisión
    element.position = newPosition;

    // Limpiar estado de colisiones previas
    element.clearCollisions();

    // Verificar colisión con todos los demás elementos
    bool collisionDetected = false;
    for (final otherElement in parkingState.allElements) {
      // No verificar colisión consigo mismo o elementos seleccionados en grupo
      if (otherElement.id == element.id ||
          parkingState.selectedElements.contains(otherElement)) {
        continue;
      }

      if (element.collidesWithElement(otherElement)) {
        element.addCollision(otherElement);
        collisionDetected = true;
      }
    }

    // Restaurar la posición original
    element.position = originalPosition;

    return collisionDetected;
  }

  /// Mostrar modal para registrar entrada de vehículo
  void _showVehicleEntryModal(BuildContext context, ParkingSpot spot) {
    // Obtener los colores disponibles para selección
    final Map<String, Color> vehicleColors = {
      'Blanco': Colors.white,
      'Negro': Colors.black87,
      'Gris': Colors.grey,
      'Plata': Colors.grey.shade300,
      'Rojo': Colors.red,
      'Azul': Colors.blue,
      'Verde': Colors.green,
      'Amarillo': Colors.amber,
    };

    // Valor inicial para la placa y color
    final plateController = TextEditingController();
    String selectedColor = 'Blanco';
    String vehicleType = 'Sedan';

    // Lista de tipos de vehículos
    final vehicleTypes = ['Sedan', 'SUV', 'Pickup', 'Compacto', 'Motocicleta'];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF1E1E1E)
                    : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 15.0,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Encabezado con diseño minimalista
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .secondary
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.login,
                          color: Theme.of(context).colorScheme.secondary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Registrar entrada',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.3,
                              ),
                            ),
                            Text(
                              'Espacio ${spot.label}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.secondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () => Navigator.pop(context),
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Icon(
                              Icons.close_rounded,
                              size: 20,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white60
                                  : Colors.black45,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Campo de placa con diseño moderno
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF2A2A2A)
                          : const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white10
                            : Colors.black12,
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: plateController,
                      style: const TextStyle(
                        fontSize: 16,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Placa del vehículo',
                        hintStyle: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white38
                              : Colors.black38,
                          fontSize: 14,
                        ),
                        prefixIcon: Icon(
                          Icons.credit_card,
                          size: 18,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white54
                              : Colors.black45,
                        ),
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 14),
                      ),
                      textCapitalization: TextCapitalization.characters,
                      textAlign: TextAlign.left,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Selección de tipo de vehículo
                  Text(
                    'Tipo de vehículo',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white70
                          : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: vehicleTypes.map((type) {
                        final isSelected = vehicleType == type;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              vehicleType = type;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Theme.of(context)
                                      .colorScheme
                                      .secondary
                                      .withOpacity(0.1)
                                  : Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white10
                                      : Colors.black.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? Theme.of(context)
                                        .colorScheme
                                        .secondary
                                        .withOpacity(0.5)
                                    : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              type,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: isSelected
                                    ? Theme.of(context).colorScheme.secondary
                                    : Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white70
                                        : Colors.black54,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Selección de color
                  Text(
                    'Color del vehículo',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white70
                          : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: vehicleColors.entries.map((entry) {
                      final isSelected = selectedColor == entry.key;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedColor = entry.key;
                          });
                        },
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: entry.value,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.secondary
                                  : Colors.grey.withOpacity(0.3),
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary
                                          .withOpacity(0.3),
                                      blurRadius: 4,
                                      spreadRadius: 1,
                                    )
                                  ]
                                : null,
                          ),
                          child: isSelected
                              ? Icon(
                                  Icons.check,
                                  color: _isColorDark(entry.value)
                                      ? Colors.white
                                      : Colors.black,
                                  size: 18,
                                )
                              : null,
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Botones de acción
                  Row(
                    children: [
                      // Botón de cancelar
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white30
                                  : Colors.black26,
                              width: 1,
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Cancelar',
                            style: TextStyle(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white70
                                  : Colors.black54,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Botón de confirmar
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.secondary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            if (plateController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                      'Debe ingresar la placa del vehículo'),
                                  backgroundColor: Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                              return;
                            }

                            // Registrar entrada
                            spot.isOccupied = true;
                            spot.vehiclePlate =
                                plateController.text.trim().toUpperCase();
                            spot.entryTime = DateTime.now();
                            spot.exitTime = null;
                            spot.vehicleColor = selectedColor;

                            // Cerrar el diálogo
                            Navigator.pop(context);

                            // Mostrar confirmación
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(Icons.check_circle,
                                        color: Colors.white),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                          'Vehículo ${spot.vehiclePlate} registrado en ${spot.label}'),
                                    ),
                                  ],
                                ),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );

                            // Imprimir ticket (simulado)
                            _printEntryTicket(spot, vehicleType, selectedColor);
                          },
                          child: const Text('Registrar entrada'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  /// Mostrar modal para registrar salida de vehículo
  void _showVehicleExitModal(BuildContext context, ParkingSpot spot) {
    final now = DateTime.now();
    final entryTime = spot.entryTime ?? now;
    final duration = now.difference(entryTime);

    // Calcular tarifa (simulado)
    final hours = (duration.inMinutes / 60).ceil();
    final cost = hours * 5.0; // $5 por hora

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF1E1E1E)
                  : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 15.0,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Encabezado con diseño minimalista
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.directions_car,
                        color: Theme.of(context).colorScheme.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Salida de vehículo',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.3,
                            ),
                          ),
                          Text(
                            'Espacio ${spot.label}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => Navigator.pop(context),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Icon(
                            Icons.close_rounded,
                            size: 20,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white60
                                    : Colors.black45,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Información de ticket con diseño moderno
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF2A2A2A)
                        : const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _buildExitInfoRow(
                          context,
                          'Placa',
                          spot.vehiclePlate ?? "No registrada",
                          Icons.credit_card),
                      const Divider(height: 20, thickness: 0.5),
                      _buildExitInfoRow(context, 'Entrada',
                          _formatDateTime(entryTime), Icons.login),
                      const Divider(height: 20, thickness: 0.5),
                      _buildExitInfoRow(context, 'Tiempo',
                          _formatDuration(duration), Icons.timer),
                      const Divider(height: 20, thickness: 0.5),
                      _buildExitInfoRow(
                        context,
                        'Tarifa',
                        '\$${cost.toStringAsFixed(2)}',
                        Icons.payments,
                        isHighlighted: true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Botones con diseño moderno y compacto
                Row(
                  children: [
                    // Botón de imprimir ticket
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.5),
                            width: 1.5,
                          ),
                        ),
                        onPressed: () {
                          // Imprimir ticket
                          _printExitTicket(spot, cost);
                          // No liberar el espacio aún
                          Navigator.pop(context);

                          // Mostrar confirmación de impresión
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Row(
                                children: [
                                  Icon(Icons.receipt_long, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text('Ticket impreso correctamente'),
                                ],
                              ),
                              backgroundColor: Colors.blueGrey,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.receipt_long, size: 16),
                        label: const Text('Imprimir ticket'),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Botón de confirmar salida
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          // Registrar salida
                          spot.isOccupied = false;
                          spot.exitTime = now;

                          // Cerrar el diálogo
                          Navigator.pop(context);

                          // Mostrar confirmación
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(Icons.check_circle,
                                      color: Colors.white),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                        'Vehículo ${spot.vehiclePlate} ha salido de ${spot.label}'),
                                  ),
                                ],
                              ),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.logout, size: 16),
                        label: const Text('Confirmar salida'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Widget para mostrar una fila de información en el modal de salida
  Widget _buildExitInfoRow(
      BuildContext context, String label, String value, IconData icon,
      {bool isHighlighted = false}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isHighlighted
                ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
                : Theme.of(context).brightness == Brightness.dark
                    ? Colors.black12
                    : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isHighlighted
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Icon(
            icon,
            size: 18,
            color: isHighlighted
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).brightness == Brightness.dark
                    ? Colors.white70
                    : Colors.black54,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white60
                      : Colors.black45,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w500,
                  color: isHighlighted
                      ? Theme.of(context).colorScheme.primary
                      : null,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Formatear fecha y hora
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// Formatear duración
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0) {
      return '$hours h $minutes min';
    } else {
      return '$minutes minutos';
    }
  }

  /// Determinar si un color es oscuro (para usar texto blanco)
  bool _isColorDark(Color color) =>
      (color.red * 0.299 + color.green * 0.587 + color.blue * 0.114) < 128;

  /// Imprimir ticket de entrada (simulado)
  void _printEntryTicket(
      ParkingSpot spot, String vehicleType, String vehicleColor) {
    // Solo simulado por ahora - implementar impresión real de tickets aquí
  }

  /// Imprimir ticket de salida (simulado)
  void _printExitTicket(ParkingSpot spot, double cost) {
    // Solo simulado por ahora - implementar impresión real de tickets aquí
  }

  // Método para manejar doble tap en un elemento (centrar vista)
  void _handleDoubleTap(TapDownDetails details, ParkingState parkingState) {
    final point = details.localPosition;

    // Convertir punto de pantalla a mundo
    final worldPoint = parkingState.camera.screenToWorld(point);

    // Buscar elemento en esta posición
    final element = parkingState.findElementAt(worldPoint);

    // Si hay un elemento, centrar vista en él con animación
    if (element != null) {
      parkingState.centerViewOnPointWithAnimation(
        element.position,
        this,
        targetZoom: 1.5,
      );
    }
  }

  // Método para mostrar mensajes de acción
  void _showActionMessage(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// Painter para dibujar el canvas del sistema de parkeo
class _ParkingCanvasPainter extends CustomPainter {
  final ParkingState parkingState;
  final Rect? selectionRect;
  final ColorScheme colorScheme;

  _ParkingCanvasPainter({
    required this.parkingState,
    required this.colorScheme,
    this.selectionRect,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Pintar el mundo
    _paintWorld(canvas, size);

    // Pintar rectángulo de selección si existe
    if (selectionRect != null) {
      final paint = Paint()
        ..color = Colors.blue.withOpacity(0.3)
        ..style = PaintingStyle.fill;

      canvas.drawRect(selectionRect!, paint);

      final borderPaint = Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;

      canvas.drawRect(selectionRect!, borderPaint);
    }

    // Dibujar rectángulos de corrección para elementos seleccionados
    if (parkingState.selectedElements.isNotEmpty) {
      for (final element in parkingState.selectedElements) {
        _drawSelectionIndicator(canvas, element);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  void _paintWorld(Canvas canvas, Size size) {
    // Actualizar el tamaño del canvas en el estado solo si ha cambiado
    // y hacerlo en un post-frame callback para evitar ciclos de notificación
    if (parkingState.canvasSize != size) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        parkingState.canvasSize = size;
      });
    }

    // Guardar el estado del canvas
    canvas.save();

    // Pintar fondo
    _paintBackground(canvas, size);

    // Pintar la cuadrícula si está habilitada
    if (parkingState.showGrid) {
      _paintGrid(canvas, size);
    }

    // Pintar el origen de coordenadas
    _paintOrigin(canvas, size);

    // Pintar guías inteligentes si están activas y estamos en modo edición
    if (parkingState.isEditMode) {
      _paintSmartGuides(canvas, size);
    }

    // Pintar elementos
    _paintElements(canvas, size);

    // Restaurar el estado del canvas
    canvas.restore();
  }

  /// Pintar la cuadrícula
  void _paintGrid(Canvas canvas, Size size) {
    final gridLines = parkingState.gridManager.getVisibleGridLines(
      parkingState.cameraPosition,
      parkingState.zoom,
      size,
    );

    for (final line in gridLines) {
      final startScreen = parkingState.camera.worldToScreen(line.start);
      final endScreen = parkingState.camera.worldToScreen(line.end);

      final paint = Paint()
        ..color = line.isMainLine
            ? colorScheme.primary.withOpacity(0.3)
            : colorScheme.onBackground.withOpacity(0.1)
        ..strokeWidth = line.thickness
        ..style = PaintingStyle.stroke;

      canvas.drawLine(startScreen, endScreen, paint);
    }
  }

  /// Pintar guías inteligentes
  void _paintSmartGuides(Canvas canvas, Size size) {
    final activeGuides = parkingState.gridManager.activeGuides;

    if (activeGuides.isEmpty) return;

    final guidePaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Para cada guía activa, dibujar una línea
    for (final guide in activeGuides) {
      final startWorld = guide.isVertical
          ? vector_math.Vector2(guide.position, -10000)
          : vector_math.Vector2(-10000, guide.position);

      final endWorld = guide.isVertical
          ? vector_math.Vector2(guide.position, 10000)
          : vector_math.Vector2(10000, guide.position);

      final startScreen = parkingState.camera.worldToScreen(startWorld);
      final endScreen = parkingState.camera.worldToScreen(endWorld);

      // Dibujar línea punteada
      _drawDashedLine(canvas, startScreen, endScreen, guidePaint);
    }
  }

  /// Dibujar una línea punteada
  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashWidth = 5;
    const dashSpace = 5;

    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final distance = math.sqrt(dx * dx + dy * dy);

    final count = distance / (dashWidth + dashSpace);
    final step = distance / count;

    final unitVectorX = dx / distance;
    final unitVectorY = dy / distance;

    double currentX = start.dx;
    double currentY = start.dy;

    for (int i = 0; i < count.round(); i++) {
      final startX = currentX;
      final startY = currentY;

      currentX += unitVectorX * dashWidth;
      currentY += unitVectorY * dashWidth;

      canvas.drawLine(
          Offset(startX, startY), Offset(currentX, currentY), paint);

      currentX += unitVectorX * dashSpace;
      currentY += unitVectorY * dashSpace;
    }
  }

  /// Pintar el fondo del canvas
  void _paintBackground(Canvas canvas, Size size) {
    // Crear un degradado suave para el fondo
    final Rect rect = Offset.zero & size;

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          colorScheme.background,
          colorScheme.surfaceVariant,
        ],
        stops: const [0.0, 1.0],
      ).createShader(rect)
      ..style = PaintingStyle.fill;

    canvas.drawRect(rect, paint);
  }

  /// Pintar el origen de coordenadas
  void _paintOrigin(Canvas canvas, Size size) {
    if (!parkingState.showCoordinates) return;

    // Calcular la posición del origen en coordenadas de pantalla usando la cámara
    final originScreen =
        parkingState.camera.worldToScreen(vector_math.Vector2(0, 0));

    // Dibujar ejes X e Y con el color primario del tema
    final axisPaint = Paint()
      ..color = colorScheme.primary.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Eje X (horizontal)
    canvas.drawLine(
      Offset(0, originScreen.dy),
      Offset(size.width, originScreen.dy),
      axisPaint,
    );

    // Eje Y (vertical)
    canvas.drawLine(
      Offset(originScreen.dx, 0),
      Offset(originScreen.dx, size.height),
      axisPaint,
    );

    // Dibujar símbolo de cruz en el origen
    final crossSize = 12.0;
    final crossPaint = Paint()
      ..color = colorScheme.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    // Línea horizontal de la cruz
    canvas.drawLine(
      Offset(originScreen.dx - crossSize / 2, originScreen.dy),
      Offset(originScreen.dx + crossSize / 2, originScreen.dy),
      crossPaint,
    );

    // Línea vertical de la cruz
    canvas.drawLine(
      Offset(originScreen.dx, originScreen.dy - crossSize / 2),
      Offset(originScreen.dx, originScreen.dy + crossSize / 2),
      crossPaint,
    );

    // Círculo decorativo alrededor de la cruz
    final circlePaint = Paint()
      ..color = colorScheme.primary.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawCircle(
      originScreen,
      crossSize,
      circlePaint,
    );
  }

  /// Pintar todos los elementos del mundo
  void _paintElements(Canvas canvas, Size size) {
    // Pintar cada tipo de elemento
    _paintElementGroup(canvas, parkingState.facilities, 1.0);
    _paintElementGroup(canvas, parkingState.spots, 1.0);
    _paintElementGroup(canvas, parkingState.signages, 1.0);
  }

  /// Pintar un grupo de elementos
  void _paintElementGroup(
      Canvas canvas, List<ParkingElement> elements, double baseOpacity) {
    for (final element in elements) {
      // No dibujar si no es visible
      if (!element.isVisible) continue;

      // Calcular la posición en pantalla usando la cámara
      final positionScreen =
          parkingState.camera.worldToScreen(element.position);

      // Guardar el estado del canvas
      canvas.save();

      // Aplicar transformaciones (posición, rotación, escala)
      canvas.translate(positionScreen.dx, positionScreen.dy);
      canvas.rotate(element.rotation * math.pi / 180);

      // Aplicar escala base * escala animada si está disponible
      final animatedScale = element.getAnimatedScale();
      canvas.scale(animatedScale * parkingState.zoom);

      // Pintar el elemento con su opacidad
      final opacity = ElementOpacityHelper.getOpacity(element.id);
      if (opacity < 1.0) {
        canvas.saveLayer(
          null,
          Paint()..color = Colors.white.withOpacity(opacity),
        );
      }

      // Renderizar el elemento
      element.render(canvas, this);

      if (opacity < 1.0) {
        canvas.restore();
      }

      // Restaurar el estado del canvas
      canvas.restore();
    }
  }

  /// Dibujar un elemento individual
  void _drawElement(Canvas canvas, ParkingElement element, double baseOpacity) {
    // Usar el método render del propio elemento
    element.render(canvas, parkingState);
  }

  /// Dibujar un rectángulo con líneas punteadas
  void _drawDashedRectangle(Canvas canvas, Rect rect, Paint paint) {
    const dashWidth = 3.0;
    const dashSpace = 3.0;

    // Dibujar los cuatro lados del rectángulo con líneas punteadas
    _drawDashedLine(
      canvas,
      Offset(rect.left, rect.top),
      Offset(rect.right, rect.top),
      paint,
    );

    _drawDashedLine(
      canvas,
      Offset(rect.right, rect.top),
      Offset(rect.right, rect.bottom),
      paint,
    );

    _drawDashedLine(
      canvas,
      Offset(rect.right, rect.bottom),
      Offset(rect.left, rect.bottom),
      paint,
    );

    _drawDashedLine(
      canvas,
      Offset(rect.left, rect.bottom),
      Offset(rect.left, rect.top),
      paint,
    );
  }

  /// Dibuja un indicador de selección alrededor del elemento
  void _drawSelectionIndicator(Canvas canvas, ParkingElement element) {
    // Obtener la posición en pantalla
    final screenPos = parkingState.camera.worldToScreen(element.position);

    // Obtener dimensiones exactas del elemento
    final size = element.getSize();
    final scaledWidth = size.width * element.scale * parkingState.zoom;
    final scaledHeight = size.height * element.scale * parkingState.zoom;

    // Pintar para la forma de colisión (en verde semitransparente)
    final collisionPaint = Paint()
      ..color = Colors.green.withOpacity(0.15)
      ..style = PaintingStyle.fill;

    // Pintar para la línea punteada (indicador de selección en azul)
    final selectionPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Guardar el estado del canvas antes de aplicar transformaciones
    canvas.save();

    // Aplicar la misma transformación que se aplica al elemento
    canvas.translate(screenPos.dx, screenPos.dy);
    canvas.rotate(element.rotation * math.pi / 180);

    // Crear rectángulo centrado en el origen (después de la traslación)
    final elementRect = Rect.fromCenter(
      center: Offset.zero,
      width: scaledWidth,
      height: scaledHeight,
    );

    // Dibujar rectángulo de colisión (verde semitransparente)
    canvas.drawRect(elementRect, collisionPaint);

    // Dibujar rectángulo de selección (línea punteada azul)
    _drawDashedRectangle(canvas, elementRect, selectionPaint);

    // Restaurar el estado del canvas después de dibujar
    canvas.restore();

    // Dibujar línea desde el elemento hasta donde iría la barra de herramientas
    // Calcular la posición de la barra considerando la rotación del elemento

    // Rotación en radianes
    final angleRad = element.rotation * math.pi / 180;

    // Calcular el punto inferior del elemento considerando rotación
    final bottomOffsetY = (scaledHeight / 2) * math.cos(angleRad);
    final bottomOffsetX = (scaledHeight / 2) * math.sin(angleRad);

    final bottomPoint =
        Offset(screenPos.dx + bottomOffsetX, screenPos.dy + bottomOffsetY);

    // Punto donde debería estar la barra de herramientas (10px más abajo)
    final toolbarPosition = Offset(
      bottomPoint.dx,
      bottomPoint.dy + 10,
    );

    final linePaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawLine(
      bottomPoint,
      toolbarPosition,
      linePaint,
    );

    // Dibujar un punto donde debería estar la barra de herramientas
    final pointPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    canvas.drawCircle(toolbarPosition, 3.0, pointPaint);
  }
}
