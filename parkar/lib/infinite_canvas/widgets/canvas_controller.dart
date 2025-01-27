import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:parkar/infinite_canvas/models/signage_object.dart';

import '../models/canvas_object.dart';
import '../models/grid_object.dart';
import '../models/spot_object.dart';

enum ChangeType { delete, add, update }

class ChangedObject {
  final InfiniteCanvasObject object;
  final ChangeType type;
  ChangedObject({required this.object, required this.type});
}

enum DrawingMode { gridObject, text }

class InfiniteCanvasController extends ChangeNotifier {
  final List<InfiniteCanvasObject> _objects = [];
  final List<InfiniteCanvasObject> _selectedObjects = [];
  final List<ChangedObject> _changedObjects = [];
  final ValueNotifier<int> objectCountNotifier = ValueNotifier(0);
  final ValueNotifier<int> changesCountNotifier = ValueNotifier(0);
  final ValueNotifier<bool> _isAnimating = ValueNotifier(false); // Control de animación

  ValueNotifier<bool> get isAnimating => _isAnimating;
  DrawingMode _canvasMode = DrawingMode.gridObject;
  double _zoom = 1.0;
  Offset _canvasOffset = Offset.zero;
  Offset? _dragStart;
  Offset? _objectDragStart;
  double _gridSize = 15.0;
  bool _showGrid = false;
  bool _editMode = false;
  Size viewportSize = Size.zero;

  // Callbacks
  Function(ChangedObject)? onChanged;
  Function(InfiniteCanvasObject)? onSelect;
  Function(String message)? onShowMessage; // Para mostrar mensajes (SnackBar)

  // Objeto copiado
  InfiniteCanvasObject? _copiedObject;

  List<InfiniteCanvasObject> get objects => _objects;
  List<InfiniteCanvasObject> get selectedObjects => _selectedObjects;
  List<ChangedObject> get changedObjects => _changedObjects;
  DrawingMode get canvasMode => _canvasMode;
  double get zoom => _zoom;
  Offset get canvasOffset => _canvasOffset;
  double get gridSize => _gridSize;
  bool get showGrid => _showGrid;
  bool get editMode => _editMode;

  void clear() {
    _objects.clear();
    _selectedObjects.clear();
    _changedObjects.clear();
    _canvasOffset = Offset.zero;
    _zoom = 1.0;
    notifyListeners();
  }

  // Método para agregar/actualizar objetos modificados
  void _addToChangedObjects({required InfiniteCanvasObject object, ChangeType type = ChangeType.add}) {
    if (!editMode) return;
    final changedObject = ChangedObject(object: object, type: type);
    final index = _changedObjects.indexWhere((o) => o.object.id == object.id);
    if (index != -1) {
      _changedObjects[index] = changedObject; // Reemplaza si ya existe
    } else {
      _changedObjects.add(changedObject); // Agrega si es nuevo
    }
    changesCountNotifier.value = _changedObjects.length;
    onChanged?.call(changedObject);
  }

  // Método para manejar atajos de teclado
  void handleKeyEvent(RawKeyEvent event) {
    if (event.isControlPressed) {
      if (event.logicalKey == LogicalKeyboardKey.keyC) {
        _copySelectedObjects();
      } else if (event.logicalKey == LogicalKeyboardKey.keyV) {
        _pasteObject();
      }
    } else if (event.logicalKey == LogicalKeyboardKey.delete) {
      deleteSelectedObjects();
    }
  }

  // Copiar objetos seleccionados
  void _copySelectedObjects() {
    if (_selectedObjects.isNotEmpty) {
      _copiedObject = _selectedObjects.first;
      onShowMessage?.call('Objeto copiado'); // Notificar al padre
    }
  }

  // Pegar objeto copiado
  void _pasteObject() {
    if (_copiedObject != null) {
      // Crear una copia del objeto con un nuevo ID
      // final newObject = _copiedObject!.copyWith(
      //   id: const Uuid().v4(), // Nuevo ID único
      //   position: _copiedObject!.position + const Offset(20, 20), // Desplazamiento
      // );

      // // Agregar el nuevo objeto al lienzo
      // _objects.add(newObject);
      // _selectedObjects.clear();
      // _selectedObjects.add(newObject);
      // _addToChangedObjects(newObject);
      // notifyListeners();
    }
  }

