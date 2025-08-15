import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as vector_math;

import '../models/index.dart';
import 'animation_manager.dart';
import 'camera.dart';
import 'clipboard_manager.dart';
import 'grid_manager.dart';
import 'history_manager.dart';
import 'keyboard_shortcuts_manager.dart';

/// Clase que gestiona el estado del sistema de parkeo
class ParkingState with ChangeNotifier {
  // Elementos del mundo
  final List<ParkingElement> _spots = [];
  final List<ParkingElement> _signages = [];
  final List<ParkingElement> _facilities = [];

  // Elementos seleccionados
  final List<ParkingElement> _selectedElements = [];

  // Cámara del sistema
  late Camera _camera;

  // Estado del editor
  bool _isEditMode = false;
  EditorMode _editorMode = EditorMode.free;

  // Estado del cursor
  vector_math.Vector2 _cursorPosition = vector_math.Vector2(0, 0);

  // Opciones de visualización
  bool _showCoordinates = true;
  bool _showGrid = true;

  // Historial para deshacer/rehacer
  late HistoryManager _historyManager;

  // Tamaño del canvas para cálculos de visualización
  Size _canvasSize = Size.zero;

  // Gestor de animaciones
  late AnimationManager animationManager;

  // Gestor de cuadrícula y guías
  late GridManager gridManager;

  // Gestor de portapapeles
  late ClipboardManager clipboardManager;

  // Gestor de atajos de teclado
  KeyboardShortcutsManager? _keyboardShortcutsManager;

  // Constructor
  ParkingState() {
    // Inicializar la cámara
    _camera =
        Camera(initialPosition: vector_math.Vector2(0, 0), initialZoom: 1.0);

    // Escuchar cambios en la cámara para notificar a los widgets
    _camera.addListener(() {
      notifyListeners();
    });

    // Inicializar el gestor de historial
    _historyManager = HistoryManager();

    // Inicializar el gestor de animaciones
    animationManager = AnimationManager(
      enableSelectionAnimation: true,
      enableMovementAnimation: true,
      enableZoomAnimation: true,
      enableCreateDeleteAnimation: true,
    );

    // Inicializar el gestor de cuadrícula y guías
    gridManager = GridManager();

    // Inicializar el gestor de portapapeles
    clipboardManager = ClipboardManager();
  }

  // Getters
  List<ParkingElement> get spots => List.unmodifiable(_spots);
  List<ParkingElement> get signages => List.unmodifiable(_signages);
  List<ParkingElement> get facilities => List.unmodifiable(_facilities);
  List<ParkingElement> get selectedElements =>
      List.unmodifiable(_selectedElements);

  // Acceso a la cámara
  Camera get camera => _camera;

  // Accesos directos a propiedades de la cámara para compatibilidad
  vector_math.Vector2 get cameraPosition => _camera.position;
  double get zoom => _camera.zoom;

  bool get isEditMode => _isEditMode;
  EditorMode get editorMode => _editorMode;

  vector_math.Vector2 get cursorPosition => _cursorPosition;

  bool get showCoordinates => _showCoordinates;
  bool get showGrid => _showGrid;

  // Getter para obtener todos los elementos
  List<ParkingElement> get allElements {
    final List<ParkingElement> result = [];
    result.addAll(_spots);
    result.addAll(_signages);
    result.addAll(_facilities);
    return result;
  }

  // Getter para el tamaño del canvas
  Size get canvasSize => _canvasSize;

  // Getter para el historial
  HistoryManager get historyManager => _historyManager;

  // Getter para el gestor de atajos de teclado
  KeyboardShortcutsManager? get keyboardShortcutsManager =>
      _keyboardShortcutsManager;

  // Setters para compatibilidad con código existente
  set cameraPosition(vector_math.Vector2 value) {
    _camera.position = value;
  }

  set zoom(double value) {
    _camera.zoom = value;
  }

  set isEditMode(bool value) {
    if (_isEditMode != value) {
      _isEditMode = value;
      notifyListeners();
    }
  }

  set editorMode(EditorMode value) {
    if (_editorMode != value) {
      _editorMode = value;
      notifyListeners();
    }
  }

