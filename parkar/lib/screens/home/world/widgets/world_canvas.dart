import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vector_math/vector_math.dart' as vector_math;
import 'dart:async';
import 'package:flutter/services.dart';

import '../core/world_state.dart';
import '../core/collision_manager.dart';
import '../engine/world_renderer.dart';
import '../models/parking_spot.dart';
import '../models/world_elements.dart';
import '../utils/drawing_utils.dart';

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

class _WorldCanvasState extends State<WorldCanvas> {
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

  @override
  void dispose() {
    _errorMessageTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WorldState>(
      builder: (context, state, child) {
        // Inicializar el gestor de colisiones con el estado actual
        _collisionManager = CollisionManager(state: state);
        
        // Suscribirse a eventos de colisión
        state.addListener(() {
          if (state.collisionErrorMessage.isNotEmpty) {
            _showTemporaryErrorMessage(state.collisionErrorMessage);
            // Limpiar el mensaje después de mostrarlo
            state.clearCollisionErrorMessage();
          }
        });
        
        return Stack(
          children: [
            GestureDetector(
              // Configuración esencial para detectar gestos
              behavior: HitTestBehavior.opaque,

              // Detectar cuando se presiona
              onPanStart: (details) {
                if (!widget.isEditMode) return; // No permitir arrastrar en modo normal
                
                final worldState = Provider.of<WorldState>(context, listen: false);
                final position = details.localPosition;

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
                        
                    _isDragging = true;
                  } else {
                    // Si no hay elemento y no se presionan teclas modificadoras, limpiar selección
                    if (!isShiftPressed && !isControlPressed) {
                      worldState.clearSelection();
                    }
                    _isDragging = false;
                  }
                });
              },

              // Actualizar durante el arrastre
              onPanUpdate: (details) {
                if (!widget.isEditMode) return; // No permitir arrastrar en modo normal
                
                final worldState = Provider.of<WorldState>(context, listen: false);
                final position = details.localPosition;
                
                setState(() {
                  _currentDragPosition = position;
                });

                // En modo selección, actualizar el rectángulo de selección
                if (widget.editorMode == EditorMode.selection && _selectionStart != null) {
                  setState(() {
                    _selectionCurrent = position;
                    
                    // Calcular qué elementos están dentro del rectángulo de selección
                    _updateSelectionElements(worldState);
                  });
                  return;
                }

                // En modo libre, arrastrar elementos o la cámara
                if (_dragStart != null) {
                  // Si estamos arrastrando un elemento
                  if (_draggedElement != null && _elementStartPosition != null) {
                    // Calcular el desplazamiento en coordenadas del mundo
                    final dx = (position.dx - _dragStart!.dx) / worldState.zoom;
                    final dy = (position.dy - _dragStart!.dy) / worldState.zoom;

                    // Verificar si el elemento arrastrado está seleccionado
                    final isSelected = worldState.selectedElements.contains(_draggedElement);
                    
                    if (isSelected && worldState.selectedElements.length > 1) {
                      // Si hay múltiples elementos seleccionados, moverlos todos
                      worldState.moveSelectedElements(vector_math.Vector2(dx, dy));
                      
                      // Actualizar la posición de inicio para el próximo movimiento
                      _dragStart = position;
                      _elementStartPosition = Offset(_draggedElement!.position.x, _draggedElement!.position.y);
                    } else {
                      // Guardar posición actual antes de actualizar
                      final originalX = _draggedElement!.position.x;
                      final originalY = _draggedElement!.position.y;
                      
                      // Actualizar posición del elemento
                      _draggedElement!.position.x = _elementStartPosition!.dx + dx;
                      _draggedElement!.position.y = _elementStartPosition!.dy + dy;

                      // Comprobar colisiones
                      _collidingElements = _collisionManager.findCollidingElements(_draggedElement!);
                      
                      // Si hay colisión, restaurar posición
                      if (_collidingElements.isNotEmpty) {
                        _draggedElement!.position.x = originalX;
                        _draggedElement!.position.y = originalY;
                      }

                      // Notificar cambio
                      worldState.notifyListeners();
                    }
                  }
                  // Si no hay elemento, mover la cámara
                  else {
                    final dx = details.delta.dx;
                    final dy = details.delta.dy;
                    worldState.moveCamera(vector_math.Vector2(
                        -dx / worldState.zoom, -dy / worldState.zoom));
                  }
                }
              },

              // Finalizar arrastre
              onPanEnd: (details) {
                if (!widget.isEditMode) return; // No permitir arrastrar en modo normal
                
                final worldState = Provider.of<WorldState>(context, listen: false);
                
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
                  return;
                }
                
                setState(() {
                  _dragStart = null;
                  _draggedElement = null;
                  _elementStartPosition = null;
                  _isDragging = false;
                  _currentDragPosition = null;
                  _collidingElements.clear();
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
          ],
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

/// Pintor para el rectángulo de selección
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
    
    // Dibujar borde con un estilo más sutil
    final Paint borderPaint = Paint()
      ..color = Colors.blue.withOpacity(0.7)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    
    // Dibujar rectángulo con esquinas redondeadas
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(4.0));
    canvas.drawRRect(rrect, borderPaint);
    
    // Dibujar fondo semitransparente
    final Paint fillPaint = Paint()
      ..color = Colors.blue.withOpacity(0.08)
      ..style = PaintingStyle.fill;
    
    canvas.drawRRect(rrect, fillPaint);
  }
  
  @override
  bool shouldRepaint(covariant _SelectionPainter oldDelegate) {
    return oldDelegate.start != start || oldDelegate.current != current;
  }
}
