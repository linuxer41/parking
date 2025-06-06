import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as vector_math;

import '../models/index.dart';
import 'world_state.dart';
import 'drag_manager.dart';

/// Enumeración para los modos de interacción
enum InteractionMode {
  view, // Modo de visualización (pan, zoom)
  select, // Modo de selección
  multiSelect, // Modo de selección múltiple
  draw, // Modo de dibujo
  edit, // Modo de edición
}

/// Clase que maneja las interacciones del usuario con el mundo
class WorldInteractionHandler {
  final WorldState state;

  // Modo de interacción actual
  InteractionMode _mode = InteractionMode.view;

  // Gestor de arrastre mejorado
  late final DragManager _dragManager;

  // Estado de gestos
  Offset? _lastPanPosition;
  Offset? _selectionStart;
  Offset? _selectionCurrent;

  // Para seguimiento de depuración
  int _updateCounter = 0;

  // Crear un rectángulo de selección
  Rect? get selectionRect {
    if (_selectionStart == null || _selectionCurrent == null) return null;

    return Rect.fromPoints(_selectionStart!, _selectionCurrent!);
  }

  WorldInteractionHandler({
    required this.state,
  }) {
    _dragManager = DragManager(state: state);
  }

  /// Cambiar el modo de interacción
  void setMode(InteractionMode mode) {
    print("WorldInteractionHandler: Cambiando modo de $_mode a $mode");
    _mode = mode;
    _resetState();
  }

  /// Reiniciar el estado de interacción
  void _resetState() {
    _lastPanPosition = null;
    _selectionStart = null;
    _selectionCurrent = null;
    _dragManager.endDrag();
  }

  /// Manejar evento de inicio de arrastre
  void onPanStart(DragStartDetails details) {
    final position = details.localPosition;
    _lastPanPosition = position;

    print("WorldInteractionHandler: onPanStart en $position, modo: $_mode");

    // Buscar un elemento en la posición actual para posible arrastre
    final worldPosition = _screenToWorldPosition(position);
    final element = _findElementAt(worldPosition);

    // Verificar si hay múltiples elementos seleccionados
    if (state.selectedElements.length > 1) {
      // Si el elemento bajo el cursor es uno de los seleccionados, iniciar arrastre múltiple
      if (element != null && state.selectedElements.contains(element)) {
        final started = _dragManager.startMultiDrag(position, state.selectedElements);
        print("WorldInteractionHandler: Arrastre múltiple iniciado: $started con ${state.selectedElements.length} elementos");
        return; // Importante: salir del método después de iniciar el arrastre múltiple
      }
    }

    // Si no hay múltiples elementos seleccionados o el elemento bajo el cursor no está seleccionado
    if (element != null) {
      // Verificar si el elemento ya está en la selección múltiple
      if (state.selectedElements.contains(element) && state.selectedElements.length > 1) {
        // Si el elemento ya está seleccionado y hay múltiples elementos seleccionados,
        // iniciar un arrastre múltiple de todos los elementos seleccionados
        final started = _dragManager.startMultiDrag(position, state.selectedElements);
        print("WorldInteractionHandler: Arrastre múltiple iniciado: $started con ${state.selectedElements.length} elementos");
      } else {
        // Si no está seleccionado o es el único seleccionado, seleccionar solo este elemento
        state.selectElement(element);
        print("WorldInteractionHandler: Elemento seleccionado para arrastre: ${element.id}");

        // Iniciar arrastre si el elemento es arrastrable
        if (element.isDraggable) {
          final started = _dragManager.startDrag(position, element);
          print("WorldInteractionHandler: Arrastre iniciado: $started");
        }
      }
    } else {
      // Si no se hizo clic en ningún elemento, iniciar pan de cámara
      // (esto ya se maneja en onPanUpdate)
    }
  }

  /// Manejar evento de actualización de arrastre
  void onPanUpdate(DragUpdateDetails details) {
    final position = details.localPosition;

    // Si estamos arrastrando un elemento, actualizar su posición
    if (_dragManager.isDragging) {
      _dragManager.updateDrag(position);
      return;
    }

    // Si no estamos arrastrando, mover la cámara
    if (_lastPanPosition != null) {
      final delta = position - _lastPanPosition!;
      state.moveCamera(
          vector_math.Vector2(-delta.dx / state.zoom, -delta.dy / state.zoom));
      _lastPanPosition = position;

      // Log menos frecuente para reducir ruido
      _updateCounter++;
      if (_updateCounter % 10 == 0) {
        print("WorldInteractionHandler: Moviendo cámara, delta: $delta");
      }
    }
  }

