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
  double gridSize = 5.0;
  
  // Información de alineamiento activo
  bool _hasHorizontalAlignment = false;
  bool _hasVerticalAlignment = false;
  double _horizontalAlignmentPosition = 0.0;
  double _verticalAlignmentPosition = 0.0;
  WorldElement? _horizontalAlignmentElement;
  WorldElement? _verticalAlignmentElement;
  
  // Umbrales de alineamiento
  final double _alignmentThreshold = 20.0; // Umbral para detectar elementos cercanos (aumentado)
  final double _snapThreshold = 8.0;      // Umbral para alinearse con elementos (aumentado)

  // Getters
  bool get isDragging => _isDragging;
  bool get hasHorizontalAlignment => _hasHorizontalAlignment;
  bool get hasVerticalAlignment => _hasVerticalAlignment;
  double get horizontalAlignmentPosition => _horizontalAlignmentPosition;
  double get verticalAlignmentPosition => _verticalAlignmentPosition;

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
    _clearAlignmentInfo();

    // Configurar nuevo arrastre
    _isDragging = true;
    _dragStartScreenPosition = screenPosition;
    _elementStartWorldPosition =
        vector_math.Vector2(element.position.x, element.position.y);

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
    _clearAlignmentInfo();

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

    return true;
  }

  /// Actualiza la posición durante el arrastre
  void updateDrag(Offset currentScreenPosition) {
    if (!_isDragging || _dragStartScreenPosition == null) {
      return;
    }

    // Limpiar información de alineamiento en cada actualización
    _clearAlignmentInfo();

    // Calcular el desplazamiento en coordenadas de pantalla
    final deltaScreen = Offset(
        currentScreenPosition.dx - _dragStartScreenPosition!.dx,
        currentScreenPosition.dy - _dragStartScreenPosition!.dy);

    // Convertir a coordenadas de mundo
    final deltaWorld = vector_math.Vector2(
        deltaScreen.dx / state.zoom, deltaScreen.dy / state.zoom);

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
      
      // Calcular posiciones para todos los elementos
      final List<vector_math.Vector2> newPositions = [];
      
      // Primero calcular las nuevas posiciones sin aplicar alineamiento
      for (final element in state.selectedElements) {
        if (_multiDragStartPositions.containsKey(element)) {
          final startPos = _multiDragStartPositions[element]!;
          final newX = startPos.x + deltaWorld.x;
          final newY = startPos.y + deltaWorld.y;
          newPositions.add(vector_math.Vector2(newX, newY));
        }
      }
      
      // Buscar posibles alineamientos para el primer elemento
      if (newPositions.isNotEmpty) {
        final firstPosition = newPositions[0];
        _checkForAlignment(firstPosition);
        
        // Aplicar alineamiento si es necesario
        if (_hasHorizontalAlignment || _hasVerticalAlignment) {
          final offsetX = _hasVerticalAlignment ? (_verticalAlignmentPosition - firstPosition.x) : 0.0;
          final offsetY = _hasHorizontalAlignment ? (_horizontalAlignmentPosition - firstPosition.y) : 0.0;
          
          // Aplicar el mismo offset a todas las posiciones
          for (int i = 0; i < newPositions.length; i++) {
            if (_hasVerticalAlignment) newPositions[i].x += offsetX;
            if (_hasHorizontalAlignment) newPositions[i].y += offsetY;
          }
        }
      }
      
      // Aplicar las nuevas posiciones a los elementos
      int i = 0;
      for (final element in state.selectedElements) {
        if (_multiDragStartPositions.containsKey(element) && i < newPositions.length) {
          // Aplicar snap to grid si está habilitado y no hay alineamiento
          final finalPosition = enableSnapToGrid && !_hasHorizontalAlignment && !_hasVerticalAlignment
              ? newPositions[i].snapToGrid(gridSize)
              : newPositions[i];
          
          element.position.x = finalPosition.x;
          element.position.y = finalPosition.y;
          i++;
        }
      }
      
      state.notifyListeners();
    }
    // Si solo hay un elemento seleccionado
    else if (state.firstSelectedElement != null && _elementStartWorldPosition != null) {
      final newX = _elementStartWorldPosition!.x + deltaWorld.x;
      final newY = _elementStartWorldPosition!.y + deltaWorld.y;

      // Crear nueva posición
      final newPosition = vector_math.Vector2(newX, newY);
      
      // Buscar posibles alineamientos
      _checkForAlignment(newPosition);
      
      // Aplicar alineamiento si es necesario
      if (_hasHorizontalAlignment) {
        newPosition.y = _horizontalAlignmentPosition;
      }
      
      if (_hasVerticalAlignment) {
        newPosition.x = _verticalAlignmentPosition;
      }

      // Aplicar snap to grid si está habilitado y no hay alineamiento
      final finalPosition = enableSnapToGrid && !_hasHorizontalAlignment && !_hasVerticalAlignment
          ? newPosition.snapToGrid(gridSize)
          : newPosition;

      // Actualizar directamente las coordenadas
      state.firstSelectedElement!.position.x = finalPosition.x;
      state.firstSelectedElement!.position.y = finalPosition.y;

      state.notifyListeners();
    }
  }
  
  /// Verifica si hay elementos cercanos para alineamiento
  void _checkForAlignment(vector_math.Vector2 position) {
    // Buscar elementos cercanos
    final nearbyElements = _findNearbyElements(position);
    
    // Verificar alineamiento horizontal (mismo valor Y)
    for (final element in nearbyElements) {
      final dy = (element.position.y - position.y).abs();
      if (dy <= _snapThreshold) {
        _hasHorizontalAlignment = true;
        _horizontalAlignmentPosition = element.position.y;
        _horizontalAlignmentElement = element;
        break;
      }
    }
    
    // Verificar alineamiento vertical (mismo valor X)
    for (final element in nearbyElements) {
      final dx = (element.position.x - position.x).abs();
      if (dx <= _snapThreshold) {
        _hasVerticalAlignment = true;
        _verticalAlignmentPosition = element.position.x;
        _verticalAlignmentElement = element;
        break;
      }
    }
  }
  
  /// Busca elementos cercanos para alineación
  List<WorldElement> _findNearbyElements(vector_math.Vector2 position) {
    return state.allElements.where((element) {
      // No considerar elementos seleccionados
      if (state.selectedElements.contains(element)) return false;
      
      // Calcular distancia
      final dx = (element.position.x - position.x).abs();
      final dy = (element.position.y - position.y).abs();
      
      // Considerar cercano si está dentro del umbral en cualquier dirección
      return dx < _alignmentThreshold || dy < _alignmentThreshold;
    }).toList();
  }
  
  /// Limpia la información de alineamiento activo
  void _clearAlignmentInfo() {
    _hasHorizontalAlignment = false;
    _hasVerticalAlignment = false;
    _horizontalAlignmentPosition = 0.0;
    _verticalAlignmentPosition = 0.0;
    _horizontalAlignmentElement = null;
    _verticalAlignmentElement = null;
  }

  /// Finaliza el arrastre
  void endDrag() {
    if (_isDragging) {
      // Aplicar alineamiento final si es necesario
      if ((_hasHorizontalAlignment || _hasVerticalAlignment) && state.selectedElements.isNotEmpty) {
        for (final element in state.selectedElements) {
          if (_hasHorizontalAlignment) {
            element.position.y = _horizontalAlignmentPosition;
          }
          
          if (_hasVerticalAlignment) {
            element.position.x = _verticalAlignmentPosition;
          }
        }
        
        // Notificar cambios
        state.notifyListeners();
      }
      
      // Limpiar estados
      _isDragging = false;
      _dragStartScreenPosition = null;
      _elementStartWorldPosition = null;
      _multiDragStartPositions.clear();
      _clearAlignmentInfo();
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
  
  /// Obtener información de alineamiento para dibujo de guías
  Map<String, dynamic> getAlignmentInfo() {
    return {
      'hasHorizontalAlignment': _hasHorizontalAlignment,
      'hasVerticalAlignment': _hasVerticalAlignment,
      'horizontalPosition': _horizontalAlignmentPosition,
      'verticalPosition': _verticalAlignmentPosition,
    };
  }
}
