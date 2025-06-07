import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:vector_math/vector_math.dart' as vector_math;

import '../models/index.dart';
import 'collision_manager.dart';
import 'history_manager.dart';
import 'drag_manager.dart';
import '../engine/game_engine.dart';
import '../models/component_system.dart';

/// Clase que maneja el estado global del editor del mundo
class WorldState extends ChangeNotifier {
  // Listas de elementos
  List<ParkingSpot> _spots = [];
  List<ParkingSignage> _signages = [];
  List<ParkingFacility> _facilities = [];

  // Elementos seleccionados
  final List<WorldElement> _selectedElements = [];

  // Elemento copiado en el portapapeles
  List<WorldElement> _clipboardElements = [];

  // Posición de la cámara
  vector_math.Vector2 _cameraPosition = vector_math.Vector2(0, 0);

  // Nivel de zoom
  double _zoom = 1.0;

  // Modo de edición
  bool _isEditMode = false;

  // Nivel actual
  int _currentLevel = 0;
  
  // Gestor de colisiones
  late CollisionManager _collisionManager;
  
  // Gestor de arrastre
  late DragManager _dragManager;
  
  // Mensaje de error de colisión
  String _collisionErrorMessage = '';
  
  // Gestor de historial
  late HistoryManager _historyManager;
  
  // Motor de juego
  GameEngine? _gameEngine;
  
  // Sistema de componentes
  final ComponentSystem _componentSystem = ComponentSystem();
  
  // Nueva propiedad para controlar actualizaciones por lotes
  bool _batchUpdatesEnabled = false;
  bool _needsNotify = false;
  
  // Constructor
  WorldState() {
    _collisionManager = CollisionManager(state: this);
    _historyManager = HistoryManager(this);
    _dragManager = DragManager(state: this);
  }

  // Getters
  List<ParkingSpot> get spots => _spots;
  List<ParkingSignage> get signages => _signages;
  List<ParkingFacility> get facilities => _facilities;
  List<WorldElement> get selectedElements => _selectedElements;
  List<WorldElement> get clipboardElements => _clipboardElements;
  vector_math.Vector2 get cameraPosition => _cameraPosition;
  double get zoom => _zoom;
  bool get isEditMode => _isEditMode;
  int get currentLevel => _currentLevel;
  CollisionManager get collisionManager => _collisionManager;
  DragManager get dragManager => _dragManager;
  String get collisionErrorMessage => _collisionErrorMessage;
  HistoryManager get historyManager => _historyManager;
  ComponentSystem get componentSystem => _componentSystem;
  
  /// Obtener el primer elemento seleccionado (si existe)
  WorldElement? get firstSelectedElement => 
      _selectedElements.isNotEmpty ? _selectedElements.first : null;
  
  // Método para limpiar el mensaje de error de colisión
  void clearCollisionErrorMessage() {
    _collisionErrorMessage = '';
  }
  
  // Método para establecer un mensaje de error de colisión
  void setCollisionErrorMessage(String message) {
    _collisionErrorMessage = message;
    notifyListeners();
  }

  /// Lista de todos los elementos
  List<WorldElement> get allElements {
    final List<WorldElement> elements = [];
    elements.addAll(_spots);
    elements.addAll(_signages);
    elements.addAll(_facilities);
    return elements;
  }

  /// Inicializar el motor de juego
  void initGameEngine(TickerProvider vsync) {
    // Si ya existe un motor, primero detenerlo
    if (_gameEngine != null) {
      stopGameEngine();
    }

    try {
      _gameEngine = GameEngine(
        worldState: this,
        onUpdate: () {
          // Notificar cambios en cada actualización del motor
          notifyListeners();
        },
      );
      
      _gameEngine!.start(vsync);
    } catch (e) {
      print('Error al iniciar motor de juego: $e');
    }
  }
  
  /// Detener el motor de juego
  void stopGameEngine() {
    try {
      if (_gameEngine != null) {
        if (_gameEngine!.isRunning) {
          // Asegurarse de que el ticker se detiene y elimina
          _gameEngine!.stop();
        }
        _gameEngine = null;
      }
    } catch (e) {
      print('Error al detener motor de juego: $e');
    }
  }
  
  /// Añadir un componente a un elemento
  void addComponent(WorldElement element, Component component) {
    _componentSystem.addComponent(element, component);
  }
  
