import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vector_math/vector_math.dart' as vector_math;
import '../core/parking_state.dart';
import '../core/history_manager.dart';
import '../core/clipboard_manager.dart';
import '../models/parking_elements.dart';

/// Barra de herramientas avanzada para el editor de estacionamiento
class EditorToolbar extends StatelessWidget {
  const EditorToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    // Acceder a los estados necesarios
    final parkingState = Provider.of<ParkingState>(context);
    final historyManager = Provider.of<HistoryManager>(context);
    final clipboardManager = Provider.of<ClipboardManager>(context);
    
    return Container(
      color: const Color(0xFF2A2A2A),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          // Grupo de historial (deshacer/rehacer)
          _buildToolGroup(
            children: [
              _buildToolButton(
                icon: Icons.undo,
                tooltip: 'Deshacer (Ctrl+Z)',
                onPressed: historyManager.canUndo 
                    ? () => _undoAction(context, historyManager, parkingState)
                    : null,
              ),
              _buildToolButton(
                icon: Icons.redo,
                tooltip: 'Rehacer (Ctrl+Y)',
                onPressed: historyManager.canRedo 
                    ? () => _redoAction(context, historyManager, parkingState)
                    : null,
              ),
            ],
          ),
          
          const SizedBox(width: 8),
          
          // Grupo de portapapeles (copiar/pegar/cortar)
          _buildToolGroup(
            children: [
              _buildToolButton(
                icon: Icons.content_copy,
                tooltip: 'Copiar (Ctrl+C)',
                onPressed: parkingState.selectedElements.isNotEmpty 
                    ? () => _copyElements(context, clipboardManager, parkingState)
                    : null,
              ),
              _buildToolButton(
                icon: Icons.content_paste,
                tooltip: 'Pegar (Ctrl+V)',
                onPressed: clipboardManager.hasItems 
                    ? () => _pasteElements(context, clipboardManager, parkingState, historyManager)
                    : null,
              ),
              _buildToolButton(
                icon: Icons.content_cut,
                tooltip: 'Cortar (Ctrl+X)',
                onPressed: parkingState.selectedElements.isNotEmpty 
                    ? () => _cutElements(context, clipboardManager, parkingState, historyManager)
                    : null,
              ),
            ],
          ),
          
          const SizedBox(width: 8),
          
          // Grupo de vista
          _buildToolGroup(
            children: [
              _buildToolButton(
                icon: Icons.center_focus_strong,
                tooltip: 'Centrar en origen (0,0)',
                onPressed: () => _centerViewOnOrigin(context, parkingState),
              ),
              _buildToolButton(
                icon: Icons.grid_on,
                tooltip: 'Mostrar/ocultar cuadrícula',
                isActive: parkingState.showGrid,
                onPressed: () => _toggleGrid(parkingState),
              ),
              _buildToolButton(
                icon: Icons.my_location,
                tooltip: 'Mostrar/ocultar coordenadas',
                isActive: parkingState.showCoordinates,
                onPressed: () => _toggleCoordinates(parkingState),
              ),
            ],
          ),
          
          // Indicador del modo actual
          const Spacer(),
          Text(
            parkingState.isEditMode ? 'Modo Edición' : 'Modo Visualización',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 16),
          
          // Contador de elementos seleccionados
          if (parkingState.selectedElements.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.3),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.select_all, color: Colors.white70, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '${parkingState.selectedElements.length} seleccionados',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
  
  // Construir un grupo de herramientas
  Widget _buildToolGroup({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF333333),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
  
  // Construir un botón de herramienta
  Widget _buildToolButton({
    required IconData icon, 
    required String tooltip, 
    VoidCallback? onPressed,
    bool isActive = false,
  }) {
    final color = isActive 
        ? Colors.blue 
        : onPressed != null ? Colors.white : Colors.white30;
        
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Icon(
              icon,
              size: 18,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
  
  // Acciones de los botones
  
  // Deshacer acción
  void _undoAction(BuildContext context, HistoryManager historyManager, ParkingState parkingState) {
    final action = historyManager.undo();
    if (action == null) return;
    
    // Aplicar la acción deshecha según su tipo
    switch (action.type) {
      case ActionType.add:
        // Eliminar elementos que se añadieron
        for (final element in action.elements) {
          parkingState.removeElement(element);
        }
        break;
        
      case ActionType.remove:
        // Restaurar elementos que se eliminaron
        for (final element in action.elements) {
          parkingState.addElement(element);
        }
        break;
        
      case ActionType.move:
        // Restaurar posición original
        final element = action.elements.first;
        final oldPosition = action.oldValues['position'] as vector_math.Vector2;
        element.position = oldPosition;
        break;
        
      case ActionType.multiMove:
        // Restaurar posiciones originales de múltiples elementos
        final oldPositions = action.oldValues['positions'] as Map<String, vector_math.Vector2>;
        for (final element in action.elements) {
          if (oldPositions.containsKey(element.id)) {
            element.position = oldPositions[element.id]!;
          }
        }
        break;
        
      case ActionType.rotate:
        // Restaurar rotación original
        final element = action.elements.first;
        final oldRotation = action.oldValues['rotation'] as double;
        element.rotation = oldRotation;
        break;
        
      case ActionType.scale:
        // Restaurar escala original
        final element = action.elements.first;
        final oldScale = action.oldValues['scale'] as double;
        element.scale = oldScale;
        break;
        
      case ActionType.edit:
        // Restaurar propiedades editadas
        final element = action.elements.first;
        action.oldValues.forEach((key, value) {
          // Manejar cada propiedad según el tipo de elemento
          if (key == 'label' && value is String) {
            element.label = value;
          }
          // Añadir más propiedades según sea necesario
        });
        break;
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Deshacer: ${action.toString()}'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  // Rehacer acción
  void _redoAction(BuildContext context, HistoryManager historyManager, ParkingState parkingState) {
    final action = historyManager.redo();
    if (action == null) return;
    
    // Aplicar la acción rehecha según su tipo
    switch (action.type) {
      case ActionType.add:
        // Añadir elementos nuevamente
        for (final element in action.elements) {
          parkingState.addElement(element);
        }
        break;
        
      case ActionType.remove:
        // Eliminar elementos nuevamente
        for (final element in action.elements) {
          parkingState.removeElement(element);
        }
        break;
        
      case ActionType.move:
        // Aplicar nueva posición
        final element = action.elements.first;
        final newPosition = action.newValues['position'] as vector_math.Vector2;
        element.position = newPosition;
        break;
        
      case ActionType.multiMove:
        // Aplicar nuevas posiciones de múltiples elementos
        final newPositions = action.newValues['positions'] as Map<String, vector_math.Vector2>;
        for (final element in action.elements) {
          if (newPositions.containsKey(element.id)) {
            element.position = newPositions[element.id]!;
          }
        }
        break;
        
      case ActionType.rotate:
        // Aplicar nueva rotación
        final element = action.elements.first;
        final newRotation = action.newValues['rotation'] as double;
        element.rotation = newRotation;
        break;
        
      case ActionType.scale:
        // Aplicar nueva escala
        final element = action.elements.first;
        final newScale = action.newValues['scale'] as double;
        element.scale = newScale;
        break;
        
      case ActionType.edit:
        // Aplicar propiedades editadas
        final element = action.elements.first;
        action.newValues.forEach((key, value) {
          // Manejar cada propiedad según el tipo de elemento
          if (key == 'label' && value is String) {
            element.label = value;
          }
          // Añadir más propiedades según sea necesario
        });
        break;
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Rehacer: ${action.toString()}'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  // Copiar elementos
  void _copyElements(BuildContext context, ClipboardManager clipboardManager, ParkingState parkingState) {
    if (parkingState.selectedElements.isEmpty) return;
    
    clipboardManager.copyElements(parkingState.selectedElements);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copiados ${clipboardManager.itemCount} elementos'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  // Pegar elementos
  void _pasteElements(
    BuildContext context, 
    ClipboardManager clipboardManager, 
    ParkingState parkingState,
    HistoryManager historyManager
  ) {
    if (!clipboardManager.hasItems) return;
    
    // Pegar en la posición actual del cursor
    final cursorPos = parkingState.cursorPosition;
    final pastedElements = clipboardManager.pasteElements(cursorPos.x, cursorPos.y);
    
    if (pastedElements.isEmpty) return;
    
    // Añadir los elementos pegados al estado
    for (final element in pastedElements) {
      parkingState.addElement(element);
    }
    
    // Seleccionar los elementos pegados
    parkingState.clearSelection();
    parkingState.selectMultipleElements(pastedElements);
    
    // Registrar acción en el historial
    for (final element in pastedElements) {
      historyManager.addElementAction(element);
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Pegados ${pastedElements.length} elementos'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  // Cortar elementos
  void _cutElements(
    BuildContext context, 
    ClipboardManager clipboardManager, 
    ParkingState parkingState,
    HistoryManager historyManager
  ) {
    if (parkingState.selectedElements.isEmpty) return;
    
    final elementsToCut = List<ParkingElement>.from(parkingState.selectedElements);
    clipboardManager.cutElements(elementsToCut);
    
    // Registrar acción en el historial antes de eliminar
    for (final element in elementsToCut) {
      historyManager.removeElementAction(element);
    }
    
    // Eliminar los elementos cortados
    for (final element in elementsToCut) {
      parkingState.removeElement(element);
    }
    
    parkingState.clearSelection();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Cortados ${elementsToCut.length} elementos'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  // Centrar vista en el origen
  void _centerViewOnOrigin(BuildContext context, ParkingState parkingState) {
    // Obtener el tamaño de la pantalla para centrar correctamente
    final size = MediaQuery.of(context).size;
    parkingState.centerViewOnOrigin(size);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Vista centrada en el origen (0,0)'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  // Alternar cuadrícula
  void _toggleGrid(ParkingState parkingState) {
    parkingState.showGrid = !parkingState.showGrid;
  }
  
  // Alternar coordenadas
  void _toggleCoordinates(ParkingState parkingState) {
    parkingState.showCoordinates = !parkingState.showCoordinates;
  }
} 