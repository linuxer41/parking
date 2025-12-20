import 'package:flutter/material.dart';
import '../../widgets/page_layout.dart';

class StatisticsPanel extends StatelessWidget {
  const StatisticsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return PageLayout(title: 'Estadísticas', body: _buildMainContent());
  }

  // Contenido principal
  Widget _buildMainContent() {
    return RefreshIndicator(
      onRefresh: () async {
        // Implementar refresh de estadísticas
        await Future.delayed(const Duration(seconds: 1));
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Builder(
          builder: (context) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Resumen general
              _buildSummaryCard(context),

              const SizedBox(height: 24),

              // Estadísticas de ganancias
              _buildEarningsSection(context),

              const SizedBox(height: 24),

              // Estadísticas de ocupación
              _buildOccupancySection(context),

              const SizedBox(height: 24),

              // Botones de acción
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 60),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.trending_up_rounded,
                  color: colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Resumen Diario',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context,
                  'Ganancia',
                  '\$1,250',
                  Icons.attach_money_rounded,
                  colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  context,
                  'Ocupación',
                  '85%',
                  Icons.local_parking_rounded,
                  colorScheme.secondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.attach_money_rounded,
              size: 20,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Text(
              'Ganancias',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _buildEarningsRow(context, 'Hoy', '\$1,250', '+12%'),
              Divider(
                height: 32,
                color: colorScheme.outline.withValues(alpha: 60),
              ),
              _buildEarningsRow(context, 'Esta semana', '\$8,750', '+8%'),
              Divider(
                height: 32,
                color: colorScheme.outline.withValues(alpha: 60),
              ),
              _buildEarningsRow(context, 'Este mes', '\$32,500', '+15%'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEarningsRow(
    BuildContext context,
    String period,
    String amount,
    String change,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isPositive = change.startsWith('+');

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          period,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        Row(
          children: [
            Text(
              amount,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isPositive
                    ? Colors.green.withValues(alpha: 60)
                    : Colors.red.withValues(alpha: 60),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                change,
                style: textTheme.bodySmall?.copyWith(
                  color: isPositive ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOccupancySection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.local_parking_rounded,
              size: 20,
              color: colorScheme.secondary,
            ),
            const SizedBox(width: 12),
            Text(
              'Ocupación',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _buildOccupancyRow(context, 'Ocupados', '85', 'de 100'),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: 0.85,
                backgroundColor: colorScheme.outline.withValues(alpha: 60),
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                minHeight: 8,
              ),
              const SizedBox(height: 12),
              Text(
                '85% de ocupación actual',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOccupancyRow(
    BuildContext context,
    String label,
    String occupied,
    String total,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          '$occupied $total',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivitySection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.history_rounded, size: 20, color: colorScheme.tertiary),
            const SizedBox(width: 12),
            Text(
              'Actividad reciente',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _buildActivityItem(
                context,
                'Nuevo vehículo registrado',
                'Hace 5 minutos',
                Icons.directions_car_rounded,
                colorScheme.primary,
              ),
              Divider(
                height: 1,
                color: colorScheme.outline.withValues(alpha: 60),
              ),
              _buildActivityItem(
                context,
                'Pago recibido',
                'Hace 15 minutos',
                Icons.payment_rounded,
                Colors.green,
              ),
              Divider(
                height: 1,
                color: colorScheme.outline.withValues(alpha: 60),
              ),
              _buildActivityItem(
                context,
                'Vehículo salió',
                'Hace 30 minutos',
                Icons.exit_to_app_rounded,
                colorScheme.secondary,
              ),
              Divider(
                height: 1,
                color: colorScheme.outline.withValues(alpha: 60),
              ),
              _buildActivityItem(
                context,
                'Nueva reserva',
                'Hace 1 hora',
                Icons.book_online_rounded,
                colorScheme.tertiary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(
    BuildContext context,
    String title,
    String time,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 60),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Acciones rápidas',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () {
                  // Implementar exportar reporte
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Exportando reporte...'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: colorScheme.primary,
                    ),
                  );
                },
                icon: const Icon(Icons.download_rounded),
                label: const Text('Exportar'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: () {
                  // Implementar compartir
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Compartiendo estadísticas...'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: colorScheme.secondary,
                    ),
                  );
                },
                icon: const Icon(Icons.share_rounded),
                label: const Text('Compartir'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: colorScheme.secondaryContainer,
                  foregroundColor: colorScheme.onSecondaryContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
