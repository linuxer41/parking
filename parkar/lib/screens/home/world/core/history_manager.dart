import 'package:flutter/foundation.dart';
import 'package:vector_math/vector_math.dart' as vector_math;

import '../models/world_elements.dart';
import '../models/index.dart';
import 'world_state.dart';

/// Clase para representar una acción que se puede deshacer/rehacer
abstract class WorldAction {
  /// Ejecuta la acción
  void execute(WorldState state);
  
  /// Deshace la acción
  void undo(WorldState state);
  
  /// Rehace la acción
  void redo(WorldState state);
  
  /// Descripción de la acción para depuración
  String get description;
}

/// Acción para añadir un elemento
class AddElementAction extends WorldAction {
  final WorldElement element;
  
  AddElementAction(this.element);
  
  @override
  void execute(WorldState state) {
    if (element is ParkingSpot) {
      state.spots.add(element as ParkingSpot);
    } else if (element is ParkingSignage) {
      state.signages.add(element as ParkingSignage);
    } else if (element is ParkingFacility) {
      state.facilities.add(element as ParkingFacility);
    }
  }
  
  @override
  void undo(WorldState state) {
    if (element is ParkingSpot) {
      state.spots.remove(element);
    } else if (element is ParkingSignage) {
      state.signages.remove(element);
    } else if (element is ParkingFacility) {
      state.facilities.remove(element);
    }
  }
  
  @override
  void redo(WorldState state) {
    execute(state);
  }
  
  @override
  String get description => 'Añadir ${element.runtimeType}';
}

/// Acción para eliminar un elemento
class DeleteElementAction extends WorldAction {
  final WorldElement element;
  int _originalIndex = -1;
  
  DeleteElementAction(this.element);
  
  @override
  void execute(WorldState state) {
    if (element is ParkingSpot) {
      _originalIndex = state.spots.indexOf(element as ParkingSpot);
      if (_originalIndex >= 0) state.spots.removeAt(_originalIndex);
    } else if (element is ParkingSignage) {
      _originalIndex = state.signages.indexOf(element as ParkingSignage);
      if (_originalIndex >= 0) state.signages.removeAt(_originalIndex);
    } else if (element is ParkingFacility) {
      _originalIndex = state.facilities.indexOf(element as ParkingFacility);
      if (_originalIndex >= 0) state.facilities.removeAt(_originalIndex);
    }
  }
  
  @override
  void undo(WorldState state) {
    if (_originalIndex >= 0) {
      if (element is ParkingSpot) {
        state.spots.insert(_originalIndex, element as ParkingSpot);
      } else if (element is ParkingSignage) {
        state.signages.insert(_originalIndex, element as ParkingSignage);
      } else if (element is ParkingFacility) {
        state.facilities.insert(_originalIndex, element as ParkingFacility);
      }
    }
  }
  
  @override
  void redo(WorldState state) {
    execute(state);
  }
  
  @override
  String get description => 'Eliminar ${element.runtimeType}';
}

/// Acción para eliminar múltiples elementos
class DeleteMultipleElementsAction extends WorldAction {
  final List<WorldElement> elements;
  final Map<WorldElement, int> _originalIndices = {};
  
  DeleteMultipleElementsAction(this.elements);
  
  @override
  void execute(WorldState state) {
    _originalIndices.clear();
    
    for (final element in elements) {
      if (element is ParkingSpot) {
        final index = state.spots.indexOf(element as ParkingSpot);
        if (index >= 0) {
          _originalIndices[element] = index;
          state.spots.removeAt(index);
        }
      } else if (element is ParkingSignage) {
        final index = state.signages.indexOf(element as ParkingSignage);
        if (index >= 0) {
          _originalIndices[element] = index;
          state.signages.removeAt(index);
        }
      } else if (element is ParkingFacility) {
        final index = state.facilities.indexOf(element as ParkingFacility);
        if (index >= 0) {
          _originalIndices[element] = index;
          state.facilities.removeAt(index);
        }
      }
    }
  }
  
