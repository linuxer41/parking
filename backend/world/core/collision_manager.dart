import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as vector_math;
import 'dart:math' as math;

import '../models/world_elements.dart';
import 'world_state.dart';

/// Clase para gestionar colisiones entre elementos del mundo
class CollisionManager {
  final WorldState state;
  
  // Umbral de colisión (margen de seguridad entre elementos)
  final double collisionThreshold;
  
  CollisionManager({
    required this.state, 
    this.collisionThreshold = 5.0,
  });
  
  /// Detecta si hay colisión entre dos elementos
  bool checkCollision(WorldElement element1, WorldElement element2) {
    // No comprobar colisión con el mismo elemento
    if (element1.id == element2.id) return false;
    
    // Usar la detección de colisiones precisa que considera rotación
    return checkCollisionPrecise(element1, element2);
  }
  
  /// Detecta si un elemento colisiona con cualquier otro en el mundo
  bool checkElementCollisions(WorldElement element, {List<WorldElement>? exclude}) {
    final elementsToCheck = state.allElements.where((e) => 
      e.id != element.id && 
      e.isVisible && 
      (exclude == null || !exclude.contains(e))
    ).toList();
    
    for (final otherElement in elementsToCheck) {
      if (checkCollisionPrecise(element, otherElement)) {
        return true;
      }
    }
    
    return false;
  }
  
  /// Encuentra todos los elementos que colisionan con el elemento dado
  List<WorldElement> findCollidingElements(WorldElement element) {
    final List<WorldElement> collidingElements = [];
    
    for (final otherElement in state.allElements) {
      if (otherElement.id != element.id && 
          otherElement.isVisible &&
          checkCollisionPrecise(element, otherElement)) {
        collidingElements.add(otherElement);
      }
    }
    
    return collidingElements;
  }
  
  /// Encuentra una posición cercana sin colisiones para un elemento
  vector_math.Vector2 findNonCollidingPosition(
    WorldElement element, 
    vector_math.Vector2 desiredPosition,
    {double maxDistance = 300.0, double step = 20.0}
  ) {
    // Guardar posición original
    final originalPosition = vector_math.Vector2(element.position.x, element.position.y);
    
    // Probar con la posición deseada primero
    element.position.x = desiredPosition.x;
    element.position.y = desiredPosition.y;
    
    // Si no hay colisión, usar esta posición
    if (!checkElementCollisions(element)) {
      return desiredPosition;
    }
    
    // Buscar referencia para posicionamiento (último elemento agregado o elemento seleccionado)
    WorldElement? referenceElement = state.firstSelectedElement;
    if (referenceElement == null && state.allElements.isNotEmpty) {
      // Si no hay elemento seleccionado, usar el último elemento agregado
      referenceElement = state.allElements.last;
      
      // Si el elemento actual es el último, usar el penúltimo como referencia
      if (referenceElement.id == element.id && state.allElements.length > 1) {
        referenceElement = state.allElements[state.allElements.length - 2];
      }
    }
    
    // Si tenemos un elemento de referencia, intentar posicionar a la derecha al mismo nivel
    if (referenceElement != null && referenceElement.id != element.id) {
      // Definir separación mínima entre elementos
      final double minSeparation = 5.0;
      
      // Calcular posición a la derecha del elemento de referencia (mismo nivel vertical)
      final rightAlignedPosition = vector_math.Vector2(
        referenceElement.position.x + referenceElement.size.width/2 + element.size.width/2 + minSeparation,
        referenceElement.position.y // Mantener la misma coordenada Y para alinear verticalmente
      );
      
      // Probar posición a la derecha alineada
      element.position.x = rightAlignedPosition.x;
      element.position.y = rightAlignedPosition.y;
      
      if (!checkElementCollisions(element)) {
        return vector_math.Vector2(element.position.x, element.position.y);
      }
      
      // Si hay colisión, intentar posición debajo del elemento de referencia
      final bottomAlignedPosition = vector_math.Vector2(
        referenceElement.position.x, // Mantener la misma coordenada X para alinear horizontalmente
        referenceElement.position.y + referenceElement.size.height/2 + element.size.height/2 + minSeparation
      );
      
      element.position.x = bottomAlignedPosition.x;
      element.position.y = bottomAlignedPosition.y;
      
      if (!checkElementCollisions(element)) {
        return vector_math.Vector2(element.position.x, element.position.y);
      }
      
      // Si hay colisión, intentar incrementar la distancia horizontal gradualmente
      for (double distance = minSeparation + 5; distance <= 100; distance += 5) {
        // Intentar posición a la derecha con mayor separación (mismo nivel)
        final rightPosition = vector_math.Vector2(
          referenceElement.position.x + referenceElement.size.width/2 + element.size.width/2 + distance,
          referenceElement.position.y // Mantener la misma coordenada Y
        );
        
        element.position.x = rightPosition.x;
        element.position.y = rightPosition.y;
        
        if (!checkElementCollisions(element)) {
          return vector_math.Vector2(element.position.x, element.position.y);
        }
      }
      
      // Si hay colisión, intentar posición diagonal (derecha y abajo)
      final diagonalPosition = vector_math.Vector2(
        referenceElement.position.x + referenceElement.size.width/2 + element.size.width/2 + minSeparation,
        referenceElement.position.y + referenceElement.size.height/2 + element.size.height/2 + minSeparation
      );
      
      element.position.x = diagonalPosition.x;
      element.position.y = diagonalPosition.y;
      
      if (!checkElementCollisions(element)) {
        return vector_math.Vector2(element.position.x, element.position.y);
      }
    }
    
    // Si las posiciones prioritarias no funcionan, usar búsqueda en cuadrícula
    // comenzando desde la esquina derecha del último elemento
    if (referenceElement != null) {
      final startX = referenceElement.position.x + referenceElement.size.width/2 + element.size.width/2 + 5;
      final startY = referenceElement.position.y - maxDistance/2; // Comenzar desde arriba
      
      // Buscar en una cuadrícula expandiéndose hacia abajo y a la derecha
      for (double x = startX; x < startX + maxDistance; x += step) {
        for (double y = startY; y < startY + maxDistance; y += step) {
          element.position.x = x;
          element.position.y = y;
          
          if (!checkElementCollisions(element)) {
            return vector_math.Vector2(x, y);
          }
        }
      }
    }
    
    // Si todo falla, usar estrategia en espiral desde la posición deseada
    double angle = 0.0;
    double radius = step;
    
    while (radius < maxDistance) {
      // Calcular nueva posición en espiral
      final x = desiredPosition.x + radius * math.cos(angle);
      final y = desiredPosition.y + radius * math.sin(angle);
      
      // Probar esta posición
      element.position.x = x;
      element.position.y = y;
      
      // Si no hay colisión, usar esta posición
      if (!checkElementCollisions(element)) {
        return vector_math.Vector2(x, y);
      }
      
      // Incrementar ángulo y radio para espiral
      angle += 0.5;
      radius += step / (2 * math.pi); // Incremento gradual del radio
    }
    
    // Restaurar posición original si no se encuentra una posición válida
    element.position.x = originalPosition.x;
    element.position.y = originalPosition.y;
    
    // Devolver la posición original si no se encuentra una mejor
    return originalPosition;
  }
  
