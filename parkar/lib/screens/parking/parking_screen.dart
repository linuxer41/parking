// Remove unused imports
// import 'dart:async';
import 'dart:math' as math;

// import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:parkar/models/parking_model.dart';
import 'package:parkar/services/parking_service.dart';
// import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
// generateId
import 'package:uuid/uuid.dart';

import '../../services/parking_realtime_service.dart';
import '../../services/vehicle_service.dart';
// Se ha eliminado la importación del servicio de tiempo real
import '../../services/service_locator.dart';
import '../../state/app_state.dart';
import '../../state/app_state_container.dart';
import 'core/parking_state.dart';
import 'engine/game_engine.dart';
import 'models/element_factory.dart';
import 'models/enums.dart';
import 'models/parking_facility.dart';
import 'models/parking_signage.dart';
import 'models/parking_spot.dart';
import 'widgets/element_controls.dart';
import 'widgets/parking_canvas.dart';
import 'widgets/toolbar.dart';
import 'widgets/register_occupancy.dart';
import 'widgets/manage_access.dart';
import 'widgets/manage_reservation.dart';
import 'widgets/manage_subscription.dart';
import 'widgets/vehicle_list_table.dart';
import 'widgets/parking_info_panel.dart';
import 'widgets/parking_status_panel.dart';
import '../../widgets/custom_snackbar.dart';

const uuid = Uuid();

/// Pantalla principal del sistema de parkeo
class ParkingScreen extends StatefulWidget {
  /// Flag para iniciar en modo edición automáticamente
  final bool startInEditMode;

  const ParkingScreen({super.key, this.startInEditMode = false});

  @override
  State<ParkingScreen> createState() => _ParkingScreenState();
}

