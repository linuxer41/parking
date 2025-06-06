import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math.dart' as vector_math;

import '../models/flame_element.dart';
import '../models/parking_spot.dart';
import '../models/parking_signage.dart';
import '../models/parking_facility.dart';
import '../state/flame_state.dart';

/// Juego Flame para el editor de estacionamientos
class ParkingGame extends FlameGame {
  final FlameState flameState;
  
  // Referencias a componentes del juego
  late final World _world;
  
  // Estado de arrastre
  bool _isDragging = false;
  FlameElement? _draggedElement;
  vector_math.Vector2? _dragStartPosition;
  vector_math.Vector2? _elementStartPosition;
  Map<FlameElement, vector_math.Vector2> _multiDragStartPositions = {};
  
  // Estado de selección
  bool _isSelecting = false;
  vector_math.Vector2? _selectionStart;
  vector_math.Vector2? _selectionCurrent;
  
  // Teclas presionadas
  final Set<LogicalKeyboardKey> _pressedKeys = {};
  
  ParkingGame({required this.flameState});
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Crear mundo
    _world = World();
    
    // Añadir el mundo al juego
    add(_world);
    
    // Configurar cámara inicial
    camera.viewfinder.zoom = flameState.zoom;
    camera.viewfinder.position = Vector2(
      flameState.cameraPosition.x,
      flameState.cameraPosition.y
    );
    
    // Añadir un componente de grid al mundo
    add(GridComponent());
    
    // Cargar elementos existentes
    _loadInitialElements();
    
    // Configurar eventos del estado
    flameState.addListener(_onStateChanged);
  }
  
  void _onStateChanged() {
    // Actualizar cuando cambia el estado
    // (cuando se añaden o eliminan elementos)
    
    // Sincronizar componentes visuales con el estado
    _syncElementsWithState();
  }
  
  /// Sincroniza los componentes visuales con el estado
  void _syncElementsWithState() {
    // Eliminar todos los elementos actuales del mundo
    _removeAllElements();
    
    // Añadir todos los elementos desde el estado
    for (final element in flameState.allElements) {
      _world.add(element);
    }
  }
  
  /// Elimina todos los elementos del mundo
  void _removeAllElements() {
    // Crear una lista de elementos a eliminar para evitar modificar durante la iteración
    final List<FlameElement> elementsToRemove = [];
    
    for (final component in _world.children) {
      if (component is FlameElement) {
        elementsToRemove.add(component);
      }
    }
    
    // Eliminar los elementos
    for (final element in elementsToRemove) {
      _world.remove(element);
    }
  }
  
  /// Carga los elementos iniciales desde el estado
  void _loadInitialElements() {
    for (final element in flameState.allElements) {
      _world.add(element);
    }
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    // Actualizar la cámara según el estado
    camera.viewfinder.zoom = flameState.zoom;
    
    // Si estamos en modo selección, actualizar el rectángulo de selección
    if (_isSelecting && _selectionStart != null && _selectionCurrent != null) {
      // Implementar lógica de selección
    }
  }
  
  /// Convierte una posición de pantalla a coordenadas de mundo
  vector_math.Vector2 screenToWorld(Vector2 screenPosition) {
    return vector_math.Vector2(
      (screenPosition.x + camera.viewfinder.position.x) / camera.viewfinder.zoom,
      (screenPosition.y + camera.viewfinder.position.y) / camera.viewfinder.zoom
    );
  }
  
  /// Encuentra un elemento en una posición de mundo
  FlameElement? findElementAt(vector_math.Vector2 worldPosition) {
    // Buscar en orden inverso (de arriba hacia abajo)
    for (final component in _world.children.toList().reversed) {
      if (component is FlameElement && component.containsPoint(worldPosition)) {
        return component;
      }
    }
    
    return null;
  }
  
  // Método para gestionar las interacciones con el juego desde fuera
  void handleTap(Offset position) {
    final worldPosition = screenToWorld(Vector2(position.dx, position.dy));
    final element = findElementAt(worldPosition);
    
    if (element != null) {
      // Seleccionar elemento
      flameState.selectElement(element);
    } else {
      // Si no se hizo clic en ningún elemento, deseleccionar todos
      flameState.clearSelection();
    }
  }
  
  void handleDragStart(Offset position) {
    final worldPosition = screenToWorld(Vector2(position.dx, position.dy));
    final element = findElementAt(worldPosition);
    
    _isDragging = false;
    _draggedElement = null;
    _dragStartPosition = null;
    _elementStartPosition = null;
    _multiDragStartPositions.clear();
    
    // Verificar si hay múltiples elementos seleccionados
    if (flameState.selectedElements.length > 1) {
      // Si el elemento bajo el cursor es uno de los seleccionados, iniciar arrastre múltiple
      if (element != null && flameState.selectedElements.contains(element)) {
        _isDragging = true;
        _dragStartPosition = vector_math.Vector2(position.dx, position.dy);
        
        // Guardar las posiciones iniciales de todos los elementos seleccionados
        for (final selectedElement in flameState.selectedElements) {
          if (selectedElement.isDraggable) {
            _multiDragStartPositions[selectedElement] = vector_math.Vector2(
              selectedElement.position.x,
              selectedElement.position.y
            );
          }
        }
      }
    }
    // Si solo hay un elemento o ninguno seleccionado
    else if (element != null && element.isDraggable) {
      _isDragging = true;
      _draggedElement = element;
      _dragStartPosition = vector_math.Vector2(position.dx, position.dy);
      _elementStartPosition = vector_math.Vector2(
        element.position.x,
        element.position.y
      );
      
      // Si el elemento no está seleccionado, seleccionarlo
      if (!element.isSelected) {
        flameState.selectElement(element);
      }
    }
  }
  
  void handleDragUpdate(Offset position) {
    if (!_isDragging || _dragStartPosition == null) return;
    
    final currentPosition = vector_math.Vector2(position.dx, position.dy);
    
    final delta = vector_math.Vector2(
      (currentPosition.x - _dragStartPosition!.x) / camera.viewfinder.zoom,
      (currentPosition.y - _dragStartPosition!.y) / camera.viewfinder.zoom
    );
    
    // Si estamos arrastrando múltiples elementos
    if (_multiDragStartPositions.isNotEmpty) {
      for (final entry in _multiDragStartPositions.entries) {
        final element = entry.key;
        final startPos = entry.value;
        
        element.position.x = startPos.x + delta.x;
        element.position.y = startPos.y + delta.y;
      }
    }
    // Si estamos arrastrando un solo elemento
    else if (_draggedElement != null && _elementStartPosition != null) {
      _draggedElement!.position.x = _elementStartPosition!.x + delta.x;
      _draggedElement!.position.y = _elementStartPosition!.y + delta.y;
    }
  }
  
  void handleDragEnd(Offset position) {
    _isDragging = false;
    _draggedElement = null;
    _dragStartPosition = null;
    _elementStartPosition = null;
    _multiDragStartPositions.clear();
  }
  
  void handleScroll(double delta) {
    // Ajustar el zoom con la rueda del ratón
    final zoomFactor = delta * 0.001;
    final newZoom = flameState.zoom * (1 - zoomFactor);
    
    // Limitar el zoom entre 0.5 y 3.0
    flameState.setZoom(newZoom.clamp(0.5, 3.0));
  }
}