  /// Obtiene el rectángulo que representa el elemento (considerando rotación)
  Rect _getElementRect(WorldElement element) {
    // Para simplificar, usamos un rectángulo alineado con ejes con margen adicional
    // para elementos rotados (aproximación)
    
    final width = element.size.width + collisionThreshold;
    final height = element.size.height + collisionThreshold;
    
    // Si hay rotación, usar una aproximación de la envolvente
    if (element.rotation != 0) {
      // Calcular la envolvente del elemento rotado (bounding box)
      final double cosR = math.cos(element.rotation).abs();
      final double sinR = math.sin(element.rotation).abs();
      
      // Calcular ancho y alto del rectángulo rotado
      final rotatedWidth = width * cosR + height * sinR;
      final rotatedHeight = width * sinR + height * cosR;
      
      return Rect.fromCenter(
        center: Offset(element.position.x, element.position.y),
        width: rotatedWidth,
        height: rotatedHeight,
      );
    } else {
      // Sin rotación, usar el rectángulo normal
      return Rect.fromCenter(
        center: Offset(element.position.x, element.position.y),
        width: width,
        height: height,
      );
    }
  }
  
  /// Método más preciso para verificar colisiones entre elementos rotados
  bool checkCollisionPrecise(WorldElement element1, WorldElement element2) {
    // No comprobar colisión con el mismo elemento
    if (element1.id == element2.id) return false;
    
    // Primero hacemos una comprobación rápida con los rectángulos envolventes
    final rect1 = _getElementRect(element1);
    final rect2 = _getElementRect(element2);
    
    // Si los rectángulos envolventes no se solapan, no hay colisión
    if (!rect1.overlaps(rect2)) {
      return false;
    }
    
    // Si ambos elementos no tienen rotación, la comprobación de rectángulos es suficiente
    if (element1.rotation == 0 && element2.rotation == 0) {
      return true;
    }
    
    // Para elementos rotados, usamos una comprobación más precisa
    // Obtenemos los vértices de los rectángulos rotados
    final vertices1 = _getRotatedRectVertices(element1);
    final vertices2 = _getRotatedRectVertices(element2);
    
    // Comprobamos si hay colisión usando el algoritmo de separación de ejes (SAT)
    return _checkSATCollision(vertices1, vertices2);
  }
  
