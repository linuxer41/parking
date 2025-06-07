import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vector_math/vector_math.dart' as vector_math;
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';

import '../core/world_state.dart';
import '../core/collision_manager.dart';
import '../core/drag_manager.dart';
import '../engine/world_renderer.dart';
import '../models/parking_spot.dart';
import '../models/world_elements.dart';
import '../utils/drawing_utils.dart';
import '../engine/game_engine.dart';
import '../models/component_system.dart';

/// Enumeración para los modos de edición
enum EditorMode { free, selection }

/// Widget personalizado que muestra el canvas del mundo y maneja las interacciones
class WorldCanvas extends StatefulWidget {
  final bool isEditMode;
  final bool showGrid;
  final double gridSize;
  final Color gridColor;
  final double gridOpacity;
  final bool isDarkMode;
  final Function(ParkingSpot)? onSpotTap;
  final EditorMode editorMode;
  final List<WorldElement> selectedElements;
  final Function(List<WorldElement>)? onElementsSelected;
  final Function(ParkingSpot)? onEditSpotProperties;

  const WorldCanvas({
    Key? key,
    this.isEditMode = false,
    this.showGrid = true,
    this.gridSize = 20.0,
    this.gridColor = Colors.grey,
    this.gridOpacity = 0.3,
    this.isDarkMode = false,
    this.onSpotTap,
    this.editorMode = EditorMode.free,
    this.selectedElements = const [],
    this.onElementsSelected,
    this.onEditSpotProperties,
  }) : super(key: key);

  @override
  State<WorldCanvas> createState() => _WorldCanvasState();
}

class _WorldCanvasState extends State<WorldCanvas> with SingleTickerProviderStateMixin {
  Offset? _dragStart;
  WorldElement? _draggedElement;
  Offset? _elementStartPosition;
  
  // Variables para el modo de selección
  Offset? _selectionStart;
  Offset? _selectionCurrent;
  List<WorldElement> _tempSelectedElements = [];
  
  // Variables para mostrar información durante el arrastre
  bool _isDragging = false;
  Offset? _currentDragPosition;
  
  // Gestor de colisiones
  late CollisionManager _collisionManager;
  
  // Lista de elementos que colisionan durante el arrastre
  List<WorldElement> _collidingElements = [];
  
  // Variables para mostrar mensajes de error temporales
  bool _showErrorMessage = false;
  String _errorMessage = '';
  Timer? _errorMessageTimer;
  
  // Variables para la optimización de repintado
  Offset? _lastPanPosition;
  int _lastFrameTime = 0;
  static const int _frameThrottleMs = 16; // Aproximadamente 60fps
  
  // Cache de elementos para reducir recálculos
  List<WorldElement>? _cachedVisibleElements;
  Size? _lastCanvasSize;
  double? _lastZoom;
  vector_math.Vector2? _lastCameraPosition;
  
  // Variables para zoom con gestos
  double _scaleStart = 1.0;
  Offset? _lastFocalPoint;
  bool _isScaling = false;
  
  // Variables para indicador visual de zoom
  bool _showZoomIndicator = false;
  Timer? _zoomIndicatorTimer;
  
  // Constantes para el zoom
  static const double _minZoom = 0.2;
  static const double _maxZoom = 5.0;
  static const double _zoomSensitivity = 0.001; // Para scroll de mouse
  static const double _zoomAnimationDuration = 250; // ms

  @override
  void initState() {
    super.initState();
    
    // Otras inicializaciones existentes...
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Inicializar el motor de juego cuando el contexto está disponible
    final worldState = Provider.of<WorldState>(context, listen: false);
    worldState.initGameEngine(this);
  }