class _ParkingScreenState extends State<ParkingScreen>
    with TickerProviderStateMixin {
  // Estado global del sistema de parkeo
  late ParkingState _parkingState;

  // Motor de juego
  late GameEngine _gameEngine;

  // Estado de carga simplificado - solo un estado de carga principal
  bool _isLoading = false;

  // Animaciones para el fondo
  late AnimationController _backgroundAnimationController;
  late Animation<double> _backgroundAnimation;

  // Estado general de la aplicación
  final AppState _appState = ServiceLocator().getAppState();

  // Servicio de parqueo
  late ParkingService _parkingService;

  // Datos detallados del estacionamiento
  ParkingModel? _detailedParking;

  // Lista de áreas del parking actual
  List<AreaModel> _areas = [];

  // Lista de spots ocupados para modo list
  List<ParkingSpot> _occupiedSpots = [];

  // Controlador para búsqueda
  final TextEditingController _searchController = TextEditingController();
  List<ParkingSpot> _filteredSpots = [];

  // Variable para evitar cargas repetidas del mismo parking
  String? _lastLoadedParkingId;

  // Funciones de acción para la tabla de vehículos
  void _handleAccessAction(ParkingSpot spot) {
    ManageAccess.show(context, spot);
  }

  void _handleReservationAction(ParkingSpot spot) {
    ManageReservation.show(context, spot);
  }

  void _handleSubscriptionAction(ParkingSpot spot) {
    ManageSubscription.show(context, spot);
  }

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

    // Escuchar cambios en el AppState
    _appState.addListener(_handleAppStateChange);

    // Entrar en modo edición automáticamente si se solicita
    if (widget.startInEditMode) {
      _parkingState.isEditMode = true;
      _parkingState.editorMode = EditorMode.free; // Cambiado a modo libre
    }

    // Inicializar animaciones del fondo
    _backgroundAnimationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _backgroundAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(_backgroundAnimationController);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Inicializar el servicio de parqueo
    _parkingService = AppStateContainer.di(context).resolve<ParkingService>();

    // Initialize the realtime service
    final realtimeService = ParkingRealtimeService();

    // Set up the callback for spot updates
    realtimeService.onSpotUpdate = (spotId, accessId) {
      // Handle spot update here
      // For example, update the UI to reflect the new spot status
      setState(() {
        // Update your state based on the spotId and accessId
        debugPrint('Spot $spotId updated with accessId: $accessId');

        // Here you would update the parking state with the new spot status
        // For example, find the spot in _parkingState and update its accessId
      });
    };

    // Start monitoring the current parking if available
    if (_appState.currentParking != null) {
      realtimeService.startMonitoring(_appState.currentParking!.id);
    }

    // Cargar datos iniciales solo si no se han cargado antes
    if (_lastLoadedParkingId == null) {
      _loadParkingData();
    }
  }

  // Método para manejar cambios en el AppState
  void _handleAppStateChange() {
    // Solo recargar si cambia el parking seleccionado
    if (mounted && !_isLoading) {
      final currentParkingId = _appState.currentParking?.id;
      if (currentParkingId != null &&
          currentParkingId != _lastLoadedParkingId) {
        _loadParkingData();
      }
    }
  }

  @override
  void dispose() {
    // Detener el motor de juego
    _gameEngine.stop();
    // Eliminar el listener del AppState
    _appState.removeListener(_handleAppStateChange);

    // Stop monitoring when the screen is disposed
    final realtimeService = AppStateContainer.di(
      context,
    ).resolve<ParkingRealtimeService>();
    realtimeService.stopMonitoring();

    // Dispose de las animaciones
    _backgroundAnimationController.dispose();

    // Dispose del controlador de búsqueda
    _searchController.dispose();

    super.dispose();
  }

  // Método simplificado para cargar datos del parking
  Future<void> _loadParkingData() async {
    // Solo proceder si hay un parking seleccionado
    if (_appState.currentParking == null) {
      debugPrint('No hay parking seleccionado');
      return;
    }

    // Evitar cargas múltiples simultáneas
    if (_isLoading) {
      debugPrint('Ya se está cargando el parking');
      return;
    }

    final parkingId = _appState.currentParking!.id;
    debugPrint('Cargando parking: ${_appState.currentParking!.name}');

    setState(() {
      _isLoading = true;
    });

    try {
      // Cargar el parking detallado
      _detailedParking = await _parkingService.getParkingById(parkingId);
      _lastLoadedParkingId = parkingId;

      // Cargar áreas
      if (_detailedParking != null && _detailedParking!.areas != null) {
        _areas = _detailedParking!.areas!;
        debugPrint('Áreas cargadas: ${_areas.length}');
      } else {
        _areas = [];
      }

      // Seleccionar área automáticamente si es necesario
      if (_areas.isNotEmpty) {
        String? areaIdToUse = _appState.selectedAreaId;
        bool areaExists =
            areaIdToUse != null && _areas.any((area) => area.id == areaIdToUse);

        if (!areaExists) {
          areaIdToUse = _areas.first.id;
          _appState.setCurrentArea(areaIdToUse);
        }

        // Actualizar la vista del estacionamiento
        _updateParkingView();
      } else {
        _parkingState.clear();
      }

      // Cargar spots ocupados si está en modo list
      final operationMode =
          _detailedParking?.operationMode ??
          _appState.currentParking?.operationMode ??
          ParkingOperationMode.map;

      if (operationMode == ParkingOperationMode.list) {
        _loadOccupiedSpots();
      }
    } catch (e) {
      debugPrint('Error al cargar el parking: $e');
      _parkingState.clear();
      _areas = [];
      _occupiedSpots = [];
      _filteredSpots = [];

      // Mostrar mensaje de error
      if (mounted) {
        _showErrorMessage('Error al cargar el estacionamiento: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Método simplificado para cargar spots ocupados
  void _loadOccupiedSpots() {
    _occupiedSpots = _parkingState.spots
        .where((element) => element is ParkingSpot && element.isOccupied)
        .cast<ParkingSpot>()
        .toList();
    _filteredSpots = List.from(_occupiedSpots);
    debugPrint('Spots ocupados: ${_occupiedSpots.length}');
  }

  // Método para buscar vehículos
  void _searchVehicle(String query) {
    final operationMode =
        _detailedParking?.operationMode ??
        _appState.currentParking?.operationMode ??
        ParkingOperationMode.map;

    if (operationMode == ParkingOperationMode.list) {
      // Modo list: filtrar la lista local
      setState(() {
        if (query.isEmpty) {
          _filteredSpots = List.from(_occupiedSpots);
        } else {
          _filteredSpots = _occupiedSpots.where((spot) {
            final vehiclePlate = spot.entry?.vehiclePlate;
            return vehiclePlate?.toLowerCase().contains(query.toLowerCase()) ==
                true;
          }).toList();
        }
      });
    } else {
      // Modo map: buscar en el canvas y enfocar el elemento
      _searchAndFocusInVisualMode(query);
    }
  }

  // Método para buscar y enfocar en modo map
  void _searchAndFocusInVisualMode(String query) {
    if (query.isEmpty) {
      _parkingState.clearHighlight();
      return;
    }

    // Buscar el spot que coincida con la placa
    ParkingSpot? foundSpot;
    for (final element in _parkingState.spots) {
      if (element is ParkingSpot && element.isOccupied) {
        final vehiclePlate = element.entry?.vehiclePlate;
        if (vehiclePlate?.toLowerCase().contains(query.toLowerCase()) ==
            true) {
          foundSpot = element;
          break;
        }
      }
    }

    if (foundSpot != null) {
      _parkingState.highlightElement(foundSpot.id);
      _parkingState.centerOnElement(foundSpot.position);
      _showInfoMessage(
        'Vehículo encontrado: ${foundSpot.entry?.vehiclePlate}',
      );
    } else {
      _parkingState.clearHighlight();
      _showErrorMessage('No se encontró vehículo con placa: $query');
    }
  }

  // Método simplificado para actualizar la vista del parking
  void _updateParkingView() {
    if (_detailedParking == null) return;

    // Limpiar datos existentes
    _parkingState.clear();

    // Buscar el área seleccionada
    final selectedAreaId = _appState.selectedAreaId;
    AreaModel? area;

    if (_areas.isNotEmpty) {
      area = _areas.firstWhere(
        (a) => a.id == selectedAreaId,
        orElse: () => _areas.first,
      );
    }

    if (area != null) {
      debugPrint('Cargando área: ${area.name}');

      // Cargar spots desde el área
      for (final spotData in area.spots) {
        final spot = ElementFactory.createSpot(spotData);
        _parkingState.addSpot(spot);
      }

      // Cargar señalización desde el área
      for (final signageData in area.signages) {
        final signage = ElementFactory.createSignage(signageData);
        _parkingState.addSignage(signage);
      }

      // Cargar instalaciones desde el área
      for (final facilityData in area.facilities) {
        final facility = ElementFactory.createFacility(facilityData);
        _parkingState.addFacility(facility);
      }
    }
  }

  // Método para obtener el nombre según el tipo de instalación
  String _getFacilityTypeName(FacilityType facilityType) {
    switch (facilityType) {
      case FacilityType.office:
        return 'Caja';
      case FacilityType.bathroom:
        return 'Baño';
      case FacilityType.cafeteria:
        return 'Cafetería';
      case FacilityType.elevator:
        return 'Ascensor';
      case FacilityType.stairs:
        return 'Escalera';
      case FacilityType.information:
        return 'Información';
      default:
        return 'Instalación';
    }
  }

  // Método para obtener el nombre según el tipo de spot
  String _getSpotTypeName(SpotType spotType) {
    switch (spotType) {
      case SpotType.vehicle:
        return 'Espacio';
      case SpotType.bicycle:
        return 'Bicicleta';
      case SpotType.motorcycle:
        return 'Motocicleta';
      case SpotType.truck:
        return 'Camión';
      default:
        return 'Espacio';
    }
  }

  // Método para obtener el nombre según el tipo de señalización
  String _getSignageTypeName(SignageType signageType) {
    switch (signageType) {
      case SignageType.entrance:
        return 'Entrada';
      case SignageType.exit:
        return 'Salida';
      case SignageType.direction:
        return 'Dirección';
      case SignageType.bidirectional:
        return 'Bidireccional';
      case SignageType.stop:
        return 'Pare';
      default:
        return 'Señal';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDarkMode = theme.brightness == Brightness.dark;

    final operationMode =
        _detailedParking?.operationMode ??
        _appState.currentParking?.operationMode ??
        ParkingOperationMode.map;

    // Envolver todo en el Provider para que esté disponible en toda la pantalla
    return ChangeNotifierProvider.value(
      value: _parkingState,
      child: Builder(
        builder: (context) {
          if (operationMode == ParkingOperationMode.list) {
            return Scaffold(
              body: Stack(
                children: [
                  // Fondo animado
                  AnimatedBuilder(
                    animation: _backgroundAnimation,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: AnimatedBackgroundPainter(
                          animation: _backgroundAnimation.value,
                          colorScheme: colorScheme,
                        ),
                        size: Size.infinite,
                      );
                    },
                  ),
                  // Contenido principal
                  SafeArea(
                    child: _isLoading
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  color: colorScheme.primary,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Cargando estacionamiento...',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Column(
                            children: [
                              // Panel superior con información del estacionamiento (fijo)
                              _buildParkingInfoPanel(
                                theme,
                                colorScheme,
                                operationMode == ParkingOperationMode.list,
                              ),

                              // Panel sticky con botón de entrada
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0,
                                  vertical: 12.0,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.surface,
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(16),
                                    bottomRight: Radius.circular(16),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.1,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.login, size: 20),
                                    label: const Text(
                                      'Registrar Entrada',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: colorScheme.primary,
                                      foregroundColor: colorScheme.onPrimary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      elevation: 1,
                                    ),
                                    onPressed: () =>
                                        _showVisualEntryDialog(context),
                                  ),
                                ),
                              ),

                              // Tabla de spots ocupados con scroll interno
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0,
                                    vertical: 16.0,
                                  ),
                                  child: VehicleListTable(
                                    occupiedSpots: _filteredSpots,
                                    onRefresh: () async {
                                      _loadOccupiedSpots();
                                      setState(() {});
                                    },
                                    isLoading: _isLoading,
                                    onAccessAction: _handleAccessAction,
                                    onReservationAction:
                                        _handleReservationAction,
                                    onSubscriptionAction:
                                        _handleSubscriptionAction,
                                    isSimpleMode:
                                        operationMode ==
                                        ParkingOperationMode.list,
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            );
          }

          return Scaffold(
            body: SafeArea(
              child: Stack(
                children: [
                  // Lienzo principal de dibujo del parkeo
                  Consumer<ParkingState>(
                    builder: (context, state, _) {
                      return Stack(
                        children: [
                          // Canvas principal para dibujo
                          const ParkingCanvas(),

                          // Panel de información en la parte superior
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: SafeArea(
                              child: _buildParkingInfoPanel(
                                theme,
                                colorScheme,
                                operationMode == ParkingOperationMode.list,
                              ),
                            ),
                          ),
                          // Panel con información del estado del parking en la parte inferior
                          if (!state.isEditMode)
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: SafeArea(
                                bottom: true,
                                child: _buildParkingStatusPanel(
                                  state,
                                  theme,
                                  colorScheme,
                                ),
                              ),
                            ),

                          // Panel de control de elementos en modo edición
                          if (state.isEditMode)
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: SafeArea(
                                bottom: true,
                                child: Center(
                                  child: ElementControlsPanel(
                                    onAddSpot: (spotType) {
                                      // Crear un nuevo spot en la posición del cursor
                                      final id = uuid.v4();

                                      // Contar cuántos spots del mismo tipo ya existen
                                      int count = 0;
                                      for (final element in state.spots) {
                                        if (element is ParkingSpot &&
                                            element.type == spotType) {
                                          count++;
                                        }
                                      }

                                      // Generar etiqueta con sufijo numérico
                                      String label = _getSpotTypeName(spotType);
                                      if (count > 0) {
                                        label = '$label-${count + 1}';
                                      }

                                      final spot = ParkingSpot(
                                        id: id,
                                        position: state.cursorPosition,
                                        type: spotType,
                                        label: label,
                                      );

                                      // Añadir al estado
                                      state.addElement(spot);

                                      // Actualizar automáticamente la lista
                                      _updateParkingView();
                                    },
                                    onAddSignage: (signageType) {
                                      // Crear una nueva señalización en la posición del cursor
                                      final id = uuid.v4();

                                      // Obtener el texto según el tipo de señalización (sin incremento)
                                      String text = _getSignageTypeName(
                                        signageType,
                                      );

                                      final signage = ParkingSignage(
                                        id: id,
                                        position: state.cursorPosition,
                                        type: signageType,
                                        text: text,
                                      );

                                      // Añadir al estado
                                      state.addElement(signage);

                                      // Actualizar automáticamente la lista
                                      _updateParkingView();
                                    },
                                    onAddFacility: (facilityType) {
                                      // Crear una nueva instalación en la posición del cursor
                                      final id = uuid.v4();

                                      // Contar cuántas instalaciones del mismo tipo ya existen
                                      int count = 0;
                                      for (final element in state.facilities) {
                                        if (element is ParkingFacility &&
                                            element.type == facilityType) {
                                          count++;
                                        }
                                      }

                                      // Generar nombre con sufijo numérico si ya existe una instalación del mismo tipo
                                      String name = _getFacilityTypeName(
                                        facilityType,
                                      );
                                      if (count > 0) {
                                        name = '$name-${count + 1}';
                                      }

                                      final facility = ParkingFacility(
                                        id: id,
                                        position: state.cursorPosition,
                                        type: facilityType,
                                        name: name,
                                      );

                                      // Añadir al estado
                                      state.addElement(facility);

                                      // Actualizar automáticamente la lista
                                      _updateParkingView();
                                    },
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),

                  // Pantalla de carga simplificada
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
                            const Text(
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

                  // Barra de herramientas vertical siempre al final para que esté por encima de todo
                  const ParkingToolbar(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Panel superior con información del estacionamiento y nivel
  Widget _buildParkingInfoPanel(
    ThemeData theme,
    ColorScheme colorScheme,
    bool isSimpleMode,
  ) {
    return ParkingInfoPanel(
      parkingName: _appState.currentParking?.name ?? 'Parqueo',
      currentAreaId: _appState.selectedAreaId,
      areas: _areas,
      onAreaChanged: (areaId) async {
        _appState.setCurrentArea(areaId);
        _updateParkingView();
      },
      showSearchField: true,
      searchController: _searchController,
      onSearchChanged: _searchVehicle,
      onEditAreaName: _showEditAreaNameDialog,
      onAddArea: _showAddAreaDialog,
    );
  }

  // Diálogo para editar el nombre de un área
  void _showEditAreaNameDialog(AreaModel area) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final nameController = TextEditingController(text: area.name);

    showDialog(
      context: context,
      barrierDismissible: true,
      useRootNavigator: true,
      builder: (dialogContext) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Título
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Editar Nombre del Área',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const Divider(),

                // Campo de texto para el nuevo nombre
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Nuevo Nombre del Área',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Botones de acción
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                      },
                      child: Text(
                        'Cancelar',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        // Aquí puedes guardar el nuevo nombre en el backend
                        // y luego actualizar el estado local si es necesario
                        final newName = nameController.text;
                        debugPrint('Nombre del área actualizado a: $newName');

                        // Aquí implementarías la lógica para actualizar el nombre
                        // Por ejemplo:
                        // _updateAreaName(area.id, newName);
                      },
                      child: const Text('Guardar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Diálogo para añadir una nueva área
  void _showAddAreaDialog() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final nameController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: true,
      useRootNavigator: true,
      builder: (dialogContext) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Título
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Añadir Nueva Área',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const Divider(),

                // Campo de texto para el nombre de la nueva área
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Nombre de la Nueva Área',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Botones de acción
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                      },
                      child: Text(
                        'Cancelar',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () {
                        final newAreaName = nameController.text;
                        if (newAreaName.isNotEmpty) {
                          Navigator.of(dialogContext).pop();
                          // Aquí implementarías la lógica para crear una nueva área
                          debugPrint('Nueva área añadida: $newAreaName');

                          // Por ejemplo:
                          // _createNewArea(newAreaName);
                        } else {
                          // Mostrar mensaje de error si el nombre está vacío
                          _showErrorMessage(
                            'El nombre del área no puede estar vacío',
                          );
                        }
                      },
                      child: const Text('Añadir'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Panel de estado de estacionamiento
  Widget _buildParkingStatusPanel(
    ParkingState state,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return ParkingStatusPanel(state: state);
  }

  // Método para mostrar mensajes de error con botón de cerrar
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Cerrar',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  // Método para mostrar mensajes de éxito con botón de cerrar
  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Cerrar',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  // Método para mostrar mensajes informativos con botón de cerrar
  void _showInfoMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Cerrar',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  // Encontrar el primer spot disponible en el orden del array
  ParkingSpot? _findFirstAvailableSpot() {
    for (final element in _parkingState.spots) {
      if (element is ParkingSpot && !element.isOccupied && element.isActive) {
        return element;
      }
    }
    return null;
  }

  // Mostrar diálogo de entrada usando el mismo del modo map
  void _showVisualEntryDialog(BuildContext context) {
    // Buscar el primer spot disponible
    final availableSpot = _findFirstAvailableSpot();

    if (availableSpot == null) {
      // Si no hay spots disponibles, mostrar mensaje
      _showErrorMessage('No hay espacios disponibles en este momento');
      return;
    }

    // Mostrar el mismo diálogo que usa el modo map con el spot disponible
    RegisterOccupancy.show(context, availableSpot);
  }

  // Mostrar diálogo de salida usando el mismo del modo map
  void _showVisualExitDialog(BuildContext context) {
    // Para el modo list, mostrar un diálogo de búsqueda de vehículo
    _showVehicleSearchDialog(context);
  }

  // Mostrar diálogo de reserva usando el mismo del modo map
  void _showVisualReservationDialog(BuildContext context) {
    // Buscar el primer spot disponible
    final availableSpot = _findFirstAvailableSpot();

    if (availableSpot == null) {
      // Si no hay spots disponibles, mostrar mensaje
      _showErrorMessage('No hay espacios disponibles para reservar');
      return;
    }

    // Mostrar el mismo diálogo que usa el modo map con el spot disponible
    RegisterOccupancy.show(context, availableSpot);
  }

  // Mostrar diálogo de suscripción usando el mismo del modo map
  void _showVisualSubscriptionDialog(BuildContext context) {
    // Buscar el primer spot disponible
    final availableSpot = _findFirstAvailableSpot();

    if (availableSpot == null) {
      // Si no hay spots disponibles, mostrar mensaje
      _showErrorMessage('No hay espacios disponibles para suscribir');
      return;
    }

    // Mostrar el mismo diálogo que usa el modo map con el spot disponible
    RegisterOccupancy.show(context, availableSpot);
  }

  // Diálogo de búsqueda de vehículo para salida
  void _showVehicleSearchDialog(BuildContext context) {
    final plateController = TextEditingController();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.search, color: colorScheme.primary),
            const SizedBox(width: 8),
            const Text('Buscar Vehículo'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: plateController,
              decoration: const InputDecoration(
                labelText: 'Placa del vehículo',
                prefixIcon: Icon(Icons.directions_car),
                hintText: 'ABC-123',
              ),
              textCapitalization: TextCapitalization.characters,
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              if (plateController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Por favor ingrese la placa del vehículo'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              Navigator.pop(context);
              await _searchAndShowVehicleAccess(plateController.text.trim());
            },
            icon: const Icon(Icons.search),
            label: const Text('Buscar'),
          ),
        ],
      ),
    );
  }

  // Buscar vehículo y mostrar su acceso
  Future<void> _searchAndShowVehicleAccess(String plate) async {
    try {
      final appState = AppStateContainer.of(context);
      final parkingId = appState.currentParking?.id;

      if (parkingId == null) {
        _showErrorMessage('No hay estacionamiento seleccionado');
        return;
      }

      final vehicleService = AppStateContainer.di(
        context,
      ).resolve<VehicleService>();
      final vehicle = await vehicleService.getVehicleByPlate(
        parkingId,
        plate.toUpperCase(),
      );

      if (!mounted) return;

      // Buscar el spot donde está el vehículo o usar el primer disponible
      ParkingSpot? targetSpot;

      // Primero buscar si el vehículo está en algún spot específico
      for (final element in _parkingState.spots) {
        if (element is ParkingSpot &&
            element.isOccupied &&
            element.entry?.vehiclePlate == plate.toUpperCase()) {
          targetSpot = element;
          break;
        }
      }

      // Si no se encontró el spot específico, usar el primer disponible
      if (targetSpot == null) {
        targetSpot = _findFirstAvailableSpot();
      }

      if (targetSpot == null) {
        _showErrorMessage('No se encontró un espacio válido');
        return;
      }

      // Mostrar el diálogo apropiado según el estado del vehículo
      if (vehicle.access != null) {
        // Si tiene acceso activo, mostrar diálogo de salida
        ManageAccess.show(context, targetSpot);
      } else if (vehicle.reservation != null) {
        // Si tiene reserva, mostrar diálogo de reserva
        ManageReservation.show(context, targetSpot);
      } else if (vehicle.subscription != null) {
        // Si tiene suscripción, mostrar diálogo de suscripción
        ManageSubscription.show(context, targetSpot);
      } else {
        // Si no tiene nada, mostrar mensaje
        _showInfoMessage('No se encontró información para el vehículo $plate');
      }
    } catch (e) {
      if (!mounted) return;

      _showErrorMessage('Error al buscar vehículo: $e');
    }
  }
}

// Clase para pintar el fondo animado
class AnimatedBackgroundPainter extends CustomPainter {
  final double animation;
  final ColorScheme colorScheme;

  AnimatedBackgroundPainter({
    required this.animation,
    required this.colorScheme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Dibujar círculos animados
    for (int i = 0; i < 8; i++) {
      final angle = animation + (i * math.pi / 4);
      final radius = 50 + (i * 20);
      final x = size.width / 2 + math.cos(angle) * radius;
      final y = size.height / 2 + math.sin(angle) * radius;

      final circlePaint = Paint()
        ..color = colorScheme.primary.withValues(alpha: 0.02)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), 30 + (i * 5), circlePaint);
    }

    // Dibujar líneas onduladas
    final path = Path();
    final wavePaint = Paint()
      ..color = colorScheme.secondary.withValues(alpha: 0.02)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (int i = 0; i < 3; i++) {
      path.reset();
      path.moveTo(0, size.height * (0.2 + i * 0.3));

      for (double x = 0; x < size.width; x += 20) {
        final y =
            size.height * (0.2 + i * 0.3) +
            math.sin((x + animation * 50) / 50) * 20;
        path.lineTo(x, y);
      }

      canvas.drawPath(path, wavePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