  void setShowGrid(bool showGrid) {
    _showGrid = showGrid;
    notifyListeners();
  }

  void setCanvasMode(DrawingMode mode) {
    _canvasMode = mode;
    notifyListeners();
  }

  void setGridSize(double gridSize) {
    _gridSize = gridSize;
    notifyListeners();
  }

  void adjustZoom(bool zoomIn) {
    _zoom = (zoomIn ? _zoom * 1.2 : _zoom / 1.2).clamp(0.1, 5.0);
    notifyListeners();
  }

  void onPanStart(DragStartDetails details) {
    _dragStart = details.localPosition;
    if (_selectedObjects.isNotEmpty) {
      _objectDragStart = _selectedObjects.first.position;
    }
    notifyListeners();
  }

  void onPanUpdate(DragUpdateDetails details) {
    final delta = (details.localPosition - _dragStart!) / _zoom;
    if ( _editMode && _selectedObjects.isNotEmpty && _objectDragStart != null) {
      final newPosition = _objectDragStart! + delta;
      bool canMove = true;
      for (var object in _objects) {
        if (object != _selectedObjects.first &&
            _checkCollision(_selectedObjects.first, newPosition, object)) {
          canMove = false;
          break;
        }
      }
      if (canMove) {
        for (var object in _selectedObjects) {
          object.position = newPosition;
          _addToChangedObjects(object: object, type: ChangeType.update);
        }
      }
    } else {
      _canvasOffset += delta;
      _dragStart = details.localPosition;
    }
    notifyListeners();
  }

  void onPanEnd(DragEndDetails details) {
    _dragStart = null;
    _objectDragStart = null;
    notifyListeners();
  }

  void onScaleStart(ScaleStartDetails details) {
    _dragStart = details.focalPoint;
  }

  void onScaleUpdate(ScaleUpdateDetails details) {
    if (details.scale != 1.0) {
      final oldZoom = _zoom;
      _zoom *= details.scale;
      _zoom = _zoom.clamp(0.1, 5.0);

      final focalPoint = details.focalPoint;
      final zoomFactor = _zoom / oldZoom;
      _canvasOffset = focalPoint - (focalPoint - _canvasOffset) * zoomFactor;
    } else {
      _canvasOffset += details.focalPoint - _dragStart!;
      _dragStart = details.focalPoint;
    }
    notifyListeners();
  }

  void onScaleEnd(ScaleEndDetails details) {
    _dragStart = null;
    notifyListeners();
  }

  void onTapDown(TapDownDetails details) {
    final canvasPosition = (details.localPosition - _canvasOffset) / _zoom;
    if (_canvasMode == DrawingMode.gridObject) {
      selectObject(canvasPosition);
    }
    notifyListeners();
  }

  void selectObject(Offset position) {
    _selectedObjects.clear();
    for (var object in _objects.reversed) {
      if (object.contains(
        position,
        Offset.zero,
        _gridSize,
        1.0,
      )) {
        _selectedObjects.add(object);
        onSelect?.call(object);
        break;
      }
    }
    notifyListeners();
  }

  bool _checkCollision(InfiniteCanvasObject object1, Offset newPosition,
      InfiniteCanvasObject object2) {
    if (object1 is GridObject && object2 is GridObject) {
      final rect1 = Rect.fromLTWH(
        newPosition.dx,
        newPosition.dy,
        object1.size.width * _gridSize,
        object1.size.height * _gridSize,
      );
      final rect2 = Rect.fromLTWH(
        object2.position.dx,
        object2.position.dy,
        object2.size.width * _gridSize,
        object2.size.height * _gridSize,
      );
      return rect1.overlaps(rect2);
    }
    return false;
  }