  /// Manejar evento de fin de arrastre
  void onPanEnd(DragEndDetails details) {
    print(
        "WorldInteractionHandler: onPanEnd, modo: $_mode, dragManager.isDragging: ${_dragManager.isDragging}");

    switch (_mode) {
      case InteractionMode.view:
        break;

      case InteractionMode.select:
        // En modo selección, finalizamos el arrastre
        if (_dragManager.isDragging) {
          _dragManager.endDrag();
        }
        break;

      case InteractionMode.multiSelect:
        // En modo selección múltiple, aplicamos la selección o finalizamos el arrastre
        if (_dragManager.isDragging) {
          _dragManager.endDrag();
        } else if (selectionRect != null) {
          state.selectElementsInRect(selectionRect!);
        }
        _selectionStart = null;
        _selectionCurrent = null;
        break;

      case InteractionMode.draw:
        // En modo dibujo, finalizamos la creación del elemento
        break;

      case InteractionMode.edit:
        // En modo edición, finalizamos la edición
        if (_dragManager.isDragging) {
          _dragManager.endDrag();
        }
        break;
    }

    _lastPanPosition = null;
    _updateCounter = 0;
  }

  /// Manejar evento de escala (zoom)
  void onScaleUpdate(ScaleUpdateDetails details) {
    // Actualizar el zoom
    if (details.scale != 1.0) {
      final newZoom = state.zoom * details.scale;
      state.setZoom(newZoom.clamp(0.5, 5.0)); // Limitar el zoom entre 0.5x y 5x
    }

    // Manejar el pan dentro del gesto de escala si no estamos arrastrando
    if (!_dragManager.isDragging) {
      final position = details.localFocalPoint;
      if (_lastPanPosition != null) {
        final delta = position - _lastPanPosition!;
        state.moveCamera(vector_math.Vector2(-delta.dx, -delta.dy));
      }
      _lastPanPosition = position;
    }
    // Si estamos arrastrando un elemento, continuar con el arrastre
    else if (_dragManager.isDragging) {
      _dragManager.updateDrag(details.localFocalPoint);
    }
  }

  /// Manejar evento de tap
  void onTap(TapDownDetails details) {
    final position = details.localPosition;

    print("WorldInteractionHandler: onTap en $position, modo: $_mode");

    switch (_mode) {
      case InteractionMode.view:
        // En modo vista, solo seleccionamos un elemento si lo hay
        _handleViewTap(position);
        break;

      case InteractionMode.select:
        // En modo selección, seleccionamos el elemento en la posición
        _handleSelectTap(position);
        break;

      case InteractionMode.multiSelect:
        // En modo selección múltiple, añadimos/quitamos el elemento de la selección
        _handleMultiSelectTap(position);
        break;

      case InteractionMode.draw:
        // En modo dibujo, creamos un nuevo elemento en la posición
        break;

      case InteractionMode.edit:
        // En modo edición, seleccionamos el elemento para editar
        _handleEditTap(position);
        break;
    }
  }

  /// Manejar tap en modo vista
  void _handleViewTap(Offset position) {
    final worldPosition = _screenToWorldPosition(position);
    final element = _findElementAt(worldPosition);

    if (element != null) {
      // Solo seleccionamos visualmente, sin permitir la edición
      state.selectElement(element);
      print(
          "WorldInteractionHandler: Elemento seleccionado en modo vista: ${element.id}");
    } else {
      state.clearSelection();
    }
  }

  /// Manejar inicio de selección
  void _handleSelectStart(Offset position) {
    final worldPosition = _screenToWorldPosition(position);
    final element = _findElementAt(worldPosition);

    if (element != null) {
      // Verificar si el elemento ya está en la selección múltiple
      if (state.selectedElements.contains(element) && state.selectedElements.length > 1) {
        // Si el elemento ya está seleccionado y hay múltiples elementos seleccionados,
        // iniciar un arrastre múltiple de todos los elementos seleccionados
        final started = _dragManager.startMultiDrag(position, state.selectedElements);
        print("WorldInteractionHandler: Arrastre múltiple iniciado: $started con ${state.selectedElements.length} elementos");
      } else {
        // Si no está seleccionado o es el único seleccionado, seleccionar solo este elemento
        state.selectElement(element);
        print("WorldInteractionHandler: Elemento seleccionado para arrastre: ${element.id}");

        // Iniciar arrastre si el elemento es arrastrable
        if (element.isDraggable) {
          final started = _dragManager.startDrag(position, element);
          print("WorldInteractionHandler: Arrastre iniciado: $started");
        }
      }
    } else {
      state.clearSelection();
    }
  }

