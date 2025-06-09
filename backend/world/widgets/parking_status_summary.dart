import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/world_state.dart';
import '../models/parking_spot.dart';
import '../models/world_elements.dart';
import '../models/enums.dart';

/// Widget que muestra un resumen del estado del estacionamiento
class ParkingStatusSummary extends StatelessWidget {
  final bool compact;
  
  const ParkingStatusSummary({
    Key? key,
    this.compact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<WorldState>(
      builder: (context, state, child) {
        // Obtener estadísticas
        final stats = _calculateStats(state);
        
        return Container(
          padding: EdgeInsets.all(compact ? 8.0 : 16.0),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: compact ? _buildCompactSummary(context, stats) : _buildFullSummary(context, stats),
        );
      },
    );
  }
  
  Widget _buildCompactSummary(BuildContext context, Map<String, dynamic> stats) {
    final theme = Theme.of(context);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildStatusIndicator(
          context, 
          stats['availableSpots'],
          stats['totalSpots'],
          Colors.green,
          Icons.check_circle,
          'Disponibles'
        ),
        const SizedBox(width: 12),
        _buildStatusIndicator(
          context, 
          stats['occupiedSpots'],
          stats['totalSpots'],
          Colors.red,
          Icons.cancel,
          'Ocupados'
        ),
      ],
    );
  }
  
  Widget _buildFullSummary(BuildContext context, Map<String, dynamic> stats) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Estado del Estacionamiento',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildStatusIndicator(
              context, 
              stats['availableSpots'],
              stats['totalSpots'],
              Colors.green,
              Icons.check_circle,
              'Disponibles'
            ),
            const SizedBox(width: 20),
            _buildStatusIndicator(
              context, 
              stats['occupiedSpots'],
              stats['totalSpots'],
              Colors.red,
              Icons.cancel,
              'Ocupados'
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Por categoría:',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            _buildCategoryItem(context, 'Normal', stats['normalSpots'], stats['normalOccupied']),
            _buildCategoryItem(context, 'Discapacitados', stats['disabledSpots'], stats['disabledOccupied']),
            _buildCategoryItem(context, 'Reservados', stats['reservedSpots'], stats['reservedOccupied']),
            _buildCategoryItem(context, 'VIP', stats['vipSpots'], stats['vipOccupied']),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Última actualización: ${_formatTime(DateTime.now())}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
            fontSize: 10,
          ),
        ),
      ],
    );
  }
  
  Widget _buildStatusIndicator(
    BuildContext context, 
    int value, 
    int total, 
    Color color,
    IconData icon,
    String label
  ) {
    final theme = Theme.of(context);
    final percentage = total > 0 ? (value / total * 100).toInt() : 0;
    
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$label: $value/$total',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$percentage%',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildCategoryItem(BuildContext context, String label, int total, int occupied) {
    final theme = Theme.of(context);
    final available = total - occupied;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$available',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '/',
                style: theme.textTheme.bodyMedium,
              ),
              Text(
                '$total',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Map<String, dynamic> _calculateStats(WorldState state) {
    final spots = state.spots;
    
    int totalSpots = spots.length;
    int occupiedSpots = spots.where((spot) => spot.isOccupied).length;
    int availableSpots = totalSpots - occupiedSpots;
    
    // Estadísticas por categoría
    int normalSpots = spots.where((spot) => spot.category == SpotCategory.normal).length;
    int disabledSpots = spots.where((spot) => spot.category == SpotCategory.disabled).length;
    int reservedSpots = spots.where((spot) => spot.category == SpotCategory.reserved).length;
    int vipSpots = spots.where((spot) => spot.category == SpotCategory.vip).length;
    
    int normalOccupied = spots.where((spot) => 
        spot.category == SpotCategory.normal && spot.isOccupied).length;
    int disabledOccupied = spots.where((spot) => 
        spot.category == SpotCategory.disabled && spot.isOccupied).length;
    int reservedOccupied = spots.where((spot) => 
        spot.category == SpotCategory.reserved && spot.isOccupied).length;
    int vipOccupied = spots.where((spot) => 
        spot.category == SpotCategory.vip && spot.isOccupied).length;
    
    return {
      'totalSpots': totalSpots,
      'occupiedSpots': occupiedSpots,
      'availableSpots': availableSpots,
      'normalSpots': normalSpots,
      'disabledSpots': disabledSpots,
      'reservedSpots': reservedSpots,
      'vipSpots': vipSpots,
      'normalOccupied': normalOccupied,
      'disabledOccupied': disabledOccupied,
      'reservedOccupied': reservedOccupied,
      'vipOccupied': vipOccupied,
    };
  }
  
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
  }
} 