  Offset getCenterOfView(Size viewportSize) {
    return Offset(
      (viewportSize.width / 2 - _canvasOffset.dx) / _zoom,
      (viewportSize.height / 2 - _canvasOffset.dy) / _zoom,
    );
  }

  void addGridObjectNode(GridObject object) {
    // check if pbjet with same id already exists
    if (_objects.any((element) => element.id == object.id)) {
      return;
    }

    // add auto label if empty
    if (object is SpotObject && object.label.isEmpty) {
      object.label = 'Lugar ${_objects.length + 1}';
    }

    Offset offset = getCenterOfView(viewportSize);
    bool positionFound = false;

    // Ajustar el offset para que el objeto esté centrado en la vista
    offset -= Offset(
        object.size.width * _gridSize / 2, object.size.height * _gridSize / 2);

    // Verificar si hay colisión en el centro de la vista
    positionFound = true;
    for (var existingObject in _objects) {
      if (existingObject is GridObject &&
          _checkCollision(object, offset, existingObject)) {
        positionFound = false;
        break;
      }
    }

    // Si no hay espacio en el centro de la vista, buscar espacio a la derecha e inferior
    if (!positionFound) {
      offset = Offset(offset.dx + object.size.width * _gridSize,
          offset.dy + object.size.height * _gridSize);
      while (!positionFound) {
        positionFound = true;
        for (var existingObject in _objects) {
          if (existingObject is GridObject &&
              _checkCollision(object, offset, existingObject)) {
            positionFound = false;
            offset =
                Offset(offset.dx + object.size.width * _gridSize, offset.dy);
            break;
          }
        }
      }
    }

    object.position = offset;
    _selectedObjects.clear();
    _selectedObjects.add(object);
    _objects.add(object);
    _addToChangedObjects(object:object, type: ChangeType.add);
    _isAnimating.value = true;
      Future.delayed(const Duration(milliseconds: 150), () {
      _isAnimating.value = false; // Finalizar animación después de 300ms
    });
    
    notifyListeners();
  }

  void deleteSelectedObjects() {
    final objects = _selectedObjects.toList();
    for (var object in objects) {
      _objects.removeWhere((o) => o.id == object.id);
      _addToChangedObjects(object: object, type: ChangeType.delete);
    }
    _selectedObjects.clear();
    notifyListeners();
  }

  void rotateSelectedObjects(double angle) {
    for (var object in _selectedObjects) {
      object.rotate(angle);
      _addToChangedObjects(object: object, type: ChangeType.update);
    }
    notifyListeners();
  }

  void toggleSignageDirection() {
    if (_selectedObjects.firstOrNull is SignageObject) {
      final object = _selectedObjects.first as SignageObject;
      object.toggleDirection();
      _addToChangedObjects(object: object, type: ChangeType.update);
      notifyListeners();
    }
  }

  void toggleSpotStatus() {
    if (_selectedObjects.firstOrNull is SpotObject) {
      final object = _selectedObjects.first as SpotObject;
      object.toggleStatus();
      _addToChangedObjects(object: object, type: ChangeType.update);
      notifyListeners();
    }
  }

  void updateSpotLabel(String label) {
    if (_selectedObjects.firstOrNull is SpotObject) {
      final object = _selectedObjects.first as SpotObject;
      object.label = label;
      _addToChangedObjects(object: object, type: ChangeType.update);
      notifyListeners();
    }
  }


  void centerCanvas() {
    _canvasOffset = Offset.zero;
    notifyListeners();
  }

  void resetZoom() {
    _zoom = 1.0;
    notifyListeners();
  }

  void copySelectedObjects() {
    // Implementar lógica para copiar objetos
    notifyListeners();
  }

  void pasteObjects() {
    // Implementar lógica para pegar objetos
    notifyListeners();
  }

  void updateCanvasOffset(double dx, double dy) {
    _canvasOffset = Offset(dx, dy);
    notifyListeners();
  }

  void updateViewportSize(Size newSize) {
    viewportSize = newSize;
    notifyListeners();
  }

  void setEditMode(bool isEditMode) {
    _editMode = isEditMode;
    notifyListeners();
  }
}
