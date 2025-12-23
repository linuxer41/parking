import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../constants/constants.dart';
import '../../../models/access_model.dart';

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
  }

  @override
  void dispose() {
    _amountUpdateTimer?.cancel();
    super.dispose();
  }

  void _startAmountUpdateTimer() {
    _amountUpdateTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted && widget.onRefresh != null) {
        widget.onRefresh!();
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
                access.vehicle.plate,
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
                      'Número: ${access.number}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  Text(
                    'Propietario: ${access.vehicle.ownerName ?? '--'}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    'Entrada: ${_formatDateTime(access.entryTime)}',
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
                      CurrencyConstants.formatAmountWithParkingParams(context, access.amount),
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
            if (!widget.isSimpleMode) const DataColumn(label: Text('Número')),
            const DataColumn(label: Text('Placa')),
            const DataColumn(label: Text('Tipo')),
            const DataColumn(label: Text('Propietario')),
            const DataColumn(label: Text('Hora Entrada')),
            const DataColumn(label: Text('Monto')),
            const DataColumn(label: Text('Acción')),
          ],
          rows: widget.accesses.map((access) {
            return DataRow(
              cells: [
                if (!widget.isSimpleMode) DataCell(Text(access.number.toString())),
                DataCell(Text(access.vehicle.plate)),
                DataCell(Text(_getVehicleTypeName(access.vehicle.type))),
                DataCell(Text(access.vehicle.ownerName ?? '--')),
                DataCell(Text(_formatDateTime(access.entryTime))),
                DataCell(Text(CurrencyConstants.formatAmountWithParkingParams(context, access.amount))),
                DataCell(
                  Center(
                    child: InkWell(
                      onTap: () => widget.onAccessAction?.call(access),
                      child: Icon(
                        Icons.visibility,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
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

  String _formatDateTime(DateTime dateTime) {
    try {
      return DateFormat('HH:mm dd/MM').format(dateTime);
    } catch (e) {
      return '--';
    }
  }
}