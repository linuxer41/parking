import 'package:flutter/material.dart';
import '../models/free_form_object.dart';
import '../models/canvas_object.dart';
import '../models/grid_object.dart';
import '../models/text_object.dart';
import '../models/spot_object.dart';

enum InfiniteCanvasMode { gridObject, text, freeForm }

class InfiniteCanvasController extends ChangeNotifier {
  final List<InfiniteCanvasObject> _objects = [];
  final List<InfiniteCanvasObject> _selectedObjects = [];
  InfiniteCanvasMode _canvasMode = InfiniteCanvasMode.gridObject;
  double _zoom = 1.0;
  Offset _canvasOffset = Offset.zero;
  final List<Offset> _freeFormPoints = [];
  bool _isDrawingFreeForm = false;
  Offset? _dragStart;
  Offset? _objectDragStart;
  double _gridSize = 50.0; // Tamaño de la cuadrícula en píxeles

  List<InfiniteCanvasObject> get objects => _objects;
  List<InfiniteCanvasObject> get selectedObjects => _selectedObjects;
  InfiniteCanvasMode get canvasMode => _canvasMode;
  double get zoom => _zoom;
  Offset get canvasOffset => _canvasOffset;
  List<Offset> get freeFormPoints => _freeFormPoints;
  double get gridSize => _gridSize;
  Size viewportSize = Size.zero;

  void setCanvasMode(InfiniteCanvasMode mode) {
    _canvasMode = mode;
    if (mode != InfiniteCanvasMode.freeForm) {
      _isDrawingFreeForm = false;
    }
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
    if (_canvasMode != InfiniteCanvasMode.freeForm) {
      _dragStart = details.localPosition;
      if (_selectedObjects.isNotEmpty) {
        _objectDragStart = _selectedObjects.first.position;
      }
    }
    notifyListeners();
  }

  void onPanUpdate(DragUpdateDetails details) {
    if (_canvasMode != InfiniteCanvasMode.freeForm) {
      final delta = (details.localPosition - _dragStart!) / _zoom;

      if (_selectedObjects.isNotEmpty && _objectDragStart != null) {
        final newPosition = _objectDragStart! + delta;
        bool canMove = true;
        for (var object in _objects) {
          if (object != _selectedObjects.first && _checkCollision(_selectedObjects.first, newPosition, object)) {
            canMove = false;
            break;
          }
        }
        if (canMove) {
          for (var object in _selectedObjects) {
            object.position = newPosition;
          }
        }
      } else {
        _canvasOffset += delta;
        _dragStart = details.localPosition;
      }
    }
    notifyListeners();
  }

  void onPanEnd(DragEndDetails details) {
    if (_canvasMode != InfiniteCanvasMode.freeForm) {
      _dragStart = null;
      _objectDragStart = null;
    }
    notifyListeners();
  }

  void onScaleStart(ScaleStartDetails details) {
    if (_canvasMode != InfiniteCanvasMode.freeForm) {
      _dragStart = details.focalPoint;
    }
  }

  void onScaleUpdate(ScaleUpdateDetails details) {
    if (_canvasMode != InfiniteCanvasMode.freeForm) {
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
    }
    notifyListeners();
  }

  void onScaleEnd(ScaleEndDetails details) {
    if (_canvasMode != InfiniteCanvasMode.freeForm) {
      _dragStart = null;
    }
    notifyListeners();
  }

  void onTapDown(TapDownDetails details) {
    final canvasPosition = (details.localPosition - _canvasOffset) / _zoom;

    if (_canvasMode == InfiniteCanvasMode.freeForm) {
      if (!_isDrawingFreeForm) {
        _freeFormPoints.clear();
        _freeFormPoints.add(canvasPosition);
        _isDrawingFreeForm = true;
      } else {
        final nearestPoint = _findNearestPoint(canvasPosition);
        if (nearestPoint != null) {
          _freeFormPoints.add(nearestPoint);
        } else {
          _freeFormPoints.add(canvasPosition);
        }
      }
    } else if (_canvasMode == InfiniteCanvasMode.gridObject) {
      selectObject(canvasPosition);
    }
    notifyListeners();
  }

