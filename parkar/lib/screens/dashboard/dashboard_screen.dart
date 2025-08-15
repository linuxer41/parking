import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/services.dart';

import '../../services/parking_service.dart';
import '../../state/app_state_container.dart';
import '../panel/statistics_panel.dart';
import '../panel/parking_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  final ParkingService _parkingService = ParkingService();
  final math.Random _random = math.Random();

  // Datos del dashboard
  Map<String, dynamic>? _dashboardData;
  bool _isLoading = true;
  bool _localeInitialized = false;
  DateTime _lastRefreshTime = DateTime.now();

  // Animaciones
  late AnimationController _backgroundAnimationController;
  late AnimationController _cardAnimationController;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _cardAnimation;

  @override
  void initState() {
    super.initState();

    // Inicializar animaciones
    _backgroundAnimationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _backgroundAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(_backgroundAnimationController);

    _cardAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _cardAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Inicializar correctamente el locale para intl
    initializeDateFormatting('es').then((_) {
      setState(() {
        _localeInitialized = true;
      });
      _loadDashboardData();
    });
  }

  @override
  void dispose() {
    _backgroundAnimationController.dispose();
    _cardAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final appState = AppStateContainer.of(context);
      final parkingId = appState.currentParking?.id;

      if (parkingId == null) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No hay estacionamiento seleccionado')),
        );
        return;
      }

      // Cargar datos desde el servicio de parking
      final dashboardData = await _parkingService.getDashboardData(parkingId);

      setState(() {
        _dashboardData = dashboardData;
        _lastRefreshTime = DateTime.now();
        _isLoading = false;
      });

      // Iniciar animación de cards
      _cardAnimationController.forward();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al cargar datos: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;
    final isLargeScreen = size.width > 600;
    final isMediumScreen = size.width > 400;
    final isSmallScreen = size.width <= 400;
    final isDark = theme.brightness == Brightness.dark;

    // Configurar el estilo de la barra de estado
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: colorScheme.surface,
        systemNavigationBarIconBrightness: isDark
            ? Brightness.light
            : Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Panel de Control',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(color: colorScheme.primary),
              )
            : RefreshIndicator(
                onRefresh: _loadDashboardData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
                  child: Center(
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: isLargeScreen ? 1200 : double.infinity,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Información de última actualización
                          _buildLastUpdateInfo(context, theme, colorScheme),

                          const SizedBox(height: 20),

                          // Botones de acción rápida (más compactos)
                          _buildQuickActionButtons(context, colorScheme, theme),

                          const SizedBox(height: 24),

                          // Resumen Financiero (primero)
                          if (_dashboardData != null)
                            _buildSection(
                              context,
                              'Resumen Financiero',
                              _buildFinancialSummary(context),
                            ),

                          const SizedBox(height: 24),

                          // Gráfico de ocupación por hora del día (segundo)
                          if (_dashboardData != null)
                            _buildSection(
                              context,
                              'Ocupación por Hora',
                              _buildHourlyOccupancyChart(colorScheme),
                            ),

                          const SizedBox(height: 24),

                          // Tabla comparativa de ingresos mensuales y Rendimiento por empleado
                          if (_dashboardData != null)
                            isLargeScreen
                                ? Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: _buildSection(
                                          context,
                                          'Comparativa de Ingresos Mensuales',
                                          _buildMonthlyComparisonTable(context),
                                        ),
                                      ),
                                      const SizedBox(width: 24),
                                      Expanded(
                                        child: _buildSection(
                                          context,
                                          'Rendimiento por Empleado',
                                          _buildEmployeePerformance(context),
                                        ),
                                      ),
                                    ],
                                  )
                                : Column(
                                    children: [
                                      _buildSection(
                                        context,
                                        'Comparativa de Ingresos Mensuales',
                                        _buildMonthlyComparisonTable(context),
                                      ),
                                      const SizedBox(height: 24),
                                      _buildSection(
                                        context,
                                        'Rendimiento por Empleado',
                                        _buildEmployeePerformance(context),
                                      ),
                                    ],
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

  Widget _buildLastUpdateInfo(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Text(
        'Última actualización: ${_formatTime(_lastRefreshTime)}',
        style: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
          fontSize: 12,
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
            color: colorScheme.onSurface,
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
          child: Padding(padding: const EdgeInsets.all(16), child: content),
        ),
      ],
    );
  }

  Widget _buildHourlyOccupancyChart(ColorScheme colorScheme) {
    if (_dashboardData == null) return const SizedBox.shrink();

    final List<double> hourlyData = List<double>.from(
      _dashboardData!['hourlyOccupancy'],
    );
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width <= 400;

    return SizedBox(
      height: isSmallScreen ? 250 : 300,
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: 100,
            minY: 0,
            groupsSpace: isSmallScreen ? 8 : 12,
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  return BarTooltipItem(
                    '${hourlyData[groupIndex].toStringAsFixed(1)}%',
                    TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: isSmallScreen ? 25 : 30,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    // Mostrar solo algunas horas para no sobrecargar el eje
                    if (value % (isSmallScreen ? 6 : 4) == 0) {
                      return Text(
                        '${value.toInt()}h',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: isSmallScreen ? 10 : 12,
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: isSmallScreen ? 35 : 40,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    if (value % (isSmallScreen ? 25 : 20) == 0) {
                      return Text(
                        '${value.toInt()}%',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: isSmallScreen ? 10 : 12,
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            gridData: FlGridData(
              show: true,
              horizontalInterval: isSmallScreen ? 25 : 20,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: colorScheme.outline.withOpacity(0.2),
                  strokeWidth: 1,
                  dashArray: [5, 5],
                );
              },
              getDrawingVerticalLine: (value) =>
                  const FlLine(color: Colors.transparent),
            ),
            borderData: FlBorderData(show: false),
            barGroups: hourlyData.asMap().entries.map((entry) {
              final int index = entry.key;
              final double value = entry.value;

              // Color basado en la ocupación
              Color barColor;
              if (value < 30) {
                barColor = Colors.green;
              } else if (value < 70) {
                barColor = Colors.orange;
              } else {
                barColor = Colors.red;
              }

              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: value,
                    color: barColor.withOpacity(0.7),
                    width: isSmallScreen ? 8 : 12,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4),
                    ),
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      toY: 100,
                      color: colorScheme.surfaceContainerHighest.withOpacity(
                        0.3,
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  // Método para construir el resumen financiero
  Widget _buildFinancialSummary(BuildContext context) {
    if (_dashboardData == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width <= 400;
    final isMediumScreen = size.width <= 600;

    // Datos financieros desde la API
    final financialData =
        _dashboardData!['financialData'] as Map<String, dynamic>;
    final monthlyRevenueData =
        _dashboardData!['monthlyRevenueData'] as Map<String, dynamic>;
    final revenueBreakdown =
        _dashboardData!['revenueBreakdown'] as Map<String, dynamic>;

    // Datos para el gráfico de ingresos mensuales
    final List<double> monthlyRevenue = List<double>.from(
      monthlyRevenueData['values'],
    );
    final List<String> months = List<String>.from(monthlyRevenueData['months']);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tarjetas de métricas financieras principales
        GridView.count(
          crossAxisCount: isSmallScreen ? 1 : (isMediumScreen ? 2 : 3),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: isSmallScreen ? 2.5 : (isMediumScreen ? 2.0 : 1.8),
          children: [
            _buildFinancialMetricCard(
              context,
              'Caja del Día',
              '\$${financialData['dailyRevenue'].toStringAsFixed(0)}',
              Icons.point_of_sale,
              Colors.green,
              'vs ayer: +${(financialData['dailyRevenue'] * 0.12).toStringAsFixed(0)}%',
            ),
            _buildFinancialMetricCard(
              context,
              'Caja de la Semana',
              '\$${financialData['weeklyRevenue'].toStringAsFixed(0)}',
              Icons.date_range,
              Colors.blue,
              'vs semana anterior: +${(financialData['weeklyRevenue'] * 0.08).toStringAsFixed(0)}%',
            ),
            _buildFinancialMetricCard(
              context,
              'Caja del Mes',
              '\$${financialData['monthlyRevenue'].toStringAsFixed(0)}',
              Icons.calendar_month,
              Colors.purple,
              'vs mes anterior: +${(financialData['monthlyRevenue'] * 0.06).toStringAsFixed(0)}%',
            ),
            _buildFinancialMetricCard(
              context,
              'Ticket Promedio',
              '\$${financialData['averageTicket'].toStringAsFixed(2)}',
              Icons.receipt_long,
              Colors.amber,
              'vs promedio: +${(financialData['averageTicket'] * 0.05).toStringAsFixed(2)}',
            ),
            _buildFinancialMetricCard(
              context,
              'Vehículos Hoy',
              '${(financialData['dailyRevenue'] / financialData['averageTicket']).round()}',
              Icons.directions_car,
              Colors.orange,
              'vs ayer: +${((financialData['dailyRevenue'] / financialData['averageTicket']) * 0.1).round()}',
            ),
            _buildFinancialMetricCard(
              context,
              'Horas Promedio',
              '${(financialData['averageTicket'] / 5).toStringAsFixed(1)}h',
              Icons.timer,
              Colors.teal,
              'por vehículo',
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Gráfico de ingresos mensuales
        Text(
          'Ingresos Mensuales',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: isSmallScreen ? 200 : 250,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 60000,
              minY: 0,
              groupsSpace: isSmallScreen ? 8 : 12,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '\$${monthlyRevenue[groupIndex].toStringAsFixed(0)}',
                      TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: isSmallScreen ? 25 : 30,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      final int index = value.toInt();
                      if (index >= 0 && index < months.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            months[index],
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: isSmallScreen ? 10 : 12,
                            ),
                          ),
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: isSmallScreen ? 50 : 60,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      if (value % 20000 == 0) {
                        return Text(
                          '\$${(value / 1000).toInt()}K',
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: isSmallScreen ? 10 : 12,
                          ),
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: FlGridData(
                show: true,
                horizontalInterval: 20000,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: colorScheme.outline.withOpacity(0.2),
                    strokeWidth: 1,
                    dashArray: [5, 5],
                  );
                },
                getDrawingVerticalLine: (value) =>
                    const FlLine(color: Colors.transparent),
              ),
              borderData: FlBorderData(show: false),
              barGroups: monthlyRevenue.asMap().entries.map((entry) {
                final int index = entry.key;
                final double value = entry.value;

                // Determinar si es el mes actual (el último)
                final bool isCurrentMonth = index == monthlyRevenue.length - 1;

                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: value,
                      color: isCurrentMonth
                          ? colorScheme.primary
                          : colorScheme.primary.withOpacity(0.7),
                      width: isSmallScreen ? 12 : 16,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                      ),
                      backDrawRodData: BackgroundBarChartRodData(
                        show: true,
                        toY: 60000,
                        color: colorScheme.surfaceContainerHighest.withOpacity(
                          0.3,
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Desglose de ingresos por tipo
        Text(
          'Tipos de Ingreso',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),

        // Layout responsivo para el gráfico circular y leyenda
        if (isSmallScreen)
          Column(
            children: [
              SizedBox(
                height: 200,
                child: PieChart(_revenueBreakdownData(revenueBreakdown)),
              ),
              const SizedBox(height: 16),
              ...revenueBreakdown.entries.map((entry) {
                final colors = [
                  Colors.blue,
                  Colors.green,
                  Colors.orange,
                  Colors.purple,
                ];
                final index = revenueBreakdown.keys.toList().indexOf(entry.key);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildLegendItem(
                    context,
                    entry.key,
                    colors[index],
                    '${entry.value}%',
                  ),
                );
              }),
            ],
          )
        else
          Row(
            children: [
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: 200,
                  child: PieChart(_revenueBreakdownData(revenueBreakdown)),
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLegendItem(
                      context,
                      'Estacionamiento por hora',
                      Colors.blue,
                      '${revenueBreakdown['Estacionamiento por hora']}%',
                    ),
                    const SizedBox(height: 8),
                    _buildLegendItem(
                      context,
                      'Suscripciones',
                      Colors.green,
                      '${revenueBreakdown['Suscripciones']}%',
                    ),
                    const SizedBox(height: 8),
                    _buildLegendItem(
                      context,
                      'Reservas',
                      Colors.orange,
                      '${revenueBreakdown['Reservas']}%',
                    ),
                    const SizedBox(height: 8),
                    _buildLegendItem(
                      context,
                      'Servicios adicionales',
                      Colors.purple,
                      '${revenueBreakdown['Servicios adicionales']}%',
                    ),
                  ],
                ),
              ),
            ],
          ),

        const SizedBox(height: 24),

        // Métricas operativas
        Text(
          'Métricas Operativas',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),

        GridView.count(
          crossAxisCount: isSmallScreen ? 2 : (isMediumScreen ? 3 : 4),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: isSmallScreen ? 2.0 : (isMediumScreen ? 2.2 : 2.5),
          children: [
            _buildPerformanceMetricCard(
              context,
              'Ingresos por Hora',
              '\$${(financialData['dailyRevenue'] / 24).toStringAsFixed(0)}',
              Icons.access_time,
              Colors.indigo,
            ),
            _buildPerformanceMetricCard(
              context,
              'Vehículos por Hora',
              '${(financialData['dailyRevenue'] / financialData['averageTicket'] / 24).round()}',
              Icons.directions_car_filled,
              Colors.red,
            ),
            _buildPerformanceMetricCard(
              context,
              'Ocupación Promedio',
              '${(financialData['dailyRevenue'] / financialData['averageTicket'] / 120 * 100).toStringAsFixed(0)}%',
              Icons.local_parking,
              Colors.cyan,
            ),
            _buildPerformanceMetricCard(
              context,
              'Rotación Diaria',
              '${(financialData['dailyRevenue'] / financialData['averageTicket'] / 120).toStringAsFixed(1)}x',
              Icons.loop,
              Colors.lime,
            ),
          ],
        ),
      ],
    );
  }

  // Widget para mostrar una métrica financiera
  Widget _buildFinancialMetricCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      color: theme.brightness == Brightness.dark
          ? colorScheme.surfaceContainerHighest
          : colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(icon, color: color, size: 16),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget para mostrar una métrica de rendimiento
  Widget _buildPerformanceMetricCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      color: theme.brightness == Brightness.dark
          ? colorScheme.surfaceContainerHighest
          : colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(icon, color: color, size: 14),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget para mostrar un elemento de leyenda
  Widget _buildLegendItem(
    BuildContext context,
    String label,
    Color color,
    String percentage,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
        ),
        Text(
          percentage,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  // Datos para el gráfico de desglose de ingresos
  PieChartData _revenueBreakdownData(Map<String, dynamic> revenueBreakdown) {
    final colors = [Colors.blue, Colors.green, Colors.orange, Colors.purple];

    return PieChartData(
      sectionsSpace: 2,
      centerSpaceRadius: 30,
      sections: revenueBreakdown.entries.map((entry) {
        final index = revenueBreakdown.keys.toList().indexOf(entry.key);
        return PieChartSectionData(
          color: colors[index].withOpacity(0.8),
          value: entry.value.toDouble(),
          title: '',
          radius: 80,
        );
      }).toList(),
    );
  }

  // Tabla comparativa de ingresos mensuales
  Widget _buildMonthlyComparisonTable(BuildContext context) {
    if (_dashboardData == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width <= 400;
    final monthlyRevenueData =
        _dashboardData!['monthlyRevenueData'] as Map<String, dynamic>;
    final List<double> monthlyRevenue = List<double>.from(
      monthlyRevenueData['values'],
    );
    final List<String> months = List<String>.from(monthlyRevenueData['months']);

    if (isSmallScreen) {
      // Versión móvil: lista de tarjetas
      return Column(
        children: monthlyRevenue.asMap().entries.map((entry) {
          final int index = entry.key;
          final double revenue = entry.value;
          final String month = months[index];

          // Calcular comparación con mes anterior
          double previousRevenue = index > 0
              ? monthlyRevenue[index - 1]
              : revenue;
          double growth = previousRevenue > 0
              ? ((revenue - previousRevenue) / previousRevenue) * 100
              : 0;

          // Determinar estado
          String status;
          Color statusColor;
          if (growth > 5) {
            status = 'Excelente';
            statusColor = Colors.green;
          } else if (growth > 0) {
            status = 'Bueno';
            statusColor = Colors.blue;
          } else if (growth > -5) {
            status = 'Estable';
            statusColor = Colors.orange;
          } else {
            status = 'Bajo';
            statusColor = Colors.red;
          }

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            elevation: 0,
            color: theme.brightness == Brightness.dark
                ? colorScheme.surfaceContainerHighest
                : colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: colorScheme.outlineVariant.withOpacity(0.3),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        month,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: statusColor.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ingresos: \$${revenue.toStringAsFixed(0)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        growth >= 0 ? Icons.trending_up : Icons.trending_down,
                        size: 16,
                        color: growth >= 0 ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${growth >= 0 ? '+' : ''}${growth.toStringAsFixed(1)}% vs mes anterior',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: growth >= 0 ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      );
    }

    // Versión desktop: tabla completa
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingTextStyle: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
        dataTextStyle: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurface,
        ),
        columns: const [
          DataColumn(label: Text('Mes')),
          DataColumn(label: Text('Ingresos')),
          DataColumn(label: Text('vs Mes Anterior')),
          DataColumn(label: Text('Crecimiento')),
          DataColumn(label: Text('Estado')),
        ],
        rows: monthlyRevenue.asMap().entries.map((entry) {
          final int index = entry.key;
          final double revenue = entry.value;
          final String month = months[index];

          // Calcular comparación con mes anterior
          double previousRevenue = index > 0
              ? monthlyRevenue[index - 1]
              : revenue;
          double growth = previousRevenue > 0
              ? ((revenue - previousRevenue) / previousRevenue) * 100
              : 0;

          // Determinar estado
          String status;
          Color statusColor;
          if (growth > 5) {
            status = 'Excelente';
            statusColor = Colors.green;
          } else if (growth > 0) {
            status = 'Bueno';
            statusColor = Colors.blue;
          } else if (growth > -5) {
            status = 'Estable';
            statusColor = Colors.orange;
          } else {
            status = 'Bajo';
            statusColor = Colors.red;
          }

          return DataRow(
            cells: [
              DataCell(Text(month)),
              DataCell(Text('\$${revenue.toStringAsFixed(0)}')),
              DataCell(
                Text(
                  growth >= 0
                      ? '+${growth.toStringAsFixed(1)}%'
                      : '${growth.toStringAsFixed(1)}%',
                ),
              ),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      growth >= 0 ? Icons.trending_up : Icons.trending_down,
                      size: 16,
                      color: growth >= 0 ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 4),
                    Text('${growth.abs().toStringAsFixed(1)}%'),
                  ],
                ),
              ),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  // Rendimiento por empleado
  Widget _buildEmployeePerformance(BuildContext context) {
    if (_dashboardData == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width <= 400;

    // Datos simulados de empleados
    final List<Map<String, dynamic>> employees = [
      {
        'name': 'Carlos López',
        'role': 'Operador',
        'vehicles_processed': 45,
        'revenue_generated': 675.0,
        'efficiency': 95.0,
        'avatar': 'CL',
      },
      {
        'name': 'María García',
        'role': 'Supervisor',
        'vehicles_processed': 38,
        'revenue_generated': 570.0,
        'efficiency': 88.0,
        'avatar': 'MG',
      },
      {
        'name': 'Juan Pérez',
        'role': 'Operador',
        'vehicles_processed': 52,
        'revenue_generated': 780.0,
        'efficiency': 92.0,
        'avatar': 'JP',
      },
      {
        'name': 'Ana Rodríguez',
        'role': 'Operador',
        'vehicles_processed': 41,
        'revenue_generated': 615.0,
        'efficiency': 89.0,
        'avatar': 'AR',
      },
    ];

    return Column(
      children: employees.map((employee) {
        final double efficiency = employee['efficiency'];
        Color efficiencyColor;
        if (efficiency >= 90) {
          efficiencyColor = Colors.green;
        } else if (efficiency >= 80) {
          efficiencyColor = Colors.blue;
        } else {
          efficiencyColor = Colors.orange;
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 0,
          color: theme.brightness == Brightness.dark
              ? colorScheme.surfaceContainerHighest
              : colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: colorScheme.outlineVariant.withOpacity(0.3),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: isSmallScreen ? 35 : 40,
                  height: isSmallScreen ? 35 : 40,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                      isSmallScreen ? 17.5 : 20,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      employee['avatar'],
                      style:
                          (isSmallScreen
                                  ? theme.textTheme.bodyMedium
                                  : theme.textTheme.titleSmall)
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                    ),
                  ),
                ),
                SizedBox(width: isSmallScreen ? 10 : 12),

                // Información del empleado
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        employee['name'],
                        style:
                            (isSmallScreen
                                    ? theme.textTheme.bodyMedium
                                    : theme.textTheme.titleSmall)
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurface,
                                ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        employee['role'],
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Métricas
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${employee['vehicles_processed']} vehículos',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.end,
                    ),
                    Text(
                      '\$${employee['revenue_generated'].toStringAsFixed(0)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: colorScheme.primary,
                      ),
                      textAlign: TextAlign.end,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: efficiencyColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${efficiency.toStringAsFixed(0)}%',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: efficiencyColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAnimatedBackground(ColorScheme colorScheme) {
    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: AnimatedBackgroundPainter(
            animation: _backgroundAnimation.value,
            colorScheme: colorScheme,
          ),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildQuickActionButtons(
    BuildContext context,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width <= 400;

    return AnimatedBuilder(
      animation: _cardAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - _cardAnimation.value)),
          child: Opacity(
            opacity: _cardAnimation.value,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Acciones Rápidas',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: isSmallScreen ? 2 : 4,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: isSmallScreen ? 1.1 : 1.3,
                  children: [
                    _buildActionCard(
                      context,
                      'Gestionar',
                      'Parqueo',
                      Icons.local_parking_rounded,
                      colorScheme.primary,
                      () {
                        final appState = AppStateContainer.of(context);
                        final currentParking = appState.currentParking;

                        if (currentParking != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ParkingDetailScreen(
                                parkingId: currentParking.id,
                                parkingName: currentParking.name,
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'No hay estacionamiento seleccionado',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                    ),
                    _buildActionCard(
                      context,
                      'Estadísticas',
                      'Análisis',
                      Icons.analytics_rounded,
                      colorScheme.secondary,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const StatisticsPanel(),
                          ),
                        );
                      },
                    ),
                    _buildActionCard(
                      context,
                      'Reportes',
                      'Informes',
                      Icons.assessment_rounded,
                      colorScheme.tertiary,
                      () {
                        // Navegar a reportes
                      },
                    ),
                    _buildActionCard(
                      context,
                      'Configuración',
                      'Ajustes',
                      Icons.settings_rounded,
                      colorScheme.error,
                      () {
                        // Navegar a configuración
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width <= 400;

    return Card(
      elevation: 1,
      shadowColor: color.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.outlineVariant.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: isSmallScreen ? 20 : 24),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Clase para pintar el fondo animado
class AnimatedBackgroundPainter extends CustomPainter {
  final double animation;
  final ColorScheme colorScheme;

  AnimatedBackgroundPainter({
    required this.animation,
    required this.colorScheme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Dibujar círculos animados
    for (int i = 0; i < 8; i++) {
      final angle = animation + (i * math.pi / 4);
      final radius = 50 + (i * 20);
      final x = size.width / 2 + math.cos(angle) * radius;
      final y = size.height / 2 + math.sin(angle) * radius;

      final circlePaint = Paint()
        ..color = colorScheme.primary.withOpacity(0.02)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), 30 + (i * 5), circlePaint);
    }

    // Dibujar líneas onduladas
    final path = Path();
    final wavePaint = Paint()
      ..color = colorScheme.secondary.withOpacity(0.02)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (int i = 0; i < 3; i++) {
      path.reset();
      path.moveTo(0, size.height * (0.2 + i * 0.3));

      for (double x = 0; x < size.width; x += 20) {
        final y =
            size.height * (0.2 + i * 0.3) +
            math.sin((x + animation * 50) / 50) * 20;
        path.lineTo(x, y);
      }

      canvas.drawPath(path, wavePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