  /// Obtener un componente específico de un elemento
  T? getComponent<T extends Component>(WorldElement element) {
    return _componentSystem.getComponent<T>(element);
  }
  
  /// Eliminar un componente específico de un elemento
  void removeComponent<T extends Component>(WorldElement element) {
    _componentSystem.removeComponent<T>(element);
  }

  /// Método para alternar el modo de edición
  void toggleEditMode() {
    _isEditMode = !_isEditMode;
    // Al salir del modo edición, deseleccionar el elemento
    if (!_isEditMode) {
      clearSelection();
    }
    notifyListeners();
  }

  /// Método para mover la cámara
  void moveCamera(vector_math.Vector2 delta) {
    // Invertir el delta para que el movimiento sea en la dirección del arrastre
    _cameraPosition -= delta / _zoom;
    notifyListeners();
  }

  /// Método para establecer el zoom
  void setZoom(double newZoom) {
    _zoom = newZoom;
    notifyListeners();
  }

  /// Método para cambiar el nivel actual
  void setCurrentLevel(int level) {
    _currentLevel = level;
    notifyListeners();
  }

  /// Método para añadir un espacio de estacionamiento
  void addSpot(ParkingSpot spot) {
    // Buscar una posición sin colisiones
    final newPosition = _findNonCollidingPosition(spot);
    spot.position.x = newPosition.x;
    spot.position.y = newPosition.y;
    
    // Usar el gestor de historial para registrar la acción
    _historyManager.executeAction(AddElementAction(spot));
    
    // Seleccionar el nuevo elemento
    _selectedElements.add(spot);
    notifyListeners();
  }

  /// Método para añadir una señalización
  void addSignage(ParkingSignage signage) {
    // Buscar una posición sin colisiones
    final newPosition = _findNonCollidingPosition(signage);
    signage.position.x = newPosition.x;
    signage.position.y = newPosition.y;
    
    // Usar el gestor de historial para registrar la acción
    _historyManager.executeAction(AddElementAction(signage));
    
    // Seleccionar el nuevo elemento
    _selectedElements.add(signage);
    notifyListeners();
  }

  /// Método para añadir una instalación
  void addFacility(ParkingFacility facility) {
    // Buscar una posición sin colisiones
    final newPosition = _findNonCollidingPosition(facility);
    facility.position.x = newPosition.x;
    facility.position.y = newPosition.y;
    
    // Usar el gestor de historial para registrar la acción
    _historyManager.executeAction(AddElementAction(facility));
    
    // Seleccionar el nuevo elemento
    _selectedElements.add(facility);
    notifyListeners();
  }
  
  /// Método para encontrar una posición sin colisiones para un nuevo elemento
  vector_math.Vector2 _findNonCollidingPosition(WorldElement element) {
    // Si no hay elementos, usar la posición original
    if (allElements.isEmpty) {
      return element.position;
    }
    
    // Buscar una posición sin colisiones
    return _collisionManager.findNonCollidingPosition(
      element, 
      element.position,
      maxDistance: 500.0,
      step: 30.0,
    );
  }

  /// Método para eliminar elementos seleccionados
  void deleteSelectedElements() {
    if (_selectedElements.isEmpty) return;

    // Crear una copia de la lista para evitar modificarla durante la iteración
    final elementsToDelete = List<WorldElement>.from(_selectedElements);
    
    // Usar el gestor de historial para registrar la acción
    _historyManager.executeAction(DeleteMultipleElementsAction(elementsToDelete));
    
    _selectedElements.clear();
    notifyListeners();
  }

  /// Método para copiar los elementos seleccionados al portapapeles
  void copySelectedElements() {
    if (_selectedElements.isEmpty) return;
    
    // Limpiar el portapapeles
    _clipboardElements.clear();
    
    // Crear copias profundas de los elementos seleccionados
    for (final element in _selectedElements) {
      final copy = _createDeepCopy(element);
      if (copy != null) {
        _clipboardElements.add(copy);
      }
    }
    
    notifyListeners();
  }