  /// Obtiene los vértices de un rectángulo rotado
  List<Offset> _getRotatedRectVertices(WorldElement element) {
    final width = element.size.width / 2 + collisionThreshold / 2;
    final height = element.size.height / 2 + collisionThreshold / 2;
    
    // Puntos del rectángulo sin rotar (desde el centro)
    final List<Offset> vertices = [
      Offset(-width, -height), // Superior izquierda
      Offset(width, -height),  // Superior derecha
      Offset(width, height),   // Inferior derecha
      Offset(-width, height),  // Inferior izquierda
    ];
    
    // Aplicar rotación a los vértices
    final List<Offset> rotatedVertices = [];
    final double cosR = math.cos(element.rotation);
    final double sinR = math.sin(element.rotation);
    
    for (final vertex in vertices) {
      // Rotar el punto
      final rotatedX = vertex.dx * cosR - vertex.dy * sinR;
      final rotatedY = vertex.dx * sinR + vertex.dy * cosR;
      
      // Trasladar al centro del elemento
      rotatedVertices.add(Offset(
        rotatedX + element.position.x,
        rotatedY + element.position.y,
      ));
    }
    
    return rotatedVertices;
  }
  
  /// Comprueba colisión usando el algoritmo de separación de ejes (SAT)
  bool _checkSATCollision(List<Offset> vertices1, List<Offset> vertices2) {
    // Obtener todos los ejes para la comprobación
    final List<Offset> axes = _getAxes(vertices1)..addAll(_getAxes(vertices2));
    
    // Comprobar cada eje
    for (final axis in axes) {
      final projection1 = _projectVertices(vertices1, axis);
      final projection2 = _projectVertices(vertices2, axis);
      
      // Si hay una separación en algún eje, no hay colisión
      if (projection1.end < projection2.start || projection2.end < projection1.start) {
        return false;
      }
    }
    
    // Si no hay separación en ningún eje, hay colisión
    return true;
  }
  
  /// Obtiene los ejes normales a los lados del polígono
  List<Offset> _getAxes(List<Offset> vertices) {
    final List<Offset> axes = [];
    
    for (int i = 0; i < vertices.length; i++) {
      final p1 = vertices[i];
      final p2 = vertices[(i + 1) % vertices.length];
      
      // Vector del lado
      final edge = Offset(p2.dx - p1.dx, p2.dy - p1.dy);
      
      // Vector normal (perpendicular)
      final normal = Offset(-edge.dy, edge.dx);
      
      // Normalizar el vector
      final length = math.sqrt(normal.dx * normal.dx + normal.dy * normal.dy);
      final normalizedNormal = Offset(normal.dx / length, normal.dy / length);
      
      axes.add(normalizedNormal);
    }
    
    return axes;
  }
  
  /// Proyecta los vértices en un eje y devuelve el rango de la proyección
  _Projection _projectVertices(List<Offset> vertices, Offset axis) {
    double min = double.infinity;
    double max = double.negativeInfinity;
    
    for (final vertex in vertices) {
      // Producto escalar para proyectar el vértice en el eje
      final projection = vertex.dx * axis.dx + vertex.dy * axis.dy;
      
      if (projection < min) min = projection;
      if (projection > max) max = projection;
    }
    
    return _Projection(min, max);
  }
  
  /// Visualiza las colisiones en el canvas (para depuración)
  void debugDrawCollisions(Canvas canvas, double zoom, vector_math.Vector2 cameraOffset) {
    final paint = Paint()
      ..color = Colors.red.withOpacity(0.3)
      ..style = PaintingStyle.fill;
      
    for (final element in state.allElements) {
      if (!element.isVisible) continue;
      
      final rect = _getElementRect(element);
      
      // Convertir a coordenadas de pantalla
      final screenX = (element.position.x - cameraOffset.x) * zoom;
      final screenY = (element.position.y - cameraOffset.y) * zoom;
      
      final screenWidth = rect.width * zoom;
      final screenHeight = rect.height * zoom;
      
      final screenRect = Rect.fromCenter(
        center: Offset(screenX, screenY),
        width: screenWidth,
        height: screenHeight,
      );
      
      // Dibujar solo si hay colisión
      if (checkElementCollisions(element)) {
        canvas.drawRect(screenRect, paint);
      }
    }
  }
}

/// Clase auxiliar para representar una proyección en un eje
class _Projection {
  final double start;
  final double end;
  
  _Projection(this.start, this.end);
} 