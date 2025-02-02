import 'dart:async';
import 'entity_system.dart';
import 'rendering/renderer.dart';
import 'physics/collision.dart';
import 'input/gesture_handler.dart';

class GameEngine {
  final EntitySystem entitySystem;
  final Renderer renderer;
  final CollisionDetector collisionDetector;
  final GestureHandler gestureHandler;

  GameEngine({
    required this.entitySystem,
    required this.renderer,
    required this.collisionDetector,
    required this.gestureHandler,
  });

  void start() {
    Timer.periodic(const Duration(milliseconds: 16), (timer) {
      update();
      render();
    });
  }

  void update() {
    // Actualizar la lógica del juego
    entitySystem.update();
    collisionDetector.update();
    gestureHandler.update(); // Actualizar la lógica de entrada
  }

  void render() {
    // Renderizar el juego
    renderer.render();
  }
}