  /// Método para pegar el elemento del portapapeles en una posición
  void pasteElements(vector_math.Vector2 position) {
    if (_clipboardElements.isEmpty) return;
    
    // Calcular el centro de los elementos copiados
    vector_math.Vector2 center = vector_math.Vector2(0, 0);
    for (final element in _clipboardElements) {
      center.x += element.position.x;
      center.y += element.position.y;
    }
    center.x /= _clipboardElements.length;
    center.y /= _clipboardElements.length;
    
    // Calcular el desplazamiento
    final offset = vector_math.Vector2(
      position.x - center.x,
      position.y - center.y
    );
    
    // Deseleccionar elementos actuales
    clearSelection();
    
    // Pegar cada elemento con el desplazamiento
    for (final element in _clipboardElements) {
      // Crear una nueva copia para pegar
      final copy = _createDeepCopy(element);
      if (copy != null) {
        // Aplicar el desplazamiento
        copy.position.x += offset.x;
        copy.position.y += offset.y;
        
        // Buscar una posición sin colisiones
        final newPosition = _findNonCollidingPosition(copy);
        copy.position.x = newPosition.x;
        copy.position.y = newPosition.y;
        
        // Añadir el elemento según su tipo
        if (copy is ParkingSpot) {
          _historyManager.executeAction(AddElementAction(copy));
        } else if (copy is ParkingSignage) {
          _historyManager.executeAction(AddElementAction(copy));
        } else if (copy is ParkingFacility) {
          _historyManager.executeAction(AddElementAction(copy));
        }
        
        // Seleccionar el elemento pegado, independientemente del modo
        _selectedElements.add(copy);
        copy.isSelected = true;
      }
    }
    
    notifyListeners();
  }
  
  /// Método para crear una copia profunda de un elemento
  WorldElement? _createDeepCopy(WorldElement element) {
    // Generar un nuevo ID único
    final newId = DateTime.now().millisecondsSinceEpoch.toString();
    
    if (element is ParkingSpot) {
      return ParkingSpot(
        id: newId,
        position: vector_math.Vector2(element.position.x, element.position.y),
        type: element.type,
        category: element.category,
        isOccupied: element.isOccupied,
        vehiclePlate: element.vehiclePlate,
        label: element.label,
        rotation: element.rotation,
        size: Size3D.copy(element.size),
      );
    } else if (element is ParkingSignage) {
      return ParkingSignage(
        id: newId,
        position: vector_math.Vector2(element.position.x, element.position.y),
        type: element.type,
        direction: element.direction,
        label: element.label,
        rotation: element.rotation,
        size: Size3D.copy(element.size),
      );
    } else if (element is ParkingFacility) {
      return ParkingFacility(
        id: newId,
        position: vector_math.Vector2(element.position.x, element.position.y),
        type: element.type,
        label: element.label,
        rotation: element.rotation,
        size: Size3D.copy(element.size),
      );
    }
    
    return null;
  }

  /// Método para seleccionar un elemento
  void selectElement(WorldElement element, {bool isShiftPressed = false, bool isControlPressed = false}) {
    // Si se presiona Control, se alterna la selección del elemento
    if (isControlPressed) {
      if (_selectedElements.contains(element)) {
        // Si ya está seleccionado, lo deseleccionamos
        _selectedElements.remove(element);
        element.isSelected = false;
      } else {
        // Si no está seleccionado, lo añadimos a la selección
        _selectedElements.add(element);
        element.isSelected = true;
      }
    }
    // Si se presiona Shift, se añade el elemento a la selección existente
    else if (isShiftPressed) {
      if (!_selectedElements.contains(element)) {
        _selectedElements.add(element);
        element.isSelected = true;
      }
    }
    // Si no se presiona ninguna tecla modificadora, se selecciona solo este elemento
    else {
      // Deseleccionar todos los elementos actuales
      for (final elem in _selectedElements) {
        elem.isSelected = false;
      }
      _selectedElements.clear();
      
      // Seleccionar el nuevo elemento
      _selectedElements.add(element);
      element.isSelected = true;
    }
    
    notifyListeners();
  }

  /// Método para deseleccionar todos los elementos
  void clearSelection() {
    // Deseleccionar todos los elementos en selección múltiple
    for (final element in _selectedElements) {
      element.isSelected = false;
    }
    _selectedElements.clear();

    notifyListeners();
  }

