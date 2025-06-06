import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as vector_math;
import '../models/world_elements.dart';
import 'world_state.dart';

/// Gestor de arrastre mejorado para elementos del mundo
class DragManager {
  final WorldState state;

  // Estados de arrastre
  bool _isDragging = false;
  Offset? _dragStartScreenPosition;
  vector_math.Vector2? _elementStartWorldPosition;
  Map<WorldElement, vector_math.Vector2> _multiDragStartPositions = {};

  // Propiedades para snap al grid
  bool enableSnapToGrid = true;
  double gridSize = 10.0;

  // Getters
  bool get isDragging => _isDragging;

  DragManager({required this.state});

  /// Inicia el arrastre de un elemento
  bool startDrag(Offset screenPosition, WorldElement? element) {
    if (element == null || !element.isDraggable) {
      return false;
    }

    // Limpiar estados anteriores
    _isDragging = false;
    _dragStartScreenPosition = null;
    _elementStartWorldPosition = null;
    _multiDragStartPositions.clear();

    // Configurar nuevo arrastre
    _isDragging = true;
    _dragStartScreenPosition = screenPosition;
    _elementStartWorldPosition =
        vector_math.Vector2(element.position.x, element.position.y);

    print(
        "DragManager: Iniciando arrastre en ${element.id} en posición $_elementStartWorldPosition");
    return true;
  }

  /// Inicia el arrastre de múltiples elementos
  bool startMultiDrag(Offset screenPosition, List<WorldElement> elements) {
    if (elements.isEmpty) {
      return false;
    }

    // Limpiar estados anteriores
    _isDragging = false;
    _dragStartScreenPosition = null;
    _elementStartWorldPosition = null;
    _multiDragStartPositions.clear();

    // Guardar la posición inicial de cada elemento
    for (final element in elements) {
      if (element.isDraggable) {
        _multiDragStartPositions[element] =
            vector_math.Vector2(element.position.x, element.position.y);
      }
    }

    if (_multiDragStartPositions.isEmpty) {
      return false;
    }

    _isDragging = true;
    _dragStartScreenPosition = screenPosition;

    print(
        "DragManager: Iniciando arrastre múltiple con ${_multiDragStartPositions.length} elementos");
    return true;
  }

  /// Actualiza la posición durante el arrastre
  void updateDrag(Offset currentScreenPosition) {
    if (!_isDragging || _dragStartScreenPosition == null) {
      print("DragManager: No hay arrastre activo");
      return;
    }

    // Calcular el desplazamiento en coordenadas de pantalla
    final deltaScreen = Offset(
        currentScreenPosition.dx - _dragStartScreenPosition!.dx,
        currentScreenPosition.dy - _dragStartScreenPosition!.dy);

    // Convertir a coordenadas de mundo
    final deltaWorld = vector_math.Vector2(
        deltaScreen.dx / state.zoom, deltaScreen.dy / state.zoom);

    print("DragManager: Arrastre activo, delta mundo: $deltaWorld");

    // Si hay múltiples elementos seleccionados, siempre moverlos todos juntos
    if (state.selectedElements.length > 1) {
      // Si no tenemos las posiciones iniciales guardadas, guardarlas ahora
      if (_multiDragStartPositions.isEmpty) {
        for (final element in state.selectedElements) {
          if (element.isDraggable) {
            _multiDragStartPositions[element] =
                vector_math.Vector2(element.position.x, element.position.y);
          }
        }
      }
      
      // Mover todos los elementos seleccionados
      for (final element in state.selectedElements) {
        if (_multiDragStartPositions.containsKey(element)) {
          final startPos = _multiDragStartPositions[element]!;

          // Calcular nueva posición
          final newX = startPos.x + deltaWorld.x;
          final newY = startPos.y + deltaWorld.y;
          final newPosition = vector_math.Vector2(newX, newY);

          // Aplicar snap to grid si está habilitado
          final finalPosition =
              enableSnapToGrid ? newPosition.snapToGrid(gridSize) : newPosition;

          // Actualizar directamente
          element.position.x = finalPosition.x;
          element.position.y = finalPosition.y;
        }
      }
      print("DragManager: ${state.selectedElements.length} elementos movidos");
      state.notifyListeners();
    }
    // Si solo hay un elemento seleccionado
    else if (state.firstSelectedElement != null && _elementStartWorldPosition != null) {
      final newX = _elementStartWorldPosition!.x + deltaWorld.x;
      final newY = _elementStartWorldPosition!.y + deltaWorld.y;

      // Crear nueva posición
      final newPosition = vector_math.Vector2(newX, newY);

      // Aplicar snap to grid si está habilitado
      final finalPosition =
          enableSnapToGrid ? newPosition.snapToGrid(gridSize) : newPosition;

      // Actualizar directamente las coordenadas
      state.firstSelectedElement!.position.x = finalPosition.x;
      state.firstSelectedElement!.position.y = finalPosition.y;

      print(
          "DragManager: Elemento movido a (${finalPosition.x}, ${finalPosition.y})");
      state.notifyListeners();
    }
  }

  /// Finaliza el arrastre
  void endDrag() {
    if (_isDragging) {
      print("DragManager: Finalizando arrastre");
      _isDragging = false;
      _dragStartScreenPosition = null;
      _elementStartWorldPosition = null;
      _multiDragStartPositions.clear();
    }
  }

  /// Convierte una posición de pantalla a coordenadas de mundo
  vector_math.Vector2 screenToWorldPosition(Offset screenPosition) {
    return vector_math.Vector2(
        (screenPosition.dx + state.cameraPosition.x) / state.zoom,
        (screenPosition.dy + state.cameraPosition.y) / state.zoom);
  }

  /// Convierte una posición de mundo a coordenadas de pantalla
  Offset worldToScreenPosition(vector_math.Vector2 worldPosition) {
    return Offset(worldPosition.x * state.zoom - state.cameraPosition.x,
        worldPosition.y * state.zoom - state.cameraPosition.y);
  }
}
