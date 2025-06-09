import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math.dart' as vector_math;
import 'parking_state.dart';
import 'clipboard_manager.dart';

/// Gestor de atajos de teclado para el editor
class KeyboardShortcutsManager {
  // Estado del estacionamiento
  final ParkingState parkingState;
  
  // Gestor de portapapeles
  final ClipboardManager clipboardManager;
  
  // Callback para notificar acciones
  final Function(String) onActionPerformed;
  
  // Constructor
  KeyboardShortcutsManager({
    required this.parkingState,
    required this.clipboardManager,
    required this.onActionPerformed,
  });
  
  /// Maneja un evento de tecla
  bool handleKeyEvent(RawKeyEvent event) {
    // Si no estamos en modo edición, no procesar atajos
    if (!parkingState.isEditMode) return false;
    
    // Solo procesar eventos de tecla hacia abajo para evitar doble ejecución
    if (event is! RawKeyDownEvent) return false;
    
    // Obtener si Control está presionado
    final bool isControlPressed = event.isControlPressed;
    final bool isShiftPressed = event.isShiftPressed;
    final bool isAltPressed = event.isAltPressed;
    
    // Obtener la tecla presionada
    final LogicalKeyboardKey key = event.logicalKey;
    
    // Ctrl+Z: Deshacer
    if (isControlPressed && key == LogicalKeyboardKey.keyZ && !isShiftPressed) {
      _undoAction();
      return true;
    }
    
    // Ctrl+Y o Ctrl+Shift+Z: Rehacer
    if ((isControlPressed && key == LogicalKeyboardKey.keyY) || 
        (isControlPressed && isShiftPressed && key == LogicalKeyboardKey.keyZ)) {
      _redoAction();
      return true;
    }
    
    // Ctrl+C: Copiar
    if (isControlPressed && key == LogicalKeyboardKey.keyC) {
      _copySelectedElements();
      return true;
    }
    
    // Ctrl+X: Cortar
    if (isControlPressed && key == LogicalKeyboardKey.keyX) {
      _cutSelectedElements();
      return true;
    }
    
    // Ctrl+V: Pegar
    if (isControlPressed && key == LogicalKeyboardKey.keyV) {
      _pasteElements();
      return true;
    }
    
    // Delete o Backspace: Eliminar elementos seleccionados
    if (key == LogicalKeyboardKey.delete || key == LogicalKeyboardKey.backspace) {
      _deleteSelectedElements();
      return true;
    }
    
    // Ctrl+A: Seleccionar todo
    if (isControlPressed && key == LogicalKeyboardKey.keyA) {
      _selectAllElements();
      return true;
    }
    
    // Ctrl+D: Deseleccionar todo
    if (isControlPressed && key == LogicalKeyboardKey.keyD) {
      _deselectAllElements();
      return true;
    }
    
    // Flechas: Mover elementos seleccionados con precisión
    if (key == LogicalKeyboardKey.arrowUp || 
        key == LogicalKeyboardKey.arrowDown || 
        key == LogicalKeyboardKey.arrowLeft || 
        key == LogicalKeyboardKey.arrowRight) {
      // Determinar la dirección y cantidad del movimiento
      final double delta = isShiftPressed ? 10.0 : 1.0; // Shift para movimiento mayor
      double dx = 0.0;
      double dy = 0.0;
      
      if (key == LogicalKeyboardKey.arrowLeft) dx = -delta;
      if (key == LogicalKeyboardKey.arrowRight) dx = delta;
      if (key == LogicalKeyboardKey.arrowUp) dy = -delta;
      if (key == LogicalKeyboardKey.arrowDown) dy = delta;
      
      _moveSelectedElements(dx, dy);
      return true;
    }
    
    // Ctrl+Shift+F: Ajustar vista a selección
    if (isControlPressed && isShiftPressed && key == LogicalKeyboardKey.keyF) {
      _fitViewToSelection();
      return true;
    }
    
    // No se manejó el atajo
    return false;
  }
  
  /// Deshacer la última acción
  void _undoAction() {
    final action = parkingState.historyManager.undo();
    if (action != null) {
      onActionPerformed('Deshacer: ${action.toString()}');
    }
  }
  