  void onDoubleTap() {
    if (_canvasMode == InfiniteCanvasMode.freeForm && _isDrawingFreeForm) {
      _finishFreeFormDrawing();
    }
  }

  void _finishFreeFormDrawing() {
    if (_freeFormPoints.length >= 2) {
      _objects.add(FreeFormObject(
        position: Offset.zero,
        color: Colors.purple,
        points: List.from(_freeFormPoints),
      ));
      _freeFormPoints.clear();
      _isDrawingFreeForm = false;
      notifyListeners();
    }
  }

  Offset? _findNearestPoint(Offset point) {
    const double snapDistance = 10.0;
    for (var object in _objects) {
      if (object is FreeFormObject) {
        for (var p in object.points) {
          if ((p - point).distance <= snapDistance) {
            return p;
          }
        }
      }
    }
    return null;
  }

  void selectObject(Offset position) {
    _selectedObjects.clear();
    for (var object in _objects.reversed) {
      if (object.contains(position, Offset.zero, 1.0, _gridSize)) {
        _selectedObjects.add(object);
        break;
      }
    }
    notifyListeners();
  }

  bool _checkCollision(InfiniteCanvasObject object1, Offset newPosition, InfiniteCanvasObject object2) {
    if (object1 is GridObject && object2 is GridObject) {
      final rect1 = Rect.fromLTWH(
        newPosition.dx,
        newPosition.dy,
        object1.width * _gridSize,
        object1.height * _gridSize,
      );
      final rect2 = Rect.fromLTWH(
        object2.position.dx,
        object2.position.dy,
        object2.width * _gridSize,
        object2.height * _gridSize,
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
    Offset offset = getCenterOfView(viewportSize);
    bool positionFound = false;

    // Ajustar el offset para que el objeto esté centrado en la vista
    offset -= Offset(object.width * _gridSize / 2, object.height * _gridSize / 2);

    // Verificar si hay colisión en el centro de la vista
    positionFound = true;
    for (var existingObject in _objects) {
      if (existingObject is GridObject && _checkCollision(object, offset, existingObject)) {
        positionFound = false;
        break;
      }
    }

    // Si no hay espacio en el centro de la vista, buscar espacio a la derecha e inferior
    if (!positionFound) {
      offset = Offset(offset.dx + object.width * _gridSize, offset.dy + object.height * _gridSize);
      while (!positionFound) {
        positionFound = true;
        for (var existingObject in _objects) {
          if (existingObject is GridObject && _checkCollision(object, offset, existingObject)) {
            positionFound = false;
            offset = Offset(offset.dx + object.width * _gridSize, offset.dy);
            break;
          }
        }
      }
    }

    object.position = offset;
    _selectedObjects.add(object);
    _objects.add(object);
    _selectedObjects.clear();
    notifyListeners();
  }

  void addText(Offset position, String text) {
    final textObject = TextObject(
      position: position,
      text: text,
      color: Colors.black,
    );
    _objects.add(textObject);
    _selectedObjects.clear();
    _selectedObjects.add(textObject);
    notifyListeners();
  }

  void deleteSelectedObjects() {
    _objects.removeWhere((object) => _selectedObjects.contains(object));
    _selectedObjects.clear();
    notifyListeners();
  }

  void rotateSelectedObjects() {
    for (var object in _selectedObjects) {
      object.rotation += 15.0;
    }
    notifyListeners();
  }

  void toggleSelectedObjectStatus() {
    if (_selectedObjects.isNotEmpty && _selectedObjects.first is SpotObject) {
      final selectedVehicle = _selectedObjects.first as SpotObject;
      selectedVehicle.isFree = !selectedVehicle.isFree;
      notifyListeners();
    }
  }

  void editSelectedText() {
    if (_selectedObjects.isNotEmpty && _selectedObjects.first is TextObject) {
      final selectedTextObject = _selectedObjects.first as TextObject;
      // Implementar lógica para editar texto
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
}