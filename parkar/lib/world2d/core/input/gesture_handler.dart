// core/input/gesture_handler.dart
import 'package:flutter/material.dart';
import '../entity_system.dart';
import '../rendering/renderer.dart';

class GestureHandler {
  Entity? selectedEntity;
  Offset? lastPosition;
  final Renderer renderer;
  final EntitySystem entitySystem;

  GestureHandler({required this.renderer, required this.entitySystem});

  void handleTapDown(TapDownDetails details) {
    // Convertir coordenadas de pantalla a coordenadas de mundo
    final worldPos = _screenToWorldPosition(details.localPosition);
    selectedEntity = findEntityAtPosition(worldPos);
    print("Entidad seleccionada: ${selectedEntity?.id}");
    lastPosition = details.localPosition;
  }

  void handleScaleStart(ScaleStartDetails details) {
    lastPosition = details.focalPoint;
  }

  void handleScaleUpdate(ScaleUpdateDetails details) {
    if (lastPosition == null) {
      lastPosition = details.focalPoint;
      return;
    }

    final delta = details.focalPoint - lastPosition!;
    lastPosition = details.focalPoint;

    if (selectedEntity != null && selectedEntity!.draggable != null) {
      // Mover la entidad seleccionada
      selectedEntity!.transform.x += delta.dx / renderer.camera.zoom;
      selectedEntity!.transform.y += delta.dy / renderer.camera.zoom;
      
      // Actualizar el rectángulo del colisionador
      if (selectedEntity!.collider != null) {
        selectedEntity!.collider!.rect = Rect.fromLTWH(
          selectedEntity!.transform.x,
          selectedEntity!.transform.y,
          selectedEntity!.collider!.rect.width,
          selectedEntity!.collider!.rect.height,
        );
      }
    } else {
      // Mover la cámara
      renderer.camera.translate(-delta.dx / renderer.camera.zoom, -delta.dy / renderer.camera.zoom);
    }

    // Manejar zoom
    if (details.scale != 1.0) {
      final oldZoom = renderer.camera.zoom;
      renderer.camera.zoom *= details.scale;
      // Limitar el zoom entre 0.5 y 3.0
      renderer.camera.zoom = renderer.camera.zoom.clamp(0.5, 3.0);
      
      // Ajustar la posición de la cámara para mantener el punto focal
      if (oldZoom != renderer.camera.zoom) {
        final focalPoint = _screenToWorldPosition(details.focalPoint);
        final scale = renderer.camera.zoom / oldZoom;
        renderer.camera.x = focalPoint.dx - (focalPoint.dx - renderer.camera.x) * scale;
        renderer.camera.y = focalPoint.dy - (focalPoint.dy - renderer.camera.y) * scale;
      }
    }
  }

  void handleScaleEnd(ScaleEndDetails details) {
    lastPosition = null;
  }

  Offset _screenToWorldPosition(Offset screenPos) {
    return Offset(
      (screenPos.dx + renderer.camera.x) / renderer.camera.zoom,
      (screenPos.dy + renderer.camera.y) / renderer.camera.zoom,
    );
  }

  Entity? findEntityAtPosition(Offset position) {
    // Recorrer las entidades en orden inverso para seleccionar la que está encima
    for (var entity in entitySystem.entities.reversed) {
      if (entity.collider != null) {
        final rect = entity.collider!.rect;
        if (rect.contains(position)) {
          return entity;
        }
      }
    }
    return null;
  }

  void update() {
    // Actualizar lógica adicional si es necesario
  }
}