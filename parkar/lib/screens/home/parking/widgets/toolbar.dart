import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/parking_state.dart';
import '../models/enums.dart';

/// Widget que muestra la barra de herramientas vertical del sistema de parkeo
class ParkingToolbar extends StatelessWidget {
  const ParkingToolbar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<ParkingState>(
        builder: (context, parkingState, child) {
          // Utilizamos un Stack para contener el Positioned
          return Stack(
            children: [
              Positioned(
                left: 12,
                top: 16,
                child: Container(
                  width: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF303030), // Color gris oscuro similar a Blender
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 4),
                      
                      // Botón de modo edición (siempre visible)
                      _buildBlenderStyleButton(
                        context,
                        icon: Icons.edit,
                        label: 'Editar',
                        tooltip: 'Modo de edición',
                        isSelected: parkingState.isEditMode,
                        onPressed: () => parkingState.toggleEditMode(),
                      ),
                      
                      // Separador
                      if (parkingState.isEditMode) 
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 2),
                          child: Divider(
                            height: 1,
                            thickness: 1,
                            color: Color(0xFF232323),
                          ),
                        ),
                      
                      // Solo mostrar estos botones cuando está en modo edición
                      if (parkingState.isEditMode) ...[
                        // Herramientas de transformación principales
                        _buildBlenderStyleButton(
                          context,
                          icon: Icons.open_with,
                          label: 'Libre',
                          tooltip: 'Edición libre',
                          mode: EditorMode.free,
                          parkingState: parkingState,
                        ),
                        _buildBlenderStyleButton(
                          context,
                          icon: Icons.select_all,
                          label: 'Select',
                          tooltip: 'Selección por bloques',
                          mode: EditorMode.select,
                          parkingState: parkingState,
                        ),
                        
                        // Separador
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 2),
                          child: Divider(
                            height: 1,
                            thickness: 1,
                            color: Color(0xFF232323),
                          ),
                        ),
                        
                        // Reiniciar cámara
                        _buildBlenderStyleButton(
                          context,
                          icon: Icons.center_focus_strong,
                          label: 'Centro',
                          tooltip: 'Centrar vista',
                          onPressed: () => parkingState.resetCamera(),
                        ),
                      ],
                      
                      const SizedBox(height: 4),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildBlenderStyleButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String tooltip,
    bool isSelected = false,
    VoidCallback? onPressed,
    EditorMode? mode,
    ParkingState? parkingState,
  }) {
    // Si se proporciona un modo, verificar si está seleccionado
    if (mode != null && parkingState != null) {
      isSelected = parkingState.isEditMode && parkingState.editorMode == mode;
      onPressed = parkingState.isEditMode
          ? () => parkingState.editorMode = mode
          : null;
    }
    
    return Tooltip(
      message: tooltip,
      preferBelow: false,
      verticalOffset: 20,
      child: Container(
        width: 42,
        height: 42,
        margin: const EdgeInsets.symmetric(vertical: 1, horizontal: 3),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3D7EDB) : Colors.transparent,
          borderRadius: BorderRadius.circular(3),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(3),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isSelected 
                      ? Colors.white 
                      : const Color(0xFFAAAAAA),
                  size: 16,
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected 
                        ? Colors.white 
                        : const Color(0xFFAAAAAA),
                    fontSize: 8,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 