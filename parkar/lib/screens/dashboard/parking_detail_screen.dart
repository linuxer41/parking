import 'package:flutter/material.dart';

import '../../models/employee_model.dart';
import '../../models/parking_model.dart';
import '../../services/parking_service.dart';
import '../../state/app_state_container.dart';
import '../../widgets/custom_address_input.dart';

import '../../widgets/custom_operation_mode_selector.dart';
import '../../widgets/page_layout.dart';
import '../dashboard/employees_screen.dart';
import '../parking/parking_screen.dart';

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
    return PageLayout(
      title: 'Detalles del Aparcamiento',
      body: _buildMainContent(),
    );
  }

  // Contenido principal
  Widget _buildMainContent() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    if (_isLoading) {
      return Center(
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
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: colorScheme.error),
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
      );
    }

    if (_parking == null) {
      return Center(
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
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshParkingDetails,
      child: _buildParkingDetailContent(context),
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
                if (_parking!.location != null)
                  _buildInfoRowWithIcon(
                    context,
                    'Ubicación',
                    'Lat: ${_parking!.location!.lat}, Long: ${_parking!.location!.lng}',
                    Icons.pin_drop_outlined,
                  ),

                // Modo de operación con chips
                _buildOperationModeChips(context),
                const SizedBox(height: 16),

                // Estado del estacionamiento
                _buildStatusToggle(context),
              ],
            ),
          ),
        ),

        // Sección de empleados
        _buildSectionHeader(
          context,
          'Empleados',
          Icons.people_outline,
          onAction: () => _navigateToEmployees(),
          actionLabel: 'Gestionar',
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
                // Información de empleados
                Row(
                  children: [
                    Icon(Icons.people, size: 24, color: colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Personal del Estacionamiento',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_parking!.employees?.length ?? 0} empleados registrados',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Lista de empleados (máximo 3 para mostrar)
                if (_parking!.employees != null &&
                    _parking!.employees!.isNotEmpty) ...[
                  ...(_parking!.employees!
                      .take(3)
                      .map(
                        (employee) => _buildEmployeeItem(context, employee),
                      )),
                  if (_parking!.employees!.length > 3)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        'Y ${_parking!.employees!.length - 3} empleados más...',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 20,
                          color: colorScheme.outline,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'No hay empleados registrados',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),

        // Botón de layout solo si el modo de operación es map
        if (_parking?.operationMode == ParkingOperationMode.map)
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
                    // Indicador map de estado
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

  // Método para construir item de empleado
  Widget _buildEmployeeItem(BuildContext context, EmployeeModel employee) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          // Avatar del empleado
          CircleAvatar(
            backgroundColor: colorScheme.primaryContainer,
            radius: 20,
            child: Text(
              employee.name.substring(0, 1).toUpperCase(),
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Información del empleado
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  employee.name,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(6),
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
        ],
      ),
    );
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

  // Navegar a la pantalla de empleados
  void _navigateToEmployees() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EmployeesScreen(
          parking: _parking!,
          onSave: () => _refreshParkingDetails(),
        ),
      ),
    );
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
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController addressController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController sloganController;
  late bool isActive;
  late ParkingOperationMode operationMode;
  bool _isLoading = false;
  String? _error;

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

    isActive = widget.parking.isActive ?? true;
    operationMode = widget.parking.operationMode ?? ParkingOperationMode.map;
  }

  @override
  void dispose() {
    nameController.dispose();
    addressController.dispose();
    emailController.dispose();
    phoneController.dispose();
    sloganController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    // Contenido del formulario
    final formContent = LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 24),

                          // Mensaje de error si existe
                          if (_error != null) ...[
                            Container(
                              margin: const EdgeInsets.only(bottom: 24),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: colorScheme.errorContainer,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: colorScheme.error.withValues(
                                    alpha: 0.2,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: colorScheme.error,
                                  ),
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
                          ],

                          // Campo de nombre del aparcamiento
                          _buildModernTextField(
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

                          // Campo de dirección
                          CustomAddressInput(
                            addressController: addressController,
                            labelText: 'Dirección',
                            hintText:
                                'Ingresa la dirección del estacionamiento',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingresa la dirección';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Campos de contacto
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _buildModernTextField(
                                  controller: emailController,
                                  label: 'Correo electrónico',
                                  icon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildModernTextField(
                                  controller: phoneController,
                                  label: 'Teléfono',
                                  icon: Icons.phone_outlined,
                                  keyboardType: TextInputType.phone,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Campo de slogan
                          _buildModernTextField(
                            controller: sloganController,
                            label: 'Slogan',
                            icon: Icons.tag_outlined,
                            hintText: 'Ej: El mejor lugar para tu vehículo',
                          ),
                          const SizedBox(height: 20),

                          // Modo de operación
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

                          // Switch de estado activo
                          _buildModernSwitchTile(),
                          const SizedBox(height: 32),

                          // Botón de guardar
                          ElevatedButton(
                            onPressed: _isLoading ? null : _saveParking,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: colorScheme.onPrimary,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Guardando...',
                                        style: textTheme.labelLarge?.copyWith(
                                          color: colorScheme.onPrimary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.save, size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Guardar Cambios',
                                        style: textTheme.labelLarge?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    // Usar PageLayout para consistencia
    return PageLayout(title: 'Editar Estacionamiento', body: formContent);
  }

  Widget _buildModernTextField({
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
        prefixIcon: Icon(icon, size: 20, color: colorScheme.onSurfaceVariant),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
    );
  }

  Widget _buildModernSwitchTile() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.power_settings_new_outlined,
              color: colorScheme.primary,
              size: 24,
            ),
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

    // Validar formulario
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final parkingService = AppStateContainer.di(
        context,
      ).resolve<ParkingService>();

      // Crear el modelo de parámetros actualizado
      final updatedParams = ParkingParamsModel(
        theme: widget.parking.params.theme,
        slogan: sloganController.text.isNotEmpty ? sloganController.text : null,
        currency: widget.parking.params.currency,
        timeZone: widget.parking.params.timeZone,
        countryCode: widget.parking.params.countryCode,
        decimalPlaces: widget.parking.params.decimalPlaces,
      );

      await parkingService.updateParking(
        widget.parking.id.toString(),
        ParkingUpdateModel(
          name: nameController.text,
          address: addressController.text,
          isOpen: isActive,
          operationMode: operationMode,
          params: updatedParams,
        ),
      );

      if (mounted) {
        widget.onSave();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Estacionamiento actualizado correctamente'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: colorScheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
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
