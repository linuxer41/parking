import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../constants/constants.dart';
import '../../../../models/access_model.dart';

/// Componente para mostrar una tabla de reportes de acceso con paginación
class AccessReportTable extends StatefulWidget {
  final List<AccessModel> accesses;
  final bool isLoading;
  final String? error;
  final VoidCallback? onRetry;

  const AccessReportTable({
    super.key,
    required this.accesses,
    this.isLoading = false,
    this.error,
    this.onRetry,
  });

  @override
  State<AccessReportTable> createState() => _AccessReportTableState();
}

class _AccessReportTableState extends State<AccessReportTable> {
  int _rowsPerPage = 10;
  int _currentPage = 0;
  final List<int> _availableRowsPerPage = [10, 25, 50, 100];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (widget.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error al cargar datos',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.error!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            if (widget.onRetry != null)
              FilledButton(
                onPressed: widget.onRetry,
                child: const Text('Reintentar'),
              ),
          ],
        ),
      );
    }

    if (widget.accesses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.table_chart_outlined,
              size: 48,
              color: colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No hay accesos en el período seleccionado',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      );
    }

    final totalPages = (widget.accesses.length / _rowsPerPage).ceil();
    final startIndex = _currentPage * _rowsPerPage;
    final endIndex = (_currentPage + 1) * _rowsPerPage;
    final currentPageData = widget.accesses.sublist(
      startIndex,
      endIndex > widget.accesses.length ? widget.accesses.length : endIndex,
    );

    return Column(
      children: [
        // Tabla
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingTextStyle: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
              dataTextStyle: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
              columns: const [
                DataColumn(label: Text('Fecha/Hora')),
                DataColumn(label: Text('Placa')),
                DataColumn(label: Text('Tipo')),
                DataColumn(label: Text('Propietario')),
                DataColumn(label: Text('Monto')),
                DataColumn(label: Text('Estado')),
              ],
              rows: currentPageData.map((access) => DataRow(
                cells: [
                  DataCell(Text(_formatDateTime(access.entryTime))),
                  DataCell(Text(access.vehicle.plate.toUpperCase())),
                  DataCell(Text(_getVehicleTypeName(access.vehicle.type))),
                  DataCell(Text(access.vehicle.ownerName ?? '--')),
                  DataCell(Text(CurrencyConstants.formatAmountWithParkingParams(context, access.amount))),
                  DataCell(_buildStatusChip(access, colorScheme)),
                ],
              )).toList(),
            ),
          ),
        ),

        // Paginación
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Column(
            children: [
              // Información de paginación y controles de filas por página
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Información de registros
                  Text(
                    'Mostrando ${startIndex + 1}-${endIndex > widget.accesses.length ? widget.accesses.length : endIndex} de ${widget.accesses.length} registros',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),

                  // Selector de filas por página
                  Row(
                    children: [
                      Text(
                        'Filas por página:',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 8),
                      DropdownButton<int>(
                        value: _rowsPerPage,
                        items: _availableRowsPerPage.map((size) {
                          return DropdownMenuItem<int>(
                            value: size,
                            child: Text(size.toString()),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _rowsPerPage = value;
                              _currentPage = 0; // Reset to first page
                            });
                          }
                        },
                        underline: const SizedBox(),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Controles de navegación
              if (totalPages > 1)
                Column(
                  children: [
                    // Navegación por números de página
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: _buildPageNumberButtons(totalPages, colorScheme),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Controles adicionales
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Primera página
                        IconButton(
                          onPressed: _currentPage > 0
                              ? () => setState(() => _currentPage = 0)
                              : null,
                          icon: const Icon(Icons.first_page),
                          tooltip: 'Primera página',
                          iconSize: 20,
                        ),

                        // Página anterior
                        IconButton(
                          onPressed: _currentPage > 0
                              ? () => setState(() => _currentPage--)
                              : null,
                          icon: const Icon(Icons.chevron_left),
                          tooltip: 'Página anterior',
                        ),

                        // Indicador de página con input para saltar
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: colorScheme.outlineVariant),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Text(
                                'Página',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 40,
                                child: TextField(
                                  controller: TextEditingController(text: (_currentPage + 1).toString()),
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodySmall,
                                  decoration: const InputDecoration(
                                    isDense: true,
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  onSubmitted: (value) {
                                    final page = int.tryParse(value);
                                    if (page != null && page > 0 && page <= totalPages) {
                                      setState(() => _currentPage = page - 1);
                                    }
                                  },
                                ),
                              ),
                              Text(
                                ' de $totalPages',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Página siguiente
                        IconButton(
                          onPressed: _currentPage < totalPages - 1
                              ? () => setState(() => _currentPage++)
                              : null,
                          icon: const Icon(Icons.chevron_right),
                          tooltip: 'Página siguiente',
                        ),

                        // Última página
                        IconButton(
                          onPressed: _currentPage < totalPages - 1
                              ? () => setState(() => _currentPage = totalPages - 1)
                              : null,
                          icon: const Icon(Icons.last_page),
                          tooltip: 'Última página',
                          iconSize: 20,
                        ),
                      ],
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(AccessModel access, ColorScheme colorScheme) {
    final isActive = access.exitTime == null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? colorScheme.primaryContainer
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isActive ? 'Activo' : 'Completado',
        style: TextStyle(
          color: isActive
              ? colorScheme.onPrimaryContainer
              : colorScheme.onSurfaceVariant,
          fontSize: 12,
          fontWeight: FontWeight.w500,
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
      case 'van':
        return 'Camioneta';
      case 'bicycle':
        return 'Bicicleta';
      default:
        return 'Vehículo';
    }
  }

  List<Widget> _buildPageNumberButtons(int totalPages, ColorScheme colorScheme) {
    final theme = Theme.of(context);
    List<Widget> buttons = [];

    // Determinar rango de páginas a mostrar
    int startPage = 0;
    int endPage = totalPages;

    // Si hay muchas páginas, mostrar solo un rango alrededor de la página actual
    if (totalPages > 7) {
      startPage = (_currentPage - 3).clamp(0, totalPages - 7);
      endPage = (startPage + 7).clamp(0, totalPages);
    }

    // Botón de primera página si no está en el rango
    if (startPage > 0) {
      buttons.add(_buildPageButton(1, colorScheme, theme));
      if (startPage > 1) {
        buttons.add(const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text('...'),
        ));
      }
    }

    // Botones de páginas
    for (int i = startPage; i < endPage; i++) {
      buttons.add(_buildPageButton(i + 1, colorScheme, theme));
    }

    // Botón de última página si no está en el rango
    if (endPage < totalPages) {
      if (endPage < totalPages - 1) {
        buttons.add(const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text('...'),
        ));
      }
      buttons.add(_buildPageButton(totalPages, colorScheme, theme));
    }

    return buttons;
  }

  Widget _buildPageButton(int pageNumber, ColorScheme colorScheme, ThemeData theme) {
    final isCurrentPage = pageNumber - 1 == _currentPage;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: TextButton(
        onPressed: () => setState(() => _currentPage = pageNumber - 1),
        style: TextButton.styleFrom(
          backgroundColor: isCurrentPage
              ? colorScheme.primary
              : Colors.transparent,
          foregroundColor: isCurrentPage
              ? colorScheme.onPrimary
              : colorScheme.onSurface,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          minimumSize: const Size(40, 36),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        child: Text(
          pageNumber.toString(),
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: isCurrentPage ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    try {
      return DateTimeConstants.formatDateTimeWithParkingParams(context, dateTime);
    } catch (e) {
      return '--';
    }
  }
}