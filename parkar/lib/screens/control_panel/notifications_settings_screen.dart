import 'package:flutter/material.dart';
import 'responsive_detail_screen.dart';

/// Pantalla para configurar las notificaciones del usuario
class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() =>
      _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState
    extends State<NotificationsSettingsScreen> {
  // Estado de las notificaciones
  bool _pushNotificationsEnabled = true;
  bool _emailNotificationsEnabled = true;
  bool _smsNotificationsEnabled = false;
  bool _parkingAlertsEnabled = true;
  bool _paymentRemindersEnabled = true;
  bool _promotionsEnabled = false;
  bool _systemUpdatesEnabled = true;
  bool _isLoading = false;

  // Método para guardar la configuración
  void _saveSettings() {
    setState(() {
      _isLoading = true;
    });

    // Simulación de guardado
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Configuración de notificaciones actualizada'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return ResponsiveDetailScreen(
      title: 'Notificaciones',
      actions: [
        IconButton(
          icon: const Icon(Icons.check),
          tooltip: 'Guardar',
          onPressed: _isLoading ? null : _saveSettings,
        ),
      ],
      body: Stack(
        children: [
          // Contenido principal
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sección de canales de notificación
                Row(
                  children: [
                    Icon(
                      Icons.notifications_outlined,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Canales de notificación',
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildSwitchTile(
                  title: 'Notificaciones push',
                  subtitle: 'Recibir alertas en tu dispositivo',
                  value: _pushNotificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _pushNotificationsEnabled = value;
                    });
                  },
                  icon: Icons.notifications_outlined,
                  colorScheme: colorScheme,
                ),
                _buildSwitchTile(
                  title: 'Correo electrónico',
                  subtitle: 'Recibir notificaciones por email',
                  value: _emailNotificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _emailNotificationsEnabled = value;
                    });
                  },
                  icon: Icons.email_outlined,
                  colorScheme: colorScheme,
                ),
                _buildSwitchTile(
                  title: 'SMS',
                  subtitle: 'Recibir notificaciones por mensaje de texto',
                  value: _smsNotificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _smsNotificationsEnabled = value;
                    });
                  },
                  icon: Icons.sms_outlined,
                  colorScheme: colorScheme,
                ),

                const Divider(height: 24),

                // Sección de tipos de notificaciones
                Row(
                  children: [
                    Icon(
                      Icons.category_outlined,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Tipos de notificaciones',
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildSwitchTile(
                  title: 'Alertas de estacionamiento',
                  subtitle: 'Notificaciones sobre tu vehículo estacionado',
                  value: _parkingAlertsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _parkingAlertsEnabled = value;
                    });
                  },
                  icon: Icons.local_parking_outlined,
                  colorScheme: colorScheme,
                ),
                _buildSwitchTile(
                  title: 'Recordatorios de pago',
                  subtitle: 'Alertas sobre pagos pendientes y vencimientos',
                  value: _paymentRemindersEnabled,
                  onChanged: (value) {
                    setState(() {
                      _paymentRemindersEnabled = value;
                    });
                  },
                  icon: Icons.payment_outlined,
                  colorScheme: colorScheme,
                ),
                _buildSwitchTile(
                  title: 'Promociones y ofertas',
                  subtitle:
                      'Recibir información sobre descuentos y promociones',
                  value: _promotionsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _promotionsEnabled = value;
                    });
                  },
                  icon: Icons.local_offer_outlined,
                  colorScheme: colorScheme,
                ),
                _buildSwitchTile(
                  title: 'Actualizaciones del sistema',
                  subtitle: 'Notificaciones sobre nuevas características',
                  value: _systemUpdatesEnabled,
                  onChanged: (value) {
                    setState(() {
                      _systemUpdatesEnabled = value;
                    });
                  },
                  icon: Icons.system_update_outlined,
                  colorScheme: colorScheme,
                ),

                const SizedBox(height: 16),

                // Botón para guardar
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isLoading ? null : _saveSettings,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                        _isLoading ? 'Guardando...' : 'Guardar configuración'),
                  ),
                ),
              ],
            ),
          ),

          // Indicador de carga
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  // Widget para construir un elemento de switch con icono
  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
    required ColorScheme colorScheme,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Card(
        elevation: 0,
        color: colorScheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: SwitchListTile(
          title: Text(title),
          subtitle: Text(subtitle),
          value: value,
          onChanged: onChanged,
          secondary: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: colorScheme.primary,
              size: 24,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
