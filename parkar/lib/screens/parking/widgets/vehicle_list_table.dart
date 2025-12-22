import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../parking_map/models/parking_spot.dart';

/// Widget para mostrar una tabla de spots ocupados en modo list
class VehicleListTable extends StatefulWidget {
  final List<ParkingSpot> occupiedSpots;
  final Future<void> Function()? onRefresh;
  final bool isLoading;
  final Function(ParkingSpot)? onAccessAction;
  final Function(ParkingSpot)? onReservationAction;
  final Function(ParkingSpot)? onSubscriptionAction;
  final bool isSimpleMode;

  const VehicleListTable({
    super.key,
    required this.occupiedSpots,
    this.onRefresh,
    this.isLoading = false,
    this.onAccessAction,
    this.onReservationAction,
    this.onSubscriptionAction,
    this.isSimpleMode = false,
  });

  @override
  State<VehicleListTable> createState() => _VehicleListTableState();
}

class _VehicleListTableState extends State<VehicleListTable> {
  bool _isTableMode = true;

  @override
  void initState() {
    super.initState();
    // Determinar el modo inicial basado en el tamaño de pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenWidth = MediaQuery.of(context).size.width;
      setState(() {
        _isTableMode = screenWidth >= 600;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Título sticky
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              border: Border(
                bottom: BorderSide(
                  color: colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.car_rental, size: 20, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Ocupados (${widget.occupiedSpots.length})',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const Spacer(),

                // Toggle para cambiar entre tabla y lista
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Botón Lista
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isTableMode = false;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: !_isTableMode
                                ? colorScheme.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.view_list,
                            size: 16,
                            color: !_isTableMode
                                ? colorScheme.onPrimary
                                : colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),

                      // Botón Tabla
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isTableMode = true;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _isTableMode
                                ? colorScheme.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.table_chart,
                            size: 16,
                            color: _isTableMode
                                ? colorScheme.onPrimary
                                : colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Botón de actualizar
                if (widget.onRefresh != null)
                  IconButton(
                    onPressed: widget.isLoading ? null : widget.onRefresh,
                    icon: widget.isLoading
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.primary,
                            ),
                          )
                        : Icon(
                            Icons.refresh,
                            size: 20,
                            color: colorScheme.primary,
                          ),
                    tooltip: 'Actualizar',
                  ),
              ],
            ),
          ),

          // Contenido scrolleable
          Expanded(
            child: widget.onRefresh != null
                ? RefreshIndicator(
                    onRefresh: widget.onRefresh!,
                    color: colorScheme.primary,
                    child: _buildContent(theme, colorScheme),
                  )
                : _buildContent(theme, colorScheme),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ThemeData theme, ColorScheme colorScheme) {
    if (widget.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.occupiedSpots.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.car_rental_outlined,
              size: 48,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No hay vehículos ocupados',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Los vehículos aparecerán aquí cuando ocupen un espacio',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return _isTableMode
        ? _buildDesktopTable(theme, colorScheme)
        : _buildMobileList(theme, colorScheme);
  }

  Widget _buildMobileList(ThemeData theme, ColorScheme colorScheme) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(8),
      itemCount: widget.occupiedSpots.length,
      itemBuilder: (context, index) {
        final spot = widget.occupiedSpots[index];
        final entry = spot.entry;
        final startDate = entry?.startDate;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.directions_car,
                color: colorScheme.primary,
                size: 20,
              ),
            ),
            title: Text(
              entry?.vehiclePlate ?? '--',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                if (!widget.isSimpleMode)
                  Text(
                    'Espacio: ${spot.label}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                Text(
                  'Propietario: ${entry?.ownerName ?? '--'}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                if (startDate != null)
                  Text(
                    'Entrada: ${_formatDateTime(startDate)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Badge de estado y botón de acción en la misma fila
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    _getOccupancyTypeText(spot),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w500,
                      fontSize: 10,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                // Botón de acción más compacto
                _buildActionButton(spot, theme, colorScheme),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDesktopTable(ThemeData theme, ColorScheme colorScheme) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: DataTable(
          headingTextStyle: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
          dataTextStyle: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface,
          ),
          columns: [
            if (!widget.isSimpleMode) const DataColumn(label: Text('Espacio')),
            const DataColumn(label: Text('Placa')),
            const DataColumn(label: Text('Tipo')),
            const DataColumn(label: Text('Propietario')),
            const DataColumn(label: Text('Hora Entrada')),
            const DataColumn(label: Text('Estado')),
            const DataColumn(label: Text('Acción')),
          ],
          rows: widget.occupiedSpots.map((spot) {
            final entry = spot.entry;
            final startDate = entry?.startDate;

            return DataRow(
              cells: [
                if (!widget.isSimpleMode) DataCell(Text(spot.label)),
                DataCell(Text(entry?.vehiclePlate ?? '--')),
                DataCell(Text('--')), // Type not available
                DataCell(Text(entry?.ownerName ?? '--')),
                DataCell(
                  Text(startDate != null ? _formatDateTime(startDate) : '--'),
                ),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: colorScheme.outline.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      _getOccupancyTypeText(spot),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                DataCell(_buildActionButton(spot, theme, colorScheme)),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    ParkingSpot spot,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    if (spot.entry != null) {
      // Es un acceso - mostrar botón de "Registrar Salida"
      return Container(
        decoration: BoxDecoration(
          color: colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
        ),
        child: IconButton(
          onPressed: () => widget.onAccessAction?.call(spot),
          icon: Icon(Icons.exit_to_app, size: 16, color: colorScheme.error),
          tooltip: 'Registrar Salida',
          padding: const EdgeInsets.all(4),
          constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
        ),
      );
    } else if (spot.booking != null) {
      // Es una reserva - mostrar botón de "Marcar Acceso"
      return Container(
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
        ),
        child: IconButton(
          onPressed: () => widget.onReservationAction?.call(spot),
          icon: Icon(Icons.login, size: 16, color: colorScheme.primary),
          tooltip: 'Marcar Acceso',
          padding: const EdgeInsets.all(4),
          constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
        ),
      );
    } else if (spot.subscription != null) {
      // Es una suscripción - mostrar botón de "Marcar Acceso"
      return Container(
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
        ),
        child: IconButton(
          onPressed: () => widget.onSubscriptionAction?.call(spot),
          icon: Icon(Icons.login, size: 16, color: colorScheme.primary),
          tooltip: 'Marcar Acceso',
          padding: const EdgeInsets.all(4),
          constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
        ),
      );
    }

    // Sin acción disponible
    return const SizedBox.shrink();
  }

  String _getOccupancyTypeText(ParkingSpot spot) {
    if (spot.entry != null) {
      return 'Acceso';
    } else if (spot.booking != null) {
      return 'Reserva';
    } else if (spot.subscription != null) {
      return 'Suscripción';
    }

    return 'Ocupado';
  }

  String _getVehicleTypeName(String type) {
    switch (type.toLowerCase()) {
      case 'car':
        return 'Automóvil';
      case 'motorcycle':
        return 'Motocicleta';
      case 'truck':
        return 'Camión';
      case 'bicycle':
        return 'Bicicleta';
      default:
        return 'Vehículo';
    }
  }

  String _formatDateTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return DateFormat('HH:mm').format(dateTime);
    } catch (e) {
      return '--';
    }
  }
}