  /// Rehacer la última acción deshecha
  void _redoAction() {
    final action = parkingState.historyManager.redo();
    if (action != null) {
      onActionPerformed('Rehacer: ${action.toString()}');
    }
  }
  
  /// Copiar elementos seleccionados al portapapeles
  void _copySelectedElements() {
    if (parkingState.selectedElements.isEmpty) return;
    
    clipboardManager.copyElements(parkingState.selectedElements);
    onActionPerformed('${parkingState.selectedElements.length} elementos copiados');
  }
  
  /// Cortar elementos seleccionados
  void _cutSelectedElements() {
    if (parkingState.selectedElements.isEmpty) return;
    
    // Primero copiar al portapapeles
    clipboardManager.copyElements(parkingState.selectedElements);
    
    // Luego eliminar los elementos
    final count = parkingState.selectedElements.length;
    for (final element in List.from(parkingState.selectedElements)) {
      parkingState.removeElement(element);
    }
    
    onActionPerformed('$count elementos cortados');
  }
  
  /// Pegar elementos desde el portapapeles
  void _pasteElements() {
    if (!clipboardManager.hasItems) return;
    
    // Obtener la posición del cursor para pegar allí
    final cursorPosition = parkingState.cursorPosition;
    
    // Generar elementos pegados utilizando el método pasteElements
    final pastedElements = clipboardManager.pasteElements(
      cursorPosition.x, 
      cursorPosition.y,
    );
    
    // Añadir los elementos al estado
    for (final element in pastedElements) {
      parkingState.addElement(element);
    }
    
    // Limpiar selección actual
    parkingState.clearSelection();
    
    // Seleccionar los elementos recién pegados
    parkingState.selectMultipleElements(pastedElements);
    
    onActionPerformed('${pastedElements.length} elementos pegados');
  }
  
  /// Eliminar elementos seleccionados
  void _deleteSelectedElements() {
    if (parkingState.selectedElements.isEmpty) return;
    
    final count = parkingState.selectedElements.length;
    
    // Eliminar elementos seleccionados
    for (final element in List.from(parkingState.selectedElements)) {
      parkingState.removeElement(element);
    }
    
    onActionPerformed('$count elementos eliminados');
  }
  
  /// Seleccionar todos los elementos
  void _selectAllElements() {
    // Deseleccionar todo primero
    parkingState.clearSelection();
    
    // Seleccionar todos los elementos
    parkingState.selectMultipleElements(parkingState.allElements);
    
    onActionPerformed('${parkingState.selectedElements.length} elementos seleccionados');
  }
  
  /// Deseleccionar todos los elementos
  void _deselectAllElements() {
    final count = parkingState.selectedElements.length;
    parkingState.clearSelection();
    
    if (count > 0) {
      onActionPerformed('$count elementos deseleccionados');
    }
  }
  
  /// Mover elementos seleccionados con precisión
  void _moveSelectedElements(double dx, double dy) {
    if (parkingState.selectedElements.isEmpty) return;
    
    // Verificar si hay elementos bloqueados
    final lockedElements = parkingState.selectedElements
        .where((element) => element.isLocked)
        .toList();
    
    if (lockedElements.isNotEmpty) {
      onActionPerformed('${lockedElements.length} elementos están bloqueados y no se pueden mover');
      return;
    }
    
    // Guardar posiciones originales para historial
    final Map<String, vector_math.Vector2> oldPositions = {};
    final Map<String, vector_math.Vector2> newPositions = {};
    
    // Mover cada elemento
    for (final element in parkingState.selectedElements) {
      // Guardar posición original
      oldPositions[element.id] = element.position;
      
      // Calcular nueva posición
      final newPosition = element.position.clone()
        ..x += dx
        ..y += dy;
      
      // Aplicar nueva posición
      element.position = newPosition;
      
      // Guardar nueva posición
      newPositions[element.id] = element.position;
    }
    
    // Registrar la acción en el historial
    if (parkingState.selectedElements.length == 1) {
      final element = parkingState.selectedElements.first;
      parkingState.historyManager.moveElementAction(
        element,
        oldPositions[element.id]!,
        newPositions[element.id]!,
      );
    } else {
      parkingState.historyManager.moveMultipleElementsAction(
        parkingState.selectedElements,
        oldPositions,
        newPositions,
      );
    }
    
    onActionPerformed(
      '${parkingState.selectedElements.length} elementos movidos ${dx != 0 ? (dx > 0 ? 'derecha' : 'izquierda') : ''} '
      '${dy != 0 ? (dy > 0 ? 'abajo' : 'arriba') : ''}'
    );
  }
  