  @override
  void dispose() {
    // Detener el motor de juego
    final worldState = Provider.of<WorldState>(context, listen: false);
    worldState.stopGameEngine();
    
    _errorMessageTimer?.cancel();
    _zoomIndicatorTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WorldState>(
      builder: (context, state, child) {
        // Inicializar el gestor de colisiones con el estado actual
        _collisionManager = CollisionManager(state: state);
        
        // Configurar el tamaño de la cuadrícula en el DragManager
        state.dragManager.gridSize = widget.gridSize;
        state.dragManager.enableSnapToGrid = widget.showGrid;
        
        // Suscribirse a eventos de colisión
        state.addListener(() {
          if (state.collisionErrorMessage.isNotEmpty) {
            _showTemporaryErrorMessage(state.collisionErrorMessage);
            // Limpiar el mensaje después de mostrarlo
            state.clearCollisionErrorMessage();
          }
        });
        
        // Usar KeyboardListener para teclas de zoom
        return KeyboardListener(
          focusNode: FocusNode()..requestFocus(),
          onKeyEvent: (keyEvent) {
            if (keyEvent is KeyDownEvent) {
              // Zoom con teclas + y -
              if (keyEvent.logicalKey == LogicalKeyboardKey.equal || 
                  keyEvent.logicalKey == LogicalKeyboardKey.numpadAdd) {
                _adjustZoom(state, state.zoom * 1.2);
              } else if (keyEvent.logicalKey == LogicalKeyboardKey.minus ||
                         keyEvent.logicalKey == LogicalKeyboardKey.numpadSubtract) {
                _adjustZoom(state, state.zoom / 1.2);
              }
            }
          },
          child: Listener(
            onPointerSignal: (PointerSignalEvent event) {
              // Manejar zoom con rueda del mouse
              if (event is PointerScrollEvent) {
                final double delta = event.scrollDelta.dy * _zoomSensitivity;
                final double newZoom = state.zoom * (1 - delta);
                _adjustZoom(state, newZoom, focalPoint: event.localPosition);
              }
            },
            child: Stack(
              children: [
                GestureDetector(
                  // Soporte para gestos de escala (pinch)
                  onScaleStart: (ScaleStartDetails details) {
                    _scaleStart = state.zoom;
                    _lastFocalPoint = details.focalPoint;
                    _isScaling = true;
                    
                    // Manejar la lógica de onPanStart
                    final worldState = Provider.of<WorldState>(context, listen: false);
                    final position = details.localFocalPoint;

                    // Si estamos en modo edición
                    if (widget.isEditMode) {
                      // Verificar si se hizo clic en un botón de la barra de herramientas
                      if (_handleToolbarButtonClick(worldState, position)) {
                        return; // Si se hizo clic en un botón, no continuar con el arrastre
                      }

                      // Convertir posición de pantalla a mundo
                      final worldX =
                          (position.dx + worldState.cameraPosition.x) / worldState.zoom;
                      final worldY =
                          (position.dy + worldState.cameraPosition.y) / worldState.zoom;

                      // Detectar teclas modificadoras
                      final isShiftPressed = HardwareKeyboard.instance.isShiftPressed;
                      final isControlPressed = HardwareKeyboard.instance.isControlPressed;

                      // En modo selección, iniciar un rectángulo de selección
                      if (widget.editorMode == EditorMode.selection) {
                        setState(() {
                          _selectionStart = position;
                          _selectionCurrent = position;
                          _tempSelectedElements = [];
                        });
                        return;
                      }

                      // En modo libre, buscar elemento en la posición para arrastrar
                      WorldElement? element;
                      for (final e in worldState.allElements) {
                        final worldPosition = vector_math.Vector2(worldX, worldY);
                        if (e.containsPoint(worldPosition)) {
                          element = e;
                          break;
                        }
                      }

                      setState(() {
                        _dragStart = position;
                        _currentDragPosition = position;

                        // Si hay un elemento, preparar para arrastre
                        if (element != null) {
                          _draggedElement = element;
                          _elementStartPosition =
                              Offset(element.position.x, element.position.y);
                          
                          // Seleccionar el elemento con las teclas modificadoras
                          worldState.selectElement(element, 
                              isShiftPressed: isShiftPressed, 
                              isControlPressed: isControlPressed);
                          
                          // Inicializar el DragManager si hay elementos seleccionados
                          if (worldState.selectedElements.length > 1) {
                            worldState.dragManager.startMultiDrag(position, worldState.selectedElements);
                          } else {
                            worldState.dragManager.startDrag(position, element);
                          }
                          
                          _isDragging = true;
                        } else {
                          // Si no hay elemento y no se presionan teclas modificadoras, limpiar selección
                          if (!isShiftPressed && !isControlPressed) {
                            worldState.clearSelection();
                          }
                          _isDragging = false;
                        }
                      });
                    } 
                    // Modo visualización - solo guardar posición inicial para mover el canvas
                    else {
                      setState(() {
                        _dragStart = position;
                        _isDragging = false;
                      });
                    }
                  },
                  onScaleUpdate: (ScaleUpdateDetails details) {
                    final worldState = Provider.of<WorldState>(context, listen: false);
                    final position = details.localFocalPoint;
                    
                    // Aplicar throttling para limitar la tasa de actualización
                    final now = DateTime.now().millisecondsSinceEpoch;
                    if (now - _lastFrameTime < _frameThrottleMs && _lastPanPosition != null) {
                      // Acumular el delta sin repintar
                      _lastPanPosition = position;
                      return;
                    }
                    
                    _lastFrameTime = now;
                    _lastPanPosition = position;
                    
                    setState(() {
                      _currentDragPosition = position;
                    });
                    
                    // Si es un gesto de escala (pinch)
                    if (details.scale != 1.0) {
                      final double newZoom = (_scaleStart * details.scale).clamp(_minZoom, _maxZoom);
                      _adjustZoom(state, newZoom, focalPoint: details.focalPoint);
                    } 
                    // Si es arrastre durante un gesto
                    else if (_lastFocalPoint != null) {
                      // Si estamos en modo edición
                      if (widget.isEditMode) {
                        // En modo selección, actualizar el rectángulo de selección
                        if (widget.editorMode == EditorMode.selection && _selectionStart != null) {
                          setState(() {
                            _selectionCurrent = position;
                            
                            // Calcular qué elementos están dentro del rectángulo de selección
                            _updateSelectionElements(worldState);
                          });
                          return;
                        }

                        // En modo libre con _dragStart definido
                        if (_dragStart != null) {
                          // Si estamos arrastrando un elemento
                          if (_draggedElement != null && _elementStartPosition != null) {
                            // Usar el DragManager para manejar el arrastre y alineamiento
                            if (!worldState.dragManager.isDragging) {
                              // Iniciar el arrastre si aún no se ha iniciado
                              if (worldState.selectedElements.length > 1) {
                                worldState.dragManager.startMultiDrag(_dragStart!, worldState.selectedElements);
                              } else {
                                worldState.dragManager.startDrag(_dragStart!, _draggedElement);
                              }
                            }
                            
                            // Actualizar la posición durante el arrastre
                            worldState.dragManager.updateDrag(position);
                            
                            // Verificar colisiones
                            if (worldState.selectedElements.length > 1) {
                              _checkCollisionsForSelectedElements(worldState);
                            } else {
                              _checkCollision(worldState, _draggedElement!);
                            }
                          } else {
                            // Si no hay elemento, mover la cámara
                            _moveCamera(worldState, position);
                          }
                        }
                      } 
                      // En modo visualización, mover la cámara
                      else if (_dragStart != null) {
                        _moveCamera(worldState, position);
                      }
                      
                      _lastFocalPoint = details.focalPoint;
                    }
                  },
                  onScaleEnd: (ScaleEndDetails details) {
                    final worldState = Provider.of<WorldState>(context, listen: false);
                    
                    // Si estamos en modo edición
                    if (widget.isEditMode) {
                      // Finalizar el arrastre si estaba en progreso
                      if (worldState.dragManager.isDragging) {
                        worldState.dragManager.endDrag();
                      }
                      
                      // En modo selección, finalizar la selección
                      if (widget.editorMode == EditorMode.selection && _selectionStart != null) {
                        // Detectar teclas modificadoras
                        final isShiftPressed = HardwareKeyboard.instance.isShiftPressed;
                        final isControlPressed = HardwareKeyboard.instance.isControlPressed;
                        
                        // Crear rectángulo de selección
                        final selectionRect = Rect.fromPoints(_selectionStart!, _selectionCurrent!);
                        
                        // Aplicar selección con teclas modificadoras
                        worldState.selectElementsInRect(selectionRect, 
                            isShiftPressed: isShiftPressed, 
                            isControlPressed: isControlPressed);
                        
                        // Notificar elementos seleccionados
                        if (widget.onElementsSelected != null) {
                          widget.onElementsSelected!(worldState.selectedElements);
                        }
                        
                        setState(() {
                          _selectionStart = null;
                          _selectionCurrent = null;
                          _tempSelectedElements.clear();
                        });
                      }
                    }
                    
                    // Limpiar variables de arrastre (en ambos modos)
                    setState(() {
                      _dragStart = null;
                      _draggedElement = null;
                      _elementStartPosition = null;
                      _isDragging = false;
                      _currentDragPosition = null;
                      _collidingElements.clear();
                      _isScaling = false;
                      _lastFocalPoint = null;
                    });
                  },

                  // Tap para seleccionar
                  onTapDown: (details) {
                    final worldState = Provider.of<WorldState>(context, listen: false);
                    final position = details.localPosition;

                    // Verificar si se hizo clic en un botón de la barra de herramientas
                    if (widget.isEditMode && _handleToolbarButtonClick(worldState, position)) {
                      return; // Si se hizo clic en un botón, no continuar con la selección
                    }

                    // Convertir posición de pantalla a mundo
                    final worldX =
                        (position.dx + worldState.cameraPosition.x) / worldState.zoom;
                    final worldY =
                        (position.dy + worldState.cameraPosition.y) / worldState.zoom;

                    // Detectar teclas modificadoras
                    final isShiftPressed = HardwareKeyboard.instance.isShiftPressed;
                    final isControlPressed = HardwareKeyboard.instance.isControlPressed;

                    // Buscar elemento en la posición
                    for (final element in worldState.allElements) {
                      final worldPosition = vector_math.Vector2(worldX, worldY);
                      if (element.containsPoint(worldPosition)) {
                        // En modo normal, solo permitir interactuar con espacios de estacionamiento
                        if (!widget.isEditMode) {
                          if (element is ParkingSpot && widget.onSpotTap != null) {
                            widget.onSpotTap!(element);
                            return;
                          }
                        } else {
                          worldState.selectElement(element, isShiftPressed: isShiftPressed, isControlPressed: isControlPressed);
                          return;
                        }
                      }
                    }

                    // Si no hay elemento, limpiar selección (solo en modo edición)
                    if (widget.isEditMode) {
                      worldState.clearSelection();
                    }
                  },
                  
                  // Configuración esencial para detectar gestos
                  behavior: HitTestBehavior.opaque,

                  child: CustomPaint(
                    painter: _WorldPainter(
                      state: state,
                      showGrid: widget.showGrid,
                      gridSize: widget.gridSize,
                      gridColor: widget.gridColor,
                      gridOpacity: widget.gridOpacity,
                      isDarkMode: widget.isDarkMode,
                      selectedElements: widget.selectedElements,
                      collisionManager: _collisionManager,
                      showCollisions: _isDragging,
                    ),
                    size: Size.infinite,
                  ),
                ),
                
                // Rectángulo de selección (solo en modo selección)
                if (widget.editorMode == EditorMode.selection && 
                    _selectionStart != null && 
                    _selectionCurrent != null)
                  CustomPaint(
                    painter: _SelectionPainter(
                      start: _selectionStart!,
                      current: _selectionCurrent!,
                    ),
                    size: Size.infinite,
                  ),
                
                // Líneas de alineamiento (cuando se está arrastrando)
                if (_isDragging && _draggedElement != null)
                  Consumer<WorldState>(
                    builder: (context, state, _) {
                      // Obtener el drag manager
                      final dragManager = state.dragManager;
                      
                      // Verificar si hay alineamiento activo
                      final hasHorizontalAlignment = dragManager.hasHorizontalAlignment;
                      final hasVerticalAlignment = dragManager.hasVerticalAlignment;
                      
                      // Si no hay alineamiento, no dibujar nada
                      if (!hasHorizontalAlignment && !hasVerticalAlignment) {
                        return const SizedBox.shrink();
                      }
                      
                      return CustomPaint(
                        painter: _AlignmentPainter(
                          hasHorizontalAlignment: hasHorizontalAlignment,
                          hasVerticalAlignment: hasVerticalAlignment,
                          horizontalPosition: dragManager.horizontalAlignmentPosition,
                          verticalPosition: dragManager.verticalAlignmentPosition,
                          zoom: state.zoom,
                          cameraPosition: state.cameraPosition,
                        ),
                        size: Size.infinite,
                      );
                    },
                  ),
                
                // Mostrar etiqueta de posición durante el arrastre
                if (_isDragging && _draggedElement != null && _currentDragPosition != null)
                  Positioned(
                    left: _currentDragPosition!.dx + 15,
                    top: _currentDragPosition!.dy - 40,
                    child: _buildDraggingLabel(state),
                  ),
                
                // Mostrar mensaje de error temporal
                if (_showErrorMessage)
                  Positioned(
                    bottom: 100,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _errorMessage,
                              style: const TextStyle(
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

                // Añadir el indicador visual de zoom
                if (_showZoomIndicator)
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            state.zoom > 1.0 ? Icons.zoom_in : Icons.zoom_out,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${(state.zoom * 100).toInt()}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  /// Construye la etiqueta que se muestra durante el arrastre
  Widget _buildDraggingLabel(WorldState state) {
    if (_draggedElement == null) return const SizedBox();
    
    // Obtener información de posición
    final posX = _draggedElement!.position.x.toInt();
    final posY = _draggedElement!.position.y.toInt();
    final label = _draggedElement!.label ?? 'Sin etiqueta';
    
    // Determinar el color de la etiqueta según si hay colisión
    final bool hasCollision = _collidingElements.isNotEmpty;
    final Color bgColor = hasCollision 
        ? Colors.red.withOpacity(0.9) 
        : Colors.black.withOpacity(0.8);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Pos: ($posX, $posY)',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
            ),
          ),
          if (hasCollision)
            Text(
              '¡Colisión detectada!',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  /// Método para actualizar elementos dentro del rectángulo de selección
  void _updateSelectionElements(WorldState worldState) {
    if (_selectionStart == null || _selectionCurrent == null) return;
    
    // Detectar teclas modificadoras
    final isShiftPressed = HardwareKeyboard.instance.isShiftPressed;
    final isControlPressed = HardwareKeyboard.instance.isControlPressed;
    
    // Crear rectángulo de selección en coordenadas de pantalla
    final selectionRect = Rect.fromPoints(_selectionStart!, _selectionCurrent!);
    
    // Lista temporal de elementos seleccionados
    final tempSelected = <WorldElement>[];
    
    // Verificar qué elementos están dentro del rectángulo
    for (final element in worldState.allElements) {
      // Convertir posición del elemento a coordenadas de pantalla
      final screenPos = DrawingUtils.worldToScreenPosition(
        element.position,
        worldState.zoom,
        worldState.cameraPosition,
      );
      
      // Si el centro del elemento está dentro del rectángulo, seleccionarlo
      if (selectionRect.contains(Offset(screenPos.x, screenPos.y))) {
        tempSelected.add(element);
        
        // Si estamos usando Control y ya está seleccionado, no hacemos nada
        // (se mantendrá la selección actual hasta que se complete el arrastre)
        if (isControlPressed && worldState.selectedElements.contains(element)) {
          continue;
        }
        
        element.isSelected = true;
      } else if (_tempSelectedElements.contains(element) && 
                !worldState.selectedElements.contains(element)) {
        // Si estaba en la selección temporal pero ya no está en el rectángulo
        // y no está en la selección permanente, deseleccionarlo solo si no usamos teclas
        if (!isShiftPressed && !isControlPressed) {
          element.isSelected = false;
        }
      }
    }
    
    _tempSelectedElements = tempSelected;
    worldState.notifyListeners(); // Notificar cambios para redibujar
  }

  /// Método para manejar clics en los botones de la barra de herramientas
  bool _handleToolbarButtonClick(WorldState worldState, Offset position) {
    if (!widget.isEditMode || worldState.firstSelectedElement == null) {
      return false;
    }

    final element = worldState.firstSelectedElement!;
    final screenPos = DrawingUtils.worldToScreenPosition(
      element.position,
      worldState.zoom,
      worldState.cameraPosition,
    );

    // Calcular posición de la barra de herramientas
    final toolbarY = screenPos.y + (element.size.height * worldState.zoom / 2) + 15;
    final toolbarX = screenPos.x;

    // Configuración de la barra de herramientas - más compacta y minimalista
    final iconSize = 16.0;
    final iconSpacing = 12.0;
    final totalButtons = 5; // Eliminar, Rotar izq, Rotar der, Copiar, Editar etiqueta
    final totalWidth =
        (iconSize * totalButtons) + (iconSpacing * (totalButtons - 1));

    // Verificar si el clic está dentro del área de la barra de herramientas
    final toolbarRect = Rect.fromCenter(
      center: Offset(toolbarX, toolbarY),
      width: totalWidth + 16,
      height: iconSize + 12,
    );

    if (!toolbarRect.contains(position)) {
      return false; // Clic fuera de la barra de herramientas
    }

    // Posiciones de los iconos
    final startX = toolbarX - totalWidth / 2 + iconSize / 2;

    // Áreas de detección para cada icono (un poco más grandes que el icono para facilitar el clic)
    final hitSize = iconSize * 1.5;

    // 1. Icono eliminar
    final deleteIconRect = Rect.fromCenter(
      center: Offset(startX, toolbarY),
      width: hitSize,
      height: hitSize,
    );

    if (deleteIconRect.contains(position)) {
      worldState.deleteSelectedElements();
      return true;
    }

    // 2. Icono rotar antihorario (izquierda)
    final rotateLeftIconRect = Rect.fromCenter(
      center: Offset(startX + iconSize + iconSpacing, toolbarY),
      width: hitSize,
      height: hitSize,
    );

    if (rotateLeftIconRect.contains(position)) {
      worldState.rotateSelectedElementCounterClockwise();
      return true;
    }

    // 3. Icono rotar horario (derecha)
    final rotateRightIconRect = Rect.fromCenter(
      center: Offset(startX + (iconSize + iconSpacing) * 2, toolbarY),
      width: hitSize,
      height: hitSize,
    );

    if (rotateRightIconRect.contains(position)) {
      worldState.rotateSelectedElementClockwise();
      return true;
    }

    // 4. Icono copiar
    final copyIconRect = Rect.fromCenter(
      center: Offset(startX + (iconSize + iconSpacing) * 3, toolbarY),
      width: hitSize,
      height: hitSize,
    );

    if (copyIconRect.contains(position)) {
      worldState.copySelectedElements();
      return true;
    }

    // 5. Icono editar etiqueta
    final editIconRect = Rect.fromCenter(
      center: Offset(startX + (iconSize + iconSpacing) * 4, toolbarY),
      width: hitSize,
      height: hitSize,
    );

    if (editIconRect.contains(position)) {
      _showLabelEditDialog(context, element, worldState);
      return true;
    }

    return false; // No se hizo clic en ningún icono
  }

  /// Mostrar diálogo para editar la etiqueta
  void _showLabelEditDialog(
      BuildContext context, WorldElement element, WorldState worldState) {
    // Si el elemento es un espacio de estacionamiento y tenemos la función callback, usarla
    if (element is ParkingSpot && widget.onEditSpotProperties != null) {
      // No cerramos ningún diálogo aquí, simplemente llamamos al callback
      widget.onEditSpotProperties!(element);
      return;
    }
    
    // Para otros tipos de elementos o si no tenemos la función callback
    final TextEditingController controller =
        TextEditingController(text: element.label);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar etiqueta'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Etiqueta',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              element.label = controller.text;
              worldState.notifyListeners();
              Navigator.of(context).pop();
            },
            child: Text('Guardar'),
          ),
        ],
      ),
    );
  }

  /// Método para mostrar un mensaje de error temporal
  void _showTemporaryErrorMessage(String message) {
    setState(() {
      _showErrorMessage = true;
      _errorMessage = message;
    });
    
    // Cancelar el timer anterior si existe
    _errorMessageTimer?.cancel();
    
    // Crear un nuevo timer para ocultar el mensaje después de 3 segundos
    _errorMessageTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showErrorMessage = false;
        });
      }
    });
  }

  /// Verificar colisiones para todos los elementos seleccionados
  void _checkCollisionsForSelectedElements(WorldState worldState) {
    _collidingElements.clear();
    
    for (final element in worldState.selectedElements) {
      final collisions = _collisionManager.findCollidingElements(element);
      if (collisions.isNotEmpty) {
        _collidingElements.addAll(collisions);
      }
    }
  }
  
  /// Verificar colisión para un solo elemento
  void _checkCollision(WorldState worldState, WorldElement element) {
    _collidingElements = _collisionManager.findCollidingElements(element);
  }
  
  /// Invalidar caché cuando cambian las condiciones
  void _invalidateCache() {
    _cachedVisibleElements = null;
    _lastCanvasSize = null;
    _lastZoom = null;
    _lastCameraPosition = null;
  }

  /// Método auxiliar para mover la cámara
  void _moveCamera(WorldState worldState, Offset position) {
    if (_dragStart == null) return;
    
    final delta = vector_math.Vector2(
      position.dx - _dragStart!.dx,
      position.dy - _dragStart!.dy,
    );
    
    worldState.moveCamera(delta);
    
    // Invalidar caché cuando se mueve la cámara
    _invalidateCache();
    
    // Actualizar posición de inicio para el próximo frame
    _dragStart = position;
  }

  /// Método para mostrar el indicador de zoom temporalmente
  void _showTemporaryZoomIndicator(WorldState state) {
    setState(() {
      _showZoomIndicator = true;
    });
    
    // Cancelar timer anterior si existe
    _zoomIndicatorTimer?.cancel();
    
    // Ocultar el indicador después de un tiempo
    _zoomIndicatorTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _showZoomIndicator = false;
        });
      }
    });
  }

  /// Método para ajustar el zoom con animación
  void _adjustZoom(WorldState worldState, double newZoom, {Offset? focalPoint}) {
    // Asegurar que el zoom esté dentro de los límites
    newZoom = newZoom.clamp(_minZoom, _maxZoom);
    
    // Si el zoom no cambió, no hacer nada
    if (newZoom == worldState.zoom) return;
    
    // Guardar posición anterior del punto focal
    final Offset viewportCenter = focalPoint ?? Offset(
      context.size?.width ?? 0 / 2, 
      context.size?.height ?? 0 / 2
    );
    
    // Convertir el punto focal a coordenadas del mundo antes del zoom
    final worldPointX = (viewportCenter.dx + worldState.cameraPosition.x) / worldState.zoom;
    final worldPointY = (viewportCenter.dy + worldState.cameraPosition.y) / worldState.zoom;
    
    // Aplicar nuevo zoom
    worldState.setZoom(newZoom);
    
    // Ajustar la posición de la cámara para mantener el punto focal
    final newScreenPointX = worldPointX * newZoom;
    final newScreenPointY = worldPointY * newZoom;
    
    final offsetX = newScreenPointX - viewportCenter.dx;
    final offsetY = newScreenPointY - viewportCenter.dy;
    
    // Usar el método existente moveCamera con la nueva posición
    final newCameraPos = vector_math.Vector2(
      offsetX, offsetY
    );
    
    worldState.cameraPosition.x = offsetX;
    worldState.cameraPosition.y = offsetY;
    worldState.notifyListeners();
    
    // Mostrar indicador de zoom
    _showTemporaryZoomIndicator(worldState);
    
    // Invalidar caché
    _invalidateCache();
  }
}