  /// Método para seleccionar elementos dentro de un rectángulo
  void selectElementsInRect(Rect rect, {bool isShiftPressed = false, bool isControlPressed = false}) {
    // Si no se presionan teclas modificadoras, limpiar la selección actual
    if (!isShiftPressed && !isControlPressed) {
      // Deseleccionar todos los elementos actuales
      for (final element in _selectedElements) {
        element.isSelected = false;
      }
      _selectedElements.clear();
    }

    // Lista temporal para almacenar elementos dentro del rectángulo
    final List<WorldElement> elementsInRect = [];

    // Encontrar elementos dentro del rectángulo
    for (final element in allElements) {
      final elementPosition = element.position;
      final elementPoint = Offset(elementPosition.x, elementPosition.y);

      if (rect.contains(elementPoint)) {
        elementsInRect.add(element);
      }
    }

    // Procesar según las teclas modificadoras
    for (final element in elementsInRect) {
      // Si se presiona Control, alternar la selección
      if (isControlPressed) {
        if (_selectedElements.contains(element)) {
          _selectedElements.remove(element);
          element.isSelected = false;
        } else {
          _selectedElements.add(element);
          element.isSelected = true;
        }
      } 
      // Si se presiona Shift o ninguna tecla, añadir a la selección
      else {
        if (!_selectedElements.contains(element)) {
          _selectedElements.add(element);
          element.isSelected = true;
        }
      }
    }

    notifyListeners();
  }

  /// Método para mover el elemento seleccionado
  void moveSelectedElement(vector_math.Vector2 delta) {
    if (_selectedElements.isNotEmpty) {
      // Guardar posición actual
      final originalX = _selectedElements.first.position.x;
      final originalY = _selectedElements.first.position.y;
      
      // Actualizar posición
      _selectedElements.first.position.x += delta.x;
      _selectedElements.first.position.y += delta.y;
      
      // Verificar colisiones
      if (_collisionManager.checkElementCollisions(_selectedElements.first)) {
        // Restaurar posición si hay colisión
        _selectedElements.first.position.x = originalX;
        _selectedElements.first.position.y = originalY;
      }
      
      notifyListeners();
    }
  }

  /// Método para mover los elementos seleccionados
  void moveSelectedElements(vector_math.Vector2 delta) {
    if (_selectedElements.isEmpty) return;

    // Guardar posiciones originales
    final Map<WorldElement, vector_math.Vector2> originalPositions = {};
    for (final element in _selectedElements) {
      originalPositions[element] = vector_math.Vector2(
        element.position.x, 
        element.position.y
      );
    }
    
    // Mover todos los elementos
    for (final element in _selectedElements) {
      element.position.x += delta.x;
      element.position.y += delta.y;
    }
    
    // Verificar colisiones
    bool hasCollision = false;
    
    // Verificar si algún elemento colisiona con elementos no seleccionados
    for (final element in _selectedElements) {
      if (_collisionManager.checkElementCollisions(element, exclude: _selectedElements)) {
        hasCollision = true;
        break;
      }
    }
    
    // Si hay colisión, restaurar posiciones originales
    if (hasCollision) {
      for (final element in _selectedElements) {
        final originalPos = originalPositions[element]!;
        element.position.x = originalPos.x;
        element.position.y = originalPos.y;
      }
      
      // Establecer mensaje de error
      setCollisionErrorMessage("No se puede mover: se detectaron colisiones");
    } else {
      // Registrar la acción en el historial para cada elemento
      for (final element in _selectedElements) {
        _historyManager.executeAction(MoveElementAction(
          element, 
          originalPositions[element]!, 
          vector_math.Vector2(element.position.x, element.position.y)
        ));
      }
    }

    notifyListeners();
  }

  /// Método para cargar el estado desde un JSON
  void loadFromJson(Map<String, dynamic> json) {
    // Implementar la lógica para cargar desde JSON
    notifyListeners();
  }

  /// Método para exportar el estado a JSON
  Map<String, dynamic> toJson() {
    // Implementar la lógica para exportar a JSON
    return {};
  }
  
  /// Método para rotar el elemento seleccionado en sentido horario
  void rotateSelectedElementClockwise() {
    if (_selectedElements.isNotEmpty && _selectedElements.first.isRotatable) {
      // Guardar rotación original
      final originalRotation = _selectedElements.first.rotation;
      
      // Rotar 45 grados (π/4 radianes) en sentido horario
      _selectedElements.first.rotation += 3.14159 / 4;
      
      // Verificar colisiones después de la rotación
      if (_collisionManager.checkElementCollisions(_selectedElements.first)) {
        // Restaurar rotación original si hay colisión
        _selectedElements.first.rotation = originalRotation;
        // Establecer mensaje de error
        setCollisionErrorMessage("No se puede rotar: se detectó una colisión");
      } else {
        // Registrar la acción en el historial
        _historyManager.executeAction(RotateElementAction(
          _selectedElements.first, 
          originalRotation, 
          _selectedElements.first.rotation
        ));
      }
      
      notifyListeners();
    }
  }

