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
  const ParkingCanvas({Key? key}) : super(key: key);

  @override
  State<ParkingCanvas> createState() => _ParkingCanvasState();
}

class _ParkingCanvasState extends State<ParkingCanvas> with TickerProviderStateMixin {
  // Control del gesto de arrastre
  Offset? _dragStartPosition;
  vector_math.Vector2? _cameraStartPosition;
  ParkingElement? _draggedElement;
  vector_math.Vector2? _elementStartPosition;
  
  // Soporte para arrastrar múltiples elementos
  bool _draggingMultiple = false;
  Map<String, vector_math.Vector2> _selectedElementsStartPositions = {};
  
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
    final RenderBox? renderBox = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
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
              onScaleStart: (details) => _handleScaleStart(details, parkingState),
              onScaleUpdate: (details) => _handleScaleUpdate(details, parkingState),
              onScaleEnd: (details) => _handleScaleEnd(details, parkingState),
              
              // Manejar tap para selección o elemento en modo de creación
              onTapDown: (details) => _handleTapDown(details, parkingState),
              
              child: Container(
                key: _canvasKey,
                width: double.infinity,
                height: double.infinity,
                child: Stack(
                  children: [
                    // Canvas principal
                    CustomPaint(
                      painter: _ParkingCanvasPainter(
                        parkingState: parkingState, 
                        selectionRect: _selectionRect,
                      ),
                      size: Size.infinite,
                    ),
                    
                    // Barra de herramientas contextual
                    if (parkingState.isEditMode && parkingState.selectedElements.isNotEmpty)
                      ContextToolbar(
                        parkingState: parkingState,
                        onRotateClockwise: () => _rotateSelectedElement(parkingState, 30),
                        onRotateCounterClockwise: () => _rotateSelectedElement(parkingState, -30),
                        onCopy: () => _copySelectedElements(parkingState),
                        onDelete: () => _deleteSelectedElements(parkingState),
                        onEditLabel: () => _editElementLabel(parkingState),
                        onAlignTop: () => _alignElements(parkingState, Alignment.topCenter),
                        onAlignBottom: () => _alignElements(parkingState, Alignment.bottomCenter),
                        onAlignLeft: () => _alignElements(parkingState, Alignment.centerLeft),
                        onAlignRight: () => _alignElements(parkingState, Alignment.centerRight),
                        onAlignCenter: () => _alignElements(parkingState, Alignment.center),
                        onDistributeHorizontal: () => _distributeElementsEvenly(parkingState, horizontal: true),
                        onDistributeVertical: () => _distributeElementsEvenly(parkingState, horizontal: false),
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
                                Icon(Icons.warning_amber_rounded, color: Colors.white, size: 16),
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
        if (elementAtPos != null && parkingState.selectedElements.contains(elementAtPos)) {
          _draggingMultiple = true;
          
          // Guardar las posiciones iniciales de todos los elementos seleccionados
          _selectedElementsStartPositions.clear();
          for (final selectedElement in parkingState.selectedElements) {
            if (!selectedElement.isLocked) {
              _selectedElementsStartPositions[selectedElement.id] = vector_math.Vector2(
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
      _selectionRect = Rect.fromPoints(_selectionStartPosition!, _selectionStartPosition!);
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
              _selectedElementsStartPositions[selectedElement.id] = vector_math.Vector2(
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
  
  void _handleScaleUpdate(ScaleUpdateDetails details, ParkingState parkingState) {
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
            final startPos = _selectedElementsStartPositions[selectedElement.id]!;
            
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
            
            if (_checkCollision(parkingState, selectedElement, adjustedPosition)) {
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
              if (_selectedElementsStartPositions.containsKey(selectedElement.id) && 
                  !selectedElement.isLocked) {
                final startPos = _selectedElementsStartPositions[selectedElement.id]!;
                
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
          _selectionRect = Rect.fromPoints(_selectionStartPosition!, details.localFocalPoint);
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
    if (_selectionRect != null && parkingState.editorMode == EditorMode.select) {
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
        content: Text('Elemento rotado ${degrees > 0 ? 'a la derecha' : 'a la izquierda'}'),
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
    final List<ParkingElement> sortedElementsX = List.from(parkingState.selectedElements)
      ..sort((a, b) => a.position.x.compareTo(b.position.x));
    
    final List<ParkingElement> sortedElementsY = List.from(parkingState.selectedElements)
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
    final double minSpacing = 10.0; // Espaciado mínimo entre elementos
    
    if (alignment == Alignment.topCenter || alignment == Alignment.bottomCenter) {
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
          final prevElement = sortedElementsX[i-1];
          final prevWidth = elementWidths[prevElement.id] ?? 0;
          final currWidth = elementWidths[element.id] ?? 0;
          
          // Calcular posición X mínima para evitar sobreposición
          final minX = prevElement.position.x + (prevWidth + currWidth) / 2 + minSpacing;
          
          // Si la posición actual ya cumple con el espaciado mínimo, mantenerla
          if (element.position.x >= minX) {
            element.position = vector_math.Vector2(element.position.x, targetY);
          } else {
            // De lo contrario, ajustar la posición X
            element.position = vector_math.Vector2(minX, targetY);
          }
        }
      }
    } else if (alignment == Alignment.centerLeft || alignment == Alignment.centerRight) {
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
          final prevElement = sortedElementsY[i-1];
          final prevHeight = elementHeights[prevElement.id] ?? 0;
          final currHeight = elementHeights[element.id] ?? 0;
          
          // Calcular posición Y mínima para evitar sobreposición
          final minY = prevElement.position.y + (prevHeight + currHeight) / 2 + minSpacing;
          
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
        
        element.position = vector_math.Vector2(
          centerX + offsetX,
          centerY + offsetY
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
  void _distributeElementsEvenly(ParkingState parkingState, {required bool horizontal, double minSpacing = 20.0}) {
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
          firstElement.position.x + requiredSpace,
          lastElement.position.y
        );
      } else {
        lastElement.position = vector_math.Vector2(
          lastElement.position.x,
          firstElement.position.y + requiredSpace
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
        content: Text('Elementos distribuidos uniformemente (espacio: ${spacing.toStringAsFixed(1)})'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  /// Verifica si hay colisión entre elementos
  bool _checkCollision(ParkingState parkingState, ParkingElement element, vector_math.Vector2 newPosition) {
    // Guardar la posición actual
    final originalPosition = vector_math.Vector2(element.position.x, element.position.y);
    
    // Mover temporalmente el elemento a la nueva posición para verificar colisión
    element.position = newPosition;
    
    // Limpiar estado de colisiones previas
    element.clearCollisions();
    
    // Verificar colisión con todos los demás elementos
    bool collisionDetected = false;
    for (final otherElement in parkingState.allElements) {
      // No verificar colisión consigo mismo o elementos seleccionados en grupo
      if (otherElement.id == element.id || parkingState.selectedElements.contains(otherElement)) {
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
    final TextEditingController plateController = TextEditingController();
    String selectedColor = 'Blanco';
    
    // Definir colores disponibles
    final Map<String, Color> colorOptions = {
      'Blanco': Colors.white,
      'Negro': Colors.black87,
      'Gris': Colors.grey,
      'Rojo': Colors.red,
      'Azul': Colors.blue,
      'Verde': Colors.green,
    };
    
    // Obtener el tipo de vehículo automáticamente según el tipo de spot
    String vehicleType = "";
    switch (spot.type) {
      case SpotType.vehicle:
        vehicleType = "Automóvil";
        break;
      case SpotType.motorcycle:
        vehicleType = "Motocicleta";
        break;
      case SpotType.truck:
        vehicleType = "Camión";
        break;
      default:
        vehicleType = "Vehículo";
    }
    
    // Añadir información de categoría especial
    if (spot.category == SpotCategory.disabled) {
      vehicleType += " (Accesibilidad)";
    } else if (spot.category == SpotCategory.vip) {
      vehicleType += " (VIP)";
    } else if (spot.category == SpotCategory.reserved) {
      vehicleType += " (Reservado)";
    }
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Registrar entrada en ${spot.label}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: plateController,
                    decoration: const InputDecoration(
                      labelText: 'Placa del vehículo',
                      hintText: 'Ej: ABC-123',
                    ),
                    textCapitalization: TextCapitalization.characters,
                  ),
                  const SizedBox(height: 16),
                  Text('Tipo: $vehicleType'),
                  const SizedBox(height: 16),
                  const Text('Color del vehículo:'),
                  const SizedBox(height: 8),
                  // Botones de colores simplificados
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: colorOptions.entries.map((entry) {
                      bool isSelected = selectedColor == entry.key;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedColor = entry.key;
                          });
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: entry.value,
                            border: Border.all(
                              color: isSelected ? Colors.blue : Colors.grey,
                              width: isSelected ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              entry.key,
                              style: TextStyle(
                                color: _isColorDark(entry.value) ? Colors.white : Colors.black,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (plateController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Debe ingresar la placa del vehículo'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    
                    // Registrar entrada
                    spot.isOccupied = true;
                    spot.vehiclePlate = plateController.text.trim().toUpperCase();
                    spot.entryTime = DateTime.now();
                    spot.exitTime = null;
                    spot.vehicleColor = selectedColor; // Guardar el color seleccionado
                    
                    // Cerrar el diálogo
                    Navigator.pop(context);
                    
                    // Mostrar confirmación
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Vehículo ${spot.vehiclePlate} registrado en ${spot.label}'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    
                    // Imprimir ticket (simulado)
                    _printEntryTicket(spot, vehicleType, selectedColor);
                  },
                  child: const Text('Registrar entrada'),
                ),
              ],
            );
          }
        );
      },
    );
  }
  
  /// Determinar si un color es oscuro (para usar texto blanco)
  bool _isColorDark(Color color) => 
      (color.red * 0.299 + color.green * 0.587 + color.blue * 0.114) < 128;
  
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
        return AlertDialog(
          title: Text('Registrar salida de ${spot.label}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Placa: ${spot.vehiclePlate ?? "No registrada"}'),
              const SizedBox(height: 8),
              Text('Entrada: ${_formatDateTime(entryTime)}'),
              const SizedBox(height: 8),
              Text('Tiempo: ${_formatDuration(duration)}'),
              const SizedBox(height: 16),
              Text('Tarifa: \$${cost.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                // Imprimir ticket
                _printExitTicket(spot, cost);
                
                // No liberar el espacio aún
                Navigator.pop(context);
              },
              child: const Text('Imprimir ticket'),
            ),
            ElevatedButton(
              onPressed: () {
                // Registrar salida
                spot.isOccupied = false;
                spot.exitTime = now;
                
                // Cerrar el diálogo
                Navigator.pop(context);
                
                // Mostrar confirmación
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Vehículo ${spot.vehiclePlate} ha salido de ${spot.label}'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Confirmar salida'),
            ),
          ],
        );
      },
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
  
  /// Imprimir ticket de entrada (simulado)
  void _printEntryTicket(ParkingSpot spot, String vehicleType, String vehicleColor) {
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
  
  _ParkingCanvasPainter({
    required this.parkingState,
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
            ? Colors.blue.withOpacity(0.3) 
            : Colors.grey.withOpacity(0.15)
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
      
      canvas.drawLine(Offset(startX, startY), Offset(currentX, currentY), paint);
      
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
          Colors.grey[50]!,
          Colors.grey[100]!,
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
    final originScreen = parkingState.camera.worldToScreen(vector_math.Vector2(0, 0));
    
    // Dibujar ejes X e Y
    final axisPaint = Paint()
      ..color = Colors.grey[400]!
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
    
    // Dibujar círculo en el origen
    final originPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      originScreen,
      5.0,
      originPaint,
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
  void _paintElementGroup(Canvas canvas, List<ParkingElement> elements, double baseOpacity) {
    for (final element in elements) {
      // No dibujar si no es visible
      if (!element.isVisible) continue;
      
      // Calcular la posición en pantalla usando la cámara
      final positionScreen = parkingState.camera.worldToScreen(element.position);
      
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
} 