// Remove unused imports
// import 'dart:async';
import 'dart:math' as math;

// import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:parkar/models/area_model.dart';
import 'package:parkar/models/parking_model.dart';
import 'package:parkar/services/parking_service.dart';
import 'package:parkar/services/user_service.dart';
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

  // Estado de carga
  bool _isLoading = true;
  bool _isLoadingDetailed = false;

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

    // Cargar datos iniciales
    _loadInitialData();
  }

  // Método para manejar cambios en el AppState
  void _handleAppStateChange() {
    // Si cambia el ID del parking o el ID del área seleccionado, recargar los datos detallados
    if (mounted && !_isLoadingDetailed) {
      // Solo recargar si no se está cargando actualmente
      _loadDetailedParking();
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

    super.dispose();
  }

  // Método para cargar datos iniciales
  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Cargar el parking detallado
      await _loadDetailedParking();
    } finally {
      // Asegurar que se quita el estado de carga aunque haya errores
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Método para cargar el parking detallado
  Future<void> _loadDetailedParking() async {
    // Solo proceder si hay un parking seleccionado en el estado
    if (_appState.currentParking == null) {
      debugPrint('No hay parking seleccionado en el estado');
      return;
    }

    // Evitar cargas múltiples simultáneas
    if (_isLoadingDetailed) {
      debugPrint('Ya se está cargando el parking detallado');
      return;
    }

    debugPrint(
      'Iniciando carga de parking detallado: ${_appState.currentParking!.name}',
    );

    setState(() {
      _isLoadingDetailed = true;
      _isLoading = true;
    });

    try {
      // Obtener los detalles completos del estacionamiento usando el ID del modelo simple
      final parkingId = _appState.currentParking!.id;
      debugPrint('Obteniendo detalles para parking ID: $parkingId');

      _detailedParking = await _parkingService.getParkingById(parkingId);
      debugPrint('Detalles obtenidos correctamente');

      // Guardar la lista de áreas localmente
      if (_detailedParking != null && _detailedParking!.areas != null) {
        _areas = _detailedParking!.areas!;
        debugPrint('Áreas cargadas: ${_areas.length}');
      } else {
        _areas = [];
        debugPrint('El estacionamiento no tiene áreas definidas');
      }

      // Actualizar el área seleccionada si es necesario
      String? areaIdToUse = _appState.selectedAreaId;

      // Si no hay área seleccionada o el área seleccionada no pertenece a este parking,
      // seleccionar la primera área
      if (_areas.isNotEmpty) {
        bool areaExists = false;
        if (areaIdToUse != null) {
          areaExists = _areas.any((area) => area.id == areaIdToUse);
          debugPrint(
            'Verificando área seleccionada: $areaIdToUse, existe: $areaExists',
          );
        }

        if (!areaExists) {
          areaIdToUse = _areas.first.id;
          debugPrint('Seleccionando primera área: $areaIdToUse');
          _appState.setCurrentArea(areaIdToUse);
        }

        // Actualizar la vista del estacionamiento
        _updateFromDetailedParking();
        debugPrint('Vista de estacionamiento actualizada');
      } else {
        // No hay áreas, limpiar el estado
        _parkingState.clear();
        debugPrint('No hay áreas disponibles en este estacionamiento');
      }
    } catch (e) {
      debugPrint('Error al cargar el parking detallado: $e');
      // Limpiar estado en caso de error para evitar datos inconsistentes
      _parkingState.clear();
      _areas = [];

      // Re-lanzar la excepción para que sea manejada por el código que llama a este método
      rethrow;
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingDetailed = false;
        });
        debugPrint('Estado de carga finalizado');
      } else {
        debugPrint('Widget no está montado, no se actualiza el estado');
      }
    }
  }

  // Método para actualizar el estado desde el parking detallado
  void _updateFromDetailedParking() {
    if (_detailedParking != null) {
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
        debugPrint(
          'Cargando datos de área: ${area.name} del estacionamiento: ${_detailedParking!.name}',
        );

        // Cargar spots desde el área
        for (final spotData in area.spots) {
          final spot = ElementFactory.createSpot(spotData);
          // Añadir al estado
          _parkingState.addSpot(spot);
        }

        // Cargar señalización desde el área
        for (final signageData in area.signages) {
          final signage = ElementFactory.createSignage(signageData);
          // Añadir al estado
          _parkingState.addSignage(signage);
        }

        // Cargar instalaciones desde el área
        for (final facilityData in area.facilities) {
          final facility = ElementFactory.createFacility(facilityData);

          // Añadir al estado
          _parkingState.addFacility(facility);
        }
      } else {
        debugPrint('No se encontró el área seleccionada');
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
        ParkingOperationMode.visual;

    if (operationMode == ParkingOperationMode.simple) {
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
                          CircularProgressIndicator(color: colorScheme.primary),
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
                        // Panel superior con información del estacionamiento (reutilizado del modo visual)
                        _buildSimpleParkingInfoPanel(theme, colorScheme),

                        const SizedBox(height: 20),

                        // Botones principales centrados
                        Expanded(
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40.0,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(height: 20),

                                  // Botón principal de entrada
                                  SizedBox(
                                    width: double.infinity,
                                    height: 68,
                                    child: ElevatedButton.icon(
                                      icon: const Icon(Icons.login, size: 26),
                                      label: const Text(
                                        'Registrar Entrada',
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: colorScheme.primary,
                                        foregroundColor: colorScheme.onPrimary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                        elevation: 3,
                                      ),
                                      onPressed: () =>
                                          _showVisualEntryDialog(context),
                                    ),
                                  ),

                                  const SizedBox(height: 16),

                                  // Botón de salida
                                  SizedBox(
                                    width: double.infinity,
                                    height: 52,
                                    child: ElevatedButton.icon(
                                      icon: const Icon(Icons.logout, size: 22),
                                      label: const Text(
                                        'Registrar Salida',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: colorScheme.secondary,
                                        foregroundColor:
                                            colorScheme.onSecondary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        elevation: 2,
                                      ),
                                      onPressed: () =>
                                          _showVisualExitDialog(context),
                                    ),
                                  ),

                                  const SizedBox(height: 24),

                                  // Botones secundarios centrados
                                  Row(
                                    children: [
                                      Expanded(
                                        child: SizedBox(
                                          height: 44,
                                          child: ElevatedButton.icon(
                                            icon: const Icon(
                                              Icons.book_online,
                                              size: 18,
                                            ),
                                            label: const Text(
                                              'Reservar',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  colorScheme.tertiary,
                                              foregroundColor:
                                                  colorScheme.onTertiary,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            onPressed: () =>
                                                _showVisualReservationDialog(
                                                  context,
                                                ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: SizedBox(
                                          height: 44,
                                          child: ElevatedButton.icon(
                                            icon: const Icon(
                                              Icons.subscriptions,
                                              size: 18,
                                            ),
                                            label: const Text(
                                              'Suscribir',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  colorScheme.primaryContainer,
                                              foregroundColor: colorScheme
                                                  .onPrimaryContainer,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            onPressed: () =>
                                                _showVisualSubscriptionDialog(
                                                  context,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Panel de estado del parking en la parte inferior
                        _buildSimpleParkingStatusPanel(theme, colorScheme),
                      ],
                    ),
            ),
          ],
        ),
      );
    }

    return ChangeNotifierProvider.value(
      value: _parkingState,
      child: Scaffold(
        // backgroundColor: isDarkMode ? Colors.black : colorScheme.background,
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
                          child: _buildParkingInfoPanel(theme, colorScheme),
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
                                },
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),

              // Pantalla de carga
              if (_isLoading)
                Container(
                  color: isDarkMode ? Colors.black87 : Colors.black54,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: colorScheme.primary),
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
      ),
    );
  }

  // Panel superior con información del estacionamiento y nivel
  Widget _buildParkingInfoPanel(ThemeData theme, ColorScheme colorScheme) {
    final parkingName = _appState.currentParking?.name ?? 'Parqueo';
    final currentAreaId = _appState.selectedAreaId;

    // Determinar si es móvil o tablet
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    // Calcular ancho máximo del contenedor
    final containerWidth = isMobile
        ? screenWidth
        : math.min(600.0, screenWidth);

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 8 : (screenWidth - containerWidth) / 2 + 8,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? colorScheme.surface.withOpacity(0.95)
            : colorScheme.surface.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Encabezado con nombre del estacionamiento y botones
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Información del parqueo
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.local_parking,
                          size: 16,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          parkingName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                // Botones de acción
                Consumer<ParkingState>(
                  builder: (context, state, _) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Botón de editar
                        Container(
                          decoration: BoxDecoration(
                            color: state.isEditMode
                                ? colorScheme.error.withOpacity(0.1)
                                : colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: state.isEditMode
                                  ? colorScheme.error.withOpacity(0.3)
                                  : colorScheme.primary.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  state.toggleEditMode();
                                  if (state.isEditMode) {
                                    state.editorMode = EditorMode.free;
                                  }
                                });
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Icon(
                                  state.isEditMode
                                      ? Icons.close
                                      : Icons.edit_note,
                                  size: 18,
                                  color: state.isEditMode
                                      ? colorScheme.error
                                      : colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Botón de cambiar parking (solo cuando NO está en edición y hay más de un parqueo)
                        if (!state.isEditMode) ...[
                          FutureBuilder<List<dynamic>>(
                            future: AppStateContainer.di(context)
                                .resolve<UserService>()
                                .getParkings(_appState.currentUser!.id),
                            builder: (context, snapshot) {
                              if (snapshot.hasData &&
                                  snapshot.data!.length > 1) {
                                return Row(
                                  children: [
                                    const SizedBox(width: 8),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: colorScheme
                                            .surfaceContainerHighest
                                            .withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: colorScheme.outline
                                              .withOpacity(0.2),
                                          width: 1,
                                        ),
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () {
                                            _showChangeParkingDialog(context);
                                          },
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8),
                                            child: Icon(
                                              Icons.swap_horiz_rounded,
                                              size: 18,
                                              color:
                                                  colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ],

                        // Botón de guardar (solo en modo edición)
                        if (state.isEditMode) ...[
                          const SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: colorScheme.primary.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  _loadDetailedParking();
                                  setState(() {
                                    state.isEditMode = false;
                                  });
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Icon(
                                    Icons.check_rounded,
                                    size: 18,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ],
            ),
          ),

          // Pestañas para seleccionar áreas (solo si hay más de un área)
          if (_areas.length > 1)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: SizedBox(
                height: 30,
                child: Row(
                  children: [
                    Expanded(
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: _areas.map((area) {
                          final isSelected = currentAreaId == area.id;
                          return Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: GestureDetector(
                              onTap: () async {
                                if (isSelected) {
                                  return; // No hacer nada si ya está seleccionada
                                }

                                // Cambiar el área seleccionada
                                _appState.setCurrentArea(area.id);

                                // Actualizar desde el estado de la aplicación
                                _updateFromDetailedParking();
                              },
                              onLongPress: () {
                                // Mostrar diálogo para editar nombre del área solo en modo edición
                                final state = Provider.of<ParkingState>(
                                  context,
                                  listen: false,
                                );
                                if (state.isEditMode) {
                                  _showEditAreaNameDialog(area);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? colorScheme.primary
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? colorScheme.primary
                                        : colorScheme.outline.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Consumer<ParkingState>(
                                  builder: (context, state, _) {
                                    return Row(
                                      children: [
                                        Text(
                                          area.name,
                                          style: TextStyle(
                                            color: isSelected
                                                ? colorScheme.onPrimary
                                                : colorScheme.onSurface
                                                      .withOpacity(0.7),
                                            fontWeight: isSelected
                                                ? FontWeight.w500
                                                : FontWeight.normal,
                                            fontSize: 12,
                                          ),
                                        ),
                                        // Solo mostrar el botón de editar si está seleccionada y en modo edición
                                        if (isSelected && state.isEditMode) ...[
                                          const SizedBox(
                                            width: 8,
                                          ), // Aumentar la separación
                                          GestureDetector(
                                            onTap: () =>
                                                _showEditAreaNameDialog(area),
                                            child: Container(
                                              padding: const EdgeInsets.all(2),
                                              decoration: BoxDecoration(
                                                color: colorScheme.onPrimary
                                                    .withOpacity(0.2),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.edit,
                                                size: 10,
                                                color: colorScheme.onPrimary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    // Botón para añadir nueva área - pegado a los tabs
                    Consumer<ParkingState>(
                      builder: (context, state, _) {
                        if (!state.isEditMode) return const SizedBox.shrink();

                        return GestureDetector(
                          onTap: () => _showAddAreaDialog(),
                          child: Container(
                            margin: EdgeInsets
                                .zero, // Eliminar margen para pegarlo a los tabs
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: colorScheme.primary.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              Icons.add,
                              size: 16,
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Diálogo para cambiar de parqueo o nivel
  void _showChangeParkingDialog(BuildContext context) {
    _showParkingSelector(context);
  }

  // Mostrar selector de estacionamiento
  void _showParkingSelector(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Estado para controlar la expansión de los estacionamientos
    final userService = AppStateContainer.di(context).resolve<UserService>();
    final userId = _appState.currentUser!.id;

    // Usar un BuildContext específico para este diálogo
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
                    'Seleccionar Estacionamiento',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const Divider(),

                // Lista de estacionamientos desde la API
                FutureBuilder<List<dynamic>>(
                  future: userService.getParkings(userId),
                  builder: (fbContext, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: SizedBox(
                          height: 100,
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.primary.withOpacity(0.5),
                            ),
                          ),
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorScheme.errorContainer.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.error_outline, color: colorScheme.error),
                            const SizedBox(height: 8),
                            Text(
                              'Error: ${snapshot.error}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.error,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest
                              .withOpacity(0.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.local_parking_rounded,
                              color: colorScheme.onSurfaceVariant.withOpacity(
                                0.7,
                              ),
                              size: 36,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'No hay estacionamientos disponibles',
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }

                    // Convertir la lista dinámica a una lista de ParkingSimpleModel
                    final parkings = snapshot.data!
                        .map((e) => e as ParkingSimpleModel)
                        .toList();

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: parkings.length,
                      itemBuilder: (lvContext, index) {
                        final parking = parkings[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: colorScheme.outline.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: ListTile(
                            title: Text(
                              parking.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              'Selecciona para ver detalles',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            leading: Icon(
                              Icons.local_parking_rounded,
                              color: colorScheme.primary,
                            ),
                            contentPadding: const EdgeInsets.all(16),
                            onTap: () async {
                              // Cerrar el diálogo de selección primero para evitar problemas de contexto
                              Navigator.of(
                                dialogContext,
                                rootNavigator: true,
                              ).pop();

                              // Mostrar indicador de carga mientras se carga el parqueo
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                useRootNavigator: true,
                                builder: (loadingContext) => WillPopScope(
                                  onWillPop: () async =>
                                      false, // Prevenir cierre con botón atrás
                                  child: const Center(
                                    child: SizedBox(
                                      width: 40,
                                      height: 40,
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                                ),
                              );

                              try {
                                debugPrint(
                                  'Cambiando a estacionamiento: ${parking.name}',
                                );

                                // Establecer el estacionamiento simple en el estado global
                                _appState.setCurrentParking(parking);

                                // Cargar los detalles completos del estacionamiento
                                await _loadDetailedParking();

                                debugPrint(
                                  'Estacionamiento cargado correctamente',
                                );

                                // Asegurar que los diálogos se cierren correctamente
                                if (context.mounted) {
                                  // Cerrar diálogo de carga
                                  Navigator.of(
                                    context,
                                    rootNavigator: true,
                                  ).pop();

                                  // Mostrar confirmación
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Estacionamiento cambiado a: ${parking.name}',
                                      ),
                                      backgroundColor: colorScheme.primary,
                                      behavior: SnackBarBehavior.floating,
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                }
                              } catch (e) {
                                debugPrint(
                                  'Error al cambiar estacionamiento: $e',
                                );

                                // Asegurarse de que el diálogo de carga se cierre
                                if (context.mounted) {
                                  Navigator.of(
                                    context,
                                    rootNavigator: true,
                                  ).pop();
                                }

                                // Mostrar error
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Error al cargar el estacionamiento: $e',
                                      ),
                                      backgroundColor: colorScheme.error,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
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
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'El nombre del área no puede estar vacío',
                              ),
                              behavior: SnackBarBehavior.floating,
                            ),
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
    // Contar espacios ocupados y libres
    int totalSpots = 0;
    int occupiedSpots = 0;

    // Calcular tiempo promedio de estancia
    double averageStayMinutes = 0;
    int vehiclesWithStay = 0;

    for (final element in state.spots) {
      if (element is ParkingSpot) {
        totalSpots++;
        if (element.isOccupied) {
          occupiedSpots++;
          if (element.occupancy != null && element.occupancy!.access != null) {
            try {
              final stayDuration = DateTime.now().difference(
                DateTime.parse(element.occupancy!.access!.startDate),
              );
              averageStayMinutes += stayDuration.inMinutes;
              vehiclesWithStay++;
            } catch (e) {
              // If parsing fails, skip this vehicle
              debugPrint('Error parsing start date: $e');
            }
          }
        }
      }
    }

    int freeSpots = totalSpots - occupiedSpots;
    double occupancyRate = totalSpots > 0
        ? (occupiedSpots / totalSpots) * 100
        : 0;

    // Calcular promedio de estancia
    if (vehiclesWithStay > 0) {
      averageStayMinutes = averageStayMinutes / vehiclesWithStay;
    }

    // Determinar el color de ocupación basado en el porcentaje
    Color occupancyColor;
    if (occupancyRate < 50) {
      occupancyColor = Colors.green;
    } else if (occupancyRate < 80) {
      occupancyColor = Colors.orange;
    } else {
      occupancyColor = Colors.red;
    }

    // Determinar si es móvil o tablet
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    // Calcular ancho máximo del contenedor
    final containerWidth = isMobile
        ? screenWidth
        : math.min(600.0, screenWidth);

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 8 : (screenWidth - containerWidth) / 2 + 8,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? colorScheme.surface.withOpacity(0.95)
            : colorScheme.surface.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Espacios Libres
            _buildStatusItem(
              icon: Icons.check_circle_outline,
              iconColor: Colors.green,
              label: 'Libres',
              value: '$freeSpots',
              theme: theme,
              colorScheme: colorScheme,
            ),

            // Separador vertical
            Container(height: 40, width: 1, color: colorScheme.outlineVariant),

            // Espacios Ocupados
            _buildStatusItem(
              icon: Icons.car_rental,
              iconColor: Colors.red,
              label: 'Ocupados',
              value: '$occupiedSpots',
              theme: theme,
              colorScheme: colorScheme,
            ),

            // Separador vertical
            Container(height: 40, width: 1, color: colorScheme.outlineVariant),

            // Porcentaje de Ocupación
            _buildStatusItem(
              icon: Icons.pie_chart,
              iconColor: occupancyColor,
              label: 'Ocupación',
              value: '${occupancyRate.toStringAsFixed(1)}%',
              theme: theme,
              colorScheme: colorScheme,
            ),
          ],
        ),
      ),
    );
  }

  // Elemento individual del panel de estado
  Widget _buildStatusItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required ThemeData theme,
    required ColorScheme colorScheme,
  }) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icono con fondo circular suave
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: iconColor.withOpacity(0.2), width: 1),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 8),

          // Valor principal
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: theme.brightness == Brightness.dark
                  ? Colors.white
                  : colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),

          // Etiqueta
          Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Mostrar error en la UI
  Widget _buildError(
    String errorMessage,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: colorScheme.error, size: 48),
            const SizedBox(height: 16),
            Text(
              'Error',
              style: theme.textTheme.titleLarge?.copyWith(
                color: colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onErrorContainer,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _loadDetailedParking,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: FilledButton.styleFrom(
                foregroundColor: colorScheme.onError,
                backgroundColor: colorScheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEntryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final plateController = TextEditingController();
        final vehicleTypeController = TextEditingController();

        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.login, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              const Text('Registrar Entrada'),
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
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: vehicleTypeController.text.isEmpty
                    ? null
                    : vehicleTypeController.text,
                decoration: const InputDecoration(
                  labelText: 'Tipo de vehículo',
                  prefixIcon: Icon(Icons.category),
                ),
                items: const [
                  DropdownMenuItem(value: 'car', child: Text('Automóvil')),
                  DropdownMenuItem(
                    value: 'motorcycle',
                    child: Text('Motocicleta'),
                  ),
                  DropdownMenuItem(value: 'truck', child: Text('Camión')),
                  DropdownMenuItem(value: 'bicycle', child: Text('Bicicleta')),
                ],
                onChanged: (value) {
                  vehicleTypeController.text = value ?? '';
                },
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
                await _registerSimpleEntry(
                  plateController.text.trim(),
                  vehicleTypeController.text,
                );
              },
              icon: const Icon(Icons.check),
              label: const Text('Registrar'),
            ),
          ],
        );
      },
    );
  }

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final plateController = TextEditingController();

        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.logout,
                color: Theme.of(context).colorScheme.secondary,
              ),
              const SizedBox(width: 8),
              const Text('Registrar Salida'),
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
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Se calculará automáticamente el tiempo de estacionamiento y el costo',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
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
                await _registerSimpleExit(plateController.text.trim());
              },
              icon: const Icon(Icons.check),
              label: const Text('Registrar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _registerSimpleEntry(String plate, String vehicleType) async {
    // TODO: Llamar al endpoint de entrada simple (sin spot)
    // Mostrar feedback al usuario
    final vehicleTypeName = _getVehicleTypeName(vehicleType);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Entrada registrada para $plate ($vehicleTypeName)'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String _getVehicleTypeName(String vehicleType) {
    switch (vehicleType) {
      case 'car':
        return 'Automóvil';
      case 'motorcycle':
        return 'Motocicleta';
      case 'truck':
        return 'Camión';
      case 'bicycle':
        return 'Bicicleta';
      default:
        return 'Vehículo';
    }
  }

  Future<void> _registerSimpleExit(String plate) async {
    // TODO: Llamar al endpoint de salida simple (sin spot)
    // Mostrar feedback al usuario con información simulada
    final duration = Duration(
      hours: 2,
      minutes: 30,
    ); // Simular tiempo de estacionamiento
    final cost = 15.50; // Simular costo

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Salida registrada para $plate',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Tiempo: ${duration.inHours}h ${duration.inMinutes % 60}min | Costo: \$${cost.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Ver Detalles',
          textColor: Colors.white,
          onPressed: () {
            // TODO: Mostrar detalles completos
          },
        ),
      ),
    );
  }

  // Método para construir tarjetas de información
  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Método para mostrar diálogo de reserva
  void _showReservationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final plateController = TextEditingController();
        final dateController = TextEditingController();

        return AlertDialog(
          title: const Text('Crear Reserva'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: plateController,
                decoration: const InputDecoration(
                  labelText: 'Placa del vehículo',
                  prefixIcon: Icon(Icons.directions_car),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: dateController,
                decoration: const InputDecoration(
                  labelText: 'Fecha y hora',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 30)),
                  );
                  if (date != null) {
                    dateController.text =
                        '${date.day}/${date.month}/${date.year}';
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _createReservation(
                  plateController.text,
                  dateController.text,
                );
              },
              child: const Text('Reservar'),
            ),
          ],
        );
      },
    );
  }

  // Método para mostrar diálogo de suscripción
  void _showSubscriptionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final plateController = TextEditingController();
        final nameController = TextEditingController();

        return AlertDialog(
          title: const Text('Crear Suscripción'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del cliente',
                  prefixIcon: Icon(Icons.person),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: plateController,
                decoration: const InputDecoration(
                  labelText: 'Placa del vehículo',
                  prefixIcon: Icon(Icons.directions_car),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _createSubscription(
                  nameController.text,
                  plateController.text,
                );
              },
              child: const Text('Suscribir'),
            ),
          ],
        );
      },
    );
  }

  // Método para crear reserva
  Future<void> _createReservation(String plate, String date) async {
    // TODO: Implementar creación de reserva
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reserva creada para $plate el $date'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Método para crear suscripción
  Future<void> _createSubscription(String name, String plate) async {
    // TODO: Implementar creación de suscripción
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Suscripción creada para $name con placa $plate'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  // Panel de información del parking para modo simple (versión compacta)
  Widget _buildSimpleParkingInfoPanel(
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final parkingName = _appState.currentParking?.name ?? 'Parqueo';
    final currentAreaId = _appState.selectedAreaId;

    // Determinar si es móvil o tablet
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    // Calcular ancho máximo del contenedor
    final containerWidth = isMobile
        ? screenWidth
        : math.min(600.0, screenWidth);

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 8 : (screenWidth - containerWidth) / 2 + 8,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? colorScheme.surface.withOpacity(0.95)
            : colorScheme.surface.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Encabezado con nombre del estacionamiento y botones
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Información del parqueo
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.local_parking,
                          size: 16,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          parkingName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                // Botón de cambiar parking (solo si hay más de un parqueo)
                FutureBuilder<List<dynamic>>(
                  future: AppStateContainer.di(context)
                      .resolve<UserService>()
                      .getParkings(_appState.currentUser!.id),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data!.length > 1) {
                      return Container(
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest
                              .withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: colorScheme.outline.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              _showChangeParkingDialog(context);
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Icon(
                                Icons.swap_horiz_rounded,
                                size: 18,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),

          // Pestañas para seleccionar áreas (solo si hay más de un área)
          if (_areas.length > 1)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: SizedBox(
                height: 30,
                child: Row(
                  children: [
                    Expanded(
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: _areas.map((area) {
                          final isSelected = currentAreaId == area.id;
                          return Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: GestureDetector(
                              onTap: () async {
                                if (isSelected) {
                                  return; // No hacer nada si ya está seleccionada
                                }

                                // Cambiar el área seleccionada
                                _appState.setCurrentArea(area.id);

                                // Actualizar desde el estado de la aplicación
                                _updateFromDetailedParking();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? colorScheme.primary
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? colorScheme.primary
                                        : colorScheme.outline.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  area.name,
                                  style: TextStyle(
                                    color: isSelected
                                        ? colorScheme.onPrimary
                                        : colorScheme.onSurface.withOpacity(
                                            0.7,
                                          ),
                                    fontWeight: isSelected
                                        ? FontWeight.w500
                                        : FontWeight.normal,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Panel de estado del parking para modo simple (versión compacta)
  Widget _buildSimpleParkingStatusPanel(
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    // Calcular estadísticas básicas
    final totalSpots =
        _detailedParking?.totalSpots ??
        _appState.currentParking?.totalSpots ??
        0;
    final availableSpots =
        _detailedParking?.availableSpots ??
        _appState.currentParking?.availableSpots ??
        0;
    final occupiedSpots =
        _detailedParking?.occupiedSpots ??
        _appState.currentParking?.occupiedSpots ??
        0;

    final occupancyRate = totalSpots > 0
        ? (occupiedSpots / totalSpots) * 100
        : 0;

    // Determinar el color de ocupación
    Color occupancyColor;
    if (occupancyRate < 50) {
      occupancyColor = Colors.green;
    } else if (occupancyRate < 80) {
      occupancyColor = Colors.orange;
    } else {
      occupancyColor = Colors.red;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Espacios Libres
          _buildSimpleStatusItem(
            icon: Icons.check_circle_outline,
            iconColor: Colors.green,
            label: 'Libres',
            value: '$availableSpots',
            theme: theme,
            colorScheme: colorScheme,
          ),

          // Separador vertical
          Container(height: 32, width: 1, color: colorScheme.outlineVariant),

          // Espacios Ocupados
          _buildSimpleStatusItem(
            icon: Icons.car_rental,
            iconColor: Colors.red,
            label: 'Ocupados',
            value: '$occupiedSpots',
            theme: theme,
            colorScheme: colorScheme,
          ),

          // Separador vertical
          Container(height: 32, width: 1, color: colorScheme.outlineVariant),

          // Porcentaje de Ocupación
          _buildSimpleStatusItem(
            icon: Icons.pie_chart,
            iconColor: occupancyColor,
            label: 'Ocupación',
            value: '${occupancyRate.toStringAsFixed(1)}%',
            theme: theme,
            colorScheme: colorScheme,
          ),
        ],
      ),
    );
  }

  // Elemento individual del panel de estado simple
  Widget _buildSimpleStatusItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required ThemeData theme,
    required ColorScheme colorScheme,
  }) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icono con fondo circular suave
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: iconColor.withOpacity(0.2), width: 1),
            ),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(height: 6),

          // Valor principal
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: theme.brightness == Brightness.dark
                  ? Colors.white
                  : colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 2),

          // Etiqueta
          Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Métodos para mostrar diálogos del modo visual en modo simple

  // Encontrar el primer spot disponible en el orden del array
  ParkingSpot? _findFirstAvailableSpot() {
    for (final element in _parkingState.spots) {
      if (element is ParkingSpot && !element.isOccupied && element.isActive) {
        return element;
      }
    }
    return null;
  }

  // Mostrar diálogo de entrada usando el mismo del modo visual
  void _showVisualEntryDialog(BuildContext context) {
    // Buscar el primer spot disponible
    final availableSpot = _findFirstAvailableSpot();

    if (availableSpot == null) {
      // Si no hay spots disponibles, mostrar mensaje
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay espacios disponibles en este momento'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Mostrar el mismo diálogo que usa el modo visual con el spot disponible
    RegisterOccupancy.show(context, availableSpot);
  }

  // Mostrar diálogo de salida usando el mismo del modo visual
  void _showVisualExitDialog(BuildContext context) {
    // Para el modo simple, mostrar un diálogo de búsqueda de vehículo
    _showVehicleSearchDialog(context);
  }

  // Mostrar diálogo de reserva usando el mismo del modo visual
  void _showVisualReservationDialog(BuildContext context) {
    // Buscar el primer spot disponible
    final availableSpot = _findFirstAvailableSpot();

    if (availableSpot == null) {
      // Si no hay spots disponibles, mostrar mensaje
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay espacios disponibles para reservar'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Mostrar el mismo diálogo que usa el modo visual con el spot disponible
    RegisterOccupancy.show(context, availableSpot);
  }

  // Mostrar diálogo de suscripción usando el mismo del modo visual
  void _showVisualSubscriptionDialog(BuildContext context) {
    // Buscar el primer spot disponible
    final availableSpot = _findFirstAvailableSpot();

    if (availableSpot == null) {
      // Si no hay spots disponibles, mostrar mensaje
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay espacios disponibles para suscribir'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Mostrar el mismo diálogo que usa el modo visual con el spot disponible
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No hay estacionamiento seleccionado'),
            backgroundColor: Colors.red,
          ),
        );
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
            element.occupancy?.access?.vehicle?.plate == plate.toUpperCase()) {
          targetSpot = element;
          break;
        }
      }

      // Si no se encontró el spot específico, usar el primer disponible
      if (targetSpot == null) {
        targetSpot = _findFirstAvailableSpot();
      }

      if (targetSpot == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se encontró un espacio válido'),
            backgroundColor: Colors.red,
          ),
        );
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se encontró información para el vehículo $plate'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al buscar vehículo: $e'),
          backgroundColor: Colors.red,
        ),
      );
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
        ..color = colorScheme.primary.withOpacity(0.02)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), 30 + (i * 5), circlePaint);
    }

    // Dibujar líneas onduladas
    final path = Path();
    final wavePaint = Paint()
      ..color = colorScheme.secondary.withOpacity(0.02)
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