  /// Ajustar vista a los elementos seleccionados
  void _fitViewToSelection() {
    if (parkingState.selectedElements.isEmpty) {
      // Si no hay selección, ajustar a todos los elementos
      _fitViewToAllElements();
      return;
    }
    
    // Calcular límites de los elementos seleccionados
    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;
    
    for (final element in parkingState.selectedElements) {
      final size = element.getSize();
      final halfWidth = size.width * element.scale / 2;
      final halfHeight = size.height * element.scale / 2;
      
      minX = math.min(minX, element.position.x - halfWidth);
      minY = math.min(minY, element.position.y - halfHeight);
      maxX = math.max(maxX, element.position.x + halfWidth);
      maxY = math.max(maxY, element.position.y + halfHeight);
    }
    
    // Calcular el centro y tamaño del grupo
    final centerX = (minX + maxX) / 2;
    final centerY = (minY + maxY) / 2;
    final width = maxX - minX;
    final height = maxY - minY;
    
    // Añadir un margen
    final margin = 50.0;
    final viewportWidth = parkingState.canvasSize.width - margin * 2;
    final viewportHeight = parkingState.canvasSize.height - margin * 2;
    
    // Calcular el zoom necesario
    final zoomX = viewportWidth / width;
    final zoomY = viewportHeight / height;
    final newZoom = math.min(zoomX, zoomY);
    
    // Aplicar el zoom y la posición
    parkingState.zoom = newZoom;
    parkingState.cameraPosition = _calculateCameraPosition(
      centerX, 
      centerY, 
      newZoom, 
      parkingState.canvasSize,
    );
    
    onActionPerformed('Vista ajustada a los elementos seleccionados');
  }
  
  /// Ajustar vista a todos los elementos
  void _fitViewToAllElements() {
    final elements = parkingState.allElements;
    if (elements.isEmpty) {
      // Si no hay elementos, centrar en el origen
      parkingState.centerViewOnOrigin(parkingState.canvasSize);
      onActionPerformed('Vista centrada en el origen');
      return;
    }
    
    // Calcular límites de todos los elementos
    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;
    
    for (final element in elements) {
      final size = element.getSize();
      final halfWidth = size.width * element.scale / 2;
      final halfHeight = size.height * element.scale / 2;
      
      minX = math.min(minX, element.position.x - halfWidth);
      minY = math.min(minY, element.position.y - halfHeight);
      maxX = math.max(maxX, element.position.x + halfWidth);
      maxY = math.max(maxY, element.position.y + halfHeight);
    }
    
    // Calcular el centro y tamaño del grupo
    final centerX = (minX + maxX) / 2;
    final centerY = (minY + maxY) / 2;
    final width = maxX - minX;
    final height = maxY - minY;
    
    // Añadir un margen
    final margin = 50.0;
    final viewportWidth = parkingState.canvasSize.width - margin * 2;
    final viewportHeight = parkingState.canvasSize.height - margin * 2;
    
    // Calcular el zoom necesario
    final zoomX = viewportWidth / width;
    final zoomY = viewportHeight / height;
    final newZoom = math.min(zoomX, zoomY);
    
    // Aplicar el zoom y la posición
    parkingState.zoom = newZoom;
    parkingState.cameraPosition = _calculateCameraPosition(
      centerX, 
      centerY, 
      newZoom, 
      parkingState.canvasSize,
    );
    
    onActionPerformed('Vista ajustada a todos los elementos');
  }
  
  /// Calcular la posición de la cámara para centrar un punto
  vector_math.Vector2 _calculateCameraPosition(
    double centerX, 
    double centerY, 
    double zoom, 
    Size canvasSize,
  ) {
    // La fórmula es: cameraPosition = (worldPoint * zoom) - (viewportSize / 2)
    return vector_math.Vector2(
      centerX * zoom - canvasSize.width / 2, 
      centerY * zoom - canvasSize.height / 2,
    );
  }
} 