/// CustomPainter para dibujar el mundo
class _WorldPainter extends CustomPainter {
  final WorldState state;
  final bool showGrid;
  final double gridSize;
  final Color gridColor;
  final double gridOpacity;
  final bool isDarkMode;
  final List<WorldElement> selectedElements;
  final CollisionManager collisionManager;
  final bool showCollisions;

  _WorldPainter({
    required this.state,
    this.showGrid = true,
    this.gridSize = 20.0,
    this.gridColor = Colors.grey,
    this.gridOpacity = 0.3,
    this.isDarkMode = false,
    this.selectedElements = const [],
    required this.collisionManager,
    this.showCollisions = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Dibujar fondo
    final backgroundPaint = Paint()
      ..color = isDarkMode ? Colors.grey[900]! : Colors.grey[100]!;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);

    // Dibujar cuadrícula si está habilitada
    if (showGrid) {
      _drawGrid(canvas, size);
    }

    // Crear renderer y dibujar elementos
    final renderer = WorldRenderer(
      state: state,
      canvasSize: size,
    );

    renderer.render(canvas);
    
    // Dibujar visualización de colisiones si está habilitado
    if (showCollisions) {
      collisionManager.debugDrawCollisions(canvas, state.zoom, state.cameraPosition);
    }
  }