  /// Método para rotar el elemento seleccionado en sentido antihorario
  void rotateSelectedElementCounterClockwise() {
    if (_selectedElements.isNotEmpty && _selectedElements.first.isRotatable) {
      // Guardar rotación original
      final originalRotation = _selectedElements.first.rotation;
      
      // Rotar 45 grados (π/4 radianes) en sentido antihorario
      _selectedElements.first.rotation -= 3.14159 / 4;
      
      // Verificar colisiones después de la rotación
      if (_collisionManager.checkElementCollisions(_selectedElements.first)) {
        // Restaurar rotación original si hay colisión
        _selectedElements.first.rotation = originalRotation;
        // Establecer mensaje de error
        setCollisionErrorMessage("No se puede rotar: se detectó una colisión");
      } else {
        // Registrar la acción en el historial
        _historyManager.executeAction(RotateElementAction(
          _selectedElements.first, 
          originalRotation, 
          _selectedElements.first.rotation
        ));
      }
      
      notifyListeners();
    }
  }
  
  /// Método para rotar elementos seleccionados con verificación de colisiones
  void rotateSelectedElementsWithAngle(double radians) {
    if (_selectedElements.isEmpty) return;
    
    // Guardar rotaciones originales
    final Map<WorldElement, double> originalRotations = {};
    for (final element in _selectedElements) {
      if (element.isRotatable) {
        originalRotations[element] = element.rotation;
      }
    }
    
    // Intentar rotar todos los elementos
    bool hasCollision = false;
    
    // Primero aplicamos la rotación a todos los elementos
    for (final element in _selectedElements) {
      if (element.isRotatable) {
        element.rotation += radians;
      }
    }
    
    // Luego verificamos colisiones
    // 1. Colisiones entre elementos seleccionados y no seleccionados
    for (final element in _selectedElements) {
      if (_collisionManager.checkElementCollisions(element, exclude: _selectedElements)) {
        hasCollision = true;
        break;
      }
    }
    
    // 2. Colisiones entre elementos seleccionados (si están muy juntos)
    if (!hasCollision && _selectedElements.length > 1) {
      for (int i = 0; i < _selectedElements.length; i++) {
        for (int j = i + 1; j < _selectedElements.length; j++) {
          if (_collisionManager.checkCollisionPrecise(_selectedElements[i], _selectedElements[j])) {
            hasCollision = true;
            break;
          }
        }
        if (hasCollision) break;
      }
    }
    
    // Si hay colisión, restaurar todas las rotaciones originales
    if (hasCollision) {
      for (final element in _selectedElements) {
        if (originalRotations.containsKey(element)) {
          element.rotation = originalRotations[element]!;
        }
      }
      // Establecer mensaje de error
      setCollisionErrorMessage("No se puede rotar: se detectaron colisiones entre elementos");
    } else {
      // Registrar la acción en el historial para cada elemento
      for (final element in _selectedElements) {
        if (element.isRotatable && originalRotations.containsKey(element)) {
          _historyManager.executeAction(RotateElementAction(
            element, 
            originalRotations[element]!, 
            element.rotation
          ));
        }
      }
    }
    
    notifyListeners();
  }
  
