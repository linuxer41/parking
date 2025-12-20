import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../services/parking_service.dart';
import '../../state/app_state_container.dart';
import '../../models/parking_model.dart';

import 'parking_detail_screen.dart';
import 'parking_rates_screen.dart';
import 'statistics_panel.dart';
import 'reports_screen.dart';
import 'employees_screen.dart';
import 'manage_subscription.dart';
import '../cash_register/cash_register_screen.dart';

// Definición de rutas para el panel de control
class DashboardRoute {
  final String id;
  final String title;
  final IconData icon;
  final Widget Function(BuildContext) builder;
  final Color? textColor;
  final Color? iconColor;

  const DashboardRoute({
    required this.id,
    required this.title,
    required this.icon,
    required this.builder,
    this.textColor,
    this.iconColor,
  });
}

// Sección del panel de control
class DashboardSection {
  final String title;
  final List<DashboardRoute> routes;

  const DashboardSection({required this.title, required this.routes});
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  final ParkingService _parkingService = ParkingService();

  // Datos del dashboard
  Map<String, dynamic>? _dashboardData;
  bool _isLoading = true;
  DateTime _lastRefreshTime = DateTime.now();

  // Estado para la página actual en el diseño responsivo (igual que perfil)
  String _currentPage = 'main';
  Widget? _currentPageWidget;

  // Animaciones
  late AnimationController _cardAnimationController;
  late Animation<double> _cardAnimation;

  // Definición de todas las rutas del panel de control
  late List<DashboardSection> _dashboardSections;

