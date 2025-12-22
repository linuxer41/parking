import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:vector_math/vector_math.dart' as vector_math;
import '../models/parking_elements.dart';

/// Gestor de portapapeles para copiar y pegar elementos
class ClipboardManager with ChangeNotifier {
  // Elementos en el portapapeles
  final List<ParkingElement> _clipboardItems = [];
  
  // Posición desde donde se copiaron los elementos
  // (para mantener las posiciones relativas entre ellos)
  double? _sourceCenterX;
  double? _sourceCenterY;
  
  // Getters
  List<ParkingElement> get items => List.unmodifiable(_clipboardItems);
  bool get hasItems => _clipboardItems.isNotEmpty;
  int get itemCount => _clipboardItems.length;
  
  /// Copiar elementos al portapapeles
  void copyElements(List<ParkingElement> elements) {
    if (elements.isEmpty) return;
    
    // Limpiar portapapeles
    _clipboardItems.clear();
    
    // Calcular el centro del grupo de elementos para mantener posiciones relativas
    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;
    
    for (final element in elements) {
      minX = math.min(minX, element.position.x);
      minY = math.min(minY, element.position.y);
      maxX = math.max(maxX, element.position.x);
      maxY = math.max(maxY, element.position.y);
    }
    
    // Guardar el centro del grupo
    _sourceCenterX = (minX + maxX) / 2;
    _sourceCenterY = (minY + maxY) / 2;
    
    // Clonar los elementos y guardarlos en el portapapeles
    for (final element in elements) {
      _clipboardItems.add(element.clone());
    }
    
    notifyListeners();
  }
  
  /// Pegar elementos desde el portapapeles en una posición específica
  List<ParkingElement> pasteElements(double targetX, double targetY) {
    if (_clipboardItems.isEmpty || _sourceCenterX == null || _sourceCenterY == null) {
      return [];
    }
    
    final pastedElements = <ParkingElement>[];
    
    // Calcular el desplazamiento desde el centro original al punto objetivo
    final offsetX = targetX - _sourceCenterX!;
    final offsetY = targetY - _sourceCenterY!;
    
    for (final sourceElement in _clipboardItems) {
      // Clonar el elemento nuevamente para crear una nueva instancia
      final newElement = sourceElement.clone();
      
      // Ajustar posición al punto objetivo manteniendo posiciones relativas
      newElement.position = vector_math.Vector2(
        sourceElement.position.x + offsetX,
        sourceElement.position.y + offsetY,
      );
      
      // Como no podemos cambiar el ID directamente (es final), creamos un nuevo
      // elemento con un ID único durante el proceso de clonación
      
      pastedElements.add(newElement);
    }
    
    notifyListeners();
    return pastedElements;
  }
  
  /// Cortar elementos (copiar y marcar para eliminar)
  List<ParkingElement> cutElements(List<ParkingElement> elements) {
    // Primero copiar los elementos
    copyElements(elements);
    
    // Devolver los elementos originales para que puedan ser eliminados
    return elements;
  }
  
  /// Limpiar el portapapeles
  void clear() {
    _clipboardItems.clear();
    _sourceCenterX = null;
    _sourceCenterY = null;
    notifyListeners();
  }
} 