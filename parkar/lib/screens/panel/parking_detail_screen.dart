import 'package:flutter/material.dart';
import '../../models/employee_model.dart';
import '../../models/parking_model.dart';
import '../../services/parking_service.dart';
import '../../state/app_state_container.dart';
import '../parking/parking_screen.dart';
import '../../widgets/custom_operation_mode_selector.dart';
import '../../widgets/custom_capacity_input.dart';
import '../../widgets/custom_address_input.dart';

import 'parking_rates_screen.dart';

/// Pantalla para mostrar los detalles completos de un estacionamiento
class ParkingDetailScreen extends StatefulWidget {
  final String parkingId;
  final String parkingName;

  const ParkingDetailScreen({
    super.key,
    required this.parkingId,
    required this.parkingName,
  });

  @override
  State<ParkingDetailScreen> createState() => _ParkingDetailScreenState();
}

class _ParkingDetailScreenState extends State<ParkingDetailScreen> {
  late ParkingService _parkingService;
  bool _isLoading = true;
  ParkingModel? _parking;
  String? _error;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _parkingService = AppStateContainer.di(context).resolve<ParkingService>();
    _loadParkingDetails();
  }

  // Cargar los detalles del estacionamiento
  Future<void> _loadParkingDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Obtener detalles completos del parking
      final parkingDetails = await _parkingService.getParkingById(
        widget.parkingId,
      );

      if (mounted) {
        setState(() {
          _parking = parkingDetails;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error al cargar detalles: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  // Refrescar los detalles del estacionamiento
  Future<void> _refreshParkingDetails() async {
    await _loadParkingDetails();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Aparcamiento',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: colorScheme.primary),
                    const SizedBox(height: 16),
                    Text(
                      'Cargando detalles...',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              )
            : _error != null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error al cargar',
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: _refreshParkingDetails,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reintentar'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : _parking == null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.local_parking_outlined,
                        size: 64,
                        color: colorScheme.outline,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No se encontró información',
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No se encontró información del estacionamiento',
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : RefreshIndicator(
                onRefresh: _refreshParkingDetails,
                child: _buildParkingDetailContent(context),
              ),
      ),
    );
  }

  Widget _buildParkingDetailContent(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return ListView(
      padding: const EdgeInsets.all(24.0),
      children: [
        // Sección de información general
        Card(
          margin: const EdgeInsets.only(bottom: 24),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con nombre y botón editar
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _parking!.name,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _showEditDialog,
                      icon: Icon(
                        Icons.edit_outlined,
                        size: 20,
                        color: colorScheme.primary,
                      ),
                      tooltip: 'Editar',
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Detalles de contacto con iconos
                _buildInfoRowWithIcon(
                  context,
                  'Dirección',
                  _parking!.address ?? 'No especificada',
                  Icons.location_on_outlined,
                ),
                const SizedBox(height: 16),

                // Teléfono
                _buildInfoRowWithIcon(
                  context,
                  'Teléfono',
                  _parking!.phone ?? 'No especificado',
                  Icons.phone_outlined,
                ),

                // Coordenadas
                if (_parking!.latitude != null && _parking!.longitude != null)
                  _buildInfoRowWithIcon(
                    context,
                    'Ubicación',
                    'Lat: ${_parking!.latitude}, Long: ${_parking!.longitude}',
                    Icons.pin_drop_outlined,
                  ),

                // Modo de operación con chips
                _buildOperationModeChips(context),
                const SizedBox(height: 16),

                // Capacidad y Estado en 2 columnas
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildCapacityRow(context)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildStatusToggle(context)),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Sección de parámetros
        _buildSectionHeader(
          context,
          'Parámetros',
          Icons.settings_outlined,
          onAction: () => _showEditParametersDialog(),
          actionLabel: 'Editar',
        ),
        Card(
          margin: const EdgeInsets.only(bottom: 24),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Primera fila: País
                _buildCountryInfoRow(context),
                const SizedBox(height: 16),

                // Segunda fila: Zona horaria
                _buildInfoRowWithIcon(
                  context,
                  'Zona horaria',
                  _parking!.params.timeZone ?? 'No especificada',
                  Icons.schedule,
                ),
                const SizedBox(height: 16),

                // Tercera fila: Moneda y Decimales
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildInfoRowWithIcon(
                        context,
                        'Moneda',
                        _parking!.params.currency,
                        Icons.currency_exchange,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInfoRowWithIcon(
                        context,
                        'Decimales',
                        _parking!.params.decimalPlaces.toString(),
                        Icons.numbers,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Botones de acción principales
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                context,
                'Tarifas',
                Icons.attach_money,
                () => _navigateToRates(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                context,
                'Empleados',
                Icons.people_outline,
                () => _showEmployeesDialog(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Botón de layout solo si el modo de operación es visual
        if (_parking?.operationMode == ParkingOperationMode.visual)
          _buildActionButton(
            context,
            'Layout',
            Icons.grid_on_outlined,
            () => _navigateToDesign(),
            isFullWidth: true,
          ),

        // Espacio al final
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onPressed, {
    bool isFullWidth = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon, {
    VoidCallback? onAction,
    String? actionLabel,
    IconData? actionIcon,
  }) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          if (onAction != null)
            TextButton.icon(
              onPressed: onAction,
              icon: Icon(actionIcon ?? Icons.edit, size: 16),
              label: Text(actionLabel ?? 'Editar'),
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                foregroundColor: colorScheme.primary,
              ),
            ),
        ],
      ),
    );
  }

  // Método para construir chips de modo de operación
  Widget _buildOperationModeChips(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.settings_outlined, size: 20, color: colorScheme.primary),
            const SizedBox(width: 16),
            Text(
              'Modo de operación',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ParkingOperationMode.values.map((mode) {
            final isSelected = _parking!.operationMode == mode;
            return FilterChip(
              selected: isSelected,
              label: Text(
                mode.displayName,
                style: textTheme.bodySmall?.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurface,
                ),
              ),
              onSelected: null, // No editable en vista de detalles
              backgroundColor: colorScheme.surfaceContainerHighest,
              selectedColor: colorScheme.primaryContainer,
              checkmarkColor: colorScheme.onPrimaryContainer,
              side: BorderSide(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.outline.withValues(alpha: 60),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // Método para construir fila de capacidad con "vehículos" inline
  Widget _buildCapacityRow(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.directions_car_outlined,
            size: 20,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Capacidad',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      _parking!.capacity?.toString() ?? 'No especificada',
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'vehículos',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant.withValues(
                          alpha: 80,
                        ),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Método para construir indicador de estado
  Widget _buildStatusToggle(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final isActive = _parking!.isActive ?? true;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.power_settings_new_outlined,
            size: 20,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estado',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    // Indicador visual de estado
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive
                            ? colorScheme.primary
                            : colorScheme.outline,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isActive ? 'Activo' : 'Inactivo',
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Método para construir fila de información del país con bandera
  Widget _buildCountryInfoRow(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    final countryCode = _parking!.params.countryCode;
    final countryName = _getCountryName(countryCode);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.flag_outlined, size: 20, color: colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'País',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (countryCode != null && countryCode.isNotEmpty)
                      Container(
                        width: 24,
                        height: 16,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          border: Border.all(
                            color: colorScheme.outline.withValues(alpha: 60),
                            width: 0.5,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: _buildFlagEmoji(countryCode),
                        ),
                      ),
                    if (countryCode != null && countryCode.isNotEmpty)
                      const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        countryName,
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Método para obtener el nombre del país
  String _getCountryName(String? countryCode) {
    if (countryCode == null || countryCode.isEmpty) {
      return 'No especificado';
    }

    final countries = {
      'US': 'Estados Unidos',
      'MX': 'México',
      'ES': 'España',
      'AR': 'Argentina',
      'BR': 'Brasil',
      'CO': 'Colombia',
      'PE': 'Perú',
      'CL': 'Chile',
      'VE': 'Venezuela',
      'EC': 'Ecuador',
      'BO': 'Bolivia',
      'PY': 'Paraguay',
      'UY': 'Uruguay',
      'GT': 'Guatemala',
      'HN': 'Honduras',
      'SV': 'El Salvador',
      'NI': 'Nicaragua',
      'CR': 'Costa Rica',
      'PA': 'Panamá',
      'CU': 'Cuba',
      'DO': 'República Dominicana',
      'PR': 'Puerto Rico',
      'CA': 'Canadá',
      'FR': 'Francia',
      'DE': 'Alemania',
      'IT': 'Italia',
      'GB': 'Reino Unido',
      'JP': 'Japón',
      'CN': 'China',
      'KR': 'Corea del Sur',
      'AU': 'Australia',
    };

    return countries[countryCode] ?? countryCode;
  }

  // Método para construir la bandera como emoji
  Widget _buildFlagEmoji(String countryCode) {
    // Convertir código de país a emoji de bandera
    final flagEmoji = _countryCodeToFlagEmoji(countryCode);

    return Center(child: Text(flagEmoji, style: const TextStyle(fontSize: 12)));
  }

  // Método para convertir código de país a emoji de bandera
  String _countryCodeToFlagEmoji(String countryCode) {
    // Convertir código de país a emoji de bandera
    // Los emojis de bandera usan códigos regionales (2 letras)
    final codePoints = countryCode
        .toUpperCase()
        .split('')
        .map((char) => 127397 + char.codeUnitAt(0))
        .toList();

    return String.fromCharCodes(codePoints);
  }

  // Método para construir filas de información con iconos
  Widget _buildInfoRowWithIcon(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Navegar a la pantalla de tarifas
  void _navigateToRates() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    try {
      if (_parking == null) {
        throw Exception('No hay información del estacionamiento cargada');
      }

      final parkingId = int.tryParse(_parking!.id);
      if (parkingId == null) {
        throw Exception('ID de estacionamiento inválido');
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ParkingRatesScreen(
            parkingId: parkingId,
            parkingName: _parking!.name,
          ),
        ),
      ).then((_) => _refreshParkingDetails());
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al abrir tarifas: ${e.toString()}'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: colorScheme.error,
        ),
      );
    }
  }

  // Navegar a la pantalla de diseño
  void _navigateToDesign() {
    // Establecer el parking actual en el AppState
    final appState = AppStateContainer.of(context);

    // Actualizar el estado con el parking seleccionado
    if (_parking != null) {
      appState.setCurrentParking(
        ParkingSimpleModel.fromParkingModel(_parking!),
      );

      // Si hay áreas disponibles, seleccionar la primera
      if (_parking!.areas != null && _parking!.areas!.isNotEmpty) {
        appState.setCurrentArea(_parking!.areas!.first.id);
      }

      // Navegar a la pantalla de parking en modo edición
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ParkingScreen(startInEditMode: true),
        ),
      ).then((_) => _refreshParkingDetails());
    }
  }

  // Mostrar diálogo para editar el estacionamiento
  void _showEditDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _EditParkingScreen(
          parking: _parking!,
          onSave: () => _refreshParkingDetails(),
        ),
      ),
    );
  }

  // Mostrar pantalla de empleados
  void _showEmployeesDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _EmployeesScreen(
          parking: _parking!,
          onSave: () => _refreshParkingDetails(),
        ),
      ),
    );
  }

  // Mostrar pantalla de edición de parámetros
  void _showEditParametersDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _EditParametersScreen(
          parking: _parking!,
          onSave: () => _refreshParkingDetails(),
        ),
      ),
    );
  }
}

