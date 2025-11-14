import 'package:flutter/material.dart';
import '../../widgets/page_layout.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedReportType = 'daily';
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return PageLayout(title: 'Reportes', body: _buildReportsContent());
  }

  Widget _buildReportsContent() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con controles
          _buildReportControls(),
          
          const SizedBox(height: 24),
          
          // Tabla de datos del reporte
          _buildReportTable(),
          
          const SizedBox(height: 24),
          
          // Botones de acción
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildReportControls() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Configuración del Reporte',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              // Selector de tipo de reporte
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tipo de Reporte',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedReportType,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'daily',
                          child: Text('Reporte Diario'),
                        ),
                        DropdownMenuItem(
                          value: 'weekly',
                          child: Text('Reporte Semanal'),
                        ),
                        DropdownMenuItem(
                          value: 'monthly',
                          child: Text('Reporte Mensual'),
                        ),
                        DropdownMenuItem(
                          value: 'vehicles',
                          child: Text('Reporte de Vehículos'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedReportType = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Selector de fecha
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fecha',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => _selectDate(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 20,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _formatDate(_selectedDate),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReportTable() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header de la tabla
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.table_chart,
                  color: colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Datos del Reporte',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                Text(
                  _getReportTitle(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          
          // Contenido de la tabla
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingTextStyle: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
              dataTextStyle: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
              columns: _getTableColumns(),
              rows: _getTableRows(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _downloadReport(),
            icon: const Icon(Icons.download),
            label: const Text('Descargar PDF'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _shareReport(),
            icon: const Icon(Icons.share),
            label: const Text('Compartir'),
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.primary,
              side: BorderSide(color: colorScheme.primary),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<DataColumn> _getTableColumns() {
    switch (_selectedReportType) {
      case 'daily':
        return const [
          DataColumn(label: Text('Hora')),
          DataColumn(label: Text('Vehículos')),
          DataColumn(label: Text('Ingresos')),
          DataColumn(label: Text('Promedio')),
        ];
      case 'weekly':
        return const [
          DataColumn(label: Text('Día')),
          DataColumn(label: Text('Vehículos')),
          DataColumn(label: Text('Ingresos')),
          DataColumn(label: Text('Ocupación')),
        ];
      case 'monthly':
        return const [
          DataColumn(label: Text('Semana')),
          DataColumn(label: Text('Vehículos')),
          DataColumn(label: Text('Ingresos')),
          DataColumn(label: Text('Crecimiento')),
        ];
      case 'vehicles':
        return const [
          DataColumn(label: Text('Tipo')),
          DataColumn(label: Text('Cantidad')),
          DataColumn(label: Text('Porcentaje')),
          DataColumn(label: Text('Ingresos')),
        ];
      default:
        return const [];
    }
  }

  List<DataRow> _getTableRows() {
    switch (_selectedReportType) {
      case 'daily':
        return _getDailyData();
      case 'weekly':
        return _getWeeklyData();
      case 'monthly':
        return _getMonthlyData();
      case 'vehicles':
        return _getVehiclesData();
      default:
        return [];
    }
  }

  List<DataRow> _getDailyData() {
    return [
      DataRow(cells: [
        const DataCell(Text('08:00')),
        const DataCell(Text('12')),
        const DataCell(Text('\$180')),
        const DataCell(Text('\$15.00')),
      ]),
      DataRow(cells: [
        const DataCell(Text('09:00')),
        const DataCell(Text('18')),
        const DataCell(Text('\$270')),
        const DataCell(Text('\$15.00')),
      ]),
      DataRow(cells: [
        const DataCell(Text('10:00')),
        const DataCell(Text('25')),
        const DataCell(Text('\$375')),
        const DataCell(Text('\$15.00')),
      ]),
      DataRow(cells: [
        const DataCell(Text('11:00')),
        const DataCell(Text('22')),
        const DataCell(Text('\$330')),
        const DataCell(Text('\$15.00')),
      ]),
      DataRow(cells: [
        const DataCell(Text('12:00')),
        const DataCell(Text('30')),
        const DataCell(Text('\$450')),
        const DataCell(Text('\$15.00')),
      ]),
    ];
  }

  List<DataRow> _getWeeklyData() {
    return [
      DataRow(cells: [
        const DataCell(Text('Lunes')),
        const DataCell(Text('156')),
        const DataCell(Text('\$2,340')),
        const DataCell(Text('78%')),
      ]),
      DataRow(cells: [
        const DataCell(Text('Martes')),
        const DataCell(Text('142')),
        const DataCell(Text('\$2,130')),
        const DataCell(Text('71%')),
      ]),
      DataRow(cells: [
        const DataCell(Text('Miércoles')),
        const DataCell(Text('168')),
        const DataCell(Text('\$2,520')),
        const DataCell(Text('84%')),
      ]),
      DataRow(cells: [
        const DataCell(Text('Jueves')),
        const DataCell(Text('175')),
        const DataCell(Text('\$2,625')),
        const DataCell(Text('88%')),
      ]),
      DataRow(cells: [
        const DataCell(Text('Viernes')),
        const DataCell(Text('192')),
        const DataCell(Text('\$2,880')),
        const DataCell(Text('96%')),
      ]),
    ];
  }

  List<DataRow> _getMonthlyData() {
    return [
      DataRow(cells: [
        const DataCell(Text('Semana 1')),
        const DataCell(Text('1,245')),
        const DataCell(Text('\$18,675')),
        const DataCell(Text('+5.2%')),
      ]),
      DataRow(cells: [
        const DataCell(Text('Semana 2')),
        const DataCell(Text('1,312')),
        const DataCell(Text('\$19,680')),
        const DataCell(Text('+5.4%')),
      ]),
      DataRow(cells: [
        const DataCell(Text('Semana 3')),
        const DataCell(Text('1,289')),
        const DataCell(Text('\$19,335')),
        const DataCell(Text('+4.8%')),
      ]),
      DataRow(cells: [
        const DataCell(Text('Semana 4')),
        const DataCell(Text('1,356')),
        const DataCell(Text('\$20,340')),
        const DataCell(Text('+5.2%')),
      ]),
    ];
  }

  List<DataRow> _getVehiclesData() {
    return [
      DataRow(cells: [
        const DataCell(Text('Automóviles')),
        const DataCell(Text('1,245')),
        const DataCell(Text('65%')),
        const DataCell(Text('\$18,675')),
      ]),
      DataRow(cells: [
        const DataCell(Text('Camionetas')),
        const DataCell(Text('432')),
        const DataCell(Text('23%')),
        const DataCell(Text('\$6,480')),
      ]),
      DataRow(cells: [
        const DataCell(Text('Motos')),
        const DataCell(Text('156')),
        const DataCell(Text('8%')),
        const DataCell(Text('\$1,560')),
      ]),
      DataRow(cells: [
        const DataCell(Text('Camiones')),
        const DataCell(Text('67')),
        const DataCell(Text('4%')),
        const DataCell(Text('\$1,005')),
      ]),
    ];
  }

  String _getReportTitle() {
    switch (_selectedReportType) {
      case 'daily':
        return 'Reporte Diario - ${_formatDate(_selectedDate)}';
      case 'weekly':
        return 'Reporte Semanal - Semana ${_getWeekNumber(_selectedDate)}';
      case 'monthly':
        return 'Reporte Mensual - ${_formatMonth(_selectedDate)}';
      case 'vehicles':
        return 'Reporte de Vehículos - ${_formatDate(_selectedDate)}';
      default:
        return 'Reporte';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatMonth(DateTime date) {
    final months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  int _getWeekNumber(DateTime date) {
    final startOfYear = DateTime(date.year, 1, 1);
    final daysSinceStart = date.difference(startOfYear).inDays;
    return ((daysSinceStart + startOfYear.weekday - 1) / 7).ceil();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _downloadReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Descargando ${_getReportTitle()}...'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _shareReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Compartiendo ${_getReportTitle()}...'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
