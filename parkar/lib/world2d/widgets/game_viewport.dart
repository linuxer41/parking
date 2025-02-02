import 'package:flutter/material.dart';

import '../components/transform.dart';
import '../core/entity_system.dart';
import '../core/game_engine.dart';
import '../core/input/gesture_handler.dart';
import '../core/physics/collision.dart';
import '../core/physics/spatial_grid.dart';
import '../core/rendering/camera.dart';
import '../core/rendering/renderer.dart';
import '../core/screen_controller.dart';
import '../entities/facility.dart';
import '../entities/signage.dart';
import '../entities/spot.dart';
import '../utils/fps_monitor.dart';

class GameViewport extends StatefulWidget {
  const GameViewport({super.key});

  @override
  State<GameViewport> createState() => _GameViewportState();
}

// widgets/game_viewport.dart
class _GameViewportState extends State<GameViewport> {
  late GameEngine gameEngine;
  late EntitySystem entitySystem;
  late Renderer renderer;
  late Camera camera;
  late CollisionDetector collisionDetector;
  late GestureHandler gestureHandler;
  late FPSMonitor fpsMonitor;
  late ScreenController screenController;

  @override
  void initState() {
    super.initState();

    fpsMonitor = FPSMonitor();
    camera = Camera();
    entitySystem = EntitySystem();
    renderer = Renderer(camera: camera);
    collisionDetector = CollisionDetector(spatialGrid: SpatialGrid());
    gestureHandler = GestureHandler(
      renderer: renderer,
      entitySystem: entitySystem,
    );
    screenController = ScreenController(entitySystem: entitySystem);

    gameEngine = GameEngine(
      entitySystem: entitySystem,
      renderer: renderer,
      collisionDetector: collisionDetector,
      gestureHandler: gestureHandler,
    );

    addInitialEntities();
    gameEngine.start();
  }

  void addInitialEntities() {
    screenController.addParkingSpot(Offset(100, 100), SpotType.car, isOccupied: true);
    screenController.addParkingSpot(Offset(200, 100), SpotType.bike);
    screenController.addFacility(Offset(300, 100), FacilityType.elevator);
    screenController.addSignage(Offset(400, 100), SignageType.exit);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTapDown: gestureHandler.handleTapDown,
          onScaleStart: gestureHandler.handleScaleStart,
          onScaleUpdate: gestureHandler.handleScaleUpdate,
          onScaleEnd: gestureHandler.handleScaleEnd,
          child: CustomPaint(
            painter: GamePainter(
              entitySystem: entitySystem,
              camera: camera,
              selectedEntity: gestureHandler.selectedEntity,
              fpsMonitor: fpsMonitor,
            ),
            child: Container(),
          ),
        ),
        Positioned(
          top: 10,
          right: 10,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(4),
            ),
            child: ValueListenableBuilder<double>(
              valueListenable: fpsMonitor.fpsNotifier,
              builder: (context, fps, child) {
                return Text(
                  'FPS: ${fps.toStringAsFixed(1)}',
                  style: const TextStyle(color: Colors.white),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
class GamePainter extends CustomPainter {
  final EntitySystem entitySystem;
  final Camera camera;
  final Entity? selectedEntity;
  final FPSMonitor fpsMonitor;

  GamePainter({
    required this.entitySystem,
    required this.camera,
    required this.selectedEntity,
    required this.fpsMonitor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    fpsMonitor.update();
        final textStyle = TextStyle(
      color: Colors.black,
      fontSize: 12 * camera.zoom,
    );
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    for (var entity in entitySystem.entities) {
      final rect = Rect.fromLTWH(
        (entity.transform.x - camera.x) * camera.zoom,
        (entity.transform.y - camera.y) * camera.zoom,
        entity.collider!.rect.width * camera.zoom,
        entity.collider!.rect.height * camera.zoom,
      );

      if (entity is ParkingSpot) {
        _drawParkingSpot(canvas, entity, rect);
      } else if (entity is Facility) {
        _drawFacility(canvas, entity, rect);
      } else if (entity is Signage) {
        _drawSignage(canvas, entity, rect);
      }
      final positionText = "(${entity.transform.x.toStringAsFixed(1)}, ${entity.transform.y.toStringAsFixed(1)})";
      textPainter.text = TextSpan(text: positionText, style: textStyle);
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(rect.left + 5 * camera.zoom, rect.top + 5 * camera.zoom),
      );

      // Dibujar indicador de selección si la entidad está seleccionada
      if (entity == selectedEntity) {
        _drawSelectionIndicator(canvas, rect);
      }

      if (entity == selectedEntity) {
        _drawSelectionIndicator(canvas, rect);
      }
    }
  }

  void _drawParkingSpot(Canvas canvas, ParkingSpot spot, Rect rect) {
    // Dibujar el contorno del lugar
    canvas.drawRect(
      rect,
      Paint()
        ..color = spot.spotColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0 * camera.zoom,
    );

    // Si está ocupado, dibujar el relleno
    if (spot.renderable!.isOccupied) {
      canvas.drawRect(
        rect.deflate(4 * camera.zoom),
        Paint()..color = spot.spotColor.withOpacity(0.3),
      );
    }
  }

  void _drawFacility(Canvas canvas, Facility facility, Rect rect) {
    canvas.drawRect(
      rect,
      Paint()
        ..color = facility.facilityColor
        ..style = PaintingStyle.fill,
    );
  }

  void _drawSignage(Canvas canvas, Signage signage, Rect rect) {
    canvas.drawRect(
      rect,
      Paint()
        ..color = signage.signageColor
        ..style = PaintingStyle.fill,
    );
  }

  void _drawSelectionIndicator(Canvas canvas, Rect rect) {
    // Dibujar un borde punteado alrededor de la entidad seleccionada
    final Paint dashPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0 * camera.zoom;

    final Path dashPath = Path();
    const double dashWidth = 5.0;
    const double dashSpace = 5.0;
    double distance = 0.0;
    final double perimeter = rect.width * 2 + rect.height * 2;

    while (distance < perimeter) {
      dashPath.moveTo(
        rect.left + (distance < rect.width ? distance : (distance < rect.width + rect.height ? rect.width : (distance < rect.width * 2 + rect.height ? rect.width - (distance - (rect.width + rect.height)) : 0))),
        rect.top + (distance < rect.width ? 0 : (distance < rect.width + rect.height ? distance - rect.width : (distance < rect.width * 2 + rect.height ? rect.height : rect.height - (distance - (rect.width * 2 + rect.height))))),
      );

      final double dashLength = dashWidth * camera.zoom;
      distance += dashLength;
      if (distance > perimeter) break;

      dashPath.lineTo(
        rect.left + (distance < rect.width ? distance : (distance < rect.width + rect.height ? rect.width : (distance < rect.width * 2 + rect.height ? rect.width - (distance - (rect.width + rect.height)) : 0))),
        rect.top + (distance < rect.width ? 0 : (distance < rect.width + rect.height ? distance - rect.width : (distance < rect.width * 2 + rect.height ? rect.height : rect.height - (distance - (rect.width * 2 + rect.height))))),
      );

      distance += dashSpace * camera.zoom;
    }

    canvas.drawPath(dashPath, dashPaint);
  }

  @override
  bool shouldRepaint(covariant GamePainter oldDelegate) {
    return true;
  }
}