  /// Método para alinear elementos seleccionados con verificación de colisiones
  void alignSelectedElements(String direction) {
    if (_selectedElements.length <= 1) return;
    
    // Encontrar los límites de los elementos seleccionados
    double minX = double.infinity;
    double maxX = double.negativeInfinity;
    double minY = double.infinity;
    double maxY = double.negativeInfinity;
    
    for (final element in _selectedElements) {
      final pos = element.position;
      if (pos.x < minX) minX = pos.x;
      if (pos.x > maxX) maxX = pos.x;
      if (pos.y < minY) minY = pos.y;
      if (pos.y > maxY) maxY = pos.y;
    }
    
    // Guardar posiciones originales
    final Map<WorldElement, vector_math.Vector2> originalPositions = {};
    for (final element in _selectedElements) {
      originalPositions[element] = vector_math.Vector2(
        element.position.x, 
        element.position.y
      );
    }
    
    // Alinear según la dirección
    switch (direction) {
      case 'left':
        for (final element in _selectedElements) {
          element.position.x = minX;
        }
        break;
      case 'right':
        for (final element in _selectedElements) {
          element.position.x = maxX;
        }
        break;
      case 'top':
        for (final element in _selectedElements) {
          element.position.y = minY;
        }
        break;
      case 'bottom':
        for (final element in _selectedElements) {
          element.position.y = maxY;
        }
        break;
      case 'center':
        final centerX = (minX + maxX) / 2;
        final centerY = (minY + maxY) / 2;
        for (final element in _selectedElements) {
          element.position.x = centerX;
          element.position.y = centerY;
        }
        break;
    }
    
    // Verificar colisiones después de la alineación
    bool hasCollision = false;
    
    // 1. Colisiones entre elementos seleccionados y no seleccionados
    for (final element in _selectedElements) {
      if (_collisionManager.checkElementCollisions(element, exclude: _selectedElements)) {
        hasCollision = true;
        break;
      }
    }
    
    // 2. Colisiones entre elementos seleccionados (importante para alineación center)
    if (!hasCollision && _selectedElements.length > 1 && direction == 'center') {
      for (int i = 0; i < _selectedElements.length; i++) {
        for (int j = i + 1; j < _selectedElements.length; j++) {
          if (_collisionManager.checkCollisionPrecise(_selectedElements[i], _selectedElements[j])) {
            hasCollision = true;
            break;
          }
        }
        if (hasCollision) break;
      }
    }
    
    // Si hay colisión, restaurar posiciones originales
    if (hasCollision) {
      for (final element in _selectedElements) {
        final originalPos = originalPositions[element]!;
        element.position.x = originalPos.x;
        element.position.y = originalPos.y;
      }
      
      // Mostrar mensaje de error específico según la dirección
      String directionText;
      switch (direction) {
        case 'left':
          directionText = 'a la izquierda';
          break;
        case 'right':
          directionText = 'a la derecha';
          break;
        case 'top':
          directionText = 'arriba';
          break;
        case 'bottom':
          directionText = 'abajo';
          break;
        case 'center':
          directionText = 'al centro';
          break;
        default:
          directionText = '';
      }
      setCollisionErrorMessage("No se puede alinear $directionText: se detectaron colisiones");
    } else {
      // Registrar la acción en el historial para cada elemento
      for (final element in _selectedElements) {
        if (originalPositions.containsKey(element)) {
          _historyManager.executeAction(MoveElementAction(
            element, 
            originalPositions[element]!, 
            vector_math.Vector2(element.position.x, element.position.y)
          ));
        }
      }
    }
    
    notifyListeners();
  }
  
  /// Método para deshacer la última acción
  void undo() {
    _historyManager.undo();
  }
  
  /// Método para rehacer la última acción deshecha
  void redo() {
    _historyManager.redo();
  }

  /// Inicia una actualización por lotes para reducir notificaciones
  void beginBatchUpdate() {
    _batchUpdatesEnabled = true;
    _needsNotify = false;
  }
  
  /// Finaliza una actualización por lotes y notifica si es necesario
  void endBatchUpdate() {
    _batchUpdatesEnabled = false;
    if (_needsNotify) {
      notifyListeners();
      _needsNotify = false;
    }
  }
  
  /// Sobrescribe notifyListeners para manejar actualizaciones por lotes
  @override
  void notifyListeners() {
    if (_batchUpdatesEnabled) {
      _needsNotify = true;
    } else {
      super.notifyListeners();
    }
  }

  /// Método para mover múltiples elementos a la vez (optimizado)
  void moveMultipleElements(List<WorldElement> elements, vector_math.Vector2 delta) {
    if (elements.isEmpty) return;
    
    beginBatchUpdate();
    
    for (final element in elements) {
      final newPosition = vector_math.Vector2(
        element.position.x + delta.x,
        element.position.y + delta.y,
      );
      element.move(newPosition);
    }
    
    endBatchUpdate();
  }
  
  /// Método optimizado para filtrar elementos por nivel y visibilidad
  List<WorldElement> getVisibleElementsInCurrentLevel() {
    return allElements.where((element) => 
      element.isVisible).toList();
  }
}
