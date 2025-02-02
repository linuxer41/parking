import 'dart:async';
import 'dart:math';

import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

// Clase principal del juego modificada
class ParkingGame extends FlameGame {
  late final ParkingWorld _world;
  late final ParkingCamera _camera;
  final double _cameraSpeed = 10.0;
  final double _zoomSpeed = 0.2;

  @override
  Future<void> onLoad() async {
    _world = ParkingWorld();
    _camera = ParkingCamera(_world);
    print("camera position: ${_camera.viewfinder.position}");
    add(_camera);
    add(_world);

    // Configurar overlays para los controles
    overlays.addAll(['controls']);
    _camera.viewfinder.position = size / 2;
  }

  // @override
  // void onGameResize(Vector2 size) {
  //   super.onGameResize(size);
  //   // Centrar la cámara al tamaño inicial del juego
  //   if (_camera.isMounted) {
  //     _camera.viewfinder.position = size / 2;
  //   }
  // }

  // Métodos para controlar la cámara
  void moveCamera(Vector2 direction) {
    _camera.viewfinder.position += direction * _cameraSpeed;
    print("moveCamera ${_camera.viewfinder.position}");
  }

  void zoomCamera(double delta) {
    _camera.viewfinder.zoom = (_camera.viewfinder.zoom + delta * _zoomSpeed)
        .clamp(0.5, 3.0); // Límites de zoom
    print("zoomCamera ${_camera.viewfinder.zoom}");
  }

  // Widget de controles overlay
  static Widget cameraControls(BuildContext context, ParkingGame game) {
    return Positioned(
      right: 20,
      bottom: 20,
      child: Column(
        children: [
          // Controles de zoom
          _ControlButton(
            icon: Icons.add,
            onPressed: () => game.zoomCamera(1),
          ),
          const SizedBox(height: 10),
          _ControlButton(
            icon: Icons.remove,
            onPressed: () => game.zoomCamera(-1),
          ),
          const SizedBox(height: 20),
          // Controles de movimiento
          _ControlButton(
            icon: Icons.arrow_upward,
            onPressed: () => game.moveCamera(Vector2(0, -1)),
          ),
          Row(
            children: [
              _ControlButton(
                icon: Icons.arrow_back,
                onPressed: () => game.moveCamera(Vector2(-1, 0)),
              ),
              const SizedBox(width: 48),
              _ControlButton(
                icon: Icons.arrow_forward,
                onPressed: () => game.moveCamera(Vector2(1, 0)),
              ),
            ],
          ),
          _ControlButton(
            icon: Icons.arrow_downward,
            onPressed: () => game.moveCamera(Vector2(0, 1)),
          ),
        ],
      ),
    );
  }
}

// Botón personalizado para los controles
class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _ControlButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      shape: const CircleBorder(),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }
}

// Modificación de la clase ParkingCamera
class ParkingCamera extends CameraComponent {
  ParkingCamera(World world)
      : super(
          world: world,
        ) {
    viewfinder.anchor = Anchor.center;
    viewfinder.zoom = 1.0;
  }
}

// Modificación de la clase ParkingWorld
class ParkingWorld extends World {
  @override
  Future<void> onLoad() async {
    addAll([
      DragTarget(),
      Spot(
        width: 60,
        height: 120,
        color: const Color(0xff4CAF50),
        position: Vector2(200, 200),
      ),
      Facilities(
        width: 60,
        height: 60,
        color: const Color(0xffFFC107),
        position: Vector2(300, 100),
      ),
      Signage(
        width: 90,
        height: 30,
        color: const Color(0xffF44336),
        position: Vector2(400, 200),
      ),
    ]);
  }
}

/// Componente de objetivo de arrastre
class DragTarget extends PositionComponent with DragCallbacks, HasWorldReference<ParkingWorld> {
  DragTarget() : super(anchor: Anchor.center);

  final _gridPaint = Paint()
    ..color = const Color.fromARGB(125, 41, 41, 41)
    ..strokeWidth = 0.25;
  final Map<int, Trail> _trails = {};

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    final camera = game.camera.viewfinder;
    final cameraPos = camera.position;
    final cameraZoom = camera.zoom;
    final gameSize = game.size;