  set cursorPosition(vector_math.Vector2 value) {
    if (_cursorPosition != value) {
      _cursorPosition = value;
      notifyListeners();
    }
  }

  set showCoordinates(bool value) {
    if (_showCoordinates != value) {
      _showCoordinates = value;
      notifyListeners();
    }
  }

  set showGrid(bool value) {
    if (_showGrid != value) {
      _showGrid = value;
      notifyListeners();
    }
  }

  // Setter para el tamaño del canvas
  set canvasSize(Size value) {
    if (_canvasSize != value) {
      _canvasSize = value;
      // Actualizar también el tamaño del viewport de la cámara sin notificar
      // para evitar un ciclo de notificaciones durante el rendering
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _camera.viewportSize = value;
      });
      notifyListeners();
    }
  }

  // Método para limpiar el estado de destacado de todos los spots
  void clearAllHighlights() {
    bool changed = false;
    
    for (final element in allElements) {
      if (element is ParkingSpot && element.isHighlighted) {
        element.isHighlighted = false;
        changed = true;
      }
    }
    
    if (changed) {
      notifyListeners();
    }
  }

  // Métodos para alternar estados
  void toggleEditMode() {
    _isEditMode = !_isEditMode;

    // Siempre limpiar la selección al cambiar de modo
    clearSelection();
    
    // Siempre limpiar el estado de destacado al cambiar de modo
    clearAllHighlights();

    // Asegurar que todos los elementos permanezcan visibles
    for (final element in allElements) {
      element.isVisible = true;
    }

    notifyListeners();
  }

  void toggleShowCoordinates() {
    showCoordinates = !_showCoordinates;
  }

  void toggleShowGrid() {
    showGrid = !_showGrid;
  }

  // Métodos para gestionar la selección
  void selectElement(ParkingElement element) {
    if (!_selectedElements.contains(element)) {
      // Actualizar el estado de selección del elemento
      element.isSelected = true;

      _selectedElements.add(element);
      notifyListeners();
    }
  }

  void deselectElement(ParkingElement element) {
    if (_selectedElements.contains(element)) {
      // Actualizar el estado de selección del elemento
      element.isSelected = false;

      _selectedElements.remove(element);
      notifyListeners();
    }
  }

  void toggleElementSelection(ParkingElement element) {
    if (_selectedElements.contains(element)) {
      deselectElement(element);
    } else {
      selectElement(element);
    }
  }

  void clearSelection() {
    // Actualizar el estado de selección de cada elemento
    for (final element in _selectedElements) {
      element.isSelected = false;
    }

    _selectedElements.clear();
    notifyListeners();
  }

  void selectMultipleElements(List<ParkingElement> elements) {
    bool changed = false;

    for (final element in elements) {
      if (!_selectedElements.contains(element)) {
        element.isSelected = true;
        _selectedElements.add(element);
        changed = true;
      }
    }

    if (changed) {
      notifyListeners();
    }
  }

  // Métodos para añadir elementos
  void addElement(ParkingElement element) {
    // Determinar a qué lista añadir basado en el tipo de elemento
    if (element is ParkingSpot) {
      _spots.add(element);
    } else if (element is ParkingSignage) {
      _signages.add(element);
    } else if (element is ParkingFacility) {
      _facilities.add(element);
    }
    notifyListeners();
  }

  void addSpot(ParkingElement spot) {
    _spots.add(spot);
    notifyListeners();
  }

  void addSignage(ParkingElement signage) {
    _signages.add(signage);
    notifyListeners();
  }

  void addFacility(ParkingElement facility) {
    _facilities.add(facility);
    notifyListeners();
  }

  // Métodos para eliminar elementos
  void removeElement(ParkingElement element) {
    bool removed = false;

    if (_spots.contains(element)) {
      _spots.remove(element);
      removed = true;
    } else if (_signages.contains(element)) {
      _signages.remove(element);
      removed = true;
    } else if (_facilities.contains(element)) {
      _facilities.remove(element);
      removed = true;
    }

    if (removed) {
      if (_selectedElements.contains(element)) {
        deselectElement(element);
      }
      notifyListeners();
    }
  }

  void removeSelectedElements() {
    if (_selectedElements.isEmpty) return;

    final elementsToRemove = List<ParkingElement>.from(_selectedElements);

    for (final element in elementsToRemove) {
      removeElement(element);
    }
  }

  // Métodos para gestionar la cámara
  void panCamera(Offset delta) {
    _camera.pan(delta);
  }

  void zoomCamera(double factor, Offset focusPoint) {
    _camera.zoomAtPoint(factor, focusPoint);
  }

  void resetCamera() {
    _camera.reset();
  }

  // Métodos para encontrar elementos
  ParkingElement? findElementAt(vector_math.Vector2 point) {
    // Buscar primero en orden inverso para encontrar elementos en la capa superior

    // Buscar en instalaciones
    for (int i = _facilities.length - 1; i >= 0; i--) {
      final facility = _facilities[i];
      if (facility.isVisible && facility.containsPoint(point, _camera.zoom)) {
        return facility;
      }
    }

    // Buscar en señalizaciones
    for (int i = _signages.length - 1; i >= 0; i--) {
      final signage = _signages[i];
      if (signage.isVisible && signage.containsPoint(point, _camera.zoom)) {
        return signage;
      }
    }

    // Buscar en espacios de estacionamiento
    for (int i = _spots.length - 1; i >= 0; i--) {
      final spot = _spots[i];
      if (spot.isVisible && spot.containsPoint(point, _camera.zoom)) {
        return spot;
      }
    }

    return null;
  }

  // Métodos para serialización
  Map<String, dynamic> toJson() {
    return {
      'spots': _spots.map((spot) => spot.toJson()).toList(),
      'signages': _signages.map((signage) => signage.toJson()).toList(),
      'facilities': _facilities.map((facility) => facility.toJson()).toList(),
      'cameraPosition': {
        'x': _camera.position.x,
        'y': _camera.position.y,
      },
      'zoom': _camera.zoom,
    };
  }

  // Método para limpiar todo el estado
  void clear() {
    _spots.clear();
    _signages.clear();
    _facilities.clear();
    _selectedElements.clear();
    _camera.reset();
    _isEditMode = false;
    _editorMode = EditorMode.free;
    notifyListeners();
  }

  /// Encuentra una posición óptima para un nuevo elemento que no colisione con otros
  /// y que esté alineado con elementos contiguos si es posible
  vector_math.Vector2 findOptimalPosition(
      Size elementSize, vector_math.Vector2 initialPosition) {
    // Paso 1: Verificar si la posición inicial es válida (sin colisiones)
    if (!_hasCollisionAtPosition(initialPosition, elementSize)) {
      return initialPosition;
    }

    // Paso 2: Buscar una posición alineada con elementos cercanos
    final alignedPosition = _findAlignedPosition(initialPosition, elementSize);
    if (alignedPosition != null) {
      return alignedPosition;
    }

    // Paso 3: Realizar una búsqueda en espiral para encontrar una posición libre
    return _findPositionWithoutCollision(initialPosition, elementSize);
  }

  /// Verifica si hay una colisión en la posición dada
  bool _hasCollisionAtPosition(vector_math.Vector2 position, Size elementSize) {
    // Crear un rectángulo para el nuevo elemento
    final elementRect = Rect.fromCenter(
      center: Offset(position.x, position.y),
      width: elementSize.width,
      height: elementSize.height,
    );

    // Verificar colisión con todos los elementos existentes
    for (final element in allElements) {
      final size = element.getSize();
      final width = size.width * element.scale;
      final height = size.height * element.scale;

      final otherRect = Rect.fromCenter(
        center: Offset(element.position.x, element.position.y),
        width: width,
        height: height,
      );

      if (elementRect.overlaps(otherRect)) {
        return true; // Hay colisión
      }
    }

    return false; // No hay colisión
  }

  /// Busca una posición alineada con elementos cercanos
  vector_math.Vector2? _findAlignedPosition(
      vector_math.Vector2 position, Size elementSize) {
    // Radio de búsqueda para elementos cercanos
    const double searchRadius = 200.0;

    // Encontrar elementos cercanos
    final nearbyElements = allElements.where((element) {
      final distance = (element.position - position).length;
      return distance < searchRadius;
    }).toList();

    if (nearbyElements.isEmpty) {
      return null;
    }

    // Intentar alinear horizontalmente
    for (final element in nearbyElements) {
      final elementPos = element.position;
      final size = element.getSize();

      // Posiciones potenciales alineadas horizontalmente (misma altura)
      final positions = [
        // A la derecha del elemento
        vector_math.Vector2(
            elementPos.x +
                (size.width * element.scale + elementSize.width) / 2 +
                10,
            elementPos.y),
        // A la izquierda del elemento
        vector_math.Vector2(
            elementPos.x -
                (size.width * element.scale + elementSize.width) / 2 -
                10,
            elementPos.y),
      ];

      for (final pos in positions) {
        if (!_hasCollisionAtPosition(pos, elementSize)) {
          return pos;
        }
      }
    }

    // Intentar alinear verticalmente
    for (final element in nearbyElements) {
      final elementPos = element.position;
      final size = element.getSize();

      // Posiciones potenciales alineadas verticalmente (misma columna)
      final positions = [
        // Debajo del elemento
        vector_math.Vector2(
            elementPos.x,
            elementPos.y +
                (size.height * element.scale + elementSize.height) / 2 +
                10),
        // Encima del elemento
        vector_math.Vector2(
            elementPos.x,
            elementPos.y -
                (size.height * element.scale + elementSize.height) / 2 -
                10),
      ];

      for (final pos in positions) {
        if (!_hasCollisionAtPosition(pos, elementSize)) {
          return pos;
        }
      }
    }

    return null;
  }

  /// Busca una posición sin colisiones usando un patrón de espiral
  vector_math.Vector2 _findPositionWithoutCollision(
      vector_math.Vector2 initialPosition, Size elementSize) {
    // Búsqueda en espiral para encontrar una posición libre
    const double stepSize = 40.0; // Tamaño del paso
    const int maxSteps = 100; // Número máximo de pasos

    int x = 0;
    int y = 0;
    int dx = 0;
    int dy = -1;

    for (int i = 0; i < maxSteps; i++) {
      if (x == y || (x < 0 && x == -y) || (x > 0 && x == 1 - y)) {
        // Cambiar dirección al llegar a un punto de giro en la espiral
        final temp = dx;
        dx = -dy;
        dy = temp;
      }

      // Avanzar en la espiral
      x += dx;
      y += dy;

      // Calcular la nueva posición
      final position = vector_math.Vector2(
          initialPosition.x + x * stepSize, initialPosition.y + y * stepSize);

      // Verificar si la posición está libre
      if (!_hasCollisionAtPosition(position, elementSize)) {
        return position;
      }
    }

    // Si no se encuentra una posición libre, devolver una posición alejada del origen
    return vector_math.Vector2(
        initialPosition.x + 300, initialPosition.y + 300);
  }

  /// Método para centrar la vista en el origen
  void centerViewOnOrigin(Size screenSize) {
    _camera.centerViewOnOrigin(screenSize);
  }

  /// Método para convertir coordenadas de pantalla a mundo
  vector_math.Vector2 screenToWorld(Offset screenPos) {
    return _camera.screenToWorld(screenPos);
  }

  /// Método para convertir coordenadas de mundo a pantalla
  Offset worldToScreen(vector_math.Vector2 worldPos) {
    return _camera.worldToScreen(worldPos);
  }

  /// Método para hacer zoom centrado en un punto
  void zoomAtPoint(double zoomFactor, Offset screenPoint) {
    _camera.zoomAtPoint(zoomFactor, screenPoint);
  }

  /// Método para centrar la vista en un punto específico con animación
  /// Este método es un wrapper para el método de la cámara
  Future<void> centerViewOnPointWithAnimation(
    vector_math.Vector2 point,
    TickerProvider vsync, {
    double? targetZoom,
  }) async {
    await _camera.centerOnPointWithAnimation(point, vsync,
        targetZoom: targetZoom);
  }

  /// Método para añadir un elemento con animación
  Future<void> addElementWithAnimation(
      ParkingElement element, TickerProvider vsync) async {
    // Añadir el elemento normalmente
    addElement(element);

    // Registrar la acción en el historial
    _historyManager.addElementAction(element);

    // Animar su aparición
    await animationManager.animateFade(element, true, vsync);
  }

  /// Método para mover elementos con animación
  Future<void> moveElementsWithAnimation(List<ParkingElement> elements,
      vector_math.Vector2 delta, TickerProvider vsync) async {
    if (elements.isEmpty) return;

    // Calcular posiciones objetivo
    final List<vector_math.Vector2> targetPositions = elements.map((element) {
      return vector_math.Vector2(
        element.position.x + delta.x,
        element.position.y + delta.y,
      );
    }).toList();

    // Animar el movimiento
    await animationManager.animateMultipleElements(
      elements,
      targetPositions,
      vsync,
    );

    // Actualizar el historial después de la animación
    if (elements.length == 1) {
      final element = elements.first;
      final oldPosition = vector_math.Vector2(
        element.position.x - delta.x,
        element.position.y - delta.y,
      );
      _historyManager.moveElementAction(element, oldPosition, element.position);
    } else {
      // Crear mapas de posiciones para historial
      final Map<String, vector_math.Vector2> oldPositions = {};
      final Map<String, vector_math.Vector2> newPositions = {};

      for (final element in elements) {
        oldPositions[element.id] = vector_math.Vector2(
          element.position.x - delta.x,
          element.position.y - delta.y,
        );
        newPositions[element.id] = element.position;
      }

      _historyManager.moveMultipleElementsAction(
        List.from(elements),
        oldPositions,
        newPositions,
      );
    }

    notifyListeners();
  }

  /// Método para rotar un elemento con animación
  Future<void> rotateElementWithAnimation(ParkingElement element,
      double targetRotation, TickerProvider vsync) async {
    // Guardar rotación anterior para historial
    final double previousRotation = element.rotation;

    // Animar la rotación
    await animationManager.animateRotation(
      element,
      targetRotation,
      vsync,
    );

    // Actualizar el historial después de la animación
    _historyManager.rotateElementAction(
      element,
      previousRotation,
      targetRotation,
    );

    notifyListeners();
  }

  /// Método para eliminar un elemento con animación
  Future<void> removeElementWithAnimation(
      ParkingElement element, TickerProvider vsync) async {
    // Registrar la acción en el historial
    _historyManager.removeElementAction(element);

    // Animar desaparición
    await animationManager.animateFade(element, false, vsync);

    // Eliminar el elemento después de la animación
    removeElement(element);
  }

  /// Sobrescribir el método de eliminación para limpiar opacidades
  @override
  void dispose() {
    // Liberar recursos de animaciones
    animationManager.dispose();

    // Limpiar opacidades
    // ElementOpacity.clear();

    super.dispose();
  }

  // Inicializar el gestor de atajos de teclado (después de crear la UI)
  void initKeyboardShortcutsManager(Function(String) onActionPerformed) {
    _keyboardShortcutsManager = KeyboardShortcutsManager(
      parkingState: this,
      clipboardManager: clipboardManager,
      onActionPerformed: onActionPerformed,
    );
  }

  /// Método para aplicar guías inteligentes a una posición propuesta
  vector_math.Vector2 applySmartGuides(
    ParkingElement element,
    vector_math.Vector2 proposedPosition,
  ) {
    // Obtener todos los elementos excepto el actual
    final otherElements = allElements.where((e) => e != element).toList();

    // Calcular y aplicar guías inteligentes
    return gridManager.calculateSmartGuides(
      element,
      proposedPosition,
      otherElements,
    );
  }

  // Métodos para deshacer/rehacer acciones

  /// Deshace la última acción realizada
  void undoLastAction() {
    final action = _historyManager.undo();
    if (action == null) return;

    // Aplicar la acción de deshacer según el tipo
    switch (action.type) {
      case ActionType.add:
        // Eliminar temporalmente el elemento añadido
        for (final element in action.elements) {
          removeElement(element);
        }
        break;
      case ActionType.remove:
        // Restaurar el elemento eliminado
        for (final element in action.elements) {
          addElement(element);
        }
        break;
      case ActionType.move:
        // Restaurar la posición anterior
        final oldPosition = action.oldValues['position'] as vector_math.Vector2;
        final element = action.elements.first;
        element.position = oldPosition;
        break;
      case ActionType.multiMove:
        // Restaurar múltiples posiciones
        final positions =
            action.oldValues['positions'] as Map<String, vector_math.Vector2>;
        for (final element in action.elements) {
          if (positions.containsKey(element.id)) {
            element.position = positions[element.id]!;
          }
        }
        break;
      case ActionType.rotate:
        // Restaurar rotación anterior
        final oldRotation = action.oldValues['rotation'] as double;
        final element = action.elements.first;
        element.rotation = oldRotation;
        break;
      case ActionType.scale:
        // Restaurar escala anterior
        final oldScale = action.oldValues['scale'] as double;
        final element = action.elements.first;
        element.scale = oldScale;
        break;
      case ActionType.edit:
        // Restaurar propiedades anteriores
        final element = action.elements.first;
        _applyProperties(element, action.oldValues);
        break;
    }

    notifyListeners();
  }

  /// Rehace la última acción deshecha
  void redoLastAction() {
    final action = _historyManager.redo();
    if (action == null) return;

    // Aplicar la acción de rehacer según el tipo
    switch (action.type) {
      case ActionType.add:
        // Volver a añadir el elemento
        for (final element in action.elements) {
          addElement(element);
        }
        break;
      case ActionType.remove:
        // Volver a eliminar el elemento
        for (final element in action.elements) {
          removeElement(element);
        }
        break;
      case ActionType.move:
        // Aplicar la nueva posición
        final newPosition = action.newValues['position'] as vector_math.Vector2;
        final element = action.elements.first;
        element.position = newPosition;
        break;
      case ActionType.multiMove:
        // Aplicar múltiples posiciones
        final positions =
            action.newValues['positions'] as Map<String, vector_math.Vector2>;
        for (final element in action.elements) {
          if (positions.containsKey(element.id)) {
            element.position = positions[element.id]!;
          }
        }
        break;
      case ActionType.rotate:
        // Aplicar nueva rotación
        final newRotation = action.newValues['rotation'] as double;
        final element = action.elements.first;
        element.rotation = newRotation;
        break;
      case ActionType.scale:
        // Aplicar nueva escala
        final newScale = action.newValues['scale'] as double;
        final element = action.elements.first;
        element.scale = newScale;
        break;
      case ActionType.edit:
        // Aplicar nuevas propiedades
        final element = action.elements.first;
        _applyProperties(element, action.newValues);
        break;
    }

    notifyListeners();
  }

  /// Reemplaza un elemento existente con una nueva versión
  void updateElement(ParkingElement oldElement, ParkingElement newElement) {
    // Verificar que el elemento existe
    if (!allElements.contains(oldElement)) {
      print("Error: No se puede actualizar un elemento que no existe");
      return;
    }

    // Verificar que los IDs coinciden
    if (oldElement.id != newElement.id) {
      print("Error: Los IDs de los elementos deben coincidir para actualizar");
      return;
    }

    // Guardar el estado de selección
    final wasSelected = oldElement.isSelected;

    // Eliminar el elemento antiguo
    removeElement(oldElement);

    // Añadir el nuevo elemento
    addElement(newElement);

    // Restaurar selección si estaba seleccionado
    if (wasSelected) {
      selectElement(newElement);
    }

    // Notificar cambios
    notifyListeners();

    print("Elemento actualizado con éxito: ${newElement.id}");
  }

  /// Método auxiliar para aplicar propiedades a un elemento
  void _applyProperties(
      ParkingElement element, Map<String, dynamic> properties) {
    // Propiedades comunes
    if (properties.containsKey('position')) {
      element.position = properties['position'] as vector_math.Vector2;
    }
    if (properties.containsKey('rotation')) {
      element.rotation = properties['rotation'] as double;
    }
    if (properties.containsKey('scale')) {
      element.scale = properties['scale'] as double;
    }
    if (properties.containsKey('isVisible')) {
      element.isVisible = properties['isVisible'] as bool;
    }
    if (properties.containsKey('isLocked')) {
      element.isLocked = properties['isLocked'] as bool;
    }

    // Propiedades específicas por tipo
    if (element is ParkingSpot && properties.containsKey('isOccupied')) {
      element.isOccupied = properties['isOccupied'] as bool;
    }
  }
}
