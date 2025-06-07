import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:parkar/screens/home/world/world_screen.dart' show WorldScreen;
import 'package:parkar/screens/home/profile_screen.dart';
import 'package:parkar/screens/home/settings_screen.dart';
import 'package:parkar/state/app_state_container.dart';
import '../dashboard/dashboard_screen.dart';
import '../history/history_screen.dart';
import 'parking/parking_screen.dart' show ParkingScreen;

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
      const WorldScreen(),
      const ParkingScreen(),
      const DashboardScreen(),
      const HistoryScreen(),
      const SettingsScreen(),
      ProfileSettings(
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
    final bool isMobile =
        MediaQuery.of(context).size.width < 600; // Detectar móvil
    final colorScheme = Theme.of(context).colorScheme;
    final padding = MediaQuery.of(context).padding;

    // Usar ValueListenableBuilder para escuchar cambios en el modo de edición
    return ValueListenableBuilder<bool>(
        valueListenable: isEditorModeActive,
        builder: (context, isEditorMode, child) {
          return Scaffold(
            // Sin AppBar para un diseño minimalista
            extendBody:
                false, // Importante: NO extender el body detrás del bottomNavigationBar
            extendBodyBehindAppBar: true,
            body: Row(
              children: [
                if (!isMobile) // Sidebar para escritorio (minimalista)
                  NavigationRail(
                    labelType: NavigationRailLabelType.selected,
                    useIndicator: true,
                    indicatorColor: colorScheme.primaryContainer,
                    selectedIconTheme:
                        IconThemeData(color: colorScheme.primary),
                    selectedLabelTextStyle:
                        TextStyle(color: colorScheme.primary),
                    backgroundColor: colorScheme.surface.withOpacity(0.9),
                    minWidth: 60,
                    elevation: 1.0,
                    groupAlignment: 0,
                    selectedIndex: _selectedIndex,
                    onDestinationSelected: (index) {
                      setState(() => _selectedIndex = index);
                    },
                    destinations: const [
                      NavigationRailDestination(
                        icon: Icon(Icons.grid_3x3_outlined),
                        selectedIcon: Icon(Icons.grid_3x3),
                        label: Text('Canvas'),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.local_parking_outlined),
                        selectedIcon: Icon(Icons.local_parking),
                        label: Text('Parking'),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.dashboard_outlined),
                        selectedIcon: Icon(Icons.dashboard),
                        label: Text('Dashboard'),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.history_outlined),
                        selectedIcon: Icon(Icons.history),
                        label: Text('Historial'),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.settings_outlined),
                        selectedIcon: Icon(Icons.settings),
                        label: Text('Ajustes'),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.person_outlined),
                        selectedIcon: Icon(Icons.person),
                        label: Text('Perfil'),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ],
                  ),
                Expanded(
                  child: _screens[_selectedIndex],
                ),
              ],
            ),
            // Solo mostrar la barra de navegación si no estamos en modo edición
            bottomNavigationBar: (isMobile && !isEditorMode)
                ? Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, -1),
                        ),
                      ],
                    ),
                    // Usar SafeArea para asegurar que está dentro de la zona visible
                    child: SafeArea(
                      child: NavigationBar(
                        selectedIndex: _selectedIndex,
                        onDestinationSelected: (index) {
                          setState(() => _selectedIndex = index);
                        },
                        height:
                            60, // Altura fija para evitar problemas de layout
                        labelBehavior:
                            NavigationDestinationLabelBehavior.onlyShowSelected,
                        backgroundColor: Colors
                            .transparent, // Transparente para mejor integración
                        elevation: 0, // Sin elevación para diseño minimalista
                        destinations: const [
                          NavigationDestination(
                            icon: Icon(Icons.grid_3x3_outlined, size: 24),
                            selectedIcon: Icon(Icons.grid_3x3, size: 24),
                            label: 'Canvas',
                          ),
                          NavigationDestination(
                            icon: Icon(Icons.local_parking_outlined, size: 24),
                            selectedIcon: Icon(Icons.local_parking, size: 24),
                            label: 'Parking',
                          ),
                          NavigationDestination(
                            icon: Icon(Icons.dashboard_outlined, size: 24),
                            selectedIcon: Icon(Icons.dashboard, size: 24),
                            label: 'Dashboard',
                          ),
                          NavigationDestination(
                            icon: Icon(Icons.history_outlined, size: 24),
                            selectedIcon: Icon(Icons.history, size: 24),
                            label: 'Historial',
                          ),
                          NavigationDestination(
                            icon: Icon(Icons.settings_outlined, size: 24),
                            selectedIcon: Icon(Icons.settings, size: 24),
                            label: 'Ajustes',
                          ),
                          NavigationDestination(
                            icon: Icon(Icons.person_outlined, size: 24),
                            selectedIcon: Icon(Icons.person, size: 24),
                            label: 'Perfil',
                          ),
                        ],
                      ),
                    ),
                  )
                : null,
          );
        });
  }
}