  void _drawGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    final gridWidth = size.width;
    final gridHeight = size.height;

    for (double x = 0; x < gridWidth; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, gridHeight), paint);
    }

    for (double y = 0; y < gridHeight; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(gridWidth, y), paint);
    }
  }

  @override
  bool shouldRepaint(_WorldPainter oldDelegate) {
    return oldDelegate.state != state ||
        oldDelegate.showGrid != showGrid ||
        oldDelegate.gridSize != gridSize ||
        oldDelegate.gridColor != gridColor ||
        oldDelegate.gridOpacity != gridOpacity ||
        oldDelegate.isDarkMode != isDarkMode ||
        oldDelegate.selectedElements != selectedElements ||
        oldDelegate.showCollisions != showCollisions;
  }
}

/// Pintor para el rectángulo de selección con estilo minimalista
class _SelectionPainter extends CustomPainter {
  final Offset start;
  final Offset current;
  
  _SelectionPainter({
    required this.start,
    required this.current,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromPoints(start, current);
    
    // Dibujar fondo ultraligero
    final Paint fillPaint = Paint()
      ..color = Colors.blue.withOpacity(0.04) // Muy sutil
      ..style = PaintingStyle.fill;
    
    // Dibujar borde con un estilo minimalista
    final Paint borderPaint = Paint()
      ..color = Colors.blue.withOpacity(0.5) // Menos opaco
      ..strokeWidth = 0.8 // Más fino
      ..style = PaintingStyle.stroke;
    
    // Rectángulo con esquinas ligeramente redondeadas
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(2.0));
    
    // Dibujar el fondo y borde principal
    canvas.drawRRect(rrect, fillPaint);
    canvas.drawRRect(rrect, borderPaint);
    
    // Dibujar pequeñas líneas en las esquinas para un aspecto más elegante
    final cornerPaint = Paint()
      ..color = Colors.blue.withOpacity(0.8) // Más visible
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    
    final cornerSize = 6.0; // Tamaño de las esquinas
    
    // Esquina superior izquierda
    canvas.drawLine(
      Offset(rect.left, rect.top + cornerSize),
      Offset(rect.left, rect.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.top),
      Offset(rect.left + cornerSize, rect.top),
      cornerPaint,
    );
    
    // Esquina superior derecha
    canvas.drawLine(
      Offset(rect.right - cornerSize, rect.top),
      Offset(rect.right, rect.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.top),
      Offset(rect.right, rect.top + cornerSize),
      cornerPaint,
    );
    
    // Esquina inferior izquierda
    canvas.drawLine(
      Offset(rect.left, rect.bottom - cornerSize),
      Offset(rect.left, rect.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.bottom),
      Offset(rect.left + cornerSize, rect.bottom),
      cornerPaint,
    );
    
    // Esquina inferior derecha
    canvas.drawLine(
      Offset(rect.right - cornerSize, rect.bottom),
      Offset(rect.right, rect.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.bottom),
      Offset(rect.right, rect.bottom - cornerSize),
      cornerPaint,
    );
    
    // Efecto de sombra interior muy sutil
    final innerGlowPaint = Paint()
      ..color = Colors.blue.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..maskFilter = MaskFilter.blur(BlurStyle.inner, 1.5);
    
    final innerRect = rect.deflate(1.0);
    final innerRRect = RRect.fromRectAndRadius(innerRect, Radius.circular(1.0));
    canvas.drawRRect(innerRRect, innerGlowPaint);
  }
  
