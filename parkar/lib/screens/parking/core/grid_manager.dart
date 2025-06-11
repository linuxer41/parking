import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as vector_math;
import '../models/parking_elements.dart';

/// Gestor de cuadrícula y guías inteligentes
class GridManager {
  // Tamaño de la cuadrícula
  double _gridSize = 20.0;

  // Tolerancia para el ajuste
  double _snapTolerance = 10.0;

  // Estado de activación
  bool _isGridEnabled = true;
  bool _isSnapToGridEnabled = true;
  bool _isSmartGuidesEnabled = true;

  // Guías inteligentes activas
  final List<GuideInfo> _activeGuides = [];

  // Getters
  double get gridSize => _gridSize;
  double get snapTolerance => _snapTolerance;
  bool get isGridEnabled => _isGridEnabled;
  bool get isSnapToGridEnabled => _isSnapToGridEnabled;
  bool get isSmartGuidesEnabled => _isSmartGuidesEnabled;
  List<GuideInfo> get activeGuides => List.unmodifiable(_activeGuides);

  // Setters
  set gridSize(double value) {
    _gridSize = math.max(5.0, value);
  }

  set snapTolerance(double value) {
    _snapTolerance = math.max(1.0, value);
  }

  set isGridEnabled(bool value) {
    _isGridEnabled = value;
  }

  set isSnapToGridEnabled(bool value) {
    _isSnapToGridEnabled = value;
  }

  set isSmartGuidesEnabled(bool value) {
    _isSmartGuidesEnabled = value;
  }

  /// Ajustar una posición a la cuadrícula más cercana
  vector_math.Vector2 snapToGrid(vector_math.Vector2 position) {
    if (!_isSnapToGridEnabled) return position;

    final double x = (position.x / _gridSize).round() * _gridSize;
    final double y = (position.y / _gridSize).round() * _gridSize;

    return vector_math.Vector2(x, y);
  }

  /// Limpiar guías activas
  void clearGuides() {
    _activeGuides.clear();
  }

  /// Calcular guías inteligentes para un elemento
  /// Retorna la posición ajustada según las guías
  vector_math.Vector2 calculateSmartGuides(
    ParkingElement element,
    vector_math.Vector2 proposedPosition,
    List<ParkingElement> otherElements,
  ) {
    // Si las guías inteligentes están desactivadas, no hacer nada
    if (!_isSmartGuidesEnabled) return proposedPosition;

    // Limpiar guías previas
    clearGuides();

    // Obtener las dimensiones del elemento
    final size = element.getSize();
    final halfWidth = size.width * element.scale / 2;
    final halfHeight = size.height * element.scale / 2;

    // Puntos clave del elemento (centro, bordes y esquinas)
    final center = proposedPosition;
    final left = center.x - halfWidth;
    final right = center.x + halfWidth;
    final top = center.y - halfHeight;
    final bottom = center.y + halfHeight;

    // Variables para rastrear las mejores guías encontradas
    GuideInfo? bestHorizontalGuide;
    GuideInfo? bestVerticalGuide;
    double minHorizontalDistance = _snapTolerance;
    double minVerticalDistance = _snapTolerance;

    // Para cada otro elemento, buscar posibles guías
    for (final otherElement in otherElements) {
      if (otherElement == element) continue;

      final otherSize = otherElement.getSize();
      final otherHalfWidth = otherSize.width * otherElement.scale / 2;
      final otherHalfHeight = otherSize.height * otherElement.scale / 2;

      final otherCenter = otherElement.position;
      final otherLeft = otherCenter.x - otherHalfWidth;
      final otherRight = otherCenter.x + otherHalfWidth;
      final otherTop = otherCenter.y - otherHalfHeight;
      final otherBottom = otherCenter.y + otherHalfHeight;

      // Verificar guías verticales (alineación horizontal)
      _checkVerticalGuides(center.x, left, right, otherCenter.x, otherLeft,
          otherRight, minVerticalDistance, (distance, position, type) {
        minVerticalDistance = distance;
        bestVerticalGuide =
            GuideInfo(position: position, isVertical: true, type: type);
      });

      // Verificar guías horizontales (alineación vertical)
      _checkHorizontalGuides(center.y, top, bottom, otherCenter.y, otherTop,
          otherBottom, minHorizontalDistance, (distance, position, type) {
        minHorizontalDistance = distance;
        bestHorizontalGuide =
            GuideInfo(position: position, isVertical: false, type: type);
      });
    }

    // Aplicar las guías encontradas
    vector_math.Vector2 result = proposedPosition.clone();

    if (bestVerticalGuide != null) {
      _activeGuides.add(bestVerticalGuide!);

      // Ajustar la posición X según el tipo de guía
      switch (bestVerticalGuide!.type) {
        case GuideType.left:
          result.x = bestVerticalGuide!.position + halfWidth;
          break;
        case GuideType.right:
          result.x = bestVerticalGuide!.position - halfWidth;
          break;
        case GuideType.center:
          result.x = bestVerticalGuide!.position;
          break;
        case GuideType.adjacent:
          // La posición ya está correcta para adjacent
          break;
        case GuideType.top:
        case GuideType.bottom:
        default:
          // Estos tipos no se aplican a guías verticales
          break;
      }
    }

    if (bestHorizontalGuide != null) {
      _activeGuides.add(bestHorizontalGuide!);

      // Ajustar la posición Y según el tipo de guía
      switch (bestHorizontalGuide!.type) {
        case GuideType.top:
          result.y = bestHorizontalGuide!.position + halfHeight;
          break;
        case GuideType.bottom:
          result.y = bestHorizontalGuide!.position - halfHeight;
          break;
        case GuideType.center:
          result.y = bestHorizontalGuide!.position;
          break;
        case GuideType.adjacent:
          // La posición ya está correcta para adjacent
          break;
        case GuideType.left:
        case GuideType.right:
        default:
          // Estos tipos no se aplican a guías horizontales
          break;
      }
    }

    return result;
  }

