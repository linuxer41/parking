import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/parking_state.dart';
import '../models/enums.dart';

/// Widget que muestra la barra de herramientas vertical del sistema de parkeo
class ParkingToolbar extends StatefulWidget {
  const ParkingToolbar({super.key});

  @override
  State<ParkingToolbar> createState() => _ParkingToolbarState();
}

class _ParkingToolbarState extends State<ParkingToolbar>
    with SingleTickerProviderStateMixin {
  // Estado de expansión de la barra
  bool _isExpanded = false; // Cambiado a false para iniciar contraído

  // Controlador de animación para expandir/colapsar
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();

    // Inicializar el controlador de animación
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    // Crear la animación de expansión
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    // Iniciar en estado contraído
    _animationController.value = 0.0; // Cambiado a 0.0 para iniciar contraído
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Método para alternar entre expandido/minimizado
  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      child: Consumer<ParkingState>(
        builder: (context, parkingState, child) {
          // No mostrar la barra de herramientas si no está en modo edición
          if (!parkingState.isEditMode) {
            return const SizedBox.shrink();
          }

          // Colores con el tema actual (fondo sólido)
          final backgroundColor = theme.brightness == Brightness.dark
              ? colorScheme
                    .surfaceContainerHighest // Usar color sólido para modo oscuro
              : colorScheme
                    .surfaceContainer; // Usar color sólido para modo claro

          final separatorColor = theme.brightness == Brightness.dark
              ? colorScheme.surfaceTint.withValues(alpha: 0.3)
              : colorScheme.outlineVariant;

          // Verificar si hay elementos seleccionados
          final hasSelection = parkingState.selectedElements.isNotEmpty;

          // Verificar si hay elementos en el clipboard
          final hasClipboardItems = parkingState.clipboardManager.hasItems;

          // Calcular la altura del panel superior
          // Valor fijo que asegura que no haya sobreposición con el panel superior
          double topPanelHeight = 120;

          // Añadir el padding del SafeArea en dispositivos con notch
          if (MediaQuery.of(context).padding.top > 0) {
            topPanelHeight += MediaQuery.of(context).padding.top;
          }

          // Utilizamos un Stack para contener el Positioned
          return Stack(
            children: [
              Positioned(
                left: 12,
                top: topPanelHeight, // Posicionar debajo del panel superior
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 50,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Herramientas de edición (siempre visibles)
                      _buildSectionTitle(context, 'EDICIÓN'),

                      _buildBlenderStyleButton(
                        context,
                        icon: Icons.create,
                        label: 'Libre',
                        tooltip: 'Edición libre',
                        mode: EditorMode.free,
                        parkingState: parkingState,
                        colorScheme: colorScheme,
                      ),
                      _buildBlenderStyleButton(
                        context,
                        icon: Icons.select_all,
                        label: 'Selección',
                        tooltip: 'Selección por bloques',
                        mode: EditorMode.select,
                        parkingState: parkingState,
                        colorScheme: colorScheme,
                      ),

                      // Botón para expandir/colapsar
                      _buildBlenderStyleButton(
                        context,
                        icon: _isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        label: _isExpanded ? 'Menos' : 'Más',
                        tooltip: _isExpanded
                            ? 'Mostrar menos herramientas'
                            : 'Mostrar más herramientas',
                        onPressed: _toggleExpanded,
                        colorScheme: colorScheme,
                      ),

                      // Secciones adicionales que se pueden colapsar
                      SizeTransition(
                        sizeFactor: _expandAnimation,
                        axisAlignment: -1.0,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Separador
                            _buildSeparator(context, separatorColor),

                            // Título de sección: VISTAS
                            _buildSectionTitle(context, 'VISTAS'),

                            // Herramientas de vista
                            _buildBlenderStyleButton(
                              context,
                              icon: Icons.center_focus_strong,
                              label: 'Centro',
                              tooltip: 'Centrar vista',
                              onPressed: () => parkingState.resetCamera(),
                              colorScheme: colorScheme,
                            ),
                            // Botones de zoom (activados)
                            _buildBlenderStyleButton(
                              context,
                              icon: Icons.zoom_in,
                              label: '+',
                              tooltip: 'Aumentar zoom',
                              onPressed: () {
                                // Utiliza el centro de la pantalla como punto de referencia
                                final screenCenter = Offset(
                                  MediaQuery.of(context).size.width / 2,
                                  MediaQuery.of(context).size.height / 2,
                                );
                                parkingState.zoomCamera(
                                  1.2,
                                  screenCenter,
                                ); // Factor 1.2 = +20%
                              },
                              colorScheme: colorScheme,
                            ),
                            _buildBlenderStyleButton(
                              context,
                              icon: Icons.zoom_out,
                              label: '−',
                              tooltip: 'Reducir zoom',
                              onPressed: () {
                                // Utiliza el centro de la pantalla como punto de referencia
                                final screenCenter = Offset(
                                  MediaQuery.of(context).size.width / 2,
                                  MediaQuery.of(context).size.height / 2,
                                );
                                parkingState.zoomCamera(
                                  0.8,
                                  screenCenter,
                                ); // Factor 0.8 = -20%
                              },
                              colorScheme: colorScheme,
                            ),

                            // Separador
                            _buildSeparator(context, separatorColor),

                            // Título de sección: ACCIONES
                            _buildSectionTitle(context, 'ACCIONES'),

                            // Herramientas de historia (historial) - versión mejorada
                            Row(
                              children: [
                                _buildBlenderStyleButton(
                                  context,
                                  icon: Icons.undo_rounded,
                                  label: 'Deshacer',
                                  tooltip: 'Deshacer última acción',
                                  onPressed: parkingState.historyManager.canUndo
                                      ? () => parkingState.undoLastAction()
                                      : null,
                                  colorScheme: colorScheme,
                                  isDisabled:
                                      !parkingState.historyManager.canUndo,
                                ),
                                _buildBlenderStyleButton(
                                  context,
                                  icon: Icons.redo_rounded,
                                  label: 'Rehacer',
                                  tooltip: 'Rehacer última acción',
                                  onPressed: parkingState.historyManager.canRedo
                                      ? () => parkingState.redoLastAction()
                                      : null,
                                  colorScheme: colorScheme,
                                  isDisabled:
                                      !parkingState.historyManager.canRedo,
                                ),
                              ],
                            ),

                            // Separador ligero
                            const SizedBox(height: 4),

                            // Botones de copiar/pegar - versión mejorada
                            Row(
                              children: [
                                _buildBlenderStyleButton(
                                  context,
                                  icon: Icons.content_copy_rounded,
                                  label: 'Copiar',
                                  tooltip: 'Copiar selección',
                                  onPressed: hasSelection
                                      ? () {
                                          // Implementar copia al clipboard
                                          parkingState.clipboardManager
                                              .copyElements(
                                                parkingState.selectedElements,
                                              );
                                          // Mostrar snackbar con tema personalizado
                                          final snackBar = SnackBar(
                                            content: Text(
                                              'Elementos copiados',
                                              style: TextStyle(
                                                color: colorScheme
                                                    .onInverseSurface,
                                              ),
                                            ),
                                            duration: const Duration(
                                              seconds: 1,
                                            ),
                                            backgroundColor:
                                                colorScheme.inverseSurface,
                                          );
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(snackBar);
                                        }
                                      : null,
                                  colorScheme: colorScheme,
                                  isDisabled: !hasSelection,
                                ),
                                _buildBlenderStyleButton(
                                  context,
                                  icon: Icons.content_paste_rounded,
                                  label: 'Pegar',
                                  tooltip: 'Pegar elementos copiados',
                                  onPressed: hasClipboardItems
                                      ? () {
                                          // Pegar en la posición del cursor
                                          final elements = parkingState
                                              .clipboardManager
                                              .pasteElements(
                                                parkingState.cursorPosition.x,
                                                parkingState.cursorPosition.y,
                                              );

                                          // Añadir los elementos pegados al estado
                                          for (final element in elements) {
                                            parkingState.addElement(element);
                                          }

                                          // Mostrar snackbar con tema personalizado
                                          final snackBar = SnackBar(
                                            content: Text(
                                              '${elements.length} elementos pegados',
                                              style: TextStyle(
                                                color: colorScheme
                                                    .onInverseSurface,
                                              ),
                                            ),
                                            duration: const Duration(
                                              seconds: 1,
                                            ),
                                            backgroundColor:
                                                colorScheme.inverseSurface,
                                          );
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(snackBar);
                                        }
                                      : null,
                                  colorScheme: colorScheme,
                                  isDisabled: !hasClipboardItems,
                                ),
                              ],
                            ),

                            // Separador ligero
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),
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

  // Widget para los títulos de sección
  Widget _buildSectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 2),
      child: Text(
        title,
        style: theme.textTheme.labelSmall?.copyWith(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // Widget para separadores
  Widget _buildSeparator(BuildContext context, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      child: Divider(height: 1, thickness: 1, color: color),
    );
  }

  // Widget para botones estilo Blender pero con tema actual
  Widget _buildBlenderStyleButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String tooltip,
    bool isSelected = false,
    bool isDisabled = false,
    VoidCallback? onPressed,
    EditorMode? mode,
    ParkingState? parkingState,
    required ColorScheme colorScheme,
  }) {
    // Si se proporciona un modo, verificar si está seleccionado
    if (mode != null && parkingState != null) {
      isSelected = parkingState.isEditMode && parkingState.editorMode == mode;
      onPressed = parkingState.isEditMode
          ? () => parkingState.editorMode = mode
          : null;
    }

    // Colores basados en el tema
    final selectedBgColor = colorScheme.primaryContainer;
    final selectedFgColor = colorScheme.onPrimaryContainer;
    final normalFgColor = colorScheme.onSurfaceVariant;
    final disabledFgColor = colorScheme.onSurfaceVariant.withValues(alpha: 0.5);

    return Tooltip(
      message: tooltip,
      preferBelow: false,
      verticalOffset: 20,
      child: Container(
        width: 56, // Ancho aumentado para mejor espaciado
        height: 56, // Alto aumentado para mejor espaciado
        margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? selectedBgColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8), // Bordes más redondeados
          border: Border.all(
            color: isSelected
                ? colorScheme.primary.withValues(alpha: 0.3)
                : Colors.transparent,
            width: 1,
          ),
          // Añadir sombra sutil para efecto elevado
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colorScheme.shadow.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isDisabled ? null : onPressed,
            borderRadius: BorderRadius.circular(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isDisabled
                      ? disabledFgColor
                      : (isSelected ? selectedFgColor : normalFgColor),
                  size: 22, // Iconos un poco más grandes
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: isDisabled
                        ? disabledFgColor
                        : (isSelected ? selectedFgColor : normalFgColor),
                    fontSize: 11, // Texto un poco más grande
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