// Pantalla para editar información del estacionamiento
class _EditParkingScreen extends StatefulWidget {
  final ParkingModel parking;
  final VoidCallback onSave;

  const _EditParkingScreen({required this.parking, required this.onSave});

  @override
  State<_EditParkingScreen> createState() => _EditParkingScreenState();
}

class _EditParkingScreenState extends State<_EditParkingScreen> {
  late TextEditingController nameController;
  late TextEditingController addressController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController sloganController;
  late TextEditingController capacityController;
  late bool isActive;
  late ParkingOperationMode operationMode;
  bool _isLoading = false;
  String? _error;
  late ParkingService _parkingService;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.parking.name);
    addressController = TextEditingController(
      text: widget.parking.address ?? '',
    );
    emailController = TextEditingController(text: widget.parking.email ?? '');
    phoneController = TextEditingController(text: widget.parking.phone ?? '');
    sloganController = TextEditingController(
      text: widget.parking.params.slogan ?? '',
    );
    capacityController = TextEditingController(
      text: widget.parking.capacity?.toString() ?? '',
    );
    isActive = widget.parking.isActive ?? true;
    operationMode = widget.parking.operationMode ?? ParkingOperationMode.visual;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _parkingService = AppStateContainer.di(context).resolve<ParkingService>();
  }

  @override
  void dispose() {
    nameController.dispose();
    addressController.dispose();
    emailController.dispose();
    phoneController.dispose();
    sloganController.dispose();
    capacityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Editar Estacionamiento',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        actions: [
          TextButton.icon(
            onPressed: _isLoading ? null : _saveParking,
            icon: _isLoading
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.primary,
                    ),
                  )
                : Icon(Icons.save, size: 18, color: colorScheme.primary),
            label: Text(
              _isLoading ? 'Guardando...' : 'Guardar',
              style: textTheme.labelMedium?.copyWith(
                color: colorScheme.primary,
              ),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_error != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.errorContainer.withValues(
                          alpha: 127,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: colorScheme.error),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _error!,
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Campo de nombre del aparcamiento
                  _buildTextField(
                    controller: nameController,
                    label: 'Nombre del estacionamiento',
                    icon: Icons.local_parking_outlined,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa el nombre';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Segunda fila: Dirección con botón de mapa
                  CustomAddressInput(
                    addressController: addressController,
                    labelText: 'Dirección',
                    hintText: 'Ingresa la dirección del estacionamiento',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa la dirección';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Tercera fila: Teléfono y Capacidad
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: phoneController,
                          label: 'Teléfono',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CustomCapacityInput(
                          controller: capacityController,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Cuarta fila: Slogan
                  _buildTextField(
                    controller: sloganController,
                    label: 'Slogan',
                    icon: Icons.tag_outlined,
                  ),
                  const SizedBox(height: 20),

                  // Quinta fila: Modo de operación
                  CustomOperationModeSelector(
                    selectedMode: operationMode,
                    onModeChanged: (mode) {
                      setState(() {
                        operationMode = mode;
                      });
                    },
                    label: 'Modo de Operación',
                  ),
                  const SizedBox(height: 20),

                  // Sexta fila: Switch de estado
                  _buildSwitchTile(),
                ],
              ),
            ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? suffixText,
    String? hintText,
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(icon, size: 18, color: colorScheme.onSurfaceVariant),
        suffixText: suffixText,
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: textTheme.bodyMedium,
    );
  }

  Widget _buildSwitchTile() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            Icons.power_settings_new_outlined,
            color: colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estacionamiento activo',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Determina si el estacionamiento está abierto al público',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isActive,
            onChanged: (value) {
              setState(() {
                isActive = value;
              });
            },
            activeColor: colorScheme.primary,
            activeTrackColor: colorScheme.primaryContainer,
            inactiveThumbColor: colorScheme.outline,
            inactiveTrackColor: colorScheme.surfaceContainerHighest,
          ),
        ],
      ),
    );
  }

  Future<void> _saveParking() async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Validar campos
    if (nameController.text.isEmpty || addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor completa los campos requeridos'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: colorScheme.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Parsear capacidad
      double? capacity;
      if (capacityController.text.isNotEmpty) {
        capacity = double.tryParse(capacityController.text);
      }

      await _parkingService.updateParking(
        widget.parking.id.toString(),
        ParkingUpdateModel(
          name: nameController.text,
          address: addressController.text,
          isOpen: isActive,
          operationMode: operationMode,
          capacity: capacity,
        ),
      );

      if (mounted) {
        widget.onSave();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Estacionamiento actualizado correctamente'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: colorScheme.primary,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error al actualizar: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }
}

// Pantalla para gestionar empleados
class _EmployeesScreen extends StatefulWidget {
  final ParkingModel parking;
  final VoidCallback onSave;

  const _EmployeesScreen({required this.parking, required this.onSave});

  @override
  State<_EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<_EmployeesScreen> {
  final bool _isLoading = false;
  String? _error;
  late List<EmployeeModel> _employees;
  late ParkingService _parkingService;

  @override
  void initState() {
    super.initState();
    _employees = List.from(widget.parking.employees ?? []);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _parkingService = AppStateContainer.di(context).resolve<ParkingService>();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Empleados',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton.icon(
            onPressed: _addEmployee,
            icon: Icon(Icons.add, size: 18, color: colorScheme.primary),
            label: Text(
              'Agregar',
              style: textTheme.labelMedium?.copyWith(
                color: colorScheme.primary,
              ),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: colorScheme.primary),
                    const SizedBox(height: 16),
                    Text(
                      'Cargando empleados...',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              )
            : _error != null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error al cargar',
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : _buildEmployeesContent(context),
      ),
    );
  }

  Widget _buildEmployeesContent(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    if (_employees.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.people_outline, size: 64, color: colorScheme.outline),
              const SizedBox(height: 16),
              Text(
                'No hay empleados registrados',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Agrega empleados para gestionar el estacionamiento',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _addEmployee,
                icon: const Icon(Icons.add),
                label: const Text('Agregar Empleado'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(24.0),
      children: [
        // Header con información
        Card(
          margin: const EdgeInsets.only(bottom: 24),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.people, size: 24, color: colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Gestión de Empleados',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Administra el personal que trabaja en el estacionamiento',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Lista de empleados
        ..._employees
            .map((employee) => _buildEmployeeCard(context, employee))
            .toList(),

        // Espacio al final
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildEmployeeCard(BuildContext context, EmployeeModel employee) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header del card
            Row(
              children: [
                // Avatar del empleado
                CircleAvatar(
                  backgroundColor: colorScheme.primaryContainer,
                  radius: 24,
                  child: Text(
                    employee.name.substring(0, 1).toUpperCase(),
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Información del empleado
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        employee.name,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          employee.role,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Botón editar
                IconButton(
                  onPressed: () => _editEmployee(employee),
                  icon: Icon(
                    Icons.edit_outlined,
                    size: 20,
                    color: colorScheme.primary,
                  ),
                  tooltip: 'Editar empleado',
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Información de contacto
            if (employee.email != null || employee.phone != null) ...[
              if (employee.email != null)
                _buildContactItem(
                  context,
                  'Email',
                  employee.email!,
                  Icons.email_outlined,
                ),
              if (employee.phone != null) ...[
                if (employee.email != null) const SizedBox(height: 8),
                _buildContactItem(
                  context,
                  'Teléfono',
                  employee.phone!,
                  Icons.phone_outlined,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Row(
      children: [
        Icon(icon, size: 18, color: colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _addEmployee() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final roleController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Añadir Empleado',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogTextField(
              controller: nameController,
              label: 'Nombre del empleado',
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 16),
            _buildDialogTextField(
              controller: emailController,
              label: 'Email (opcional)',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            _buildDialogTextField(
              controller: phoneController,
              label: 'Teléfono (opcional)',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            _buildDialogTextField(
              controller: roleController,
              label: 'Rol',
              icon: Icons.work_outline,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              // Implementar lógica para añadir empleado
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Funcionalidad en desarrollo'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: colorScheme.primary,
                ),
              );
            },
            child: const Text('Añadir'),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18, color: colorScheme.onSurfaceVariant),
      ),
      keyboardType: keyboardType,
      style: textTheme.bodyMedium,
    );
  }

  void _editEmployee(EmployeeModel employee) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final roleController = TextEditingController(text: employee.role);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Editar Empleado',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Empleado: ${employee.name}',
              style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
            ),
            if (employee.email != null) ...[
              const SizedBox(height: 8),
              Text(
                'Email: ${employee.email}',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if (employee.phone != null) ...[
              const SizedBox(height: 8),
              Text(
                'Teléfono: ${employee.phone}',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 16),
            _buildDialogTextField(
              controller: roleController,
              label: 'Rol',
              icon: Icons.work_outline,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              // Implementar lógica para actualizar empleado
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Funcionalidad en desarrollo'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: colorScheme.primary,
                ),
              );
            },
            child: const Text('Actualizar'),
          ),
        ],
      ),
    );
  }
}

// Pantalla para editar parámetros del estacionamiento
class _EditParametersScreen extends StatefulWidget {
  final ParkingModel parking;
  final VoidCallback onSave;

  const _EditParametersScreen({required this.parking, required this.onSave});

  @override
  State<_EditParametersScreen> createState() => _EditParametersScreenState();
}

class _EditParametersScreenState extends State<_EditParametersScreen> {
  late TextEditingController currencyController;
  late TextEditingController timeZoneController;
  late TextEditingController countryCodeController;
  late TextEditingController decimalPlacesController;
  bool _isLoading = false;
  String? _error;
  late ParkingService _parkingService;

  // Variables para los selectores
  String? _selectedTimeZone;
  String? _selectedCountryCode;

  @override
  void initState() {
    super.initState();
    currencyController = TextEditingController(
      text: widget.parking.params.currency,
    );
    timeZoneController = TextEditingController(
      text: widget.parking.params.timeZone ?? '',
    );
    countryCodeController = TextEditingController(
      text: widget.parking.params.countryCode ?? '',
    );
    decimalPlacesController = TextEditingController(
      text: widget.parking.params.decimalPlaces.toString(),
    );

    // Inicializar selectores
    _selectedTimeZone = widget.parking.params.timeZone;
    _selectedCountryCode = widget.parking.params.countryCode;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _parkingService = AppStateContainer.di(context).resolve<ParkingService>();
  }

  @override
  void dispose() {
    currencyController.dispose();
    timeZoneController.dispose();
    countryCodeController.dispose();
    decimalPlacesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Editar Parámetros',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        actions: [
          TextButton.icon(
            onPressed: _isLoading ? null : _saveParameters,
            icon: _isLoading
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.primary,
                    ),
                  )
                : Icon(Icons.save, size: 18, color: colorScheme.primary),
            label: Text(
              _isLoading ? 'Guardando...' : 'Guardar',
              style: textTheme.labelMedium?.copyWith(
                color: colorScheme.primary,
              ),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_error != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.errorContainer.withValues(
                          alpha: 127,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: colorScheme.error),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _error!,
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Primera fila: País (1 columna)
                  _buildCountrySelector(),
                  const SizedBox(height: 20),

                  // Segunda fila: Zona horaria (1 columna)
                  _buildTimeZoneSelector(),
                  const SizedBox(height: 20),

                  // Tercera fila: Moneda y Decimales (2 columnas)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: currencyController,
                          label: 'Moneda',
                          icon: Icons.currency_exchange,
                          hintText: 'Ej: USD, EUR',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa la moneda';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          controller: decimalPlacesController,
                          label: 'Decimales',
                          icon: Icons.numbers,
                          keyboardType: TextInputType.number,
                          hintText: 'Ej: 2',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa el número de decimales';
                            }
                            final decimal = int.tryParse(value);
                            if (decimal == null || decimal < 0 || decimal > 4) {
                              return 'Debe ser un número entre 0 y 4';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? hintText,
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(icon, size: 18, color: colorScheme.onSurfaceVariant),
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: textTheme.bodyMedium,
    );
  }

  Widget _buildTimeZoneSelector() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final timeZones = [
      'America/New_York',
      'America/Chicago',
      'America/Denver',
      'America/Los_Angeles',
      'America/Mexico_City',
      'America/Sao_Paulo',
      'America/La_Paz',
      'America/Bogota',
      'America/Lima',
      'America/Caracas',
      'America/Guayaquil',
      'America/Asuncion',
      'America/Montevideo',
      'America/Guatemala',
      'America/Tegucigalpa',
      'America/El_Salvador',
      'America/Managua',
      'America/Costa_Rica',
      'America/Panama',
      'America/Havana',
      'America/Santo_Domingo',
      'America/Puerto_Rico',
      'America/Toronto',
      'Europe/London',
      'Europe/Paris',
      'Europe/Berlin',
      'Europe/Madrid',
      'Europe/Rome',
      'Europe/Moscow',
      'Asia/Tokyo',
      'Asia/Shanghai',
      'Asia/Seoul',
      'Asia/Singapore',
      'Asia/Hong_Kong',
      'Asia/Bangkok',
      'Australia/Sydney',
      'Australia/Melbourne',
      'Pacific/Auckland',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Zona horaria',
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: colorScheme.outline.withValues(alpha: 60),
                width: 1,
              ),
            ),
          ),
          child: DropdownButtonFormField<String>(
            value:
                _selectedTimeZone != null &&
                    timeZones.contains(_selectedTimeZone)
                ? _selectedTimeZone
                : null,
            decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.schedule,
                size: 18,
                color: colorScheme.onSurfaceVariant,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 16,
              ),
            ),
            hint: Text(
              'Seleccionar zona horaria',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            items: timeZones.map((timeZone) {
              return DropdownMenuItem<String>(
                value: timeZone,
                child: Text(timeZone, style: textTheme.bodyMedium),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedTimeZone = value;
              });
            },
            dropdownColor: colorScheme.surface,
            icon: Icon(
              Icons.arrow_drop_down,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCountrySelector() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final countries = [
      {'code': 'US', 'name': 'Estados Unidos'},
      {'code': 'MX', 'name': 'México'},
      {'code': 'ES', 'name': 'España'},
      {'code': 'AR', 'name': 'Argentina'},
      {'code': 'BR', 'name': 'Brasil'},
      {'code': 'CO', 'name': 'Colombia'},
      {'code': 'PE', 'name': 'Perú'},
      {'code': 'CL', 'name': 'Chile'},
      {'code': 'VE', 'name': 'Venezuela'},
      {'code': 'EC', 'name': 'Ecuador'},
      {'code': 'BO', 'name': 'Bolivia'},
      {'code': 'PY', 'name': 'Paraguay'},
      {'code': 'UY', 'name': 'Uruguay'},
      {'code': 'GT', 'name': 'Guatemala'},
      {'code': 'HN', 'name': 'Honduras'},
      {'code': 'SV', 'name': 'El Salvador'},
      {'code': 'NI', 'name': 'Nicaragua'},
      {'code': 'CR', 'name': 'Costa Rica'},
      {'code': 'PA', 'name': 'Panamá'},
      {'code': 'CU', 'name': 'Cuba'},
      {'code': 'DO', 'name': 'República Dominicana'},
      {'code': 'PR', 'name': 'Puerto Rico'},
      {'code': 'CA', 'name': 'Canadá'},
      {'code': 'FR', 'name': 'Francia'},
      {'code': 'DE', 'name': 'Alemania'},
      {'code': 'IT', 'name': 'Italia'},
      {'code': 'GB', 'name': 'Reino Unido'},
      {'code': 'JP', 'name': 'Japón'},
      {'code': 'CN', 'name': 'China'},
      {'code': 'KR', 'name': 'Corea del Sur'},
      {'code': 'AU', 'name': 'Australia'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'País',
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: colorScheme.outline.withValues(alpha: 60),
                width: 1,
              ),
            ),
          ),
          child: DropdownButtonFormField<String>(
            value:
                _selectedCountryCode != null &&
                    countries.any((c) => c['code'] == _selectedCountryCode)
                ? _selectedCountryCode
                : null,
            decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.flag_outlined,
                size: 18,
                color: colorScheme.onSurfaceVariant,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 16,
              ),
            ),
            hint: Text(
              'Seleccionar país',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            items: countries.map((country) {
              return DropdownMenuItem<String>(
                value: country['code'],
                child: Text(
                  '${country['code']} - ${country['name']}',
                  style: textTheme.bodyMedium,
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCountryCode = value;
              });
            },
            dropdownColor: colorScheme.surface,
            icon: Icon(
              Icons.arrow_drop_down,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _saveParameters() async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Validar campos requeridos
    if (currencyController.text.isEmpty ||
        decimalPlacesController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor completa los campos requeridos'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: colorScheme.error,
        ),
      );
      return;
    }

    // Validar decimales
    final decimalPlaces = int.tryParse(decimalPlacesController.text);
    if (decimalPlaces == null || decimalPlaces < 0 || decimalPlaces > 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Los decimales deben ser un número entre 0 y 4'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: colorScheme.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Crear modelo de actualización de parámetros
      final updatedParams = ParkingParamsModel(
        theme: widget.parking.params.theme, // Mantener el tema actual
        currency: currencyController.text.trim(),
        timeZone: _selectedTimeZone?.isNotEmpty == true
            ? _selectedTimeZone!
            : '',
        countryCode: _selectedCountryCode?.isNotEmpty == true
            ? _selectedCountryCode!
            : '',
        decimalPlaces: decimalPlaces,
        slogan: widget.parking.params.slogan, // Mantener el slogan actual
      );

      // Actualizar parámetros en el parking usando el método existente
      await _parkingService.updateParking(
        widget.parking.id.toString(),
        ParkingUpdateModel(params: updatedParams),
      );

      if (mounted) {
        widget.onSave();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Parámetros actualizados correctamente'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: colorScheme.primary,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error al actualizar parámetros: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }
}
