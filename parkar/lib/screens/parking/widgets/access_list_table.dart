import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parkar/constants/constants.dart';
import '../../../models/access_model.dart';
import '../../../state/app_state_container.dart';
import '../../../utils/parking_utils.dart';

/// Widget para mostrar una tabla de accesos en modo list
class AccessListTable extends StatefulWidget {
  final List<AccessModel> accesses;
  final Future<void> Function()? onRefresh;
  final bool isLoading;
  final Function(AccessModel)? onAccessAction;
  final bool isSimpleMode;

  const AccessListTable({
    super.key,
    required this.accesses,
    this.onRefresh,
    this.isLoading = false,
    this.onAccessAction,
    this.isSimpleMode = false,
  });

  @override
  State<AccessListTable> createState() => _AccessListTableState();
}

class _AccessListTableState extends State<AccessListTable> {
  bool _isTableMode = true;
  Timer? _amountUpdateTimer;
  Timer? _realTimeUpdateTimer;
  DateTime _lastUpdate = DateTime.now();

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

    // Iniciar timer para actualizar montos en tiempo real cada minuto
    _startAmountUpdateTimer();

    // Iniciar timer para actualizar UI en tiempo real cada 10 segundos
    _startRealTimeUpdateTimer();
  }

  @override
  void dispose() {
    _amountUpdateTimer?.cancel();
    _realTimeUpdateTimer?.cancel();
    super.dispose();
  }

  void _startAmountUpdateTimer() {
    _amountUpdateTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted && widget.onRefresh != null) {
        widget.onRefresh!();
      }
    });
  }

  void _startRealTimeUpdateTimer() {
    _realTimeUpdateTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (mounted) {
        setState(() {
          _lastUpdate = DateTime.now();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      color: colorScheme.surface,
      child: Column(
        children: [
          // Título sticky
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            color: colorScheme.surfaceContainerHighest,
            child: Row(
              children: [
                // Sección izquierda: Título y subtítulo con cantidad
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'En el parqueo',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              '${widget.accesses.length} vehículos en parqueo',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Sección derecha: Controles
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
                                horizontal: 8,
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
                                horizontal: 8,
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

                    // Botón de actualizar
                    // if (widget.onRefresh != null)
                    //   IconButton(
                    //     onPressed: widget.isLoading ? null : widget.onRefresh,
                    //     icon: widget.isLoading
                    //         ? SizedBox(
                    //             width: 16,
                    //             height: 16,
                    //             child: CircularProgressIndicator(
                    //               strokeWidth: 2,
                    //               color: colorScheme.primary,
                    //             ),
                    //           )
                    //         : Icon(
                    //             Icons.refresh,
                    //             size: 20,
                    //             color: colorScheme.primary,
                    //           ),
                    //     tooltip: 'Actualizar',
                    //     padding: EdgeInsets.zero,
                    //     constraints: const BoxConstraints(),
                    //   ),
                  ],
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

    if (widget.accesses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_parking,
              size: 48,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No hay vehículos en el parqueo',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Los vehículos aparecerán aquí cuando entren al estacionamiento',
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
      itemCount: widget.accesses.length,
      itemBuilder: (context, index) {
        final access = widget.accesses[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: InkWell(
            onTap: () => widget.onAccessAction?.call(access),
            borderRadius: BorderRadius.circular(8),
            child: Column(
              children: [
                ListTile(
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
                    access.vehicle.plate,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        'Permanencia: ${_formatElapsedTime(access.entryTime)} • ${_getVehicleTypeName(access.vehicle.type)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Badge de monto a pagar
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: colorScheme.outline.withValues(alpha: 0.5),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary.withValues(alpha: 0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          CurrencyConstants.formatAmountWithParkingParams(context, _calculateCurrentCost(access)),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Chevron indicador
                      Icon(
                        Icons.chevron_right,
                        color: colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                    ],
                  ),
                ),
                // Additional details below
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: Row(
                    children: [
                      if (!widget.isSimpleMode)
                        Expanded(
                          child: Text(
                            'N° ${access.number}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      Expanded(
                        child: Text(
                          'Propietario: ${access.vehicle.ownerName ?? '--'}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Ingreso: ${_formatDateTime(access.entryTime)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ),
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
      child: Column(
        children: [
          // Header
          Container(
            color: colorScheme.surfaceContainerHighest,
            child: Row(
              children: [
                Expanded(flex: 2, child: Padding(padding: const EdgeInsets.all(12), child: Text('Ingreso', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)))),
                Expanded(flex: 2, child: Padding(padding: const EdgeInsets.all(12), child: Text('Placa', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)))),
                Expanded(flex: 2, child: Padding(padding: const EdgeInsets.all(12), child: Text('Permanencia', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)))),
                Expanded(flex: 2, child: Padding(padding: const EdgeInsets.all(12), child: Text('Costo', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)))),
                Expanded(flex: 3, child: Padding(padding: const EdgeInsets.all(12), child: Text('Propietario', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)))),
                Expanded(flex: 2, child: Padding(padding: const EdgeInsets.all(12), child: Text('Tipo', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)))),
              ],
            ),
          ),
          ...widget.accesses.map((access) => _buildTableRow(access, theme, colorScheme)),
        ],
      ),
    );
  }

  Widget _buildTableRow(AccessModel access, ThemeData theme, ColorScheme colorScheme) {
    return InkWell(
      onTap: () => widget.onAccessAction?.call(access),
      hoverColor: colorScheme.primary.withValues(alpha: 0.1),
      mouseCursor: SystemMouseCursors.click,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Expanded(flex: 2, child: Padding(padding: const EdgeInsets.only(left: 12), child: Text(_formatDateTime(access.entryTime), style: theme.textTheme.bodyMedium))),
            Expanded(flex: 2, child: Text(access.vehicle.plate, style: theme.textTheme.bodyMedium)),
            Expanded(flex: 2, child: Text(_formatElapsedTime(access.entryTime), style: theme.textTheme.bodyMedium)),
            Expanded(flex: 2, child: Text(CurrencyConstants.formatAmountWithParkingParams(context, _calculateCurrentCost(access)), style: theme.textTheme.bodyMedium)),
            Expanded(flex: 3, child: Text(access.vehicle.ownerName ?? '--', style: theme.textTheme.bodyMedium)),
            Expanded(flex: 2, child: Text(_getVehicleTypeName(access.vehicle.type), style: theme.textTheme.bodyMedium)),
            Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant, size: 16),
          ],
        ),
      ),
    );
  }


  String _getVehicleTypeName(String? type) {
    return getVehicleCategoryLabel(type);
  }

  String _formatDateTime(DateTime dateTime) {
    try {
      return DateTimeConstants.formatDateTimeWithParkingParams(context, dateTime, format: 'HH:mm dd/MM');
    } catch (e) {
      return '--';
    }
  }

  String _formatElapsedTime(DateTime entryTime) {
    final now = DateTime.now();
    final duration = now.difference(entryTime);

    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  double _calculateCurrentCost(AccessModel access) {
    try {
      final appState = AppStateContainer.of(context);
      final rates = appState.currentParking?.rates ?? [];
      if (rates.isEmpty) return access.amount;

      return calculateParkingFee(
        access.entryTime.toIso8601String(),
        rates,
        access.vehicle.type,
      );
    } catch (e) {
      return access.amount;
    }
  }
}