  @override
  bool shouldRepaint(covariant _SelectionPainter oldDelegate) {
    return oldDelegate.start != start || oldDelegate.current != current;
  }
}

/// Painter para dibujar líneas de alineamiento
class _AlignmentPainter extends CustomPainter {
  final bool hasHorizontalAlignment;
  final bool hasVerticalAlignment;
  final double horizontalPosition;
  final double verticalPosition;
  final double zoom;
  final vector_math.Vector2 cameraPosition;
  
  _AlignmentPainter({
    required this.hasHorizontalAlignment,
    required this.hasVerticalAlignment,
    required this.horizontalPosition,
    required this.verticalPosition,
    required this.zoom,
    required this.cameraPosition,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    // Estilo para las líneas de alineamiento - Más visibles
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.9) // Más opaco
      ..strokeWidth = 1.5  // Más grueso
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    // Dibujar línea horizontal de alineamiento
    if (hasHorizontalAlignment) {
      // Convertir posición del mundo a pantalla
      final screenY = horizontalPosition * zoom - cameraPosition.y;
      
      // Dibujar línea horizontal punteada
      final path = Path();
      final dashWidth = 8.0;  // Dashes más largos
      final dashSpace = 4.0;  // Espacios más cortos
      double startX = 0;
      
      while (startX < size.width) {
        path.moveTo(startX, screenY);
        path.lineTo(startX + dashWidth, screenY);
        startX += dashWidth + dashSpace;
      }
      
      canvas.drawPath(path, paint);
      
      // Añadir indicadores en los extremos
      final indicatorPaint = Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.fill;
      
      // Círculos pequeños en los extremos
      canvas.drawCircle(Offset(5, screenY), 3, indicatorPaint);
      canvas.drawCircle(Offset(size.width - 5, screenY), 3, indicatorPaint);
    }
    
    // Dibujar línea vertical de alineamiento
    if (hasVerticalAlignment) {
      // Convertir posición del mundo a pantalla
      final screenX = verticalPosition * zoom - cameraPosition.x;
      
      // Dibujar línea vertical punteada
      final path = Path();
      final dashHeight = 8.0;  // Dashes más largos
      final dashSpace = 4.0;   // Espacios más cortos
      double startY = 0;
      
      while (startY < size.height) {
        path.moveTo(screenX, startY);
        path.lineTo(screenX, startY + dashHeight);
        startY += dashHeight + dashSpace;
      }
      
      canvas.drawPath(path, paint);
      
      // Añadir indicadores en los extremos
      final indicatorPaint = Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.fill;
      
      // Círculos pequeños en los extremos
      canvas.drawCircle(Offset(screenX, 5), 3, indicatorPaint);
      canvas.drawCircle(Offset(screenX, size.height - 5), 3, indicatorPaint);
    }
    
    // Añadir un efecto de brillo sutil alrededor de las líneas
    if (hasHorizontalAlignment || hasVerticalAlignment) {
      final glowPaint = Paint()
        ..color = Colors.blue.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3.0);
      
      if (hasHorizontalAlignment) {
        final screenY = horizontalPosition * zoom - cameraPosition.y;
        canvas.drawLine(Offset(0, screenY), Offset(size.width, screenY), glowPaint);
      }
      
      if (hasVerticalAlignment) {
        final screenX = verticalPosition * zoom - cameraPosition.x;
        canvas.drawLine(Offset(screenX, 0), Offset(screenX, size.height), glowPaint);
      }
    }
  }
  
  @override
  bool shouldRepaint(_AlignmentPainter oldDelegate) {
    return hasHorizontalAlignment != oldDelegate.hasHorizontalAlignment ||
           hasVerticalAlignment != oldDelegate.hasVerticalAlignment ||
           horizontalPosition != oldDelegate.horizontalPosition ||
           verticalPosition != oldDelegate.verticalPosition ||
           zoom != oldDelegate.zoom ||
           cameraPosition != oldDelegate.cameraPosition;
  }
}
