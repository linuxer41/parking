import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/services.dart';

import '../../services/vehicle_service.dart';
import '../../state/app_state_container.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final VehicleService _vehicleService = VehicleService();
  final math.Random _random = math.Random();

  // Estadísticas simuladas
  int _totalSpots = 0;
  int _occupiedSpots = 0;
  int _availableSpots = 0;
  double _occupancyRate = 0.0;
  double _dailyRevenue = 0.0;
  double _weeklyRevenue = 0.0;
  int _vehiclesProcessed = 0;

  // Datos para gráficos
  List<FlSpot> _weeklyOccupancyData = [];
  List<FlSpot> _weeklyRevenueData = [];

  // Para simular datos de tiempo real
  DateTime _lastRefreshTime = DateTime.now();
  bool _isLoading = true;
  bool _localeInitialized = false;

  // Datos simulados para las gráficas
  final List<double> weeklyOccupancy = [65, 72, 58, 80, 75, 68, 70];
  final List<double> dailyRevenue = [1200, 1500, 1100, 1800, 1600, 1400, 1300];
  final Map<String, double> parkingDuration = {
    '< 1h': 30,
    '1-2h': 25,
    '2-4h': 20,
    '4-8h': 15,
    '> 8h': 10,
  };

  // Configuración del gráfico de ocupación semanal
  LineChartData get weeklyOccupancyChartData {
    return LineChartData(
      gridData: FlGridData(show: false),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              const days = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
              if (value >= 0 && value < days.length) {
                return Text(
                  days[value.toInt()],
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                );
              }
              return const Text('');
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: weeklyOccupancy.asMap().entries.map((entry) {
            return FlSpot(entry.key.toDouble(), entry.value);
          }).toList(),
          isCurved: true,
          color: Theme.of(context).colorScheme.primary,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          ),
        ),
      ],
      minY: 0,
      maxY: 100,
    );
  }

  @override
  void initState() {
    super.initState();
    // Inicializar correctamente el locale para intl
    initializeDateFormatting('es').then((_) {
      setState(() {
        _localeInitialized = true;
      });
      _loadDashboardData();
    });
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    // Simulación de carga de datos
    await Future.delayed(const Duration(milliseconds: 800));

    // Obtener datos del estado actual del parqueo
    try {
      // En una implementación real, estos datos vendrían de la base de datos
      // Aquí estamos generando datos de muestra
      final appState = AppStateContainer.of(context);

      setState(() {
        // Espacios totales (simulados)
        _totalSpots = 100 + _random.nextInt(50);

        // Datos simulados
        _occupiedSpots = (_totalSpots * 0.6 + _random.nextInt(10)).floor();
        _availableSpots = _totalSpots - _occupiedSpots;
        _occupancyRate = _occupiedSpots / _totalSpots;
        _dailyRevenue = 120 + _random.nextDouble() * 80;
        _weeklyRevenue = _dailyRevenue * (5 + _random.nextDouble() * 2);
        _vehiclesProcessed = 45 + _random.nextInt(30);

        // Datos para gráficos
        _generateChartData();

        _lastRefreshTime = DateTime.now();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar datos: $e')),
      );
    }
  }

  void _generateChartData() {
    // Generar datos de ocupación para los últimos 7 días
    _weeklyOccupancyData = List.generate(7, (index) {
      return FlSpot(
        index.toDouble(),
        (0.5 + _random.nextDouble() * 0.4) * 100, // Valor entre 50% y 90%
      );
    });

    // Generar datos de ingresos para los últimos 7 días
    _weeklyRevenueData = List.generate(7, (index) {
      return FlSpot(
        index.toDouble(),
        80.0 + _random.nextDouble() * 120.0, // Valor entre $80 y $200
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;
    final isLargeScreen = size.width > 600;
    final isDark = theme.brightness == Brightness.dark;

    // Configurar el estilo de la barra de estado
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: colorScheme.background,
      systemNavigationBarIconBrightness:
          isDark ? Brightness.light : Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SafeArea(
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: colorScheme.primary,
                ),
              )
            : RefreshIndicator(
                onRefresh: _loadDashboardData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: isLargeScreen ? 1200 : double.infinity,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Título y última actualización
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Panel de Control',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              Text(
                                'Última actualización: ${_formatTime(_lastRefreshTime)}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Tarjetas de resumen
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 1.5,
                            children: [
                              _buildSummaryCard(
                                context,
                                'Ingresos Hoy',
                                '\$2,450',
                                Icons.attach_money,
                                Colors.green,
                                '+15% vs ayer',
                              ),
                              _buildSummaryCard(
                                context,
                                'Ocupación Actual',
                                '75%',
                                Icons.local_parking,
                                Colors.orange,
                                '85 de 120 espacios',
                              ),
                              _buildSummaryCard(
                                context,
                                'Tiempo Promedio',
                                '2.5h',
                                Icons.timer,
                                Colors.blue,
                                '↑ 0.3h vs promedio',
                              ),
                              _buildSummaryCard(
                                context,
                                'Rotación Diaria',
                                '3.2x',
                                Icons.loop,
                                Colors.purple,
                                '↓ 0.1x vs promedio',
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Gráfica de ocupación semanal
                          _buildSection(
                            context,
                            'Ocupación Semanal',
                            SizedBox(
                              height: 200,
                              child: LineChart(
                                weeklyOccupancyChartData,
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Distribución de duración de estacionamiento
                          _buildSection(
                            context,
                            'Duración de Estancia',
                            SizedBox(
                              height: 200,
                              child: PieChart(
                                _parkingDurationData(),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Estadísticas detalladas
                          _buildSection(
                            context,
                            'Estadísticas Detalladas',
                            _buildDetailedStats(context),
                          ),

                          const SizedBox(height: 24),

                          // Alertas y notificaciones
                          _buildSection(
                            context,
                            'Alertas Recientes',
                            _buildAlerts(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Widget _buildSummaryCard(BuildContext context, String title, String value,
      IconData icon, Color color, String subtitle) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      color: theme.brightness == Brightness.dark
          ? colorScheme.surfaceContainerHighest
          : colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant.withOpacity(0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, Widget content) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onBackground,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 0,
          color: theme.brightness == Brightness.dark
              ? colorScheme.surfaceContainerHighest
              : colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: colorScheme.outlineVariant.withOpacity(0.5),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: content,
          ),
        ),
      ],
    );
  }

  PieChartData _parkingDurationData() {
    final colorScheme = Theme.of(context).colorScheme;
    final colors = [
      colorScheme.primary,
      colorScheme.secondary,
      colorScheme.tertiary,
      colorScheme.error,
      colorScheme.primaryContainer,
    ];

    return PieChartData(
      sectionsSpace: 2,
      centerSpaceRadius: 40,
      sections: parkingDuration.entries.map((entry) {
        final index = parkingDuration.keys.toList().indexOf(entry.key);
        return PieChartSectionData(
          color: colors[index].withOpacity(0.8),
          value: entry.value,
          title: '${entry.value.toStringAsFixed(0)}%',
          radius: 80,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDetailedStats(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        _buildStatRow(
          context,
          'Espacios VIP ocupados',
          '8/10',
          Icons.star,
          Colors.amber,
        ),
        const Divider(),
        _buildStatRow(
          context,
          'Espacios discapacitados',
          '3/5',
          Icons.accessible,
          Colors.blue,
        ),
        const Divider(),
        _buildStatRow(
          context,
          'Tiempo pico de ocupación',
          '14:00 - 16:00',
          Icons.access_time,
          Colors.orange,
        ),
        const Divider(),
        _buildStatRow(
          context,
          'Satisfacción del cliente',
          '4.5/5.0',
          Icons.sentiment_satisfied_alt,
          Colors.green,
        ),
      ],
    );
  }

  Widget _buildStatRow(BuildContext context, String label, String value,
      IconData icon, Color color) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlerts(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        _buildAlert(
          context,
          'Ocupación alta en nivel 2',
          '95% ocupado - Hace 5 min',
          Icons.warning_amber,
          Colors.orange,
        ),
        const Divider(),
        _buildAlert(
          context,
          'Mantenimiento programado',
          'Nivel 3 - Mañana 22:00',
          Icons.build,
          Colors.blue,
        ),
        const Divider(),
        _buildAlert(
          context,
          'Nuevo récord de ingresos',
          'Meta mensual alcanzada',
          Icons.celebration,
          Colors.green,
        ),
      ],
    );
  }

  Widget _buildAlert(BuildContext context, String title, String subtitle,
      IconData icon, Color color) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
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
}
