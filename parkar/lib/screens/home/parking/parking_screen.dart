import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vector_math/vector_math.dart' as vector_math;

import '../../../state/theme.dart';
import '../../../state/app_state.dart';
import '../../../state/app_state_container.dart';
import '../../../services/service_locator.dart';
import '../../../services/parking_realtime_service.dart';
import 'core/parking_state.dart';
import 'core/camera.dart';
import 'engine/game_engine.dart';
import 'widgets/index.dart';
import 'widgets/element_controls.dart';
import 'models/enums.dart';
import 'models/element_factory.dart';
import 'models/parking_elements.dart';
import 'models/parking_spot.dart';
import 'models/parking_signage.dart';
import 'models/parking_facility.dart';

/// Pantalla principal del sistema de parkeo
class ParkingScreen extends StatefulWidget {
  const ParkingScreen({Key? key}) : super(key: key);

  @override
  State<ParkingScreen> createState() => _ParkingScreenState();
}

class _ParkingScreenState extends State<ParkingScreen> with TickerProviderStateMixin {
  // Estado global del sistema de parkeo
  late ParkingState _parkingState;
  
  // Motor de juego
  late GameEngine _gameEngine;
  
  // Estado de carga
  bool _isLoading = true;
  
  // Servicio de tiempo real
  final ParkingRealtimeService _realtimeService = ParkingRealtimeService();
  
  // Estado general de la aplicación
  final AppState _appState = ServiceLocator().getAppState();
  
  @override
  void initState() {
    super.initState();
    
    // Inicializar el estado del parkeo
    _parkingState = ParkingState();
    
    // Inicializar el motor de juego
    _gameEngine = GameEngine(
      parkingState: _parkingState,
      onUpdate: () {
        if (mounted) {
          setState(() {});
        }
      },
    );
    
    // Iniciar el motor
    _gameEngine.start(this);
    
    // Cargar datos iniciales
    _loadInitialData();
    
    // Iniciar actualizaciones en tiempo real
    _initRealtimeUpdates();
  }
  
  @override
  void dispose() {
    // Detener el motor de juego
    _gameEngine.stop();
    // Detener las actualizaciones en tiempo real
    _realtimeService.stopRealtimeUpdates();
    super.dispose();
  }
  
