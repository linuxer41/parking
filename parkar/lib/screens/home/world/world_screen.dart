import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:vector_math/vector_math.dart' as vector_math;

import '../../../utils/theme_helper.dart';
import 'core/index.dart';
import 'models/index.dart';
import 'widgets/world_canvas.dart';
import '../world/dialogs/spot_properties_dialog.dart';

/// Enumeración para los modos de vista
enum ViewMode { normal, editor }

/// Enumeración para las direcciones de alineación
enum AlignmentDirection { left, right, top, bottom, center }

/// Pantalla moderna y minimalista del editor de mundo
class WorldScreen extends StatefulWidget {
  const WorldScreen({Key? key}) : super(key: key);

  @override
  State<WorldScreen> createState() => _WorldScreenState();
}

class _WorldScreenState extends State<WorldScreen>
    with SingleTickerProviderStateMixin {
  // Estado global del mundo
  late WorldState _worldState;

  // Modo de interacción actual
  ViewMode _viewMode = ViewMode.normal;
  
  // Modo de edición actual
  EditorMode _editorMode = EditorMode.free;
  
  // Elementos seleccionados (tanto individual como múltiple)
  final List<WorldElement> _selectedElements = [];

  // Estado de carga
  bool _isLoading = true;
  String _loadingMessage = 'Cargando...';

  // Controlador de animación para el panel de edición
  late AnimationController _animationController;

  // Controlador de pestañas para el diálogo de agregar elementos
  int _selectedTabIndex = 0;

  // FocusNode para capturar eventos de teclado
  late FocusNode _keyboardFocusNode;


  @override
  void initState() {
    super.initState();
    // Crear el estado del mundo
    _worldState = WorldState();

    // Inicializar el controlador de animación
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    // Inicializar el FocusNode para eventos de teclado
    _keyboardFocusNode = FocusNode();

    // Configurar modo pantalla completa
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: [], // Ocultar todas las barras del sistema
    );
    
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    ));

    // Cargar datos iniciales
    _loadInitialData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Activar modo de edición aquí es seguro porque didChangeDependencies
    // se llama después de initState y el contexto ya está disponible
    if (!_worldState.isEditMode && _viewMode == ViewMode.editor) {
    _toggleEditMode();
    }
  }

  @override
  void didUpdateWidget(WorldScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Solicitar el foco para capturar eventos de teclado cuando estamos en modo edición
    if (_worldState.isEditMode && !_keyboardFocusNode.hasFocus) {
      _keyboardFocusNode.requestFocus();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  // Método para cambiar entre modo normal y editor
  void _toggleViewMode() {
    setState(() {
      if (_viewMode == ViewMode.normal) {
        _viewMode = ViewMode.editor;
        if (!_worldState.isEditMode) {
          _toggleEditMode();
        }
      } else {
        _viewMode = ViewMode.normal;
        if (_worldState.isEditMode) {
          _toggleEditMode();
        }
      }
    });
  }

  // Método para alternar el modo de edición con animación
  void _toggleEditMode() {
    setState(() {
      _worldState.toggleEditMode();

      if (_worldState.isEditMode) {
        _animationController.forward();
        // Hacer la barra de estado transparente y ocultar la barra de navegación
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarDividerColor: Colors.transparent,
        ));
        
        // Solicitar el foco para capturar eventos de teclado
        _keyboardFocusNode.requestFocus();
      } else {
        _animationController.reverse();
        // Restaurar la visibilidad de las barras del sistema
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
            overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
      }
    });
  }

  // Método para cargar datos iniciales
  Future<void> _loadInitialData() async {
    if (!mounted) return; // Verificar si el widget sigue montado

    setState(() {
      _isLoading = true;
      _loadingMessage = 'Cargando datos...';
    });

    try {
      // Simulamos la carga de datos
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        // for (final spot in spots) {
        //   _worldState.addSpot(spot);
        // }
        // for (final signage in signages) {
        //   _worldState.addSignage(signage);
        // }
        // for (final facility in facilities) {
        //   _worldState.addFacility(facility);
        // }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      // Mostrar error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar datos: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Método para mostrar diálogo de asignación de vehículo a un espacio
  void _showAssignVehicleDialog(ParkingSpot spot) {
    // Controlador para el campo de texto de la placa
    final TextEditingController plateController = TextEditingController(text: spot.vehiclePlate);
    
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          titlePadding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          title: Row(
            children: [
              Icon(
                ElementProperties.spotVisuals[spot.type]!.icon,
                color: ElementProperties.spotVisuals[spot.type]!.color,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Espacio ${spot.label}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              // Botón para editar propiedades del espacio
              IconButton(
                icon: const Icon(Icons.edit, size: 16),
                tooltip: 'Editar propiedades',
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  showSpotPropertiesDialog(spot);
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Campo para ingresar placa
              TextField(
                controller: plateController,
                decoration: const InputDecoration(
                  labelText: 'Placa del vehículo',
                  border: OutlineInputBorder(),
                  isDense: true,
                  contentPadding: EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 16),
              
              // Botones de acción
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Estado del espacio
                  Row(
                    children: [
                      Icon(
                        spot.isOccupied ? Icons.cancel : Icons.check_circle,
                        color: spot.isOccupied ? Colors.red : Colors.green,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        spot.isOccupied ? 'Ocupado' : 'Disponible',
                        style: TextStyle(
                          color: spot.isOccupied ? Colors.red : Colors.green,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('CANCELAR'),
            ),
            ElevatedButton(
              onPressed: () {
                // Actualizar el estado del spot
                final String plate = plateController.text.trim();
                if (plate.isEmpty) {
                  // Si no hay placa, marcar como disponible
                  spot.setOccupied(false, plate: null);
                } else {
                  // Si hay placa, marcar como ocupado
                  spot.setOccupied(true, plate: plate);
                }
                _worldState.notifyListeners();
                Navigator.of(dialogContext).pop();
              },
              child: const Text('GUARDAR'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ThemeHelper.isDarkMode(context);
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final primaryColor = ThemeHelper.getAccentColor(context);
    final subtleColor = ThemeHelper.getSubtleColor(context);
    
    // Actualizar el estilo de la barra de estado según el tema actual
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: ThemeHelper.getStatusBarBrightness(context),
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    ));
    
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: ThemeHelper.getStatusBarBrightness(context),
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarDividerColor: Colors.transparent,
        ),
        child: SafeArea(
          child: FocusScope(
            child: KeyboardListener(
              focusNode: _keyboardFocusNode,
              autofocus: true,
              onKeyEvent: _handleKeyboardEvent,
              child: GestureDetector(
                // Capturar taps en cualquier parte de la pantalla para mantener el foco
                onTap: () {
                  if (_worldState.isEditMode) {
                    _keyboardFocusNode.requestFocus();
                  }
                },
          child: Stack(
            children: [
                    // Canvas principal (en el fondo)
                    ChangeNotifierProvider.value(
                      value: _worldState,
                      child: WorldCanvas(
                        isEditMode: _worldState.isEditMode,
                        isDarkMode: isDarkMode,
                        showGrid: true,
                        gridSize: 20.0,
                        gridColor: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                        gridOpacity: 0.08, // Reducido para hacer la cuadrícula más sutil
                        onSpotTap: _viewMode == ViewMode.normal ? _showAssignVehicleDialog : null,
                        editorMode: _editorMode,
                        selectedElements: _selectedElements,
                        onElementsSelected: (elements) {
                          setState(() {
                            _selectedElements.clear();
                            _selectedElements.addAll(elements);
                          });
                        },
                        onEditSpotProperties: showSpotPropertiesDialog,
                      ),
                    ),

                    // Panel lateral unificado (izquierda) - Solo en modo editor
                    if (_viewMode == ViewMode.editor && _worldState.isEditMode)
                      Material(
                        type: MaterialType.transparency,
                        child: Row(
                          children: [
                            // Panel de edición vertical (izquierda)
                            Container(
                              width: 50, // Reducido de 60 a 50
                              height: double.infinity,
                              decoration: BoxDecoration(
                                color: surfaceColor,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 3,
                                    offset: const Offset(1, 0),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  // Selector de modo de edición
                                  Container(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: Column(
                                      children: [
                                        Text(
                                          'MODO',
                                          style: TextStyle(
                                            fontSize: 8,
                                            fontWeight: FontWeight.bold,
                                            color: subtleColor,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            _buildEditorModeButton(
                                              EditorMode.free,
                                              Icons.edit,
                                              'Edición libre',
                                              primaryColor,
                                            ),
                                            const SizedBox(height: 2),
                                            _buildEditorModeButton(
                                              EditorMode.selection,
                                              Icons.select_all,
                                              'Selección',
                                              primaryColor,
                                            ),
                                          ],
                                        ),
                                        const Divider(height: 8, thickness: 0.5),
                                      ],
                                    ),
                                  ),
                                  
                                  // Pestañas para elementos (integradas en la barra lateral)
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 6), // Reducido de 8 a 6
                                      child: Column(
                                        children: [
                                          // Etiqueta de la sección
                                          Text(
                                            'ELEMENTOS',
                                            style: TextStyle(
                                              fontSize: 8, // Reducido de 9 a 8
                                              fontWeight: FontWeight.bold,
                                              color: subtleColor,
                                            ),
                                          ),
                                          const SizedBox(height: 4), // Reducido de 8 a 4
                                          _buildVerticalCategoryTab(0, 'Espacios', Icons.directions_car, subtleColor),
                                          const SizedBox(height: 2), // Reducido de 4 a 2
                                          _buildVerticalCategoryTab(1, 'Señales', Icons.signpost, subtleColor),
                                          const SizedBox(height: 2), // Reducido de 4 a 2
                                          _buildVerticalCategoryTab(2, 'Instalaciones', Icons.elevator, subtleColor),
                                          
                                          // Mostrar elementos de la categoría seleccionada
                                          const Spacer(),
                                          const SizedBox(height: 4),
                                          
                                          // Mostrar elementos de la categoría seleccionada directamente en el panel lateral
                                          Expanded(
        child: Container(
                                              padding: const EdgeInsets.symmetric(vertical: 4),
                                              child: SingleChildScrollView(
                                                child: Column(
                                                  children: _buildCompactElementsForCategory(_selectedTabIndex),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Espacio vacío para permitir que el canvas sea interactivo
                            const Expanded(child: SizedBox()),
                          ],
                        ),
                      ),

                    // Panel de herramientas para elementos seleccionados (solo en modo selección)
                    if (_viewMode == ViewMode.editor && _editorMode == EditorMode.selection && _selectedElements.isNotEmpty)
                      Positioned(
                        bottom: 80,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
                              color: surfaceColor.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${_selectedElements.length} seleccionados',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: ThemeHelper.getTextColor(context),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                _buildSelectionToolButton(
                                  icon: Icons.delete,
                                  tooltip: 'Eliminar seleccionados',
                                  onPressed: _deleteSelectedElements,
                                  primaryColor: Colors.red,
                                ),
                                const SizedBox(width: 8),
                                _buildSelectionToolButton(
                                  icon: Icons.rotate_right,
                                  tooltip: 'Rotar 90°',
                                  onPressed: () => _rotateSelectedElements(90),
                                  primaryColor: primaryColor,
                                ),
                                const SizedBox(width: 8),
                                _buildSelectionToolButton(
                                  icon: Icons.align_horizontal_left,
                                  tooltip: 'Alinear a la izquierda',
                                  onPressed: () => _alignSelectedElements(AlignmentDirection.left),
                                  primaryColor: primaryColor,
                                ),
                                const SizedBox(width: 8),
                                _buildSelectionToolButton(
                                  icon: Icons.align_horizontal_right,
                                  tooltip: 'Alinear a la derecha',
                                  onPressed: () => _alignSelectedElements(AlignmentDirection.right),
                                  primaryColor: primaryColor,
                                ),
                                const SizedBox(width: 8),
                                _buildSelectionToolButton(
                                  icon: Icons.align_horizontal_center,
                                  tooltip: 'Alinear arriba',
                                  onPressed: () => _alignSelectedElements(AlignmentDirection.top),
                                  primaryColor: primaryColor,
                                ),
                                const SizedBox(width: 8),
                                _buildSelectionToolButton(
                                  icon: Icons.align_vertical_bottom,
                                  tooltip: 'Alinear abajo',
                                  onPressed: () => _alignSelectedElements(AlignmentDirection.bottom),
                                  primaryColor: primaryColor,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    // Botón para cambiar entre modos (esquina superior derecha)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Material(
                        color: Colors.transparent,
      child: InkWell(
                          onTap: _toggleViewMode,
                          borderRadius: BorderRadius.circular(8),
        child: Container(
                            padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
                              color: surfaceColor.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _viewMode == ViewMode.normal ? Icons.edit : Icons.visibility,
                                  color: primaryColor,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _viewMode == ViewMode.normal ? 'Modo Editor' : 'Modo Normal',
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Controles de zoom (esquina inferior derecha)
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: surfaceColor.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                _buildToolButton(
                                  icon: Icons.zoom_in,
                                  tooltip: 'Acercar',
                                  onPressed: () {
                                    _worldState.setZoom(_worldState.zoom * 1.2);
                                  },
                                  isSelected: false,
                                  primaryColor: primaryColor,
                                  subtleColor: subtleColor,
                                ),
                                const Divider(height: 1, thickness: 1),
                                _buildToolButton(
                                  icon: Icons.zoom_out,
                                  tooltip: 'Alejar',
                                  onPressed: () {
                                    _worldState.setZoom(_worldState.zoom / 1.2);
                                  },
                                  isSelected: false,
                                  primaryColor: primaryColor,
                                  subtleColor: subtleColor,
                                ),
                                const Divider(height: 1, thickness: 1),
                                _buildToolButton(
                                  icon: Icons.center_focus_strong,
                                  tooltip: 'Centrar y resetear zoom',
                                  onPressed: _resetViewAndZoom,
                                  isSelected: false,
                                  primaryColor: primaryColor,
                                  subtleColor: subtleColor,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Indicador de carga
                    if (_isLoading)
                      Container(
                        color: (isDarkMode ? Colors.black : Colors.white).withOpacity(0.8),
                        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
                              CircularProgressIndicator(
                                color: primaryColor,
                                strokeWidth: 2.0,
                              ),
                              const SizedBox(height: 16),
              Text(
                                _loadingMessage,
                style: TextStyle(
                                  color: ThemeHelper.getTextColor(context),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                ),
              ),
            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Maneja eventos de teclado para atajos comunes
  void _handleKeyboardEvent(KeyEvent event) {
    // Solo procesar eventos cuando se suelta la tecla para evitar repeticiones
    if (event is! KeyUpEvent) return;
    
    // Debug: Imprimir información sobre el evento de teclado
    print('KeyEvent: ${event.logicalKey.keyLabel} (${event.logicalKey})');
    print('Control pressed: ${HardwareKeyboard.instance.isControlPressed}');
    print('Shift pressed: ${HardwareKeyboard.instance.isShiftPressed}');
    
    // Solo procesar eventos en modo edición
    if (!_worldState.isEditMode) {
      print('Ignorando evento de teclado: no estamos en modo edición');
      return;
    }
    
    // Obtener el centro de la pantalla para pegar elementos
    final center = vector_math.Vector2(
      _worldState.cameraPosition.x + 200 / _worldState.zoom,
      _worldState.cameraPosition.y + 200 / _worldState.zoom,
    );
    
    // Combinaciones con Control
    if (HardwareKeyboard.instance.isControlPressed) {
      if (event.logicalKey == LogicalKeyboardKey.keyC) { // Ctrl+C - Copiar
        print('Ejecutando: Copiar');
        if (_selectedElements.isNotEmpty) {
          _worldState.copySelectedElements();
        }
      } else if (event.logicalKey == LogicalKeyboardKey.keyV) { // Ctrl+V - Pegar
        print('Ejecutando: Pegar');
        _worldState.pasteElements(center);
      } else if (event.logicalKey == LogicalKeyboardKey.keyZ) { // Ctrl+Z - Deshacer/Rehacer
        if (HardwareKeyboard.instance.isShiftPressed) {
          // Ctrl+Shift+Z - Rehacer
          print('Ejecutando: Rehacer (Ctrl+Shift+Z)');
          _worldState.redo();
        } else {
          // Ctrl+Z - Deshacer
          print('Ejecutando: Deshacer (Ctrl+Z)');
          _worldState.undo();
        }
      } else if (event.logicalKey == LogicalKeyboardKey.keyY) { // Ctrl+Y - Rehacer (alternativa)
        print('Ejecutando: Rehacer (Ctrl+Y)');
        _worldState.redo();
      }
    } else if (event.logicalKey == LogicalKeyboardKey.delete || 
               event.logicalKey == LogicalKeyboardKey.backspace) { // Teclas Delete/Backspace - Eliminar
      print('Ejecutando: Eliminar');
      if (_selectedElements.isNotEmpty) {
        _worldState.deleteSelectedElements();
      }
    }
  }

  // Widget para botones de herramientas (más compacto)
  Widget _buildToolButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    bool isSelected = false,
    required Color primaryColor,
    required Color subtleColor,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(4),
          child: Container(
            width: 32, // Reducido de 36 a 32
            height: 32, // Reducido de 36 a 32
            decoration: BoxDecoration(
              color: isSelected ? primaryColor.withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
              border: isSelected ? Border.all(color: primaryColor, width: 1) : null,
            ),
            child: Icon(
              icon,
              color: isSelected ? primaryColor : subtleColor,
              size: 16, // Reducido de 18 a 16
            ),
          ),
        ),
      ),
    );
  }

  // Método para construir pestaña de categoría vertical
  Widget _buildVerticalCategoryTab(int index, String title, IconData icon, Color subtleColor) {
    final bool isSelected = _selectedTabIndex == index;
    final Color categoryColor = index == 0
        ? ElementProperties.spacesTabColor
        : index == 1
            ? ElementProperties.signsTabColor
            : ElementProperties.facilitiesTabColor;

    return Tooltip(
      message: title,
        child: InkWell(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        borderRadius: BorderRadius.circular(4),
          child: Container(
          width: 40, // Reducido de 44 a 40
          height: 40, // Reducido de 44 a 40
            decoration: BoxDecoration(
            color: isSelected
                ? categoryColor.withOpacity(0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            border:
                isSelected ? Border.all(color: categoryColor, width: 1) : null,
            ),
            child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                size: 16, // Reducido de 18 a 16
                color: isSelected ? categoryColor : subtleColor,
                ),
              const SizedBox(height: 2),
                Text(
                title.split(' ')[0], // Solo la primera palabra
                  style: TextStyle(
                  fontSize: 8, // Reducido de 9 a 8
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? categoryColor : subtleColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Método para construir elementos según la categoría seleccionada (versión compacta para panel lateral)
  List<Widget> _buildCompactElementsForCategory(int categoryIndex) {
    switch (categoryIndex) {
      case 0: // Espacios
        return [
          _buildCompactElementButton(
            icon: ElementProperties.spotVisuals[SpotType.vehicle]!.icon,
            color: ElementProperties.spotVisuals[SpotType.vehicle]!.color,
            label: "Vehículo",
            onTap: () => _showSpotCategorySelector(SpotType.vehicle),
          ),
          const SizedBox(height: 2),
          _buildCompactElementButton(
            icon: ElementProperties.spotVisuals[SpotType.motorcycle]!.icon,
            color: ElementProperties.spotVisuals[SpotType.motorcycle]!.color,
            label: "Moto",
            onTap: () => _showSpotCategorySelector(SpotType.motorcycle),
          ),
          const SizedBox(height: 2),
          _buildCompactElementButton(
            icon: ElementProperties.spotVisuals[SpotType.truck]!.icon,
            color: ElementProperties.spotVisuals[SpotType.truck]!.color,
            label: "Camión",
            onTap: () => _showSpotCategorySelector(SpotType.truck),
          ),
        ];
      case 1: // Señales
        return [
          _buildCompactElementButton(
            icon: ElementProperties.signageVisuals[SignageType.entrance]!.icon,
            color: ElementProperties.signageVisuals[SignageType.entrance]!.color,
            label: "Entrada",
            onTap: () => _addSignage(type: SignageType.entrance),
          ),
          const SizedBox(height: 2),
          _buildCompactElementButton(
            icon: ElementProperties.signageVisuals[SignageType.exit]!.icon,
            color: ElementProperties.signageVisuals[SignageType.exit]!.color,
            label: "Salida",
            onTap: () => _addSignage(type: SignageType.exit),
          ),
          const SizedBox(height: 2),
          _buildCompactElementButton(
            icon: ElementProperties.signageVisuals[SignageType.noParking]!.icon,
            color: ElementProperties.signageVisuals[SignageType.noParking]!.color,
            label: "No Est",
            onTap: () => _addSignage(type: SignageType.noParking),
          ),
          const SizedBox(height: 2),
          _buildCompactElementButton(
            icon: ElementProperties.signageVisuals[SignageType.oneWay]!.icon,
            color: ElementProperties.signageVisuals[SignageType.oneWay]!.color,
            label: "Vía",
            onTap: () => _addSignage(type: SignageType.oneWay),
          ),
          const SizedBox(height: 2),
          _buildCompactElementButton(
            icon: ElementProperties.signageVisuals[SignageType.twoWay]!.icon,
            color: ElementProperties.signageVisuals[SignageType.twoWay]!.color,
            label: "Doble Vía",
            onTap: () => _addSignage(type: SignageType.twoWay),
          ),
        ];
      case 2: // Instalaciones
        return [
          _buildCompactElementButton(
            icon: ElementProperties.facilityVisuals[FacilityType.elevator]!.icon,
            color: ElementProperties.facilityVisuals[FacilityType.elevator]!.color,
            label: "Ascensor",
            onTap: () => _addFacility(type: FacilityType.elevator),
          ),
          const SizedBox(height: 2),
          _buildCompactElementButton(
            icon: ElementProperties.facilityVisuals[FacilityType.bathroom]!.icon,
            color: ElementProperties.facilityVisuals[FacilityType.bathroom]!.color,
            label: "Baño",
            onTap: () => _addFacility(type: FacilityType.bathroom),
          ),
          const SizedBox(height: 2),
          _buildCompactElementButton(
            icon: ElementProperties.facilityVisuals[FacilityType.payStation]!.icon,
            color: ElementProperties.facilityVisuals[FacilityType.payStation]!.color,
            label: "Caja",
            onTap: () => _addFacility(type: FacilityType.payStation),
          ),
          const SizedBox(height: 2),
          _buildCompactElementButton(
            icon: ElementProperties.facilityVisuals[FacilityType.securityOffice]!.icon,
            color: ElementProperties.facilityVisuals[FacilityType.securityOffice]!.color,
            label: "Seguridad",
            onTap: () => _addFacility(type: FacilityType.securityOffice),
          ),
        ];
      default:
        return [];
    }
  }

  // Método para construir botón de elemento compacto para el panel lateral
  Widget _buildCompactElementButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    String? label,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: 40,
          height: 42,
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 0.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: color,
                size: 18,
              ),
              if (label != null) ...[
                const SizedBox(height: 1),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 7,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Añadir espacio de estacionamiento con parámetros opcionales
  void _addSpot({
    SpotType type = SpotType.vehicle,
    SpotCategory category = SpotCategory.normal,
    String? label,
  }) {
    final center = vector_math.Vector2(
      _worldState.cameraPosition.x + 200 / _worldState.zoom,
      _worldState.cameraPosition.y + 200 / _worldState.zoom,
    );

    // Crear el espacio con etiqueta personalizada o automática
    final spot = WorldElementFactory.createSpot(
      position: center,
      label: label ?? _generateDefaultLabel(type),
      type: type,
      category: category,
      // Sin rotación inicial para mantener consistencia
      rotation: 0.0, // 0 grados en radianes
    );

    // Añadir el spot al mundo - la detección de colisiones se maneja en el WorldState
    _worldState.addSpot(spot);
    
    // En modo edición no abrimos el diálogo automáticamente
    // El usuario puede hacer clic en el elemento para editar sus propiedades
  }

  // Mostrar selector de categoría para espacios de estacionamiento
  void _showSpotCategorySelector(SpotType spotType, {ParkingSpot? existingSpot}) {
    if (existingSpot != null) {
      // Si ya existe un spot, mostrar el diálogo de propiedades directamente
      showSpotPropertiesDialog(existingSpot);
    } else {
      // Si es un nuevo spot, crearlo con valores predeterminados
      _addSpot(type: spotType);
    }
  }
  
  // Método unificado para mostrar propiedades de un spot (tanto para crear como para editar)
  void showSpotPropertiesDialog(ParkingSpot spot) {
    // Mostrar diálogo con opciones para editar el spot
    showDialog(
      context: context,
      builder: (context) => SpotPropertiesDialog(
        spot: spot,
        isEditMode: _viewMode == ViewMode.editor,
        onSave: (updatedSpot) {
          setState(() {
            // Las propiedades ya se actualizaron directamente en el objeto
            _worldState.notifyListeners();
          });
        },
      ),
    );
  }

  // Generar etiqueta predeterminada para elementos
  String _generateDefaultLabel(SpotType spotType) {
    // Prefijo según el tipo
    String prefix = '';
    
    switch (spotType) {
      case SpotType.vehicle:
        prefix = 'V-';
        break;
      case SpotType.motorcycle:
        prefix = 'M-';
        break;
      case SpotType.truck:
        prefix = 'C-';
        break;
    }
    
    // Contar espacios existentes del mismo tipo
    int count = _worldState.spots
        .where((spot) => spot.type == spotType)
        .length + 1;
    
    // Formatear el número con ceros a la izquierda (001, 002, etc.)
    String formattedCount = count.toString().padLeft(3, '0');
    
    return '$prefix$formattedCount';
  }

  // Añadir señalización con parámetros opcionales y tamaños realistas
  void _addSignage({
    SignageType type = SignageType.info,
  }) {
    final center = vector_math.Vector2(
      _worldState.cameraPosition.x + 200 / _worldState.zoom,
      _worldState.cameraPosition.y + 200 / _worldState.zoom,
    );

    // Crear la señalización con el factory y obtener etiqueta automática
    final signage = WorldElementFactory.createSignage(
      position: center,
      label: ElementProperties.signageVisuals[type]?.label ?? 'Info',
      type: type,
      // Orientación vertical (90 grados)
      rotation: 0.0, // Sin rotación inicial, se ajustará según la dirección
      direction: type == SignageType.oneWay || type == SignageType.twoWay
          ? 2
          : 0, // Dirección vertical para flechas
    );

    // La detección de colisiones se maneja en el WorldState
    _worldState.addSignage(signage);
  }

  // Añadir instalación con parámetros opcionales y tamaños realistas
  void _addFacility({
    FacilityType type = FacilityType.elevator,
  }) {
    final center = vector_math.Vector2(
      _worldState.cameraPosition.x + 200 / _worldState.zoom,
      _worldState.cameraPosition.y + 200 / _worldState.zoom,
    );

    // Crear la instalación con el factory
    final facility = WorldElementFactory.createFacility(
      position: center,
      label: ElementProperties.facilityVisuals[type]?.label ?? 'Instalación',
      type: type,
    );

    // La detección de colisiones se maneja en el WorldState
    _worldState.addFacility(facility);
  }

  // Método para resetear la vista y el zoom
  void _resetViewAndZoom() {
    // Calcular el desplazamiento necesario para volver al origen
    final currentPos = _worldState.cameraPosition;
    final delta = vector_math.Vector2(-currentPos.x, -currentPos.y);
    
    // Resetear zoom y posición
    _worldState.setZoom(1.0);
    _worldState.moveCamera(delta);
  }

  // Método para construir botón de modo de edición
  Widget _buildEditorModeButton(EditorMode mode, IconData icon, String label, Color primaryColor) {
    final bool isSelected = _editorMode == mode;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
    setState(() {
            _editorMode = mode;
          });
        },
        borderRadius: BorderRadius.circular(4),
        child: Container(
          width: 40,
          height: 36,
          decoration: BoxDecoration(
            color: isSelected ? primaryColor.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            border: isSelected ? Border.all(color: primaryColor, width: 1) : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? primaryColor : Colors.grey,
                size: 14,
              ),
              const SizedBox(height: 2),
              Text(
                label.split(' ')[0], // Solo la primera palabra para hacerlo más compacto
                style: TextStyle(
                  fontSize: 7,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? primaryColor : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget para botones de herramientas de selección
  Widget _buildSelectionToolButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    required Color primaryColor,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(4),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              icon,
              color: primaryColor,
              size: 18,
            ),
          ),
        ),
      ),
    );
  }

  // Método para eliminar elementos seleccionados
  void _deleteSelectedElements() {
    if (_selectedElements.isEmpty) return;
    
    _worldState.deleteSelectedElements();
    
    setState(() {
      _selectedElements.clear();
    });
  }

  // Método para rotar elementos seleccionados
  void _rotateSelectedElements(double degrees) {
    if (_selectedElements.isEmpty) return;
    
    final double radians = degrees * (3.14159 / 180);
    
    // Usar el nuevo método que verifica colisiones
    _worldState.rotateSelectedElementsWithAngle(radians);
  }

  // Método para alinear elementos seleccionados
  void _alignSelectedElements(AlignmentDirection direction) {
    if (_selectedElements.length <= 1) return;
    
    // Convertir la dirección a string para el nuevo método
    String directionStr;
    switch (direction) {
      case AlignmentDirection.left:
        directionStr = 'left';
        break;
      case AlignmentDirection.right:
        directionStr = 'right';
        break;
      case AlignmentDirection.top:
        directionStr = 'top';
        break;
      case AlignmentDirection.bottom:
        directionStr = 'bottom';
        break;
      case AlignmentDirection.center:
        directionStr = 'center';
        break;
    }
    
    // Usar el nuevo método que verifica colisiones
    _worldState.alignSelectedElements(directionStr);
  }
}
