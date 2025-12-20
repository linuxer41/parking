import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/parking_state.dart';
import '../models/parking_spot.dart';

/// Panel inferior reutilizable con información del estado del parking
class ParkingStatusPanel extends StatelessWidget {
  final ParkingState state;
  final double? cashTotal;
  final VoidCallback? onCashTap;

  const ParkingStatusPanel({
    super.key,
    required this.state,
    this.cashTotal,
    this.onCashTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
          if (element.entry != null) {
            try {
              final stayDuration = DateTime.now().difference(
                DateTime.parse(element.entry!.startDate),
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
            ? colorScheme.surface.withValues(alpha: 0.95)
            : colorScheme.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
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

            // Separador vertical
            if (cashTotal != null) Container(height: 40, width: 1, color: colorScheme.outlineVariant),

            // Total de Caja (solo si hay datos)
            if (cashTotal != null)
              _buildStatusItem(
                icon: Icons.attach_money,
                iconColor: Colors.green,
                label: 'Caja',
                value: '\$${cashTotal!.toStringAsFixed(0)}',
                theme: theme,
                colorScheme: colorScheme,
                onTap: onCashTap,
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
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icono con fondo circular suave
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: iconColor.withValues(alpha: 0.3),
                  width: 1,
                ),
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
      ),
    );
  }
}