  /// Manejar tap en modo selección
  void _handleSelectTap(Offset position) {
    final worldPosition = _screenToWorldPosition(position);
    final element = _findElementAt(worldPosition);

    // Detectar teclas modificadoras (en una app real, podrían ser botones en la interfaz)
    final isShiftPressed = false; // Aquí se detectaría la tecla Shift
    final isControlPressed = false; // Aquí se detectaría la tecla Control

    if (element != null) {
      state.selectElement(element, isShiftPressed: isShiftPressed, isControlPressed: isControlPressed);
      print(
          "WorldInteractionHandler: Elemento seleccionado con tap: ${element.id}");
    } else {
      state.clearSelection();
    }
  }

  /// Manejar inicio de selección múltiple
  void _handleMultiSelectStart(Offset position) {
    final worldPosition = _screenToWorldPosition(position);
    final element = _findElementAt(worldPosition);

    // Si hay algún elemento seleccionado y el tap está sobre uno seleccionado
    if (element != null && state.selectedElements.contains(element)) {
      // Iniciar arrastre de múltiples elementos
      final started =
          _dragManager.startMultiDrag(position, state.selectedElements);
      print(
          "WorldInteractionHandler: Arrastre múltiple iniciado: $started con ${state.selectedElements.length} elementos");
    } else if (element != null) {
      // Si el tap está sobre un elemento no seleccionado, seleccionarlo
      if (state.selectedElements.contains(element)) {
        state.selectedElements.remove(element);
      } else {
        state.selectedElements.add(element);
      }
      state.notifyListeners();
    } else {
      // Si el tap no está sobre ningún elemento, iniciar rectángulo de selección
      _selectionStart = position;
      _selectionCurrent = position;

      // Si mantenemos una tecla modificadora (para simular), mantener la selección actual
      // En caso contrario, limpiar la selección
      // Para una app móvil, podríamos usar otro mecanismo como gestos o botones
      state.clearSelection();
    }
  }

  /// Manejar tap en modo selección múltiple
  void _handleMultiSelectTap(Offset position) {
    final worldPosition = _screenToWorldPosition(position);
    final element = _findElementAt(worldPosition);

    if (element != null) {
      if (state.selectedElements.contains(element)) {
        state.selectedElements.remove(element);
      } else {
        state.selectedElements.add(element);
      }
      state.notifyListeners();
    }
  }

  /// Manejar inicio de edición
  void _handleEditStart(Offset position) {
    final worldPosition = _screenToWorldPosition(position);
    final element = _findElementAt(worldPosition);

    if (element != null) {
      // Verificar si el elemento ya está en la selección múltiple
      if (state.selectedElements.contains(element) && state.selectedElements.length > 1) {
        // Si el elemento ya está seleccionado y hay múltiples elementos seleccionados,
        // iniciar un arrastre múltiple de todos los elementos seleccionados
        final started = _dragManager.startMultiDrag(position, state.selectedElements);
        print("WorldInteractionHandler: Arrastre múltiple iniciado en modo edición: $started con ${state.selectedElements.length} elementos");
      } else {
        // Si no está seleccionado o es el único seleccionado, seleccionar solo este elemento
        state.selectElement(element);
        print("WorldInteractionHandler: Elemento seleccionado para edición: ${element.id}");

        // Iniciar arrastre si el elemento es arrastrable
        if (element.isDraggable) {
          final started = _dragManager.startDrag(position, element);
          print("WorldInteractionHandler: Arrastre en modo edición iniciado: $started");
        }
      }
    }
  }

  /// Manejar tap en modo edición
  void _handleEditTap(Offset position) {
    final worldPosition = _screenToWorldPosition(position);
    final element = _findElementAt(worldPosition);

    if (element != null) {
      state.selectElement(element);
      print(
          "WorldInteractionHandler: Elemento seleccionado con tap en modo edición: ${element.id}");
    } else {
      state.clearSelection();
    }
  }

  /// Convertir posición de pantalla a posición de mundo
  vector_math.Vector2 _screenToWorldPosition(Offset screenPosition) {
    return _dragManager.screenToWorldPosition(screenPosition);
  }

  /// Encontrar un elemento en una posición de mundo
  WorldElement? _findElementAt(vector_math.Vector2 worldPosition) {
    // Buscar en todos los elementos
    for (final element in state.allElements) {
      if (element.containsPoint(worldPosition)) {
        return element;
      }
    }

    return null;
  }

  /// Manejar evento de inicio de escala (zoom)
  void onScaleStart(ScaleStartDetails details) {
    _lastPanPosition = details.localFocalPoint;
  }
}
