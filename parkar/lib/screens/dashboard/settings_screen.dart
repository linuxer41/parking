import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../widgets/page_layout.dart';
import '../../services/parking_service.dart';
import '../../state/app_state_container.dart';
import '../../models/parking_model.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _autoBackupEnabled = true;
  String _selectedLanguage = 'Español';
  String _selectedCurrency = 'USD';

  // Variables para parámetros del parking
  late TextEditingController _currencyController;
  late TextEditingController _decimalPlacesController;
  String? _selectedTimeZone;
  String? _selectedCountryCode;
  bool _isLoadingParkingParams = false;
  String? _parkingParamsError;
  late ParkingService _parkingService;
  ParkingDetailedModel? _currentParking;

  @override
  void initState() {
    super.initState();
    _currencyController = TextEditingController(text: 'USD');
    _decimalPlacesController = TextEditingController(text: '2');
    _loadParkingParameters();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _parkingService = AppStateContainer.di(context).resolve<ParkingService>();
  }

  @override
  void dispose() {
    _currencyController.dispose();
    _decimalPlacesController.dispose();
    super.dispose();
  }

  // Cargar parámetros del parking actual
  Future<void> _loadParkingParameters() async {
    final appState = AppStateContainer.of(context);
    final currentParking = appState.currentParking;

    if (currentParking == null) {
      setState(() {
        _parkingParamsError = 'No hay estacionamiento seleccionado';
      });
      return;
    }

    setState(() {
      _isLoadingParkingParams = true;
      _parkingParamsError = null;
    });

    try {
      final parking = await _parkingService.getParkingDetailed(currentParking.id);

      if (mounted) {
        setState(() {
          _currentParking = parking;
          _currencyController.text = parking.params.currency;
          _decimalPlacesController.text = parking.params.decimalPlaces
              .toString();
          _selectedTimeZone = parking.params.timeZone;
          _selectedCountryCode = parking.params.countryCode;
          _isLoadingParkingParams = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _parkingParamsError = 'Error al cargar parámetros: ${e.toString()}';
          _isLoadingParkingParams = false;
        });
      }
    }
  }

  // Guardar parámetros del parking
  Future<void> _saveParkingParameters() async {
    if (_currentParking == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay estacionamiento seleccionado'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validar campos requeridos
    if (_currencyController.text.isEmpty ||
        _decimalPlacesController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa los campos requeridos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validar decimales
    final decimalPlaces = int.tryParse(_decimalPlacesController.text);
    if (decimalPlaces == null || decimalPlaces < 0 || decimalPlaces > 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Los decimales deben ser un número entre 0 y 4'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoadingParkingParams = true;
      _parkingParamsError = null;
    });

    try {
      // Crear modelo de actualización de parámetros
      final updatedParams = ParkingParamsModel(
        theme: _currentParking!.params.theme, // Mantener el tema actual
        currency: _currencyController.text.trim(),
        timeZone: _selectedTimeZone?.isNotEmpty == true
            ? _selectedTimeZone!
            : '',
        countryCode: _selectedCountryCode?.isNotEmpty == true
            ? _selectedCountryCode!
            : '',
        decimalPlaces: decimalPlaces,
        slogan: _currentParking!.params.slogan, // Mantener el slogan actual
      );

      // Actualizar parámetros en el parking
      await _parkingService.updateParking(
        _currentParking!.id.toString(),
        ParkingUpdateModel(params: updatedParams),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Parámetros actualizados correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        await _loadParkingParameters(); // Recargar datos
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _parkingParamsError =
              'Error al actualizar parámetros: ${e.toString()}';
          _isLoadingParkingParams = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageLayout(title: 'Configuraciones', body: _buildSettingsContent());
  }

  Widget _buildSettingsContent() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sección de Parámetros del Parking
          _buildSettingsSection(
            context,
            'Parámetros del Parking',
            Icons.settings,
            [
              if (_parkingParamsError != null)
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer.withValues(alpha: 127),
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
                          _parkingParamsError!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              if (_isLoadingParkingParams)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                )
              else ...[
                _buildCountrySelector(context),
                _buildTimeZoneSelector(context),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _currencyController,
                          label: 'Moneda',
                          icon: Icons.currency_exchange,
                          hintText: 'Ej: USD, EUR',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          controller: _decimalPlacesController,
                          label: 'Decimales',
                          icon: Icons.numbers,
                          keyboardType: TextInputType.number,
                          hintText: 'Ej: 2',
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoadingParkingParams
                          ? null
                          : _saveParkingParameters,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoadingParkingParams
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Guardar Parámetros'),
                    ),
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 24),

          // Sección de Notificaciones
          _buildSettingsSection(
            context,
            'Notificaciones',
            Icons.notifications,
            [
              _buildSwitchSetting(
                context,
                'Notificaciones Push',
                'Recibe notificaciones sobre actividad del parking',
                _notificationsEnabled,
                (value) => setState(() => _notificationsEnabled = value),
              ),
              _buildSwitchSetting(
                context,
                'Alertas de Ocupación',
                'Notificaciones cuando el parking esté lleno',
                _notificationsEnabled,
                (value) => setState(() => _notificationsEnabled = value),
              ),
              _buildSwitchSetting(
                context,
                'Reportes Automáticos',
                'Recibe reportes diarios por email',
                _notificationsEnabled,
                (value) => setState(() => _notificationsEnabled = value),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Sección de Apariencia
          _buildSettingsSection(context, 'Apariencia', Icons.palette, [
            _buildSwitchSetting(
              context,
              'Modo Oscuro',
              'Cambiar entre tema claro y oscuro',
              _darkModeEnabled,
              (value) => setState(() {
                _darkModeEnabled = value;
                
              }),
            ),
            _buildListSetting(
              context,
              'Idioma',
              'Selecciona el idioma de la aplicación',
              _selectedLanguage,
              ['Español', 'English', 'Français'],
              (value) => setState(() => _selectedLanguage = value),
            ),
          ]),

          const SizedBox(height: 24),

          // Sección de Datos
          _buildSettingsSection(context, 'Datos y Respaldo', Icons.storage, [
            _buildSwitchSetting(
              context,
              'Respaldo Automático',
              'Realizar respaldo automático de datos',
              _autoBackupEnabled,
              (value) => setState(() => _autoBackupEnabled = value),
            ),
            _buildActionSetting(
              context,
              'Exportar Datos',
              'Descargar todos los datos del parking',
              Icons.download,
              () => _exportData(),
            ),
            _buildActionSetting(
              context,
              'Importar Datos',
              'Restaurar datos desde un archivo',
              Icons.upload,
              () => _importData(),
            ),
          ]),

          const SizedBox(height: 24),

          // Sección de Seguridad
          _buildSettingsSection(context, 'Seguridad', Icons.security, [
            _buildActionSetting(
              context,
              'Cambiar Contraseña',
              'Actualizar tu contraseña de acceso',
              Icons.lock,
              () => _changePassword(),
            ),
            _buildActionSetting(
              context,
              'Autenticación de Dos Factores',
              'Configurar 2FA para mayor seguridad',
              Icons.verified_user,
              () => _setupTwoFactor(),
            ),
            _buildActionSetting(
              context,
              'Sesiones Activas',
              'Ver y gestionar sesiones activas',
              Icons.devices,
              () => _manageSessions(),
            ),
          ]),

          const SizedBox(height: 24),

          // Sección de Sistema
          _buildSettingsSection(context, 'Sistema', Icons.settings, [
            _buildActionSetting(
              context,
              'Información del Sistema',
              'Versión y detalles técnicos',
              Icons.info,
              () => _showSystemInfo(),
            ),
            _buildActionSetting(
              context,
              'Limpiar Caché',
              'Liberar espacio de almacenamiento',
              Icons.cleaning_services,
              () => _clearCache(),
            ),
            _buildActionSetting(
              context,
              'Restablecer Configuración',
              'Volver a la configuración por defecto',
              Icons.restore,
              () => _resetSettings(),
            ),
          ]),

          const SizedBox(height: 32),

          // Botón de Guardar
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveSettings,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Guardar Configuración',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(
    BuildContext context,
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: colorScheme.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 0,
          color: colorScheme.surfaceContainerHighest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: colorScheme.outlineVariant.withOpacity(0.3),
            ),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSwitchSetting(
    BuildContext context,
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListTile(
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: colorScheme.primary,
      ),
    );
  }

  Widget _buildListSetting(
    BuildContext context,
    String title,
    String subtitle,
    String currentValue,
    List<String> options,
    ValueChanged<String> onChanged,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListTile(
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: DropdownButton<String>(
        value: currentValue,
        onChanged: (value) {
          if (value != null) onChanged(value);
        },
        items: options.map((option) {
          return DropdownMenuItem(value: option, child: Text(option));
        }).toList(),
        underline: Container(),
      ),
    );
  }

  Widget _buildActionSetting(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: colorScheme.primary, size: 20),
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: colorScheme.onSurfaceVariant,
      ),
      onTap: onTap,
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

  Widget _buildCountrySelector(BuildContext context) {
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
      ),
    );
  }

  Widget _buildTimeZoneSelector(BuildContext context) {
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
      ),
    );
  }

  void _saveSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Configuración guardada exitosamente'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _exportData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exportar Datos'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.download, size: 48, color: Colors.blue),
            SizedBox(height: 16),
            Text('¿Deseas exportar todos los datos del parking?'),
            SizedBox(height: 8),
            Text(
              'Esto incluirá: historial, reportes, configuraciones y estadísticas.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Exportando datos...'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            child: const Text('Exportar'),
          ),
        ],
      ),
    );
  }

  void _importData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidad de importación en desarrollo'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _changePassword() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cambiar Contraseña'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Contraseña Actual',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Nueva Contraseña',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Confirmar Nueva Contraseña',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Contraseña actualizada'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Actualizar'),
          ),
        ],
      ),
    );
  }

  void _setupTwoFactor() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Configuración de 2FA en desarrollo'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _manageSessions() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Gestión de sesiones en desarrollo'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _showSystemInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Información del Sistema'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Versión de la App: 1.0.0'),
            SizedBox(height: 8),
            Text('Versión de Flutter: 3.16.0'),
            SizedBox(height: 8),
            Text('Plataforma: Android/iOS'),
            SizedBox(height: 8),
            Text('Última actualización: 15/12/2024'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _clearCache() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpiar Caché'),
        content: const Text('¿Estás seguro de que quieres limpiar el caché?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Caché limpiado exitosamente'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Limpiar'),
          ),
        ],
      ),
    );
  }

  void _resetSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restablecer Configuración'),
        content: const Text(
          '¿Estás seguro de que quieres restablecer toda la configuración? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _notificationsEnabled = true;
                _darkModeEnabled = false;
                _autoBackupEnabled = true;
                _selectedLanguage = 'Español';
                _selectedCurrency = 'USD';
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Configuración restablecida'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Restablecer'),
          ),
        ],
      ),
    );
  }
}
