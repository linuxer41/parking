import 'package:flutter/material.dart';

import '../../models/employee_model.dart';
import '../../models/parking_model.dart';
import '../../services/parking_service.dart';
import '../../state/app_state_container.dart';
import '../../widgets/custom_address_input.dart';

import '../../widgets/custom_operation_mode_selector.dart';
import '../../widgets/page_layout.dart';
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
  ParkingDetailedModel? _parking;

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
    });

    try {
      // Obtener detalles completos del parking
      final parkingDetails = await _parkingService.getParkingDetailed(
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
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar detalles: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
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
        _buildSectionHeader(context, 'Información General', Icons.info_outline),
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

        // Sección de parámetros del parking
        _buildSectionHeader(
          context,
          'Parámetros del Parking',
          Icons.settings_outlined,
          onAction: () => _showParkingParametersDialog(),
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
                // País
                _buildCountryInfoRow(context),
                const SizedBox(height: 16),

                // Zona horaria
                _buildInfoRowWithIcon(
                  context,
                  'Zona horaria',
                  _parking!.params.timeZone ?? 'No especificada',
                  Icons.schedule_outlined,
                ),
                const SizedBox(height: 16),

                // Moneda y decimales
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoRowWithIcon(
                        context,
                        'Moneda',
                        _parking!.params.currency,
                        Icons.currency_exchange_outlined,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInfoRowWithIcon(
                        context,
                        'Decimales',
                        _parking!.params.decimalPlaces.toString(),
                        Icons.numbers_outlined,
                      ),
                    ),
                  ],
                ),
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

  Widget _buildCountrySelector(
    BuildContext context,
    String? selectedCountryCode,
    ValueChanged<String?> onChanged,
  ) {
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

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
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
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 60),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonFormField<String>(
              value:
                  selectedCountryCode != null &&
                      countries.any((c) => c['code'] == selectedCountryCode)
                  ? selectedCountryCode
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
                  vertical: 12,
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
              onChanged: onChanged,
              dropdownColor: colorScheme.surface,
              icon: Icon(
                Icons.arrow_drop_down,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeZoneSelector(
    BuildContext context,
    String? selectedTimeZone,
    ValueChanged<String?> onChanged,
  ) {
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

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
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
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 60),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonFormField<String>(
              value:
                  selectedTimeZone != null &&
                      timeZones.contains(selectedTimeZone)
                  ? selectedTimeZone
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
                  vertical: 12,
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
              onChanged: onChanged,
              dropdownColor: colorScheme.surface,
              icon: Icon(
                Icons.arrow_drop_down,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencySelector(
    BuildContext context,
    String? selectedCurrency,
    ValueChanged<String?> onChanged,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final currencies = [
      {'code': 'USD', 'name': 'Dólar estadounidense', 'symbol': '\$'},
      {'code': 'EUR', 'name': 'Euro', 'symbol': '€'},
      {'code': 'GBP', 'name': 'Libra esterlina', 'symbol': '£'},
      {'code': 'JPY', 'name': 'Yen japonés', 'symbol': '¥'},
      {'code': 'CAD', 'name': 'Dólar canadiense', 'symbol': 'C\$'},
      {'code': 'AUD', 'name': 'Dólar australiano', 'symbol': 'A\$'},
      {'code': 'CHF', 'name': 'Franco suizo', 'symbol': 'CHF'},
      {'code': 'CNY', 'name': 'Yuan chino', 'symbol': '¥'},
      {'code': 'SEK', 'name': 'Corona sueca', 'symbol': 'kr'},
      {'code': 'NZD', 'name': 'Dólar neozelandés', 'symbol': 'NZ\$'},
      {'code': 'MXN', 'name': 'Peso mexicano', 'symbol': '\$'},
      {'code': 'SGD', 'name': 'Dólar singapurense', 'symbol': 'S\$'},
      {'code': 'HKD', 'name': 'Dólar hongkonés', 'symbol': 'HK\$'},
      {'code': 'NOK', 'name': 'Corona noruega', 'symbol': 'kr'},
      {'code': 'KRW', 'name': 'Won surcoreano', 'symbol': '₩'},
      {'code': 'TRY', 'name': 'Lira turca', 'symbol': '₺'},
      {'code': 'RUB', 'name': 'Rublo ruso', 'symbol': '₽'},
      {'code': 'INR', 'name': 'Rupia india', 'symbol': '₹'},
      {'code': 'BRL', 'name': 'Real brasileño', 'symbol': 'R\$'},
      {'code': 'ZAR', 'name': 'Rand sudafricano', 'symbol': 'R'},
      {'code': 'ARS', 'name': 'Peso argentino', 'symbol': '\$'},
      {'code': 'CLP', 'name': 'Peso chileno', 'symbol': '\$'},
      {'code': 'COP', 'name': 'Peso colombiano', 'symbol': '\$'},
      {'code': 'PEN', 'name': 'Sol peruano', 'symbol': 'S/'},
      {'code': 'BOB', 'name': 'Boliviano', 'symbol': 'Bs'},
      {'code': 'PYG', 'name': 'Guaraní paraguayo', 'symbol': '₲'},
      {'code': 'UYU', 'name': 'Peso uruguayo', 'symbol': '\$'},
      {'code': 'VES', 'name': 'Bolívar venezolano', 'symbol': 'Bs'},
      {'code': 'CRC', 'name': 'Colón costarricense', 'symbol': '₡'},
      {'code': 'GTQ', 'name': 'Quetzal guatemalteco', 'symbol': 'Q'},
      {'code': 'HNL', 'name': 'Lempira hondureña', 'symbol': 'L'},
      {'code': 'NIO', 'name': 'Córdoba nicaragüense', 'symbol': 'C\$'},
      {'code': 'PAB', 'name': 'Balboa panameño', 'symbol': 'B/.'},
      {'code': 'SVC', 'name': 'Colón salvadoreño', 'symbol': '\$'},
      {'code': 'DOP', 'name': 'Peso dominicano', 'symbol': 'RD\$'},
      {'code': 'HTG', 'name': 'Gourde haitiano', 'symbol': 'G'},
      {'code': 'JMD', 'name': 'Dólar jamaiquino', 'symbol': 'J\$'},
      {'code': 'TTD', 'name': 'Dólar trinitense', 'symbol': 'TT\$'},
      {'code': 'XCD', 'name': 'Dólar del Caribe Oriental', 'symbol': 'EC\$'},
      {'code': 'BSD', 'name': 'Dólar bahameño', 'symbol': 'B\$'},
      {'code': 'BBD', 'name': 'Dólar barbadense', 'symbol': 'Bds\$'},
      {'code': 'BZD', 'name': 'Dólar beliceño', 'symbol': 'BZ\$'},
      {'code': 'KYD', 'name': 'Dólar de las Islas Caimán', 'symbol': 'CI\$'},
      {'code': 'FJD', 'name': 'Dólar fiyiano', 'symbol': 'FJ\$'},
      {'code': 'GYD', 'name': 'Dólar guyanés', 'symbol': 'G\$'},
      {'code': 'SRD', 'name': 'Dólar surinamés', 'symbol': 'SR\$'},
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Moneda',
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 60),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonFormField<String>(
              value:
                  selectedCurrency != null &&
                      currencies.any((c) => c['code'] == selectedCurrency)
                  ? selectedCurrency
                  : null,
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.currency_exchange,
                  size: 18,
                  color: colorScheme.onSurfaceVariant,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              hint: Text(
                'Seleccionar moneda',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              items: currencies.map((currency) {
                return DropdownMenuItem<String>(
                  value: currency['code'],
                  child: Text(
                    '${currency['code']} - ${currency['name']} (${currency['symbol']})',
                    style: textTheme.bodyMedium,
                  ),
                );
              }).toList(),
              onChanged: onChanged,
              dropdownColor: colorScheme.surface,
              icon: Icon(
                Icons.arrow_drop_down,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? hintText,
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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
      keyboardType: keyboardType,
      style: textTheme.bodyMedium,
    );
  }

  // Mostrar diálogo de parámetros del parking
  void _showParkingParametersDialog() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Controladores para los campos
    String? selectedCurrency = _parking!.params.currency;
    final decimalPlacesController = TextEditingController(
      text: _parking!.params.decimalPlaces.toString(),
    );
    String? selectedTimeZone = _parking!.params.timeZone;
    String? selectedCountryCode = _parking!.params.countryCode;
    bool isLoading = false;
    String? error;

    showDialog(
      context: context,
      barrierDismissible: true,
      useRootNavigator: true,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
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
                      'Parámetros del Parking',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const Divider(),

                  if (error != null)
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.errorContainer.withValues(
                          alpha: 127,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: colorScheme.error,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              error!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else ...[
                    _buildCountrySelector(dialogContext, selectedCountryCode, (
                      value,
                    ) {
                      setState(() => selectedCountryCode = value);
                    }),
                    _buildTimeZoneSelector(dialogContext, selectedTimeZone, (
                      value,
                    ) {
                      setState(() => selectedTimeZone = value);
                    }),
                    _buildCurrencySelector(dialogContext, selectedCurrency, (
                      value,
                    ) {
                      setState(() => selectedCurrency = value);
                    }),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: _buildTextField(
                        controller: decimalPlacesController,
                        label: 'Decimales',
                        icon: Icons.numbers,
                        keyboardType: TextInputType.number,
                        hintText: 'Ej: 2',
                      ),
                    ),
                  ],

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
                        onPressed: isLoading
                            ? null
                            : () async {
                                // Validar campos requeridos
                                if (selectedCurrency == null ||
                                    selectedCurrency!.isEmpty ||
                                    decimalPlacesController.text.isEmpty) {
                                  setState(() {
                                    error =
                                        'Por favor completa los campos requeridos';
                                  });
                                  return;
                                }

                                // Validar decimales
                                final decimalPlaces = int.tryParse(
                                  decimalPlacesController.text,
                                );
                                if (decimalPlaces == null ||
                                    decimalPlaces < 0 ||
                                    decimalPlaces > 4) {
                                  setState(() {
                                    error =
                                        'Los decimales deben ser un número entre 0 y 4';
                                  });
                                  return;
                                }

                                setState(() {
                                  isLoading = true;
                                  error = null;
                                });

                                try {
                                  // Crear modelo de actualización de parámetros
                                  final updatedParams = ParkingParamsModel(
                                    theme: _parking!
                                        .params
                                        .theme, // Mantener el tema actual
                                    currency: selectedCurrency!,
                                    timeZone:
                                        selectedTimeZone?.isNotEmpty == true
                                        ? selectedTimeZone!
                                        : '',
                                    countryCode:
                                        selectedCountryCode?.isNotEmpty == true
                                        ? selectedCountryCode!
                                        : '',
                                    decimalPlaces: decimalPlaces,
                                    slogan: _parking!
                                        .params
                                        .slogan, // Mantener el slogan actual
                                  );

                                  // Actualizar parámetros en el parking
                                  await _parkingService.updateParking(
                                    _parking!.id.toString(),
                                    ParkingUpdateModel(params: updatedParams),
                                  );

                                  if (mounted) {
                                    Navigator.of(dialogContext).pop();
                                    await _refreshParkingDetails();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Parámetros actualizados correctamente',
                                        ),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  setState(() {
                                    error =
                                        'Error al actualizar parámetros: ${e.toString()}';
                                    isLoading = false;
                                  });
                                }
                              },
                        child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Guardar'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
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
        ParkingModel.fromParkingDetailedModel(_parking!),
        _parking?.currentEmployee ,
      );

      // Si hay áreas disponibles, seleccionar la primera
      if (_parking!.areas != null && _parking!.areas!.isNotEmpty) {
        appState.setCurrentArea(_parking!.areas!.first.id);
      }

      // Navegar a la pantalla de parking en modo edición
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ParkingScreen(),
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
  final ParkingDetailedModel parking;
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
  late TextEditingController latitudeController;
  late TextEditingController longitudeController;
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
    latitudeController = TextEditingController(
      text: widget.parking.location?.lat?.toString() ?? '',
    );
    longitudeController = TextEditingController(
      text: widget.parking.location?.lng?.toString() ?? '',
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
    latitudeController.dispose();
    longitudeController.dispose();

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
                            latitudeController: latitudeController,
                            longitudeController: longitudeController,
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

                          // Campos de coordenadas
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _buildModernTextField(
                                  controller: latitudeController,
                                  label: 'Latitud',
                                  icon: Icons.location_on_outlined,
                                  keyboardType: TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildModernTextField(
                                  controller: longitudeController,
                                  label: 'Longitud',
                                  icon: Icons.location_on_outlined,
                                  keyboardType: TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                                ),
                              ),
                            ],
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

      // Crear el modelo de ubicación actualizado
      ParkingLocationModel? location;
      if (latitudeController.text.isNotEmpty &&
          longitudeController.text.isNotEmpty) {
        final lat = double.tryParse(latitudeController.text);
        final lng = double.tryParse(longitudeController.text);
        if (lat != null && lng != null) {
          location = ParkingLocationModel(lat: lat, lng: lng);
        }
      }

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
          location: location,
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
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
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
    }
  }
}