  @override
  void undo(WorldState state) {
    for (final entry in _originalIndices.entries) {
      final element = entry.key;
      final index = entry.value;
      
      if (element is ParkingSpot) {
        if (index <= state.spots.length) {
          state.spots.insert(index, element as ParkingSpot);
        } else {
          state.spots.add(element as ParkingSpot);
        }
      } else if (element is ParkingSignage) {
        if (index <= state.signages.length) {
          state.signages.insert(index, element as ParkingSignage);
        } else {
          state.signages.add(element as ParkingSignage);
        }
      } else if (element is ParkingFacility) {
        if (index <= state.facilities.length) {
          state.facilities.insert(index, element as ParkingFacility);
        } else {
          state.facilities.add(element as ParkingFacility);
        }
      }
    }
  }
  
  @override
  void redo(WorldState state) {
    execute(state);
  }
  
  @override
  String get description => 'Eliminar ${elements.length} elementos';
}

/// Acción para mover un elemento
class MoveElementAction extends WorldAction {
  final WorldElement element;
  final vector_math.Vector2 oldPosition;
  final vector_math.Vector2 newPosition;
  
  MoveElementAction(this.element, this.oldPosition, this.newPosition);
  
  @override
  void execute(WorldState state) {
    element.position.x = newPosition.x;
    element.position.y = newPosition.y;
  }
  
  @override
  void undo(WorldState state) {
    element.position.x = oldPosition.x;
    element.position.y = oldPosition.y;
  }
  
  @override
  void redo(WorldState state) {
    execute(state);
  }
  
  @override
  String get description => 'Mover ${element.runtimeType}';
}

/// Acción para rotar un elemento
class RotateElementAction extends WorldAction {
  final WorldElement element;
  final double oldRotation;
  final double newRotation;
  
  RotateElementAction(this.element, this.oldRotation, this.newRotation);
  
  @override
  void execute(WorldState state) {
    element.rotation = newRotation;
  }
  
  @override
  void undo(WorldState state) {
    element.rotation = oldRotation;
  }
  
  @override
  void redo(WorldState state) {
    execute(state);
  }
  
  @override
  String get description => 'Rotar ${element.runtimeType}';
}

/// Gestor de historial para hacer/deshacer acciones
class HistoryManager {
  final WorldState _state;
  final List<WorldAction> _undoStack = [];
  final List<WorldAction> _redoStack = [];
  final int _maxHistorySize;
  
  HistoryManager(this._state, {int maxHistorySize = 100}) : _maxHistorySize = maxHistorySize;
  
  /// Verifica si se puede deshacer
  bool get canUndo => _undoStack.isNotEmpty;
  
  /// Verifica si se puede rehacer
  bool get canRedo => _redoStack.isNotEmpty;
  
  /// Ejecuta y registra una acción
  void executeAction(WorldAction action) {
    // Ejecutar la acción
    action.execute(_state);
    
    // Añadir a la pila de deshacer
    _undoStack.add(action);
    
    // Limpiar la pila de rehacer
    _redoStack.clear();
    
    // Limitar el tamaño del historial
    if (_undoStack.length > _maxHistorySize) {
      _undoStack.removeAt(0);
    }
    
    // Notificar cambios
    _state.notifyListeners();
  }
  
  /// Deshace la última acción
  void undo() {
    if (!canUndo) return;
    
    // Obtener la última acción
    final action = _undoStack.removeLast();
    
    // Deshacer la acción
    action.undo(_state);
    
    // Añadir a la pila de rehacer
    _redoStack.add(action);
    
    // Notificar cambios
    _state.notifyListeners();
  }
  
  /// Rehace la última acción deshecha
  void redo() {
    if (!canRedo) return;
    
    // Obtener la última acción deshecha
    final action = _redoStack.removeLast();
    
    // Rehacer la acción
    action.redo(_state);
    
    // Añadir a la pila de deshacer
    _undoStack.add(action);
    
    // Notificar cambios
    _state.notifyListeners();
  }
  
  /// Limpia el historial
  void clear() {
    _undoStack.clear();
    _redoStack.clear();
  }
} 