import 'package:flutter/foundation.dart';
import 'package:vector_math/vector_math.dart' as vector_math;
import '../models/parking_elements.dart';

/// Tipos de acciones que se pueden deshacer/rehacer
enum ActionType {
  add,        // Añadir elemento
  remove,     // Eliminar elemento
  move,       // Mover elemento(s)
  rotate,     // Rotar elemento
  scale,      // Escalar elemento
  edit,       // Editar propiedades
  multiMove,  // Mover múltiples elementos
}

/// Acción que se puede deshacer/rehacer
class ParkingAction {
  final ActionType type;
  final List<ParkingElement> elements;
  final Map<String, dynamic> oldValues;
  final Map<String, dynamic> newValues;
  final DateTime timestamp;
  
  ParkingAction({
    required this.type,
    required this.elements,
    required this.oldValues,
    required this.newValues,
  }) : timestamp = DateTime.now();
  
  @override
  String toString() {
    String actionName = '';
    switch (type) {
      case ActionType.add:
        actionName = 'Añadir ${elements.length} elemento(s)';
        break;
      case ActionType.remove:
        actionName = 'Eliminar ${elements.length} elemento(s)';
        break;
      case ActionType.move:
        actionName = 'Mover elemento';
        break;
      case ActionType.rotate:
        actionName = 'Rotar elemento';
        break;
      case ActionType.scale:
        actionName = 'Escalar elemento';
        break;
      case ActionType.edit:
        actionName = 'Editar propiedades';
        break;
      case ActionType.multiMove:
        actionName = 'Mover ${elements.length} elementos';
        break;
    }
    
    return '$actionName (${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')})';
  }
}

/// Gestor de historial para deshacer/rehacer acciones
class HistoryManager with ChangeNotifier {
  // Pilas de historial
  final List<ParkingAction> _undoStack = [];
  final List<ParkingAction> _redoStack = [];
  
  // Límite máximo de historial
  final int maxHistorySize;
  
  // Constructor
  HistoryManager({this.maxHistorySize = 50});
  
  // Getters para verificar si se puede deshacer/rehacer
  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;
  
  // Obtener listas de acciones (para UI)
  List<ParkingAction> get undoActions => List.unmodifiable(_undoStack);
  List<ParkingAction> get redoActions => List.unmodifiable(_redoStack);
  
  /// Añadir una acción al historial
  void addAction(ParkingAction action) {
    _undoStack.add(action);
    
    // Limitar tamaño del historial
    if (_undoStack.length > maxHistorySize) {
      _undoStack.removeAt(0);
    }
    
    // Limpiar pila de rehacer
    _redoStack.clear();
    
    notifyListeners();
  }
  
  /// Crear y añadir acción de añadir elemento
  void addElementAction(ParkingElement element) {
    final action = ParkingAction(
      type: ActionType.add,
      elements: [element],
      oldValues: {'exists': false},
      newValues: {'exists': true},
    );
    
    addAction(action);
  }
  
  /// Crear y añadir acción de eliminar elemento
  void removeElementAction(ParkingElement element) {
    final action = ParkingAction(
      type: ActionType.remove,
      elements: [element],
      oldValues: {'exists': true},
      newValues: {'exists': false},
    );
    
    addAction(action);
  }
  
  /// Crear y añadir acción de mover elemento
  void moveElementAction(
    ParkingElement element, 
    vector_math.Vector2 oldPosition, 
    vector_math.Vector2 newPosition
  ) {
    final action = ParkingAction(
      type: ActionType.move,
      elements: [element],
      oldValues: {'position': oldPosition},
      newValues: {'position': newPosition},
    );
    
    addAction(action);
  }
  
  /// Crear y añadir acción de mover múltiples elementos
  void moveMultipleElementsAction(
    List<ParkingElement> elements,
    Map<String, vector_math.Vector2> oldPositions,
    Map<String, vector_math.Vector2> newPositions,
  ) {
    final action = ParkingAction(
      type: ActionType.multiMove,
      elements: elements,
      oldValues: {'positions': oldPositions},
      newValues: {'positions': newPositions},
    );
    
    addAction(action);
  }
  
  /// Crear y añadir acción de rotar elemento
  void rotateElementAction(
    ParkingElement element,
    double oldRotation,
    double newRotation,
  ) {
    final action = ParkingAction(
      type: ActionType.rotate,
      elements: [element],
      oldValues: {'rotation': oldRotation},
      newValues: {'rotation': newRotation},
    );
    
    addAction(action);
  }
  
  /// Crear y añadir acción de escalar elemento
  void scaleElementAction(
    ParkingElement element,
    double oldScale,
    double newScale,
  ) {
    final action = ParkingAction(
      type: ActionType.scale,
      elements: [element],
      oldValues: {'scale': oldScale},
      newValues: {'scale': newScale},
    );
    
    addAction(action);
  }
  
  /// Crear y añadir acción de editar propiedades
  void editElementAction(
    ParkingElement element,
    Map<String, dynamic> oldValues,
    Map<String, dynamic> newValues,
  ) {
    final action = ParkingAction(
      type: ActionType.edit,
      elements: [element],
      oldValues: oldValues,
      newValues: newValues,
    );
    
    addAction(action);
  }
  
  /// Deshacer la última acción
  ParkingAction? undo() {
    if (!canUndo) return null;
    
    final action = _undoStack.removeLast();
    _redoStack.add(action);
    
    notifyListeners();
    return action;
  }
  
  /// Rehacer la última acción deshecha
  ParkingAction? redo() {
    if (!canRedo) return null;
    
    final action = _redoStack.removeLast();
    _undoStack.add(action);
    
    notifyListeners();
    return action;
  }
  
  /// Limpiar todo el historial
  void clearHistory() {
    _undoStack.clear();
    _redoStack.clear();
    notifyListeners();
  }
} 