  /// Verifica las guías verticales (alineación en X)
  void _checkVerticalGuides(
      double centerX,
      double leftX,
      double rightX,
      double otherCenterX,
      double otherLeftX,
      double otherRightX,
      double minDistance,
      void Function(double distance, double position, GuideType type)
          onBetterGuide) {
    // Alineación de centros
    _checkGuideDistance(centerX, otherCenterX, minDistance,
        (dist) => onBetterGuide(dist, otherCenterX, GuideType.center));

    // Alineación de bordes izquierdos
    _checkGuideDistance(leftX, otherLeftX, minDistance,
        (dist) => onBetterGuide(dist, otherLeftX, GuideType.left));

    // Alineación de bordes derechos
    _checkGuideDistance(rightX, otherRightX, minDistance,
        (dist) => onBetterGuide(dist, otherRightX, GuideType.right));

    // Alineación de borde izquierdo con borde derecho
    _checkGuideDistance(leftX, otherRightX, minDistance,
        (dist) => onBetterGuide(dist, otherRightX, GuideType.adjacent));

    // Alineación de borde derecho con borde izquierdo
    _checkGuideDistance(rightX, otherLeftX, minDistance,
        (dist) => onBetterGuide(dist, otherLeftX, GuideType.adjacent));
  }

  /// Verifica las guías horizontales (alineación en Y)
  void _checkHorizontalGuides(
      double centerY,
      double topY,
      double bottomY,
      double otherCenterY,
      double otherTopY,
      double otherBottomY,
      double minDistance,
      void Function(double distance, double position, GuideType type)
          onBetterGuide) {
    // Alineación de centros
    _checkGuideDistance(centerY, otherCenterY, minDistance,
        (dist) => onBetterGuide(dist, otherCenterY, GuideType.center));

    // Alineación de bordes superiores
    _checkGuideDistance(topY, otherTopY, minDistance,
        (dist) => onBetterGuide(dist, otherTopY, GuideType.top));

    // Alineación de bordes inferiores
    _checkGuideDistance(bottomY, otherBottomY, minDistance,
        (dist) => onBetterGuide(dist, otherBottomY, GuideType.bottom));

    // Alineación de borde superior con borde inferior
    _checkGuideDistance(topY, otherBottomY, minDistance,
        (dist) => onBetterGuide(dist, otherBottomY, GuideType.adjacent));

    // Alineación de borde inferior con borde superior
    _checkGuideDistance(bottomY, otherTopY, minDistance,
        (dist) => onBetterGuide(dist, otherTopY, GuideType.adjacent));
  }