  // Método para cargar datos iniciales
  void _loadInitialData() {
    // Intentar cargar desde la API
    Future.delayed(const Duration(milliseconds: 500), () {
      // Actualizar el estado
      _updateFromAppState();
      
      setState(() {
        _isLoading = false;
      });
      
      // Asegurar que la vista esté centrada en el origen
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Obtener el tamaño de la pantalla para una centralización óptima
        final Size screenSize = MediaQuery.of(context).size;
        _parkingState.centerViewOnOrigin(screenSize);
      });
    });
  }
  
  // Método para iniciar actualizaciones en tiempo real
  void _initRealtimeUpdates() {
    // Iniciar actualizaciones periódicas
    _realtimeService.startRealtimeUpdates(interval: const Duration(seconds: 10));
    
    // Escuchar cambios en el estado de los espacios de estacionamiento
    _realtimeService.parkingSpots.listen((spots) {
      // Actualizar spots en el estado local
      _updateParkingSpotsFromAPI(spots);
    });
  }
  
  // Método para actualizar el estado desde el estado general de la aplicación
  void _updateFromAppState() {
    if (_appState.currentLevel != null && _appState.currentParking != null) {
      // Aquí se actualizaría el estado local con datos del nivel actual
      // Por ahora, sólo mostramos mensajes informativos
      
      // También podemos cargar los elementos (spots, signs, facilities) desde el nivel
      // Esta es una implementación simulada
      
      // En una implementación real, se convertirían los datos del nivel en ParkingElement
      // Ejemplo:
      // final level = _appState.currentLevel!;
      // for (final spotData in level.spots) {
      //   final spot = ElementFactory.createSpotFromAPI(spotData);
      //   _parkingState.addSpot(spot);
      // }
      
      // Añadir datos de simulación si no hay datos reales
      if (_parkingState.spots.isEmpty) {
        _addSimulationData();
      }
    }
  }
  
  // Método para actualizar los spots desde la API
  void _updateParkingSpotsFromAPI(List<dynamic> apiSpots) {
    // Implementación simplificada para actualizar estado de ocupación
    // En una implementación real, se mapearían los SpotModel a ParkingSpot
    
    // Ejemplo usando simulación:
    for (final spot in _parkingState.spots) {
      if (spot is ParkingSpot) {
        // Simular cambios aleatorios en ocupación para demostración
        final shouldUpdate = DateTime.now().millisecondsSinceEpoch % 3 == 0;
        if (shouldUpdate) {
          // Alternar el estado de ocupación
          spot.isOccupied = !spot.isOccupied;
          if (spot.isOccupied) {
            spot.entryTime = DateTime.now();
            spot.vehiclePlate = "SIM-${(1000 + DateTime.now().second * 17) % 9999}";
          } else {
            spot.exitTime = DateTime.now();
          }
        }
      }
    }
  }
  
  // Método para añadir datos de simulación
  void _addSimulationData() {
    // Añadir algunos elementos para demostración si no hay datos reales
    // Esto sería reemplazado por datos reales de la API
    
    // Añadir algunos spots
    final spotTypes = [SpotType.vehicle, SpotType.motorcycle, SpotType.truck];
    final spotCategories = [SpotCategory.normal, SpotCategory.disabled, SpotCategory.vip];
    
    for (int i = 0; i < 10; i++) {
      final type = spotTypes[i % spotTypes.length];
      final category = spotCategories[(i ~/ 3) % spotCategories.length];
      final position = vector_math.Vector2((i - 5) * 100.0, (i % 3) * 180.0);
      
      final spot = ElementFactory.createSpot(
        position: position,
        type: type,
        category: category,
        label: 'Spot-${i + 1}',
      ) as ParkingSpot;
      
      // Algunos spots ocupados para demostración
      if (i % 3 == 0) {
        spot.isOccupied = true;
        spot.vehiclePlate = "SIM-${1000 + i * 111}";
        spot.entryTime = DateTime.now().subtract(Duration(minutes: i * 10));
      }
      
      _parkingState.addSpot(spot);
    }
    
    // Añadir algunas señalizaciones
    final signageTypes = [SignageType.entrance, SignageType.exit, SignageType.path, SignageType.info];
    
    for (int i = 0; i < 4; i++) {
      final type = signageTypes[i % signageTypes.length];
      final position = vector_math.Vector2((i - 2) * 150.0, -200.0);
      
      final signage = ElementFactory.createSignage(
        position: position,
        type: type,
      );
      
      _parkingState.addSignage(signage);
    }
    
    // Añadir algunas instalaciones
    final facilityTypes = [FacilityType.elevator, FacilityType.bathroom, FacilityType.paymentStation];
    
    for (int i = 0; i < 3; i++) {
      final type = facilityTypes[i % facilityTypes.length];
      final position = vector_math.Vector2((i - 1) * 150.0, 250.0);
      
      final facility = ElementFactory.createFacility(
        position: position,
        type: type,
        name: 'Facility-${i + 1}',
      );
      
      _parkingState.addFacility(facility);
    }
  }
  
  // Método común para manejar la adición de elementos
  void _handleAddElement<T extends ParkingElement>({
    required vector_math.Vector2 position,
    required Size elementSize,
    required T Function(vector_math.Vector2) createElement,
    required void Function(T) addToState,
  }) {
    if (!_parkingState.isEditMode) return;
    
    // Encontrar una posición óptima sin colisiones
    final optimalPosition = _parkingState.findOptimalPosition(elementSize, position);
    
    // Crear el nuevo elemento en la posición óptima
    final newElement = createElement(optimalPosition);
    
    // Asegurar que el nuevo elemento sea visible
    newElement.isVisible = true;
    
    // Añadir al estado
    addToState(newElement);
    
    // Seleccionar el nuevo elemento
    _parkingState.clearSelection();
    _parkingState.selectElement(newElement);
    
    // Registrar la acción en el historial
    _parkingState.historyManager.addElementAction(newElement);
  }
  
  // Métodos para manejar la adición de elementos
  void _handleAddSpot(SpotType type) {
    // Obtener posición del cursor en el mundo
    final cursorPos = _parkingState.cursorPosition;
    
    // Obtener tamaño del nuevo elemento
    final elementSize = ElementProperties.spotVisuals[type]!;
    final elementSizeObj = Size(elementSize.width, elementSize.height);
    
    _handleAddElement<ParkingSpot>(
      position: cursorPos,
      elementSize: elementSizeObj,
      createElement: (pos) => ElementFactory.createSpot(
        position: pos,
        type: type,
        label: 'Spot-${_parkingState.spots.length + 1}',
      ) as ParkingSpot,
      addToState: _parkingState.addSpot,
    );
  }
  
  void _handleAddSignage(SignageType type) {
    // Obtener posición del cursor en el mundo
    final cursorPos = _parkingState.cursorPosition;
    
    // Obtener tamaño del nuevo elemento
    final elementSize = ElementProperties.signageVisuals[type]!;
    final elementSizeObj = Size(elementSize.width, elementSize.height);
    
    _handleAddElement<ParkingSignage>(
      position: cursorPos,
      elementSize: elementSizeObj,
      createElement: (pos) => ElementFactory.createSignage(
        position: pos,
        type: type,
      ) as ParkingSignage,
      addToState: _parkingState.addSignage,
    );
  }
  
  void _handleAddFacility(FacilityType type) {
    // Obtener posición del cursor en el mundo
    final cursorPos = _parkingState.cursorPosition;
    
    // Obtener tamaño del nuevo elemento
    final elementSize = ElementProperties.facilityVisuals[type]!;
    final elementSizeObj = Size(elementSize.width, elementSize.height);
    
    _handleAddElement<ParkingFacility>(
      position: cursorPos,
      elementSize: elementSizeObj,
      createElement: (pos) => ElementFactory.createFacility(
        position: pos,
        type: type,
        name: '${elementSize.label} ${_parkingState.facilities.length + 1}',
      ) as ParkingFacility,
      addToState: _parkingState.addFacility,
    );
  }
  
  // Método para alternar el modo de tema
  void _toggleThemeMode() {
    final appTheme = Provider.of<AppTheme>(context, listen: false);
    appTheme.toggleThemeMode();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final appTheme = AppStateContainer.theme(context);
    final colorScheme = theme.colorScheme;
    
    return ChangeNotifierProvider.value(
      value: _parkingState,
      child: ChangeNotifierProvider.value(
        value: appTheme,
        child: Scaffold(
          body: Stack(
            children: [
              // Canvas principal del sistema de parkeo
              const ParkingCanvas(),
              
              // Barra de herramientas vertical (estilo Blender)
              const ParkingToolbar(),
              
              // Panel superior con información del estacionamiento y nivel
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Center(
                  child: FractionallySizedBox(
                    widthFactor: 0.8,
                    child: _buildParkingInfoPanel(theme, colorScheme),
                  ),
                ),
              ),
              
              // Panel de control inferior (solo visible en modo edición)
              Consumer<ParkingState>(
                builder: (context, state, _) {
                  if (state.isEditMode) {
                    return Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: SafeArea(
                        bottom: true,
                        child: Center(
                          child: ElementControlsPanel(
                            onAddSpot: _handleAddSpot,
                            onAddSignage: _handleAddSignage,
                            onAddFacility: _handleAddFacility,
                            onSaveChanges: () {
                              state.isEditMode = false;
                            },
                            onCancelChanges: () {
                              state.isEditMode = false;
                            },
                          ),
                        ),
                      ),
                    );
                  } else {
                    // Panel de estadísticas cuando no está en modo edición
                    return Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: SafeArea(
                        bottom: true,
                        child: _buildParkingStatusPanel(state, theme, colorScheme),
                      ),
                    );
                  }
                },
              ),
              
              // Botón para alternar modo oscuro/claro
              Positioned(
                top: 16,
                right: 16,
                child: SafeArea(
                  child: FloatingActionButton(
                    mini: true,
                    backgroundColor: isDarkMode 
                        ? colorScheme.primaryContainer
                        : colorScheme.primary.withOpacity(0.8),
                    onPressed: _toggleThemeMode,
                    tooltip: isDarkMode ? 'Modo claro' : 'Modo oscuro',
                    child: Icon(
                      isDarkMode ? Icons.light_mode : Icons.dark_mode,
                      color: isDarkMode ? colorScheme.onPrimaryContainer : colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
              
              // Pantalla de carga
              if (_isLoading)
                Container(
                  color: isDarkMode ? Colors.black87 : Colors.black54,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          color: colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Cargando estacionamiento...',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
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
    );
  }
  
  // Panel superior con información del estacionamiento y nivel
  Widget _buildParkingInfoPanel(ThemeData theme, ColorScheme colorScheme) {
    final parkingName = _appState.currentParking?.name ?? 'Estacionamiento';
    final levelName = _appState.currentLevel?.name ?? 'Planta principal';
    
    return Container(
      padding: const EdgeInsets.only(top: 16, bottom: 8, left: 16, right: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.brightness == Brightness.dark
                ? Colors.black.withOpacity(0.7)
                : colorScheme.primary.withOpacity(0.7),
            theme.brightness == Brightness.dark
                ? Colors.black.withOpacity(0.0)
                : colorScheme.primary.withOpacity(0.0),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              parkingName,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    offset: const Offset(0, 1),
                    blurRadius: 3.0,
                    color: Colors.black.withOpacity(0.3),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.layers,
                  size: 16,
                  color: Colors.white.withOpacity(0.9),
                ),
                const SizedBox(width: 4),
                Text(
                  levelName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                    shadows: [
                      Shadow(
                        offset: const Offset(0, 1),
                        blurRadius: 2.0,
                        color: Colors.black.withOpacity(0.3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  // Panel de estado de estacionamiento
  Widget _buildParkingStatusPanel(ParkingState state, ThemeData theme, ColorScheme colorScheme) {
    // Contar espacios ocupados y libres
    int totalSpots = 0;
    int occupiedSpots = 0;
    
    for (final element in state.spots) {
      if (element is ParkingSpot) {
        totalSpots++;
        if (element.isOccupied) {
          occupiedSpots++;
        }
      }
    }
    
    int freeSpots = totalSpots - occupiedSpots;
    double occupancyRate = totalSpots > 0 ? (occupiedSpots / totalSpots) * 100 : 0;
    
    final backgroundColor = theme.brightness == Brightness.dark 
        ? theme.cardColor.withOpacity(0.8)
        : colorScheme.surfaceVariant.withOpacity(0.9);
    
    return Container(
      color: backgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatusItem(
            Icons.check_circle_outline,
            Colors.green,
            'Espacios Libres',
            '$freeSpots',
            theme,
            colorScheme,
          ),
          _buildStatusItem(
            Icons.do_not_disturb_on_outlined,
            Colors.red,
            'Espacios Ocupados',
            '$occupiedSpots',
            theme,
            colorScheme,
          ),
          _buildStatusItem(
            Icons.pie_chart_outline,
            colorScheme.primary,
            'Ocupación',
            '${occupancyRate.toStringAsFixed(1)}%',
            theme,
            colorScheme,
          ),
        ],
      ),
    );
  }
  
  // Elemento individual del panel de estado
  Widget _buildStatusItem(IconData icon, Color color, String label, String value, ThemeData theme, ColorScheme colorScheme) {
    final textColor = theme.brightness == Brightness.dark ? Colors.white : colorScheme.onSurfaceVariant;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: textColor.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
} 