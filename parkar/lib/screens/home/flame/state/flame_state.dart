import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'; // Importamos para Rect y Offset
import 'package:vector_math/vector_math.dart' as vector_math;
import 'package:uuid/uuid.dart';

import '../models/flame_element.dart';
import '../models/parking_spot.dart';
import '../models/parking_signage.dart';
import '../models/parking_facility.dart';

/// Clase que maneja el estado global del editor del mundo con Flame
class FlameState extends ChangeNotifier {
  // Listas de elementos
  final List<FlameSpot> _spots = [];
  final List<FlameSignage> _signages = [];
  final List<FlameFacility> _facilities = [];

  // Elementos seleccionados
  final List<FlameElement> _selectedElements = [];

  // Elemento copiado en el portapapeles
  final List<FlameElement> _clipboardElements = [];

  // Posición de la cámara
  vector_math.Vector2 _cameraPosition = vector_math.Vector2(0, 0);

  // Nivel de zoom
  double _zoom = 1.0;

  // Modo de edición
  bool _isEditMode = true;

  // Nivel actual
  int _currentLevel = 0;

  // Constructor
  FlameState();

  // Getters
  List<FlameSpot> get spots => _spots;
  List<FlameSignage> get signages => _signages;
  List<FlameFacility> get facilities => _facilities;
  List<FlameElement> get selectedElements => _selectedElements;
  List<FlameElement> get clipboardElements => _clipboardElements;
  vector_math.Vector2 get cameraPosition => _cameraPosition;
  double get zoom => _zoom;
  bool get isEditMode => _isEditMode;
  int get currentLevel => _currentLevel;
  
  /// Obtener el primer elemento seleccionado (si existe)
  FlameElement? get firstSelectedElement => 
      _selectedElements.isNotEmpty ? _selectedElements.first : null;

  /// Lista de todos los elementos
  List<FlameElement> get allElements {
    final List<FlameElement> elements = [];
    elements.addAll(_spots);
    elements.addAll(_signages);
    elements.addAll(_facilities);
    return elements;
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
    _cameraPosition += delta;
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
  void addSpot(FlameSpot spot) {
    _spots.add(spot);
    // Seleccionar el nuevo elemento
    _selectedElements.clear();
    _selectedElements.add(spot);
    notifyListeners();
  }

  /// Método para añadir una señalización
  void addSignage(FlameSignage signage) {
    _signages.add(signage);
    // Seleccionar el nuevo elemento
    _selectedElements.clear();
    _selectedElements.add(signage);
    notifyListeners();
  }

  /// Método para añadir una instalación
  void addFacility(FlameFacility facility) {
    _facilities.add(facility);
    // Seleccionar el nuevo elemento
    _selectedElements.clear();
    _selectedElements.add(facility);
    notifyListeners();
  }

  /// Método para eliminar elementos seleccionados
  void deleteSelectedElements() {
    if (_selectedElements.isEmpty) return;

    // Crear una copia de la lista para evitar modificarla durante la iteración
    final elementsToDelete = List<FlameElement>.from(_selectedElements);
    
    for (final element in elementsToDelete) {
      if (element is FlameSpot) {
        _spots.remove(element);
      } else if (element is FlameSignage) {
        _signages.remove(element);
      } else if (element is FlameFacility) {
        _facilities.remove(element);
      }
    }
    
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
        
        // Añadir el elemento según su tipo
        if (copy is FlameSpot) {
          _spots.add(copy);
        } else if (copy is FlameSignage) {
          _signages.add(copy);
        } else if (copy is FlameFacility) {
          _facilities.add(copy);
        }
        
        // Seleccionar el elemento pegado
        _selectedElements.add(copy);
      }
    }
    
    notifyListeners();
  }
  
  /// Método para crear una copia profunda de un elemento
  FlameElement? _createDeepCopy(FlameElement element) {
    // Generar un nuevo ID único
    final String newId = const Uuid().v4();
    
    // Usar el método clone() del elemento y actualizar su ID
    final FlameElement copy = element.clone();
    
    // Como no podemos modificar el ID directamente (es final),
    // creamos una nueva instancia con el nuevo ID según el tipo
    if (element is FlameSpot) {
      return FlameSpot(
        id: newId,
        position: vector_math.Vector2(copy.position.x, copy.position.y),
        size: copy.size.clone(),
        spotType: element.spotType,
        rotation: copy.angle,
        label: copy.label,
        isOccupied: element.isOccupied,
        vehiclePlate: element.vehiclePlate,
      );
    } else if (element is FlameSignage) {
      return FlameSignage(
        id: newId,
        position: vector_math.Vector2(copy.position.x, copy.position.y),
        size: copy.size.clone(),
        signageType: element.signageType,
        rotation: copy.angle,
        label: copy.label,
        direction: element.direction,
      );
    } else if (element is FlameFacility) {
      return FlameFacility(
        id: newId,
        position: vector_math.Vector2(copy.position.x, copy.position.y),
        size: copy.size.clone(),
        facilityType: element.facilityType,
        rotation: copy.angle,
        label: copy.label,
      );
    }
    
    return null;
  }

  /// Método para seleccionar un elemento
  void selectElement(FlameElement element, {bool isShiftPressed = false, bool isControlPressed = false}) {
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
    final List<FlameElement> elementsInRect = [];

    // Encontrar elementos dentro del rectángulo
    for (final element in allElements) {
      // Convertir posición a Offset para facilitar la comparación
      final elementOffset = Offset(element.position.x, element.position.y);
      if (rect.contains(elementOffset)) {
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

  /// Método para mover los elementos seleccionados
  void moveSelectedElements(vector_math.Vector2 delta) {
    if (_selectedElements.isEmpty) return;

    // Mover todos los elementos seleccionados
    for (final element in _selectedElements) {
      element.position.x += delta.x;
      element.position.y += delta.y;
    }

    notifyListeners();
  }

  /// Método para rotar los elementos seleccionados
  void rotateSelectedElements(double deltaRotation) {
    if (_selectedElements.isEmpty) return;

    // Rotar todos los elementos seleccionados
    for (final element in _selectedElements) {
      element.angle += deltaRotation;
    }

    notifyListeners();
  }
} 