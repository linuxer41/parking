import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:parkar/screens/parking_map/core/index.dart';
import 'package:vector_math/vector_math.dart' as vector_math;

import '../models/enums.dart';
import '../models/parking_elements.dart';
import '../models/parking_signage.dart';
import '../models/parking_spot.dart';
import 'context_toolbar.dart';
import 'register_occupancy.dart';
import 'manage_access.dart';
import 'manage_reservation.dart';
import 'manage_subscription.dart';

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

  // Estado de hover para tooltips
  ParkingSpot? _hoveredSpot;

  // GlobalKey para obtener el tamaño del widget
  final GlobalKey _canvasKey = GlobalKey();

  // Añadir variable para tracking del último tap (para detectar doble tap)
  DateTime? _lastTapTime;

  // Estado para teclas
  bool _isShiftPressed = false;

  @override
  void initState() {
    super.initState();
    final parkingMapState = ParkingMapStateContainer.of(context);
    parkingMapState.initKeyboardShortcutsManager(_showActionMessage);
  }

  @override
  Widget build(BuildContext context) {
    final parkingMapState = ParkingMapStateContainer.of(context);
    return KeyboardListener(
      focusNode: FocusNode()..requestFocus(),
      onKeyEvent: _handleKeyEvent,
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          final colorScheme = theme.colorScheme;

          return MouseRegion(
            onHover: (event) {
              // Funcionalidad de hover temporalmente deshabilitada
              // No hacer nada
            },
            onExit: (_) {
              // Funcionalidad de hover temporalmente deshabilitada
              // No hacer nada
            },
            child: Listener(
              onPointerSignal: (PointerSignalEvent signal) {
                if (signal is PointerScrollEvent) {
                  // Manejo del zoom con el scroll del mouse
                  final double scrollDelta = signal.scrollDelta.dy;

                  // Determinar el factor de zoom basado en la dirección del scroll
                  // Valores negativos aumentan el zoom, positivos lo disminuyen
                  // Usar un factor más suave para un zoom más gradual
                  final double zoomFactor = scrollDelta > 0 ? 0.95 : 1.05;

                  // Actualizar la posición del cursor para asegurar un zoom centrado
                  final cursorWorldPos = parkingMapState.camera.screenToWorld(
                    signal.position,
                  );
                  parkingMapState.cursorPosition = cursorWorldPos;

                  // Aplicar zoom centrado en la posición actual del cursor
                  parkingMapState.zoomCamera(zoomFactor, signal.position);
                }
              },
              child: GestureDetector(
                // Manejar tanto arrastre como zoom con el reconocedor de escala
                onScaleStart: (details) =>
                    _handleScaleStart(details, parkingMapState),
                onScaleUpdate: (details) =>
                    _handleScaleUpdate(details, parkingMapState),
                onScaleEnd: (details) =>
                    _handleScaleEnd(details, parkingMapState),

                // Manejar tap para selección o elemento en modo de creación
                onTapDown: (details) =>
                    _handleTapDown(details, parkingMapState),

                child: SizedBox(
                  key: _canvasKey,
                  width: double.infinity,
                  height: double.infinity,
                  child: Stack(
                    children: [
                      // Canvas principal
                      CustomPaint(
                        painter: _ParkingCanvasPainter(
                          parkingMapState: parkingMapState,
                          colorScheme: colorScheme,
                          selectionRect: _selectionRect,
                        ),
                        size: Size.infinite,
                      ),

                      // Barra de herramientas contextual
                      if (parkingMapState.isEditMode &&
                          parkingMapState.selectedElements.isNotEmpty)
                        ContextToolbar(
                          parkingMapState: parkingMapState,
                          onRotateClockwise: () {
                            debugPrint("Callback onRotateClockwise llamado");
                            _rotateSelectedElement(parkingMapState, 30);
                          },
                          onRotateCounterClockwise: () {
                            debugPrint(
                              "Callback onRotateCounterClockwise llamado",
                            );
                            _rotateSelectedElement(parkingMapState, -30);
                          },
                          onCopy: () {
                            debugPrint("Callback onCopy llamado");
                            _copySelectedElements(parkingMapState);
                          },
                          onDelete: () {
                            debugPrint("Callback onDelete llamado");
                            _deleteSelectedElements(parkingMapState);
                          },
                          onEditLabel: () {
                            debugPrint("Botón de editar etiqueta presionado");
                            _editElementLabel(parkingMapState);
                          },
                          onAlignTop: () => _alignElements(
                            parkingMapState,
                            Alignment.topCenter,
                          ),
                          onAlignBottom: () => _alignElements(
                            parkingMapState,
                            Alignment.bottomCenter,
                          ),
                          onAlignLeft: () => _alignElements(
                            parkingMapState,
                            Alignment.centerLeft,
                          ),
                          onAlignRight: () => _alignElements(
                            parkingMapState,
                            Alignment.centerRight,
                          ),
                          onAlignCenter: () =>
                              _alignElements(parkingMapState, Alignment.center),
                          onDistributeHorizontal: () =>
                              _distributeElementsEvenly(
                                parkingMapState,
                                horizontal: true,
                              ),
                          onDistributeVertical: () => _distributeElementsEvenly(
                            parkingMapState,
                            horizontal: false,
                          ),
                          selectedElementPosition: () {
                            // Obtener el elemento seleccionado
                            final element =
                                parkingMapState.selectedElements.first;

                            // Obtener la posición actual en pantalla
                            final screenPos = parkingMapState.camera
                                .worldToScreen(element.position);

                            // Obtener dimensiones del elemento
                            final size = element.getSize();
                            final scaledHeight =
                                size.height *
                                element.scale *
                                parkingMapState.zoom;

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
                            color: Colors.red.withAlpha(230),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.warning_amber_rounded,
                                    color: Colors.white,
                                    size: 16,
                                  ),
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

                      // Tooltip para espacio al hacer hover (modo normal) - temporalmente deshabilitado
                      // if (!parkingMapState.isEditMode && _hoveredSpot != null)
                      //   SpotInfoPopup(
                      //     spot: _hoveredSpot!,
                      //     position: parkingMapState.camera.worldToScreen(_hoveredSpot!.position),
                      //   ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleScaleStart(
    ScaleStartDetails details,
    ParkingMapState parkingMapState,
  ) {
    _dragStartPosition = details.localFocalPoint;
    _cameraStartPosition = vector_math.Vector2(
      parkingMapState.cameraPosition.x,
      parkingMapState.cameraPosition.y,
    );
    _previousScaleFactor = 1.0;
    _baseScaleFactor = parkingMapState.zoom;

    // Modo de selección: iniciar un rectángulo de selección o arrastrar elementos seleccionados
    if (parkingMapState.isEditMode &&
        parkingMapState.editorMode == EditorMode.select &&
        details.pointerCount == 1) {
      // Comprobar si ya hay elementos seleccionados y si el clic es dentro del área de selección
      if (parkingMapState.selectedElements.isNotEmpty) {
        // Convertir la posición del clic a coordenadas del mundo
        final worldPos = parkingMapState.camera.screenToWorld(
          details.localFocalPoint,
        );

        // Verificar si hay algún elemento seleccionado en la posición del clic
        final elementAtPos = parkingMapState.findElementAt(worldPos);

        // Si se hace clic en un elemento seleccionado, iniciar arrastre grupal
        if (elementAtPos != null &&
            parkingMapState.selectedElements.contains(elementAtPos)) {
          _draggingMultiple = true;

          // Guardar las posiciones iniciales de todos los elementos seleccionados
          _selectedElementsStartPositions.clear();
          for (final selectedElement in parkingMapState.selectedElements) {
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
      _selectionRect = Rect.fromPoints(
        _selectionStartPosition!,
        _selectionStartPosition!,
      );
      return;
    }

    // Modo de edición libre: verificar si estamos arrastrando elementos
    if (parkingMapState.isEditMode &&
        parkingMapState.editorMode == EditorMode.free &&
        details.pointerCount == 1) {
      final worldPos = parkingMapState.camera.screenToWorld(
        details.localFocalPoint,
      );

      final element = parkingMapState.findElementAt(worldPos);

      // Si hay un elemento en la posición y está seleccionado, preparar para arrastrarlo
      if (element != null &&
          parkingMapState.selectedElements.contains(element)) {
        // Si hay múltiples elementos seleccionados, activar el modo de arrastre múltiple
        if (parkingMapState.selectedElements.length > 1) {
          _draggingMultiple = true;

          // Guardar las posiciones iniciales de todos los elementos seleccionados
          _selectedElementsStartPositions.clear();
          for (final selectedElement in parkingMapState.selectedElements) {
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
    ScaleUpdateDetails details,
    ParkingMapState parkingMapState,
  ) {
    // Actualizar la posición del cursor
    final cursorWorldPos = parkingMapState.camera.screenToWorld(
      details.localFocalPoint,
    );
    parkingMapState.cursorPosition = cursorWorldPos;

    // Reiniciar el estado de colisión
    setState(() {
      _collisionDetected = false;
    });

    // Modo de selección: actualizar el rectángulo de selección o arrastrar el grupo seleccionado
    if (parkingMapState.isEditMode &&
        parkingMapState.editorMode == EditorMode.select) {
      // Si estamos arrastrando múltiples elementos en modo de selección
      if (_draggingMultiple && _selectedElementsStartPositions.isNotEmpty) {
        final delta = details.localFocalPoint - _dragStartPosition!;

        // Convertir el delta de pantalla a delta de mundo
        final worldDelta = vector_math.Vector2(
          delta.dx / parkingMapState.zoom,
          delta.dy / parkingMapState.zoom,
        );

        // Verificar colisiones para cada elemento seleccionado
        bool anyCollision = false;

        for (final selectedElement in parkingMapState.selectedElements) {
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
            final adjustedPosition = parkingMapState.applySmartGuides(
              selectedElement,
              proposedPosition,
            );

            if (_checkCollision(
              parkingMapState,
              selectedElement,
              adjustedPosition,
            )) {
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
            for (final selectedElement in parkingMapState.selectedElements) {
              if (_selectedElementsStartPositions.containsKey(
                    selectedElement.id,
                  ) &&
                  !selectedElement.isLocked) {
                final startPos =
                    _selectedElementsStartPositions[selectedElement.id]!;

                // Calcular la nueva posición propuesta
                final proposedPosition = vector_math.Vector2(
                  startPos.x + worldDelta.x,
                  startPos.y + worldDelta.y,
                );

                // Aplicar guías inteligentes
                final adjustedPosition = parkingMapState.applySmartGuides(
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
            _selectionStartPosition!,
            details.localFocalPoint,
          );
        });
        return;
      }
    }

    // Si es un gesto de escala (zoom)
    if (details.scale != 1.0) {
      final scaleFactor = details.scale / _previousScaleFactor;
      _previousScaleFactor = details.scale;

      // Aplicar zoom con foco en el punto de escala
      parkingMapState.zoomCamera(scaleFactor, details.localFocalPoint);
    }
    // Si es un gesto de arrastre (pan) - solo un dedo
    else if (details.pointerCount == 1 && _dragStartPosition != null) {
      final delta = details.localFocalPoint - _dragStartPosition!;

      // Si estamos arrastrando un elemento en modo edición
      if (parkingMapState.isEditMode && _draggedElement != null) {
        // Convertir delta de pantalla a delta de mundo
        final worldDelta = vector_math.Vector2(
          delta.dx / parkingMapState.zoom,
          delta.dy / parkingMapState.zoom,
        );

        // Calcular la nueva posición propuesta
        final proposedPosition = vector_math.Vector2(
          _elementStartPosition!.x + worldDelta.x,
          _elementStartPosition!.y + worldDelta.y,
        );

        // Aplicar guías inteligentes para obtener la posición final
        final adjustedPosition = parkingMapState.applySmartGuides(
          _draggedElement!,
          proposedPosition,
        );

        // Verificar colisión
        if (_checkCollision(
          parkingMapState,
          _draggedElement!,
          adjustedPosition,
        )) {
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
        parkingMapState.cameraPosition = vector_math.Vector2(
          _cameraStartPosition!.x - delta.dx,
          _cameraStartPosition!.y - delta.dy,
        );
      }
    }
  }

  void _handleScaleEnd(
    ScaleEndDetails details,
    ParkingMapState parkingMapState,
  ) {
    // Finalizar selección por rectángulo
    if (_selectionRect != null &&
        parkingMapState.editorMode == EditorMode.select) {
      // Convertir el rectángulo de selección a coordenadas del mundo
      final worldTopLeft = parkingMapState.camera.screenToWorld(
        Offset(_selectionRect!.left, _selectionRect!.top),
      );

      final worldBottomRight = parkingMapState.camera.screenToWorld(
        Offset(_selectionRect!.right, _selectionRect!.bottom),
      );

      final worldSelectionRect = Rect.fromPoints(
        Offset(worldTopLeft.x, worldTopLeft.y),
        Offset(worldBottomRight.x, worldBottomRight.y),
      );

      // Encontrar todos los elementos dentro del rectángulo de selección
      final elementsInRect = parkingMapState.allElements.where((element) {
        final elementPos = Offset(element.position.x, element.position.y);
        return worldSelectionRect.contains(elementPos);
      }).toList();

      // Si no estamos manteniendo Shift, limpiar la selección actual
      if (!isShiftPressed) {
        parkingMapState.clearSelection();
      }

      // Seleccionar todos los elementos encontrados
      if (elementsInRect.isNotEmpty) {
        parkingMapState.selectMultipleElements(elementsInRect);
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

  void _handleTapDown(TapDownDetails details, ParkingMapState parkingMapState) {
    // Detección de doble tap
    final currentTime = DateTime.now();
    final isDoubleTap =
        _lastTapTime != null &&
        currentTime.difference(_lastTapTime!).inMilliseconds < 300;
    _lastTapTime = currentTime;

    // Guardar la posición del último tap
    _lastTapPosition = details.localPosition;

    if (isDoubleTap) {
      _handleDoubleTap(details, parkingMapState);
      return;
    }

    // Convertir punto de pantalla a mundo
    final worldPoint = parkingMapState.camera.screenToWorld(
      details.localPosition,
    );

    // En modo edición, manejar la selección de elementos para cualquier modo
    if (parkingMapState.isEditMode) {
      // Actualizar la posición del cursor
      parkingMapState.cursorPosition = worldPoint;

      // Encontrar el elemento en la posición del tap
      final element = parkingMapState.findElementAt(worldPoint);

      if (element != null) {
        // Verificar si el elemento ya está en un grupo seleccionado
        // Si está en un grupo, no hacer nada para mantener la selección grupal
        if (parkingMapState.selectedElements.contains(element) &&
            parkingMapState.selectedElements.length > 1) {
          // No hacer nada, mantener la selección múltiple intacta
          return;
        }

        // Si estamos manteniendo Shift, alternar la selección del elemento
        if (isShiftPressed) {
          parkingMapState.toggleElementSelection(element);
        }
        // De lo contrario, seleccionar solo este elemento
        else {
          parkingMapState.clearSelection();
          parkingMapState.selectElement(element);
        }
      } else {
        // Verificar si el clic está en la barra de herramientas
        // Si hay elementos seleccionados, verificar si el clic está cerca de la barra de herramientas
        if (parkingMapState.selectedElements.isNotEmpty) {
          final selectedElement = parkingMapState.selectedElements.first;
          final screenPos = parkingMapState.camera.worldToScreen(
            selectedElement.position,
          );
          final size = selectedElement.getSize();
          final scaledHeight =
              size.height * selectedElement.scale * parkingMapState.zoom;

          // Calcular la posición aproximada de la barra de herramientas
          final toolbarY = screenPos.dy + (scaledHeight / 2) + 10;
          final toolbarX = screenPos.dx;

          // Verificar si el clic está en el área de la barra de herramientas
          final clickX = details.localPosition.dx;
          final clickY = details.localPosition.dy;

          // Área aproximada de la barra de herramientas (ajustar según sea necesario)
          final toolbarArea = Rect.fromCenter(
            center: Offset(toolbarX, toolbarY),
            width: 200, // Ancho aproximado de la barra
            height: 50, // Alto aproximado de la barra
          );

          if (toolbarArea.contains(Offset(clickX, clickY))) {
            debugPrint(
              "Clic detectado en la barra de herramientas, no deseleccionar",
            );
            return; // No deseleccionar si el clic está en la barra de herramientas
          }
        }

        // Solo deseleccionar si no estamos manteniendo Shift y no es un clic en la barra de herramientas
        if (!isShiftPressed) {
          parkingMapState.clearSelection();
        }
      }
    }
    // En modo normal, si hacemos clic en un spot, mostrar modal o destacarlo
    else if (!parkingMapState.isEditMode) {
      final element = parkingMapState.findElementAt(worldPoint);

      // Primero, quitar el destacado de todos los spots
      parkingMapState.clearAllHighlights();

      if (element != null && element is ParkingSpot) {
        // Destacar el spot al hacer clic en él
        element.isHighlighted = true;

        // Mostrar el modal apropiado según el estado del spot
        if (element.status == 'occupied') {
          // Si está ocupado, mostrar modal de acceso
          ManageAccess.show(context, element);
        } else if (element.status == 'reserved') {
          // Si tiene reserva, mostrar modal de reserva
          ManageReservation.show(context, element);
        } else if (element.status == 'subscribed') {
          // Si tiene suscripción, mostrar modal de suscripción
          ManageSubscription.show(context, element);
        } else {
          // Si está libre, mostrar modal de entrada
          RegisterOccupancy.show(context, element);
        }
      }
      // Si se hace clic en un área vacía, simplemente se limpia el destacado (ya realizado arriba)
    }
  }

  // Método para quitar el destacado de todos los spots
  void _clearAllHighlights(ParkingMapState parkingMapState) {
    for (final element in parkingMapState.allElements) {
      if (element is ParkingSpot && element.isHighlighted) {
        element.isHighlighted = false;
      }
    }
  }

  // Método para manejar eventos de teclado
  bool _handleKeyEvent(KeyEvent event) {
    // Actualizar estado de teclas modificadoras
    if (event is KeyDownEvent) {
      setState(() {
        _isShiftPressed =
            event.logicalKey == LogicalKeyboardKey.shiftLeft ||
            event.logicalKey == LogicalKeyboardKey.shiftRight;
      });
    } else if (event is KeyUpEvent) {
      setState(() {
        _isShiftPressed = false;
      });
    }

    final parkingMapState = ParkingMapStateContainer.of(context);
    final keyboardManager = parkingMapState.keyboardShortcutsManager;
    if (keyboardManager != null) {
      // TODO: Actualizar KeyboardShortcutsManager para manejar KeyEvent directamente
      // Por ahora, comentamos esta línea para evitar errores
      // return keyboardManager.handleKeyEvent(_convertKeyEventToRawKeyEvent(event));
    }
    return false;
  }

  // Getter para saber si Shift está pulsado
  bool get isShiftPressed => _isShiftPressed;

  /// Rota el elemento seleccionado en X grados
  void _rotateSelectedElement(ParkingMapState parkingMapState, double degrees) {
    debugPrint("_rotateSelectedElement llamado con $degrees grados");
    if (parkingMapState.selectedElements.length != 1) {
      debugPrint(
        "No hay exactamente un elemento seleccionado: ${parkingMapState.selectedElements.length}",
      );
      return;
    }

    final element = parkingMapState.selectedElements.first;
    debugPrint(
      "Elemento a rotar: ${element.runtimeType} con ID: ${element.id}",
    );

    if (element.isLocked) {
      debugPrint("El elemento está bloqueado, no se puede rotar");
      return;
    }

    final newRotation = element.rotation + degrees;
    debugPrint(
      "Rotación actual: ${element.rotation}, nueva rotación: $newRotation",
    );

    setState(() {
      element.rotation = newRotation;
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Elemento rotado ${degrees > 0 ? 'a la derecha' : 'a la izquierda'}',
        ),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Copia los elementos seleccionados
  void _copySelectedElements(ParkingMapState parkingMapState) {
    if (parkingMapState.selectedElements.isEmpty) return;

    final copiedElements = <ParkingElement>[];

    for (final element in parkingMapState.selectedElements) {
      // Crear una copia del elemento con un offset para que sea visible
      final copy = element.clone();
      copy.position = vector_math.Vector2(
        element.position.x + 20,
        element.position.y + 20,
      );

      parkingMapState.addElement(copy);
      copiedElements.add(copy);
    }

    // Seleccionar los nuevos elementos copiados
    parkingMapState.clearSelection();
    parkingMapState.selectMultipleElements(copiedElements);

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
  void _deleteSelectedElements(ParkingMapState parkingMapState) {
    debugPrint("_deleteSelectedElements llamado");
    if (parkingMapState.selectedElements.isEmpty) {
      debugPrint("No hay elementos seleccionados para eliminar");
      return;
    }

    final count = parkingMapState.selectedElements.length;
    debugPrint("Eliminando $count elementos");

    // Eliminar elementos seleccionados
    for (final element in List.from(parkingMapState.selectedElements)) {
      debugPrint(
        "Eliminando elemento: ${element.runtimeType} con ID: ${element.id}",
      );
      parkingMapState.removeElement(element);
    }

    // Limpiar selección después de eliminar
    parkingMapState.clearSelection();

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
  void _editElementLabel(ParkingMapState parkingMapState) {
    debugPrint("_editElementLabel llamado");
    if (parkingMapState.selectedElements.length != 1) {
      debugPrint(
        "No hay exactamente un elemento seleccionado: ${parkingMapState.selectedElements.length}",
      );
      return;
    }

    final element = parkingMapState.selectedElements.first;
    debugPrint(
      "Elemento seleccionado: ${element.runtimeType} con ID: ${element.id}",
    );

    // No permitir editar señales
    if (element is ParkingSignage) {
      debugPrint("Es una señal, no se permite editar");
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se puede editar el texto de las señales'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Obtener la etiqueta actual
    String currentLabel = element.label ?? '';
    debugPrint("Etiqueta actual: $currentLabel");

    // Si es un ParkingSpot, mostrar opciones adicionales
    if (element is ParkingSpot) {
      debugPrint(
        "Es un ParkingSpot, mostrando diálogo con opciones adicionales",
      );
      final spot = element;

      // Variables para almacenar los valores seleccionados
      SpotType selectedType = spot.type;
      bool isActive = true; // Default to active

      // Mostrar diálogo con opciones adicionales
      showDialog(
        context: context,
        builder: (context) {
          final textController = TextEditingController(text: currentLabel);

          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text('Editar espacio de estacionamiento'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Campo para la etiqueta
                      TextField(
                        controller: textController,
                        decoration: const InputDecoration(
                          labelText: 'Etiqueta',
                          hintText: 'Ingrese una etiqueta para el espacio',
                        ),
                        autofocus: true,
                      ),

                      const SizedBox(height: 24),

                      // Selector de tipo de espacio
                      const Text(
                        'Tipo de espacio',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: SpotType.values.map((type) {
                          final isSelected = selectedType == type;

                          // Determinar el icono según el tipo
                          IconData iconData;
                          switch (type) {
                            case SpotType.bicycle:
                              iconData = Icons.pedal_bike;
                              break;
                            case SpotType.vehicle:
                              iconData = Icons.directions_car;
                              break;
                            case SpotType.motorcycle:
                              iconData = Icons.motorcycle;
                              break;
                            case SpotType.truck:
                              iconData = Icons.local_shipping;
                              break;
                          }

                          return FilterChip(
                            selected: isSelected,
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(iconData, size: 16),
                                const SizedBox(width: 4),
                                Text(_formatSpotType(type)),
                              ],
                            ),
                            onSelected: (selected) {
                              setState(() {
                                selectedType = type;
                              });
                            },
                            backgroundColor: isSelected
                                ? Theme.of(
                                    context,
                                  ).colorScheme.primary.withOpacity(0.1)
                                : null,
                            selectedColor: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.2),
                            checkmarkColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 16),

                      // Checkbox para activar/desactivar el espacio
                      SwitchListTile(
                        title: const Text('Espacio activo'),
                        subtitle: const Text(
                          'Determina si el espacio está disponible para uso',
                        ),
                        value: isActive,
                        onChanged: (value) {
                          setState(() {
                            isActive = value;
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  TextButton(
                    onPressed: () {
                      // Actualizar todos los valores del spot
                      spot.label = textController.text.trim();

                      // Crear un nuevo spot con los valores actualizados
                      final newSpot = ParkingSpot(
                        id: spot.id,
                        position: vector_math.Vector2(
                          spot.position.x,
                          spot.position.y,
                        ),
                        type: selectedType,
                        label: textController.text.trim(),
                        isOccupied: spot.isOccupied,
                        rotation: spot.rotation,
                        scale: spot.scale,
                        isVisible: isActive, // Use isActive for visibility
                        isLocked: spot.isLocked,
                        entry: spot.entry,
                        booking: spot.booking,
                        subscription: spot.subscription,
                        status: spot.status,
                      );

                      // Actualizar el elemento en el estado
                      parkingMapState.updateElement(spot, newSpot);

                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Espacio actualizado'),
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
        },
      );
    } else {
      // Para otros tipos de elementos, mostrar solo edición de etiqueta
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
  }

  // Método auxiliar para formatear el tipo de spot
  String _formatSpotType(SpotType type) {
    switch (type) {
      case SpotType.bicycle:
        return 'Bicicleta';
      case SpotType.vehicle:
        return 'Auto';
      case SpotType.motorcycle:
        return 'Moto';
      case SpotType.truck:
        return 'Camión';
      default:
        return 'Desconocido';
    }
  }

  /// Alinea los elementos seleccionados según la alineación especificada
  void _alignElements(ParkingMapState parkingMapState, Alignment alignment) {
    if (parkingMapState.selectedElements.length <= 1) return;

    // Calcular los límites del grupo seleccionado
    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;

    // Ordenar elementos según su posición para alinear al elemento más externo
    final List<ParkingElement> sortedElementsX = List.from(
      parkingMapState.selectedElements,
    )..sort((a, b) => a.position.x.compareTo(b.position.x));

    final List<ParkingElement> sortedElementsY = List.from(
      parkingMapState.selectedElements,
    )..sort((a, b) => a.position.y.compareTo(b.position.y));

    // Obtener el elemento más a la izquierda, derecha, arriba y abajo
    final ParkingElement leftmostElement = sortedElementsX.first;
    final ParkingElement rightmostElement = sortedElementsX.last;
    final ParkingElement topmostElement = sortedElementsY.first;
    final ParkingElement bottommostElement = sortedElementsY.last;

    // También calcular los límites generales para el centrado
    for (final element in parkingMapState.selectedElements) {
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
      for (final element in parkingMapState.selectedElements) {
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
      for (final element in parkingMapState.selectedElements) {
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
          final minY =
              prevElement.position.y +
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
      for (final element in parkingMapState.selectedElements) {
        if (element.isLocked) continue;
        element.position = vector_math.Vector2(centerX, centerY);
      }

      // Aplicar un ligero desplazamiento radial para evitar sobreposición total
      double angleStep = 2 * math.pi / parkingMapState.selectedElements.length;
      double radius = 10.0; // Radio de separación

      for (int i = 0; i < parkingMapState.selectedElements.length; i++) {
        final element = parkingMapState.selectedElements[i];
        if (element.isLocked) continue;

        double angle = i * angleStep;
        double offsetX = radius * math.cos(angle);
        double offsetY = radius * math.sin(angle);

        element.position = vector_math.Vector2(
          centerX + offsetX,
          centerY + offsetY,
        );
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
  void _distributeElementsEvenly(
    ParkingMapState parkingMapState, {
    required bool horizontal,
    double minSpacing = 20.0,
  }) {
    final elements = parkingMapState.selectedElements;

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
          firstElement.position.x + requiredSpace,
          lastElement.position.y,
        );
      } else {
        lastElement.position = vector_math.Vector2(
          lastElement.position.x,
          firstElement.position.y + requiredSpace,
        );
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
          'Elementos distribuidos uniformemente (espacio: ${spacing.toStringAsFixed(1)})',
        ),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Verifica si hay colisión entre elementos
  bool _checkCollision(
    ParkingMapState parkingMapState,
    ParkingElement element,
    vector_math.Vector2 newPosition,
  ) {
    // Guardar la posición actual
    final originalPosition = vector_math.Vector2(
      element.position.x,
      element.position.y,
    );

    // Mover temporalmente el elemento a la nueva posición para verificar colisión
    element.position = newPosition;

    // Limpiar estado de colisiones previas
    element.clearCollisions();

    // Verificar colisión con todos los demás elementos
    bool collisionDetected = false;
    for (final otherElement in parkingMapState.allElements) {
      // No verificar colisión consigo mismo o elementos seleccionados en grupo
      if (otherElement.id == element.id ||
          parkingMapState.selectedElements.contains(otherElement)) {
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

  // Método para manejar doble tap en un elemento (centrar vista)
  void _handleDoubleTap(
    TapDownDetails details,
    ParkingMapState parkingMapState,
  ) {
    final point = details.localPosition;

    // Convertir punto de pantalla a mundo
    final worldPoint = parkingMapState.camera.screenToWorld(point);

    // Buscar elemento en esta posición
    final element = parkingMapState.findElementAt(worldPoint);

    // Si hay un elemento, centrar vista en él con animación
    if (element != null) {
      parkingMapState.centerViewOnPointWithAnimation(
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
  final ParkingMapState parkingMapState;
  final Rect? selectionRect;
  final ColorScheme colorScheme;

  _ParkingCanvasPainter({
    required this.parkingMapState,
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
        ..color = Colors.blue.withAlpha(77)
        ..style = PaintingStyle.fill;

      canvas.drawRect(selectionRect!, paint);

      final borderPaint = Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;

      canvas.drawRect(selectionRect!, borderPaint);
    }

    // Dibujar rectángulos de corrección para elementos seleccionados
    if (parkingMapState.selectedElements.isNotEmpty) {
      for (final element in parkingMapState.selectedElements) {
        if (!element.isVisible) continue;
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
    if (parkingMapState.canvasSize != size) {
      parkingMapState.canvasSize = size;
    }

    // Guardar el estado del canvas
    canvas.save();

    // Pintar fondo
    _paintBackground(canvas, size);

    // Pintar la cuadrícula si está habilitada
    if (parkingMapState.showGrid) {
      _paintGrid(canvas, size);
    }

    // Pintar el origen de coordenadas
    _paintOrigin(canvas, size);

    // Pintar guías inteligentes si están activas y estamos en modo edición
    if (parkingMapState.isEditMode) {
      _paintSmartGuides(canvas, size);
    }

    // Pintar elementos
    _paintElements(canvas, size);

    // Restaurar el estado del canvas
    canvas.restore();
  }

  /// Pintar la cuadrícula
  void _paintGrid(Canvas canvas, Size size) {
    final gridLines = parkingMapState.gridManager.getVisibleGridLines(
      parkingMapState.cameraPosition,
      parkingMapState.zoom,
      size,
    );

    for (final line in gridLines) {
      final startScreen = parkingMapState.camera.worldToScreen(line.start);
      final endScreen = parkingMapState.camera.worldToScreen(line.end);

      final paint = Paint()
        ..color = line.isMainLine
            ? colorScheme.primary.withAlpha(77)
            : colorScheme.onSurface.withAlpha(26)
        ..strokeWidth = line.thickness
        ..style = PaintingStyle.stroke;

      canvas.drawLine(startScreen, endScreen, paint);
    }
  }

  /// Pintar guías inteligentes
  void _paintSmartGuides(Canvas canvas, Size size) {
    final activeGuides = parkingMapState.gridManager.activeGuides;

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

      final startScreen = parkingMapState.camera.worldToScreen(startWorld);
      final endScreen = parkingMapState.camera.worldToScreen(endWorld);

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
        Offset(startX, startY),
        Offset(currentX, currentY),
        paint,
      );

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
        colors: [colorScheme.surface, colorScheme.surfaceContainerHighest],
        stops: const [0.0, 1.0],
      ).createShader(rect)
      ..style = PaintingStyle.fill;

    canvas.drawRect(rect, paint);
  }

  /// Pintar el origen de coordenadas
  void _paintOrigin(Canvas canvas, Size size) {
    if (!parkingMapState.showCoordinates) return;

    // Calcular la posición del origen en coordenadas de pantalla usando la cámara
    final originScreen = parkingMapState.camera.worldToScreen(
      vector_math.Vector2(0, 0),
    );

    // Dibujar ejes X e Y con el color primario del tema
    final axisPaint = Paint()
      ..color = colorScheme.primary.withAlpha(77)
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
    const crossSize = 12.0;
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
      ..color = colorScheme.primary.withAlpha(51)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawCircle(originScreen, crossSize, circlePaint);
  }

  /// Pintar todos los elementos del mundo
  void _paintElements(Canvas canvas, Size size) {
    // Pintar cada tipo de elemento
    _paintElementGroup(canvas, parkingMapState.facilities, 1.0);
    _paintElementGroup(canvas, parkingMapState.spots, 1.0);
    _paintElementGroup(canvas, parkingMapState.signages, 1.0);
  }

  /// Pintar un grupo de elementos
  void _paintElementGroup(
    Canvas canvas,
    List<ParkingElement> elements,
    double baseOpacity,
  ) {
    for (final element in elements) {
      if (!element.isVisible) continue;
      // Calcular la posición en pantalla usando la cámara
      final positionScreen = parkingMapState.camera.worldToScreen(
        element.position,
      );

      // Guardar el estado del canvas
      canvas.save();

      // Aplicar transformaciones (posición, rotación, escala)
      canvas.translate(positionScreen.dx, positionScreen.dy);
      canvas.rotate(element.rotation * math.pi / 180);

      // Aplicar escala base * escala animada si está disponible
      final animatedScale = element.getAnimatedScale();
      canvas.scale(animatedScale * parkingMapState.zoom);

      // Pintar el elemento con su opacidad
      final opacity = ElementOpacityHelper.getOpacity(element.id);
      if (opacity < 1.0) {
        canvas.saveLayer(
          null,
          Paint()..color = Colors.white.withAlpha((opacity * 255).round()),
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

  /// Dibuja un indicador de selección alrededor del elemento
  void _drawSelectionIndicator(Canvas canvas, ParkingElement element) {
    // Obtener la posición en pantalla
    final screenPos = parkingMapState.camera.worldToScreen(element.position);

    // Obtener dimensiones exactas del elemento
    final size = element.getSize();
    final scaledWidth = size.width * element.scale * parkingMapState.zoom;
    final scaledHeight = size.height * element.scale * parkingMapState.zoom;

    // Rotación en radianes
    final angleRad = element.rotation * math.pi / 180;

    // Calcular el punto inferior del elemento considerando rotación
    final bottomOffsetY = (scaledHeight / 2) * math.cos(angleRad);
    final bottomOffsetX = (scaledHeight / 2) * math.sin(angleRad);

    final bottomPoint = Offset(
      screenPos.dx + bottomOffsetX,
      screenPos.dy + bottomOffsetY,
    );

    // Punto donde debería estar la barra de herramientas (10px más abajo)
    final toolbarPosition = Offset(bottomPoint.dx, bottomPoint.dy + 10);

    final linePaint = Paint()
      ..color = colorScheme.primary.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawLine(bottomPoint, toolbarPosition, linePaint);

    // Dibujar un punto donde debería estar la barra de herramientas
    final pointPaint = Paint()
      ..color = colorScheme.primary
      ..style = PaintingStyle.fill;

    canvas.drawCircle(toolbarPosition, 2.0, pointPaint);
  }
}
