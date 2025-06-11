import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:parkar/screens/control_panel/user_control_panel.dart';
import 'package:parkar/state/app_state_container.dart';
import '../../widgets/responsive_layout.dart';

import '../dashboard/dashboard_screen.dart';
import '../history/history_screen.dart';
import '../parking/parking_screen.dart' show ParkingScreen;

// Notificador para el modo de edición
final ValueNotifier<bool> isEditorModeActive = ValueNotifier<bool>(false);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // Índice del elemento seleccionado
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initScreens();
  }

  void _initScreens() {
    final appState = AppStateContainer.of(context);
    _screens = [
      const ParkingScreen(),
      const DashboardScreen(),
      const HistoryScreen(),
      UserControlPanel(
        onEditProfile: () {},
        onLogout: () {
          appState.logout();
          context.go('/login');
        },
        onToggleTheme: () {
          // Implementar cambio de tema
          final currentTheme = appState.theme;
          if (currentTheme != null) {
            currentTheme.toggleThemeMode();
            appState.setTheme(currentTheme);
          }
        },
        userName: appState.user?.name,
        userEmail: appState.user?.email,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Usar ValueListenableBuilder para escuchar cambios en el modo de edición
    return ValueListenableBuilder<bool>(
        valueListenable: isEditorModeActive,
        builder: (context, isEditorMode, child) {
          // Contenido para móviles
          final mobileContent = Scaffold(
            extendBody: false,
            extendBodyBehindAppBar: true,
            body: SafeArea(
              child: _screens[_selectedIndex],
            ),
            bottomNavigationBar: !isEditorMode
                ? Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      child: NavigationBar(
                        selectedIndex: _selectedIndex,
                        onDestinationSelected: (index) {
                          setState(() => _selectedIndex = index);
                        },
                        height: 62,
                        labelBehavior:
                            NavigationDestinationLabelBehavior.alwaysShow,
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        surfaceTintColor: Colors.transparent,
                        indicatorColor:
                            colorScheme.secondaryContainer.withOpacity(0.7),
                        destinations: [
                          NavigationDestination(
                            icon: Icon(Icons.local_parking_outlined, size: 22),
                            selectedIcon: Icon(Icons.local_parking, size: 22),
                            label: 'Parqueo',
                          ),
                          NavigationDestination(
                            icon: Icon(Icons.dashboard_outlined, size: 22),
                            selectedIcon: Icon(Icons.dashboard, size: 22),
                            label: 'Panel',
                          ),
                          NavigationDestination(
                            icon: Icon(Icons.list_alt_outlined, size: 22),
                            selectedIcon: Icon(Icons.list_alt, size: 22),
                            label: 'Registros',
                          ),
                          NavigationDestination(
                            icon: Icon(Icons.more_horiz, size: 22),
                            selectedIcon: Icon(Icons.more_horiz, size: 22),
                            label: 'Más',
                          ),
                        ],
                      ),
                    ),
                  )
                : null,
          );

          // Contenido para tablets y escritorio
          final desktopContent = Scaffold(
            extendBody: false,
            extendBodyBehindAppBar: true,
            body: SafeArea(
              child: Row(
                children: [
                  // Navigation Rail
                  NavigationRail(
                    labelType: NavigationRailLabelType.all,
                    useIndicator: true,
                    indicatorColor: colorScheme.primaryContainer,
                    selectedIconTheme:
                        IconThemeData(color: colorScheme.primary, size: 20),
                    unselectedIconTheme: IconThemeData(
                        color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                        size: 20),
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    selectedLabelTextStyle: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                    unselectedLabelTextStyle: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                    minWidth: 68,
                    minExtendedWidth: 150,
                    elevation: 1,
                    groupAlignment: 0,
                    selectedIndex: _selectedIndex,
                    onDestinationSelected: (index) {
                      setState(() => _selectedIndex = index);
                    },
                    destinations: [
                      NavigationRailDestination(
                        icon: const Icon(Icons.local_parking_outlined),
                        selectedIcon: const Icon(Icons.local_parking),
                        label: const Text('Parqueo'),
                      ),
                      NavigationRailDestination(
                        icon: const Icon(Icons.dashboard_outlined),
                        selectedIcon: const Icon(Icons.dashboard),
                        label: const Text('Panel'),
                      ),
                      NavigationRailDestination(
                        icon: const Icon(Icons.list_alt_outlined),
                        selectedIcon: const Icon(Icons.list_alt),
                        label: const Text('Registros'),
                      ),
                      NavigationRailDestination(
                        icon: const Icon(Icons.more_horiz),
                        selectedIcon: const Icon(Icons.more_horiz),
                        label: const Text('Más'),
                      ),
                    ],
                  ),

                  // Contenido principal sin restricciones de ancho
                  Expanded(
                    child: _screens[_selectedIndex],
                  ),
                ],
              ),
            ),
          );

          // Aplicar el layout responsivo
          return ResponsiveLayout(
            mobile: mobileContent,
            desktop: desktopContent,
          );
        });
  }
}