/// Componente para dibujar una cuadrícula
class GridComponent extends Component with HasGameRef<ParkingGame> {
  @override
  void render(Canvas canvas) {
    final flameState = gameRef.flameState;
    final camera = gameRef.camera;
    
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..strokeWidth = 1.0;
    
    final gridSize = 50.0 * camera.viewfinder.zoom;
    final screenWidth = gameRef.size.x;
    final screenHeight = gameRef.size.y;
    
    final startX = (camera.viewfinder.position.x % gridSize) - gridSize;
    final startY = (camera.viewfinder.position.y % gridSize) - gridSize;
    
    // Dibujar líneas verticales
    for (double x = startX; x < screenWidth + gridSize; x += gridSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, screenHeight),
        paint,
      );
    }
    
    // Dibujar líneas horizontales
    for (double y = startY; y < screenHeight + gridSize; y += gridSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(screenWidth, y),
        paint,
      );
    }
    
    // Dibujar líneas principales (cada 5 cuadros) con un color más oscuro
    final mainPaint = Paint()
      ..color = Colors.grey.withOpacity(0.5)
      ..strokeWidth = 1.5;
    
    final mainGridSize = gridSize * 5;
    final startMainX = (camera.viewfinder.position.x % mainGridSize) - mainGridSize;
    final startMainY = (camera.viewfinder.position.y % mainGridSize) - mainGridSize;
    
    // Dibujar líneas verticales principales
    for (double x = startMainX; x < screenWidth + mainGridSize; x += mainGridSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, screenHeight),
        mainPaint,
      );
    }
    
    // Dibujar líneas horizontales principales
    for (double y = startMainY; y < screenHeight + mainGridSize; y += mainGridSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(screenWidth, y),
        mainPaint,
      );
    }
  }
} 