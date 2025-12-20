import 'dart:async';
import 'package:flutter/material.dart';
import '../../widgets/page_layout.dart';
import '../../state/app_state_container.dart';
import '../../services/parking_service.dart';
import '../../models/parking_model.dart';

class ManageSubscriptionScreen extends StatefulWidget {
  const ManageSubscriptionScreen({super.key});

  @override
  State<ManageSubscriptionScreen> createState() => _ManageSubscriptionScreenState();
}

class _ManageSubscriptionScreenState extends State<ManageSubscriptionScreen> {
  late ParkingService _parkingService;
  bool _isLoading = true;
  ParkingModel? _currentParking;

  // Mock data for subscription plans (since functionality is not active yet)
  final List<Map<String, dynamic>> _subscriptionPlans = [
    {
      'id': 'basic',
      'name': 'Plan Básico',
      'price': 29.99,
      'currency': 'USD',
      'features': [
        'Hasta 5 estacionamientos',
        'Reportes básicos',
        'Soporte por email',
        'Actualizaciones gratuitas',
      ],
      'isPopular': false,
      'isCurrent': true,
    },
    {
      'id': 'professional',
      'name': 'Plan Profesional',
      'price': 79.99,
      'currency': 'USD',
      'features': [
        'Hasta 25 estacionamientos',
        'Reportes avanzados',
        'Soporte prioritario',
        'API access',
        'Integraciones personalizadas',
      ],
      'isPopular': true,
      'isCurrent': false,
    },
    {
      'id': 'enterprise',
      'name': 'Plan Empresarial',
      'price': 199.99,
      'currency': 'USD',
      'features': [
        'Estacionamientos ilimitados',
        'Reportes personalizados',
        'Soporte 24/7',
        'API completa',
        'Consultoría dedicada',
        'SLA garantizado',
      ],
      'isPopular': false,
      'isCurrent': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    // Don't call _loadCompanyData here - wait for didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _parkingService = AppStateContainer.di(context).resolve<ParkingService>();
    _loadCompanyDetails();
  }

  // Cargar los detalles de la empresa
  Future<void> _loadCompanyDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final appState = AppStateContainer.of(context);
      final currentParking = appState.currentParking;

      if (currentParking == null) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        return;
      }

      // Load full parking data to get company information
      final parking = await _parkingService.getParkingById(currentParking.id).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Tiempo de espera agotado'),
      );

      if (mounted) {
        setState(() {
          _currentParking = parking;
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
            content: Text('Error al cargar información de la empresa: ${e.toString()}'),
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

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      title: 'Administrar Suscripción',
      body: _buildMainContent(),
    );
  }

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
              'Cargando información...',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    if (_currentParking == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.business_outlined,
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
                'No se encontró información de la empresa',
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
      onRefresh: _loadCompanyDetails,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: _buildSubscriptionContent(),
      ),
    );
  }

  Widget _buildSubscriptionContent() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Company Information Card
          Card(
            elevation: 0,
            color: colorScheme.surfaceContainerHighest,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: colorScheme.outlineVariant.withOpacity(0.3),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.business,
                        color: colorScheme.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Información de la Empresa',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_currentParking?.owner?.name != null) ...[
                    _buildInfoRow(
                      'Propietario',
                      _currentParking!.owner!.name,
                      Icons.person,
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (_currentParking?.name != null) ...[
                    _buildInfoRow(
                      'Estacionamiento',
                      _currentParking!.name,
                      Icons.local_parking,
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (_currentParking?.email != null) ...[
                    _buildInfoRow(
                      'Email',
                      _currentParking!.email!,
                      Icons.email,
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (_currentParking?.phone != null) ...[
                    _buildInfoRow(
                      'Teléfono',
                      _currentParking!.phone!,
                      Icons.phone,
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Current Plan Status
          Card(
            elevation: 0,
            color: colorScheme.primaryContainer.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: colorScheme.primary.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: colorScheme.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Plan Actual: Básico',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tu suscripción actual incluye funciones básicas del sistema.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Próxima renovación: 15 Dic 2024',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Available Plans
          Text(
            'Planes Disponibles',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),

          const SizedBox(height: 16),

          ..._subscriptionPlans.map((plan) => _buildPlanCard(plan)).toList(),

          const SizedBox(height: 32),

          // Usage Statistics (Mock data for now)
          Text(
            'Estadísticas de Uso',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),

          const SizedBox(height: 16),

          _buildUsageStats(),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: colorScheme.primary, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
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

  Widget _buildPlanCard(Map<String, dynamic> plan) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isCurrent = plan['isCurrent'] as bool;
    final isPopular = plan['isPopular'] as bool;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: isPopular ? 4 : 0,
      color: isCurrent
          ? colorScheme.primaryContainer.withOpacity(0.5)
          : colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isCurrent
              ? colorScheme.primary.withOpacity(0.5)
              : isPopular
                  ? colorScheme.primary.withOpacity(0.3)
                  : colorScheme.outlineVariant.withOpacity(0.3),
          width: isCurrent ? 2 : 1,
        ),
      ),
      child: Stack(
        children: [
          if (isPopular) ...[
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Más Popular',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      plan['name'],
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    if (isCurrent) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Actual',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '\$${plan['price']}',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${plan['currency']}/mes',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...List<Widget>.from(
                  (plan['features'] as List<String>).map(
                    (feature) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: colorScheme.primary,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              feature,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: isCurrent
                        ? null
                        : () => _upgradeToPlan(plan),
                    style: FilledButton.styleFrom(
                      backgroundColor: isCurrent
                          ? colorScheme.onSurfaceVariant
                          : colorScheme.primary,
                      foregroundColor: isCurrent
                          ? colorScheme.surface
                          : colorScheme.onPrimary,
                    ),
                    child: Text(isCurrent ? 'Plan Actual' : 'Actualizar Plan'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageStats() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.outlineVariant.withOpacity(0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildStatItem(
              'Estacionamientos Activos',
              '1 de 5',
              Icons.local_parking,
              colorScheme.primary,
              0.2, // 1/5
            ),
            const SizedBox(height: 16),
            _buildStatItem(
              'Reportes Generados',
              '45 este mes',
              Icons.assessment,
              colorScheme.secondary,
              0.75, // Mock progress
            ),
            const SizedBox(height: 16),
            _buildStatItem(
              'Uso de API',
              '2,340 llamadas',
              Icons.api,
              colorScheme.tertiary,
              0.4, // Mock progress
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon, Color color, double progress) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: color.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _upgradeToPlan(Map<String, dynamic> plan) {
    // Mock functionality - subscription to business plan not active yet
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Actualizar a ${plan['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.info_outline,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'La funcionalidad de suscripción a planes empresariales aún no está disponible.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Esta es una vista previa de los planes que estarán disponibles próximamente.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
}