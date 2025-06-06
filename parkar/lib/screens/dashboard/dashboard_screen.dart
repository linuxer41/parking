import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';

import '../../models/vehicle_model.dart';
import '../../services/vehicle_service.dart';
import '../../state/app_state_container.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
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
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Encabezado con la fecha y la última actualización
                    _buildHeader(theme),
                    
                    const SizedBox(height: 16),
                    
                    // Tarjetas de estadísticas principales
                    _buildStatCards(colorScheme),
                    
                    const SizedBox(height: 24),
                    
                    // Gráficos
                    Text(
                      'Estadísticas semanales',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Gráfico de ocupación semanal
                    _buildWeeklyOccupancyChart(theme, colorScheme),
                    
                    const SizedBox(height: 24),
                    
                    // Gráfico de ingresos semanales
                    _buildWeeklyRevenueChart(theme, colorScheme),
                    
                    const SizedBox(height: 24),
                    
                    // Estadísticas adicionales
                    Text(
                      'Datos adicionales',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    _buildAdditionalStats(colorScheme),
                    
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
    );
  }
  
  Widget _buildHeader(ThemeData theme) {
    final now = DateTime.now();
    
    // Si el locale no está inicializado, usar un formato simple
    if (!_localeInitialized) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cargando fecha...',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Última actualización: ${_lastRefreshTime.hour}:${_lastRefreshTime.minute}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                ),
              ),
            ],
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.history, size: 16),
            label: const Text('Historial'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            onPressed: () {
              Navigator.of(context).pushNamed('/history');
            },
          ),
        ],
      );
    }
    
    // Si el locale está inicializado, usar DateFormat
    final dateFormat = DateFormat('EEEE d MMMM, yyyy', 'es');
    final timeFormat = DateFormat('HH:mm');
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dateFormat.format(now),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Última actualización: ${timeFormat.format(_lastRefreshTime)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
              ),
            ),
          ],
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.history, size: 16),
          label: const Text('Historial'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          onPressed: () {
            Navigator.of(context).pushNamed('/history');
          },
        ),
      ],
    );
  }
  
  Widget _buildStatCards(ColorScheme colorScheme) {
    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        // Tarjeta de ocupación
        _buildStatCard(
          title: 'Ocupación',
          value: '${(_occupancyRate * 100).toStringAsFixed(1)}%',
          icon: Icons.local_parking,
          color: colorScheme.primary,
          subtitle: '$_occupiedSpots de $_totalSpots espacios',
        ),
        
        // Tarjeta de ingresos diarios
        _buildStatCard(
          title: 'Ingresos hoy',
          value: '\$${_dailyRevenue.toStringAsFixed(2)}',
          icon: Icons.attach_money,
          color: colorScheme.tertiary,
          subtitle: '+${(10 + _random.nextInt(20))}% vs ayer',
        ),
        
        // Tarjeta de espacios disponibles
        _buildStatCard(
          title: 'Disponibles',
          value: '$_availableSpots',
          icon: Icons.check_circle_outline,
          color: Colors.green,
          subtitle: 'Espacios libres',
        ),
        
        // Tarjeta de vehículos procesados
        _buildStatCard(
          title: 'Vehículos hoy',
          value: '$_vehiclesProcessed',
          icon: Icons.directions_car,
          color: colorScheme.secondary,
          subtitle: 'Entradas y salidas',
        ),
      ],
    );
  }
  
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildWeeklyOccupancyChart(ThemeData theme, ColorScheme colorScheme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tasa de ocupación semanal',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Porcentaje de espacios ocupados',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    drawHorizontalLine: true,
                    horizontalInterval: 20,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey[300],
                        strokeWidth: 1,
                      );
                    },
                    getDrawingVerticalLine: (value) {
                      return FlLine(
                        color: Colors.grey[300],
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          const days = ['Lun', 'Mar', 'Mie', 'Jue', 'Vie', 'Sab', 'Dom'];
                          if (value >= 0 && value < days.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                days[value.toInt()],
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
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
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Text(
                              '${value.toInt()}%',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        },
                        interval: 20,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: false,
                  ),
                  minX: 0,
                  maxX: 6,
                  minY: 0,
                  maxY: 100,
                  lineBarsData: [
                    LineChartBarData(
                      spots: _weeklyOccupancyData,
                      isCurved: true,
                      color: colorScheme.primary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: colorScheme.primary.withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildWeeklyRevenueChart(ThemeData theme, ColorScheme colorScheme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ingresos semanales',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ingresos diarios en USD',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 50,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey[300],
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          const days = ['Lun', 'Mar', 'Mie', 'Jue', 'Vie', 'Sab', 'Dom'];
                          if (value >= 0 && value < days.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                days[value.toInt()],
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
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
                        reservedSize: 50,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Text(
                              '\$${value.toInt()}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        },
                        interval: 50,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: false,
                  ),
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 250,
                  barGroups: _weeklyRevenueData.asMap().entries.map((entry) {
                    final index = entry.key;
                    final y = entry.value.y;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: y,
                          color: colorScheme.tertiary,
                          width: 20,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: 250,
                            color: Colors.grey[200],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAdditionalStats(ColorScheme colorScheme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatRow(
              'Ingreso semanal',
              '\$${_weeklyRevenue.toStringAsFixed(2)}',
              Icons.timeline,
              colorScheme.tertiary,
            ),
            const SizedBox(height: 16),
            _buildStatRow(
              'Tiempo medio de estacionamiento',
              '${(1 + _random.nextInt(3))}h ${_random.nextInt(60)}m',
              Icons.access_time,
              Colors.blue,
            ),
            const SizedBox(height: 16),
            _buildStatRow(
              'Horas pico',
              '${8 + _random.nextInt(3)}:00 - ${12 + _random.nextInt(3)}:00',
              Icons.trending_up,
              Colors.orange,
            ),
            const SizedBox(height: 16),
            _buildStatRow(
              'Tipo de vehículo más común',
              'Sedán (${42 + _random.nextInt(20)}%)',
              Icons.directions_car,
              Colors.purple,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
} 