  @override
  void initState() {
    super.initState();

    // Inicializar animaciones
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _cardAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _cardAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Inicializar correctamente el locale para intl
    initializeDateFormatting('es').then((_) {
      if (mounted) {
        setState(() {});
      }
      _loadDashboardData();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Inicializar las secciones y rutas
    _initializeRoutes();
  }

  void _initializeRoutes() {
    _dashboardSections = [
      // Sección de gestión de parking
      DashboardSection(
        title: 'Gestión',
        routes: [
          DashboardRoute(
            id: 'parkingDetail',
            title: 'Gestionar Parqueo',
            icon: Icons.local_parking_rounded,
            builder: (context) {
              final appState = AppStateContainer.of(context);
              final currentParking = appState.currentParking;
              if (currentParking != null) {
                return ParkingDetailScreen(
                  parkingId: currentParking.id,
                  parkingName: currentParking.name,
                );
              }
              return const Center(
                child: Text('No hay estacionamiento seleccionado'),
              );
            },
          ),
          DashboardRoute(
            id: 'employees',
            title: 'Empleados',
            icon: Icons.people_rounded,
            builder: (context) => const EmployeesScreen(),
          ),
          DashboardRoute(
            id: 'parkingRates',
            title: 'Tarifas y Precios',
            icon: Icons.attach_money_rounded,
            builder: (context) {
              final appState = AppStateContainer.of(context);
              final currentParking = appState.currentParking;
              if (currentParking != null) {
                return ParkingRatesScreen(
                  parkingId: currentParking.id,
                  parkingName: currentParking.name,
                );
              }
              return const Center(
                child: Text('No hay estacionamiento seleccionado'),
              );
            },
          ),
        ],
      ),

      // Sección de análisis y reportes
      DashboardSection(
        title: 'Análisis',
        routes: [
          DashboardRoute(
            id: 'statistics',
            title: 'Estadísticas',
            icon: Icons.analytics_rounded,
            builder: (context) => const StatisticsPanel(),
          ),
          DashboardRoute(
            id: 'reports',
            title: 'Reportes',
            icon: Icons.assessment_rounded,
            builder: (context) => const ReportsScreen(),
          ),
        ],
      ),

      // Sección de configuración
      DashboardSection(
        title: 'Configuración',
        routes: [
          DashboardRoute(
            id: 'cashRegister',
            title: 'Caja Registradora',
            icon: Icons.attach_money_rounded,
            builder: (context) => const CashRegisterScreen(),
          ),
          DashboardRoute(
            id: 'manageSubscriptionCard',
            title: 'Suscripción',
            icon: Icons.subscriptions_rounded,
            builder: (context) => const ManageSubscriptionScreen(),
          ),
        ],
      ),
    ];
  }

  @override
  void dispose() {
    _cardAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final appState = AppStateContainer.of(context);
      final parkingId = appState.currentParking?.id;

      if (parkingId == null) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No hay estacionamiento seleccionado'),
            ),
          );
        }
        return;
      }

      // Cargar datos desde el servicio de parking
      final dashboardData = await _parkingService.getDashboard(parkingId);

      if (mounted) {
        setState(() {
          _dashboardData = dashboardData;
          _lastRefreshTime = DateTime.now();
          _isLoading = false;
        });

        // Iniciar animación de cards
        _cardAnimationController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al cargar datos: $e')));
      }
    }
  }

  // Método para navegar a una ruta específica (igual que perfil)
  void _navigateToRoute(DashboardRoute route) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;

    if (isDesktop) {
      setState(() {
        _currentPage = route.id;
        _currentPageWidget = route.builder(context);
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => route.builder(context)),
      );
    }
  }

  // Método para volver al dashboard principal
  void _backToMain() {
    setState(() {
      _currentPage = 'main';
      _currentPageWidget = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;

    // Configurar el estilo de la barra de estado
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: theme.brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
        systemNavigationBarColor: colorScheme.surface,
        systemNavigationBarIconBrightness: theme.brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
      ),
    );

    // Contenido principal del panel de opciones
    final leftPanelContent = _isLoading
        ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
        : RefreshIndicator(
            onRefresh: _loadDashboardData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Información de última actualización
                  _buildLastUpdateInfo(context, theme, colorScheme),

                  const SizedBox(height: 20),

                  // Botones de acción rápida (mantener apariencia original)
                  _buildQuickActionButtons(context, colorScheme, theme),

                  const SizedBox(height: 24),

                  // Dashboard Financiero
                  if (_dashboardData != null) _buildFinancialSummary(context),

                  const SizedBox(height: 100), // Espacio extra al final
                ],
              ),
            ),
          );

    // En móvil, mostrar como página completa
    if (!isDesktop) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Panel de Control',
            style: textTheme.titleSmall?.copyWith(
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
        body: SafeArea(child: leftPanelContent),
      );
    }

    // En desktop, mostrar layout de dos columnas
    return Scaffold(
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Panel izquierdo (menú) - con ancho fijo de 320px
            SizedBox(
              width: 450,
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  border: Border(
                    right: BorderSide(
                      color: colorScheme.outline.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título del Panel
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Panel de Control',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : colorScheme.onSurface,
                        ),
                      ),
                    ),
                    // Contenido del panel izquierdo
                    Expanded(child: leftPanelContent),
                  ],
                ),
              ),
            ),

            // Panel derecho (contenido) - ocupa todo el espacio restante
            Expanded(
              child: Column(
                children: [
                  // Header del panel derecho
                  if (_currentPage != 'main')
                    _buildRightPanelHeader()
                  else
                    _buildDefaultHeader(),

                  // Contenido del panel derecho
                  Expanded(child: _currentPageWidget ?? _buildDefaultContent()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye el header del panel derecho cuando estamos en una página específica
  Widget _buildRightPanelHeader() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
            onPressed: _backToMain,
          ),
          const SizedBox(width: 8),
          Text(
            _getCurrentPageTitle() ?? '',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  /// Construye el header por defecto del panel derecho
  Widget _buildDefaultHeader() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.dashboard_outlined,
            color: colorScheme.onSurfaceVariant,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'Área de Contenido',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  /// Construye el contenido por defecto del panel derecho
  Widget _buildDefaultContent() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.touch_app,
            size: 64,
            color: colorScheme.primary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Selecciona una opción',
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }

  /// Obtiene el título de la página actual
  String? _getCurrentPageTitle() {
    if (_currentPage == 'main') return null;

    // Buscar la ruta actual en todas las secciones
    for (final section in _dashboardSections) {
      for (final route in section.routes) {
        if (route.id == _currentPage) {
          return route.title;
        }
      }
    }
    return null;
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

  // Método para construir el dashboard financiero unificado
  Widget _buildFinancialSummary(BuildContext context) {
    if (_dashboardData == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width <= 400;

    // Datos financieros desde la API
    final financialData =
        _dashboardData!['financialData'] as Map<String, dynamic>;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header compacto
          Row(
            children: [
              Icon(Icons.local_parking, color: colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Estado del Parqueo',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              Text(
                '${DateTime.now().day}/${DateTime.now().month}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // KPIs principales orientados al servicio
          Row(
            children: [
              Expanded(
                child: _buildKPICard(
                  context,
                  'Vehículos Hoy',
                  '${(financialData['dailyRevenue'] / financialData['averageTicket']).round()}',
                  Icons.directions_car,
                  Colors.blue,
                  'registrados',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildKPICard(
                  context,
                  'Ingresos del Día',
                  '\$${financialData['dailyRevenue'].toStringAsFixed(0)}',
                  Icons.attach_money,
                  Colors.green,
                  'recaudado',
                ),
              ),
              if (!isSmallScreen) ...[
                const SizedBox(width: 16),
                Expanded(
                  child: _buildKPICard(
                    context,
                    'Ocupación Actual',
                    '${(_dashboardData!['summary']['currentOccupancy'] as double).toStringAsFixed(0)}%',
                    Icons.local_parking,
                    Colors.orange,
                    'del parqueo',
                  ),
                ),
              ],
            ],
          ),

          if (isSmallScreen) ...[
            const SizedBox(height: 16),
            _buildKPICard(
              context,
              'Ocupación Actual',
              '${(_dashboardData!['summary']['currentOccupancy'] as double).toStringAsFixed(0)}%',
              Icons.local_parking,
              Colors.orange,
              'del parqueo',
            ),
          ],

          const SizedBox(height: 24),

          // Métricas adicionales orientadas al servicio
          GridView.count(
            crossAxisCount: isSmallScreen ? 2 : 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: [
              _buildMetricItem(
                context,
                'Espacios Totales',
                '${_dashboardData!['summary']['totalSpots']}',
                Icons.local_parking,
                Colors.blue,
              ),
              _buildMetricItem(
                context,
                'Espacios Ocupados',
                '${_dashboardData!['summary']['occupiedSpots']}',
                Icons.directions_car,
                Colors.orange,
              ),
              _buildMetricItem(
                context,
                'Tiempo Promedio',
                '${_dashboardData!['summary']['averageTime'].toStringAsFixed(1)}h',
                Icons.schedule,
                Colors.green,
              ),
              _buildMetricItem(
                context,
                'Rotación Diaria',
                '${_dashboardData!['summary']['dailyRotation'].toStringAsFixed(1)}',
                Icons.refresh,
                Colors.purple,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget para mostrar una métrica financiera moderna
  Widget _buildModernMetricCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              Icon(Icons.trending_up, color: Colors.green, size: 16),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  // Widget para mostrar una fila de información
  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    Color color,
    String text,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // Widget para mostrar una métrica financiera compacta
  Widget _buildCompactMetricCard(
    BuildContext context,
    String value,
    IconData icon,
    Color color,
    String title,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const Spacer(),
              Icon(Icons.trending_up, color: Colors.green, size: 14),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  // Widget para mostrar una fila de información compacta
  Widget _buildCompactInfoRow(
    BuildContext context,
    IconData icon,
    Color color,
    String value,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(icon, color: color, size: 14),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // Widget para mostrar una fila de información con etiqueta
  Widget _buildLabeledInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget para KPI principal
  Widget _buildKPICard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              Icon(Icons.trending_up, color: Colors.green, size: 16),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.green,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // Widget para ítem de métrica adicional
  Widget _buildMetricItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const Spacer(),
              Icon(Icons.arrow_upward, color: color, size: 14),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButtons(
    BuildContext context,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
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
                LayoutBuilder(
                  builder: (context, constraints) {
                    // Definir los datos de las acciones rápidas
                    final actions = [
                      {
                        'title': 'Gestionar',
                        'subtitle': 'Parqueo',
                        'icon': Icons.local_parking_rounded,
                        'color': colorScheme.primary,
                        'onTap': () {
                          final appState = AppStateContainer.of(context);
                          final currentParking = appState.currentParking;

                          if (currentParking != null) {
                            // En pantallas grandes, usar el diseño de dos columnas
                            final size = MediaQuery.of(context).size;
                            if (size.width > 900) {
                              _navigateToRoute(
                                DashboardRoute(
                                  id: 'parkingDetail',
                                  title: 'Gestionar Parqueo',
                                  icon: Icons.local_parking_rounded,
                                  builder: (context) => ParkingDetailScreen(
                                    parkingId: currentParking.id,
                                    parkingName: currentParking.name,
                                  ),
                                ),
                              );
                            } else {
                              // En pantallas pequeñas, usar navegación normal
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ParkingDetailScreen(
                                    parkingId: currentParking.id,
                                    parkingName: currentParking.name,
                                  ),
                                ),
                              );
                            }
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
                      },
                      {
                        'title': 'Estadísticas',
                        'subtitle': 'Análisis',
                        'icon': Icons.analytics_rounded,
                        'color': colorScheme.secondary,
                        'onTap': () {
                          // En pantallas grandes, usar el diseño de dos columnas
                          final size = MediaQuery.of(context).size;
                          if (size.width > 900) {
                            _navigateToRoute(
                              DashboardRoute(
                                id: 'statistics',
                                title: 'Estadísticas',
                                icon: Icons.analytics_rounded,
                                builder: (context) => const StatisticsPanel(),
                              ),
                            );
                          } else {
                            // En pantallas pequeñas, usar navegación normal
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const StatisticsPanel(),
                              ),
                            );
                          }
                        },
                      },
                      {
                        'title': 'Tarifas',
                        'subtitle': 'Precios',
                        'icon': Icons.attach_money_rounded,
                        'color': colorScheme.tertiary,
                        'onTap': () {
                          final appState = AppStateContainer.of(context);
                          final currentParking = appState.currentParking;

                          if (currentParking != null) {
                            // En pantallas grandes, usar el diseño de dos columnas
                            final size = MediaQuery.of(context).size;
                            if (size.width > 900) {
                              _navigateToRoute(
                                DashboardRoute(
                                  id: 'parkingRates',
                                  title: 'Tarifas y Precios',
                                  icon: Icons.attach_money_rounded,
                                  builder: (context) => ParkingRatesScreen(
                                    parkingId: currentParking.id,
                                    parkingName: currentParking.name,
                                  ),
                                ),
                              );
                            } else {
                              // En pantallas pequeñas, usar navegación normal
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ParkingRatesScreen(
                                    parkingId: currentParking.id,
                                    parkingName: currentParking.name,
                                  ),
                                ),
                              );
                            }
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
                      },
                      {
                        'title': 'Reportes',
                        'subtitle': 'Informes',
                        'icon': Icons.assessment_rounded,
                        'color': colorScheme.error,
                        'onTap': () {
                          // En pantallas grandes, usar el diseño de dos columnas
                          final size = MediaQuery.of(context).size;
                          if (size.width > 900) {
                            _navigateToRoute(
                              DashboardRoute(
                                id: 'reports',
                                title: 'Reportes',
                                icon: Icons.assessment_rounded,
                                builder: (context) => const ReportsScreen(),
                              ),
                            );
                          } else {
                            // En pantallas pequeñas, usar navegación normal
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ReportsScreen(),
                              ),
                            );
                          }
                        },
                      },
                      {
                        'title': 'Empleados',
                        'subtitle': 'Gestionar',
                        'icon': Icons.people_rounded,
                        'color': Colors.teal,
                        'onTap': () {
                          // En pantallas grandes, usar el diseño de dos columnas
                          final size = MediaQuery.of(context).size;
                          if (size.width > 900) {
                            _navigateToRoute(
                              DashboardRoute(
                                id: 'employees',
                                title: 'Empleados',
                                icon: Icons.people_rounded,
                                builder: (context) => const EmployeesScreen(),
                              ),
                            );
                          } else {
                            // En pantallas pequeñas, usar navegación normal
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const EmployeesScreen(),
                              ),
                            );
                          }
                        },
                      },
                      {
                        'title': 'Suscripción',
                        'subtitle': 'Administrar',
                        'icon': Icons.subscriptions_rounded,
                        'color': Colors.purple,
                        'onTap': () {
                          // En pantallas grandes, usar el diseño de dos columnas
                          final size = MediaQuery.of(context).size;
                          if (size.width > 900) {
                            _navigateToRoute(
                              DashboardRoute(
                                id: 'manageSubscriptionCard',
                                title: 'Suscripción',
                                icon: Icons.subscriptions_rounded,
                                builder: (context) =>
                                    const ManageSubscriptionScreen(),
                              ),
                            );
                          } else {
                            // En pantallas pequeñas, usar navegación normal
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ManageSubscriptionScreen(),
                              ),
                            );
                          }
                        },
                      },
                    ];

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: actions.length,
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 150,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 0.9,
                          ),
                      itemBuilder: (context, index) {
                        final action = actions[index];
                        return _buildActionCard(
                          context,
                          action['title'] as String,
                          action['subtitle'] as String,
                          action['icon'] as IconData,
                          action['color'] as Color,
                          action['onTap'] as VoidCallback,
                        );
                      },
                    );
                  },
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

    return Card(
      elevation: 1,
      shadowColor: color.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: Text(
                  title,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 2),
              Flexible(
                child: Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