    // Calcular área visible de la cámara en coordenadas del mundo
    final visibleAreaTopLeft = cameraPos - (gameSize / 2) / cameraZoom;
    final visibleAreaBottomRight = cameraPos + (gameSize / 2) / cameraZoom;

    const step = 15.0; // Tamaño base de la grilla
    final adjustedStep = step / cameraZoom;

    // Calcular rangos de líneas a dibujar
    final startX = (visibleAreaTopLeft.x ~/ adjustedStep) * adjustedStep - adjustedStep;
    final endX = visibleAreaBottomRight.x + adjustedStep;
    final startY = (visibleAreaTopLeft.y ~/ adjustedStep) * adjustedStep - adjustedStep;
    final endY = visibleAreaBottomRight.y + adjustedStep;

    // Dibujar líneas verticales
    for (double x = startX; x <= endX; x += adjustedStep) {
      final lineX = (x - cameraPos.x) * cameraZoom + gameSize.x / 2;
      canvas.drawLine(
        Offset(lineX, 0),
        Offset(lineX, gameSize.y),
        _gridPaint,
      );
    }

    // Dibujar líneas horizontales
    for (double y = startY; y <= endY; y += adjustedStep) {
      final lineY = (y - cameraPos.y) * cameraZoom + gameSize.y / 2;
      canvas.drawLine(
        Offset(0, lineY),
        Offset(gameSize.x, lineY),
        _gridPaint,
      );
    }
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    final trail = Trail(event.localPosition);
    _trails[event.pointerId] = trail;
    add(trail);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    _trails[event.pointerId]!.addPoint(event.localEndPosition);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    _trails.remove(event.pointerId)!.end();
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event);
    _trails.remove(event.pointerId)!.cancel();
  }
}

/// Componente de rastro (trail)
class Trail extends Component {
  Trail(Vector2 origin)
      : _paths = [Path()..moveTo(origin.x, origin.y)],
        _opacities = [1],
        _lastPoint = origin.clone(),
        _color =
            HSLColor.fromAHSL(1, random.nextDouble() * 360, 1, 0.8).toColor();

  final List<Path> _paths;
  final List<double> _opacities;
  Color _color;
  late final _linePaint = Paint()..style = PaintingStyle.stroke;
  late final _circlePaint = Paint()..color = _color;
  bool _released = false;
  double _timer = 0;
  final _vanishInterval = 0.03;
  final Vector2 _lastPoint;

  static final random = Random();
  static const lineWidth = 10.0;

  @override
  void render(Canvas canvas) {
    assert(_paths.length == _opacities.length);
    for (var i = 0; i < _paths.length; i++) {
      final path = _paths[i];
      final opacity = _opacities[i];
      if (opacity > 0) {
        _linePaint.color = _color.withValues(alpha: opacity);
        _linePaint.strokeWidth = lineWidth * opacity;
        canvas.drawPath(path, _linePaint);
      }
    }
    canvas.drawCircle(
      _lastPoint.toOffset(),
      (lineWidth - 2) * _opacities.last + 2,
      _circlePaint,
    );
  }

  @override
  void update(double dt) {
    assert(_paths.length == _opacities.length);
    _timer += dt;
    while (_timer > _vanishInterval) {
      _timer -= _vanishInterval;
      for (var i = 0; i < _paths.length; i++) {
        _opacities[i] -= 0.01;
        if (_opacities[i] <= 0) {
          _paths[i].reset();
        }
      }
      if (!_released) {
        _paths.add(Path()..moveTo(_lastPoint.x, _lastPoint.y));
        _opacities.add(1);
      }
    }
    if (_opacities.last < 0) {
      removeFromParent();
    }
  }

  void addPoint(Vector2 point) {
    if (!point.x.isNaN) {
      for (final path in _paths) {
        path.lineTo(point.x, point.y);
      }
      _lastPoint.setFrom(point);
    }
  }

  void end() => _released = true;

  void cancel() {
    _released = true;
    _color = const Color(0xFFFFFFFF);
  }
}

