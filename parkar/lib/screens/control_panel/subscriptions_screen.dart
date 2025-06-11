import 'package:flutter/material.dart';
import 'base_detail_screen.dart';

/// Modelo para representar una suscripción de estacionamiento
class ParkingSubscription {
  final int id;
  final String parkingName;
  final String vehicleType;
  final double monthlyRate;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;

  ParkingSubscription({
    required this.id,
    required this.parkingName,
    required this.vehicleType,
    required this.monthlyRate,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
  });
}

/// Pantalla para gestionar las suscripciones de estacionamiento
class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  bool _isLoading = false;
  List<ParkingSubscription> _subscriptions = [];
  final _refreshKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _loadSubscriptions();
  }

  // Cargar suscripciones (simulación)
  Future<void> _loadSubscriptions() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    // Simulación de carga de datos
    await Future.delayed(const Duration(milliseconds: 800));

    if (mounted) {
      setState(() {
        _subscriptions = [
          ParkingSubscription(
            id: 1,
            parkingName: 'Estacionamiento Central',
            vehicleType: 'Automóvil',
            monthlyRate: 300.00,
            startDate: DateTime.now().subtract(const Duration(days: 15)),
            endDate: DateTime.now().add(const Duration(days: 15)),
            isActive: true,
          ),
          ParkingSubscription(
            id: 2,
            parkingName: 'Estacionamiento Norte',
            vehicleType: 'Motocicleta',
            monthlyRate: 150.00,
            startDate: DateTime.now().subtract(const Duration(days: 5)),
            endDate: DateTime.now().add(const Duration(days: 25)),
            isActive: true,
          ),
        ];
        _isLoading = false;
      });
    }
  }

  // Renovar suscripción
  void _renewSubscription(ParkingSubscription subscription) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Renovar suscripción'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Estás por renovar tu suscripción mensual para ${subscription.vehicleType} en ${subscription.parkingName}.',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Precio mensual'),
                subtitle:
                    Text('\$${subscription.monthlyRate.toStringAsFixed(2)}'),
                leading: const Icon(Icons.calendar_month),
              ),
              const SizedBox(height: 8),
              ListTile(
                title: const Text('Nueva fecha de vencimiento'),
                subtitle: Text(
                  _formatDate(DateTime(
                    subscription.endDate.year,
                    subscription.endDate.month + 1,
                    subscription.endDate.day,
                  )),
                ),
                leading: const Icon(Icons.event),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              // Simular renovación
              setState(() {
                final index =
                    _subscriptions.indexWhere((s) => s.id == subscription.id);
                if (index != -1) {
                  _subscriptions[index] = ParkingSubscription(
                    id: subscription.id,
                    parkingName: subscription.parkingName,
                    vehicleType: subscription.vehicleType,
                    monthlyRate: subscription.monthlyRate,
                    startDate: subscription.startDate,
                    endDate: DateTime(
                      subscription.endDate.year,
                      subscription.endDate.month + 1,
                      subscription.endDate.day,
                    ),
                    isActive: subscription.isActive,
                  );
                }
              });

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Suscripción renovada correctamente'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
              Navigator.of(context).pop();
            },
            child: const Text('Renovar'),
          ),
        ],
      ),
    );
  }

  // Cancelar suscripción
  void _cancelSubscription(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar suscripción'),
        content: const Text(
          '¿Estás seguro de que deseas cancelar esta suscripción? '
          'Perderás el acceso al finalizar el período actual.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('No, mantener'),
          ),
          FilledButton(
            onPressed: () {
              setState(() {
                final index = _subscriptions.indexWhere((s) => s.id == id);
                if (index != -1) {
                  _subscriptions[index] = ParkingSubscription(
                    id: _subscriptions[index].id,
                    parkingName: _subscriptions[index].parkingName,
                    vehicleType: _subscriptions[index].vehicleType,
                    monthlyRate: _subscriptions[index].monthlyRate,
                    startDate: _subscriptions[index].startDate,
                    endDate: _subscriptions[index].endDate,
                    isActive: false,
                  );
                }
              });
              Navigator.of(context).pop();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Suscripción cancelada'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    );
  }

  // Formatear fecha
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Calcular días restantes
  int _getRemainingDays(DateTime endDate) {
    return endDate.difference(DateTime.now()).inDays;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return BaseDetailScreen(
      title: 'Mis suscripciones',
      body: Stack(
        children: [
          // Lista de suscripciones
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _subscriptions.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.card_membership_outlined,
                            size: 64,
                            color: colorScheme.primary.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No tienes suscripciones activas',
                            style: textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Adquiere una suscripción mensual para ahorrar',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      key: _refreshKey,
                      onRefresh: _loadSubscriptions,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: _subscriptions.length,
                        itemBuilder: (context, index) {
                          final subscription = _subscriptions[index];
                          return _buildSubscriptionCard(
                              subscription, colorScheme);
                        },
                      ),
                    ),
        ],
      ),
    );
  }

  // Construir tarjeta para cada suscripción
  Widget _buildSubscriptionCard(
      ParkingSubscription subscription, ColorScheme colorScheme) {
    final remainingDays = _getRemainingDays(subscription.endDate);
    final isExpired = remainingDays < 0;
    final isAboutToExpire = remainingDays <= 5;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado con nombre del estacionamiento y estado
            Row(
              children: [
                Icon(
                  Icons.local_parking,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subscription.parkingName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        'Vehículo: ${subscription.vehicleType}',
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: subscription.isActive
                        ? (isExpired
                            ? Colors.red.withOpacity(0.2)
                            : (isAboutToExpire
                                ? Colors.orange.withOpacity(0.2)
                                : colorScheme.primaryContainer))
                        : colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    subscription.isActive
                        ? (isExpired
                            ? 'Expirada'
                            : (isAboutToExpire ? 'Por vencer' : 'Activa'))
                        : 'Cancelada',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: subscription.isActive
                          ? (isExpired
                              ? Colors.red
                              : (isAboutToExpire
                                  ? Colors.orange
                                  : colorScheme.onPrimaryContainer))
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Detalles de la suscripción
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: colorScheme.outline.withOpacity(0.1),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildSubscriptionInfo(
                          'Fecha inicio',
                          _formatDate(subscription.startDate),
                          Icons.calendar_today,
                          colorScheme,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildSubscriptionInfo(
                          'Fecha vencimiento',
                          _formatDate(subscription.endDate),
                          Icons.event,
                          colorScheme,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSubscriptionInfo(
                          'Tarifa mensual',
                          '\$${subscription.monthlyRate.toStringAsFixed(2)}',
                          Icons.attach_money,
                          colorScheme,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildSubscriptionInfo(
                          'Días restantes',
                          isExpired ? '0' : remainingDays.toString(),
                          Icons.timer,
                          colorScheme,
                          textColor: isAboutToExpire && !isExpired
                              ? Colors.orange
                              : (isExpired ? Colors.red : null),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Botones de acción
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (subscription.isActive) ...[
                  TextButton.icon(
                    onPressed: () => _renewSubscription(subscription),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Renovar'),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => _cancelSubscription(subscription.id),
                    icon: const Icon(Icons.cancel_outlined),
                    label: const Text('Cancelar'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ] else ...[
                  TextButton.icon(
                    onPressed: () => _renewSubscription(subscription),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reactivar'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget para mostrar información de suscripción
  Widget _buildSubscriptionInfo(
    String label,
    String value,
    IconData icon,
    ColorScheme colorScheme, {
    Color? textColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textColor ?? colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