  /// Comprueba la distancia entre dos valores y actualiza si es mejor que la actual
  void _checkGuideDistance(
      double value1,
      double value2,
      double currentBestDistance,
      void Function(double distance) onBetterDistance) {
    final distance = (value1 - value2).abs();
    if (distance < currentBestDistance) {
      onBetterDistance(distance);
    }
  }

  /// Obtener las líneas de la cuadrícula visibles para una cámara
  List<GridLine> getVisibleGridLines(
    vector_math.Vector2 cameraPosition,
    double zoom,
    Size viewportSize,
  ) {
    if (!_isGridEnabled) return [];

    final List<GridLine> gridLines = [];

    // Calcular el tamaño de la cuadrícula escalado
    final scaledGridSize = _gridSize * zoom;

    // Si la cuadrícula es demasiado pequeña, usar una escala mayor
    double displayGridSize = _gridSize;
    double lineThickness = 0.5;

    if (scaledGridSize < 10) {
      final factor = (10 / scaledGridSize).ceil();
      displayGridSize = _gridSize * factor;
      lineThickness = factor == 1 ? 0.5 : 0.8;
    }

    // Agregar un margen adicional para garantizar que la cuadrícula cubra toda la pantalla
    // incluso durante desplazamientos y zooms rápidos
    const double margin = 500.0; // Margen extra para cubrir toda la pantalla

    // Calcular los límites del mundo visible (con margen adicional)
    final double left =
        (cameraPosition.x - viewportSize.width / 2) / zoom - margin / zoom;
    final double top =
        (cameraPosition.y - viewportSize.height / 2) / zoom - margin / zoom;
    final double right =
        (cameraPosition.x + viewportSize.width / 2) / zoom + margin / zoom;
    final double bottom =
        (cameraPosition.y + viewportSize.height / 2) / zoom + margin / zoom;

    // Calcular las coordenadas de inicio y fin para las líneas de la cuadrícula
    final startX = (left / displayGridSize).floor() * displayGridSize;
    final startY = (top / displayGridSize).floor() * displayGridSize;
    final endX = (right / displayGridSize).ceil() * displayGridSize;
    final endY = (bottom / displayGridSize).ceil() * displayGridSize;

    // Crear líneas verticales
    for (double x = startX; x <= endX; x += displayGridSize) {
      final bool isMainLine = (x % (displayGridSize * 5)).abs() < 0.001;

      gridLines.add(GridLine(
        start: vector_math.Vector2(x, startY),
        end: vector_math.Vector2(x, endY),
        isMainLine: isMainLine,
        thickness: isMainLine ? lineThickness * 1.5 : lineThickness,
      ));
    }

    // Crear líneas horizontales
    for (double y = startY; y <= endY; y += displayGridSize) {
      final bool isMainLine = (y % (displayGridSize * 5)).abs() < 0.001;

      gridLines.add(GridLine(
        start: vector_math.Vector2(startX, y),
        end: vector_math.Vector2(endX, y),
        isMainLine: isMainLine,
        thickness: isMainLine ? lineThickness * 1.5 : lineThickness,
      ));
    }

    return gridLines;
  }
}

/// Enumeración de los tipos de guías
enum GuideType {
  center, // Alineación de centros
  left, // Alineación de bordes izquierdos
  right, // Alineación de bordes derechos
  top, // Alineación de bordes superiores
  bottom, // Alineación de bordes inferiores
  adjacent, // Elementos adyacentes (sin espacio)
}

/// Información sobre una guía inteligente
class GuideInfo {
  final double position; // Posición de la guía
  final bool isVertical; // Si es vertical (true) u horizontal (false)
  final GuideType type; // Tipo de guía

  GuideInfo({
    required this.position,
    required this.isVertical,
    required this.type,
  });
}

/// Línea de la cuadrícula
class GridLine {
  final vector_math.Vector2 start; // Punto de inicio
  final vector_math.Vector2 end; // Punto de fin
  final bool isMainLine; // Si es una línea principal
  final double thickness; // Grosor de la línea

  GridLine({
    required this.start,
    required this.end,
    this.isMainLine = false,
    this.thickness = 1.0,
  });
}