/// Componente Spot (punto)
class Spot extends PositionComponent
    with DragCallbacks, TapCallbacks, HoverCallbacks {
  Spot({
    required double width,
    required double height,
    required this.color,
    super.position,
  }) {
    _path = Path()
      ..addRRect(RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: width, height: height),
          const Radius.circular(10)));
  }

  final Color color;
  final Paint _paint = Paint();
  final Paint _borderPaint = Paint()
    ..color = const Color(0xFFffffff)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3;
  late final Path _path;

  @override
  void onLongTapDown(TapDownEvent event) {
    print("LongTapDown at ${event.localPosition}");
    super.onLongTapDown(event);
  }

  @override
  bool containsLocalPoint(Vector2 point) {
    return _path.contains(point.toOffset());
  }

  @override
  void render(Canvas canvas) {
    if (isDragged) {
      _paint.color = color.withValues(alpha: 0.5);
      canvas.drawPath(_path, _paint);
      canvas.drawPath(_path, _borderPaint);
    } else if (isHovered) {
      _paint.color = color.withValues(alpha: 0.25);
      canvas.drawPath(_path, _paint);
      canvas.drawPath(_path, _borderPaint);
    } else {
      _paint.color = color.withValues(alpha: 1);
      canvas.drawPath(_path, _paint);
    }
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    priority = 10;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    priority = 0;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    position += event.localDelta;
  }
}

/// Componente Facilities (instalaciones)
class Facilities extends PositionComponent
    with DragCallbacks, TapCallbacks, HoverCallbacks {
  Facilities({
    required double width,
    required double height,
    required this.color,
    super.position,
  }) {
    _path = Path()
      ..addRRect(RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: width, height: height),
          const Radius.circular(10)));
  }

  final Color color;
  final Paint _paint = Paint();
  final Paint _borderPaint = Paint()
    ..color = const Color(0xFFffffff)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3;
  late final Path _path;

  @override
  void onLongTapDown(TapDownEvent event) {
    print("LongTapDown at ${event.localPosition}");
    super.onLongTapDown(event);
  }

  @override
  bool containsLocalPoint(Vector2 point) {
    return _path.contains(point.toOffset());
  }

  @override
  void render(Canvas canvas) {
    if (isDragged) {
      _paint.color = color.withValues(alpha: 0.5);
      canvas.drawPath(_path, _paint);
      canvas.drawPath(_path, _borderPaint);
    } else {
      _paint.color = color.withValues(alpha: 1);
      canvas.drawPath(_path, _paint);
    }
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    priority = 10;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    priority = 0;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    position += event.localDelta;
  }
}

/// Componente Signage (letrero)
class Signage extends PositionComponent
    with DragCallbacks, TapCallbacks, HoverCallbacks {
  Signage({
    required double width,
    required double height,
    required this.color,
    super.position,
  }) {
    _path = Path()
      ..addRRect(RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: width, height: height),
          const Radius.circular(10)));
  }

  final Color color;
  final Paint _paint = Paint();
  final Paint _borderPaint = Paint()
    ..color = const Color(0xFFffffff)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3;
  late final Path _path;

  @override
  Future<void> onLoad() async {
    add(TextComponent(
      text: 'Señalización',
      position: Vector2(0, height / 2),
      angle: 25,
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    ));
  }

  @override
  void onTapDown(TapDownEvent details) {
    print("TapDown at ${details.localPosition}");
  }

  @override
  bool containsLocalPoint(Vector2 point) {
    return _path.contains(point.toOffset());
  }

  @override
  void render(Canvas canvas) {
    if (isDragged) {
      _paint.color = color.withValues(alpha: 0.5);
      canvas.drawPath(_path, _paint);
      canvas.drawPath(_path, _borderPaint);
    } else {
      _paint.color = color.withValues(alpha: 1);
      canvas.drawPath(_path, _paint);
    }
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    priority = 10;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    priority = 0;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    position += event.localDelta;
  }
}

// Cómo usar el juego en tu widget principal:
/*
void main() {
  runApp(
    MaterialApp(
      home: GameWidget(
        game: ParkingGame(),
        overlayBuilderMap: {
          'controls': (context, game) => 
              ParkingGame.cameraControls(context, game as ParkingGame),
        },
      ),
    ),
  );
}
*/
