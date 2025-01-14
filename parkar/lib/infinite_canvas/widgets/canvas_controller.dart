// ignore_for_file: prefer_final_fields

import 'package:flutter/material.dart';
import '../models/free_form_object.dart';
import '../models/canvas_object.dart';
import '../models/grid_object.dart';
import '../models/text_object.dart';
import '../models/spot_object.dart';

enum InfiniteCanvasMode { gridObject, text, freeForm }

class InfiniteCanvasController extends ChangeNotifier {
  List<InfiniteCanvasObject> _objects = [];
  List<InfiniteCanvasObject> _selectedObjects = [];
  InfiniteCanvasMode _canvasMode = InfiniteCanvasMode.gridObject;
  double _zoom = 1.0;
  Offset _canvasOffset = Offset.zero;
  List<Offset> _freeFormPoints = [];
  bool _isDrawingFreeForm =
      false; // Indica si se está dibujando una forma libre
  Offset? _dragStart; // Punto de inicio del arrastre
  Offset? _objectDragStart; // Posición inicial del objeto al arrastrar
  double gridSize = 10;
  SpotObjectType spotObjectType = SpotObjectType.car;

  List<InfiniteCanvasObject> get objects => _objects;
  List<InfiniteCanvasObject> get selectedObjects => _selectedObjects;
  InfiniteCanvasMode get canvasMode => _canvasMode;
  double get zoom => _zoom;
  Offset get canvasOffset => _canvasOffset;
  List<Offset> get freeFormPoints => _freeFormPoints;

  InfiniteCanvasController({
    this.gridSize = 10,
  });

  void setCanvasMode(InfiniteCanvasMode mode) {
    _canvasMode = mode;
    if (mode != InfiniteCanvasMode.freeForm) {
      _isDrawingFreeForm = false; // Finalizar el dibujo si se cambia de modo
    }
    notifyListeners();
  }

  void adjustZoom(bool zoomIn) {
    _zoom = (zoomIn ? _zoom * 1.2 : _zoom / 1.2).clamp(0.1, 5.0);
    notifyListeners();
  }

  void onPanStart(DragStartDetails details) {
    if (_canvasMode != InfiniteCanvasMode.freeForm) {
      _dragStart =
          details.localPosition; // Guardar el punto de inicio del arrastre
      if (_selectedObjects.isNotEmpty) {
        _objectDragStart = _selectedObjects
            .first.position; // Guardar la posición inicial del objeto
      }
    }
    notifyListeners();
  }

  void onPanUpdate(DragUpdateDetails details) {
    if (_canvasMode != InfiniteCanvasMode.freeForm) {
      final delta = (details.localPosition - _dragStart!) / _zoom;

      // Ajustar el delta a la cuadrícula
      final gridDelta = Offset(
        (delta.dx / gridSize).round() * gridSize,
        (delta.dy / gridSize).round() * gridSize,
      );

      if (_selectedObjects.isNotEmpty && _objectDragStart != null) {
        // Calcular la nueva posición temporal
        final newPosition = _objectDragStart! + gridDelta;

        // Verificar si la nueva posición colisiona con otros objetos
        bool canMove = true;
        for (var object in _objects) {
          if (object != _selectedObjects.first && _checkCollision(_selectedObjects.first, newPosition, object)) {
            canMove = false;
            break;
          }
        }

        // Mover el objeto solo si no hay colisión
        if (canMove) {
          for (var object in _selectedObjects) {
            object.position = newPosition;
          }
        }
      } else {
        // Mover el lienzo en incrementos de la cuadrícula
        _canvasOffset += gridDelta * _zoom;
        _dragStart = details.localPosition;
      }
    }
    notifyListeners();
  }

  void onPanEnd(DragEndDetails details) {
    if (_canvasMode != InfiniteCanvasMode.freeForm) {
      _dragStart = null; // Reiniciar el punto de inicio del arrastre
      _objectDragStart = null; // Reiniciar la posición inicial del objeto
    }
    notifyListeners();
  }

  void onScaleStart(ScaleStartDetails details) {
    if (_canvasMode != InfiniteCanvasMode.freeForm) {
      _dragStart =
          details.focalPoint; // Guardar el punto de inicio de la escala
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
      _dragStart = null; // Reiniciar el punto de inicio de la escala
    }
    notifyListeners();
  }

  void onTapDown(TapDownDetails details) {
    final canvasPosition = (details.localPosition - _canvasOffset) / _zoom;

    if (_canvasMode == InfiniteCanvasMode.freeForm) {
      if (!_isDrawingFreeForm) {
        // Iniciar una nueva forma libre
        _freeFormPoints.clear();
        _freeFormPoints.add(canvasPosition); // Agregar el primer punto
        _isDrawingFreeForm = true;
      } else {
        // Agregar un nuevo punto y unirlo al último punto
        final nearestPoint = _findNearestPoint(canvasPosition);
        if (nearestPoint != null) {
          // Unirse al punto más cercano si está dentro del rango
          _freeFormPoints.add(nearestPoint);
        } else {
          // Agregar el nuevo punto
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
      // Finalizar la forma libre al hacer doble clic
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
    const double snapDistance = 10.0; // Distancia máxima para unirse a un punto
    for (var object in _objects) {
      if (object is FreeFormObject) {
        for (var p in object.points) {
          if ((p - point).distance <= snapDistance) {
            return p; // Retornar el punto más cercano
          }
        }
      }
    }
    return null; // No hay puntos cercanos
  }

  void selectObject(Offset position) {
    _selectedObjects.clear();
    for (var object in _objects.reversed) {
      if (object.contains(position, Offset.zero, 1.0, gridSize)) {
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
        object1.width * gridSize,
        object1.height * gridSize,
      );
      final rect2 = Rect.fromLTWH(
        object2.position.dx,
        object2.position.dy,
        object2.width * gridSize,
        object2.height * gridSize,
      );
      return rect1.overlaps(rect2);
    }
    return false;
  }

  void addGridObjectNode(GridObject object) {
    Offset offset = Offset.zero;
    bool positionFound = false;

    while (!positionFound) {
      positionFound = true;
      for (var existingObject in _objects) {
        if (existingObject is GridObject && _checkCollision(object, offset, existingObject)) {
          positionFound = false;
          offset = Offset(offset.dx + object.width * gridSize, offset.dy);
          break;
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
  void setGridSize(double newGridSize) {
    gridSize = newGridSize;
    notifyListeners();
  }
}
