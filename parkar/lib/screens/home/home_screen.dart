import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:parkar/screens/profile/profile_screen.dart';
import 'package:parkar/state/app_state_container.dart';
import '../../widgets/responsive_layout.dart';

import '../dashboard/dashboard_screen.dart';
import '../parking/parking_screen.dart' show ParkingScreen;


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
      ProfilePanel(
        onLogout: () {
          appState.logout();
          context.go('/login');
        },
        user: appState.currentUser!,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Usar ValueListenableBuilder para escuchar cambios en el modo de edición
    return Builder(
      builder: (context) {
        // Contenido para móviles
        final mobileContent = Scaffold(
          extendBody: false,
          extendBodyBehindAppBar: true,
          body: SafeArea(child: _screens[_selectedIndex]),
          bottomNavigationBar: Container(
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
                      indicatorColor: colorScheme.secondaryContainer
                          .withOpacity(0.7),
                      destinations: const [
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
                          icon: Icon(Icons.person_outline, size: 22),
                          selectedIcon: Icon(Icons.person, size: 22),
                          label: 'Perfil',
                        ),
                      ],
                    ),
                  ),
                ),
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
                  selectedIconTheme: IconThemeData(
                    color: colorScheme.primary,
                    size: 20,
                  ),
                  unselectedIconTheme: IconThemeData(
                    color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                    size: 20,
                  ),
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
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.local_parking_outlined),
                      selectedIcon: Icon(Icons.local_parking),
                      label: Text('Parqueo'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.dashboard_outlined),
                      selectedIcon: Icon(Icons.dashboard),
                      label: Text('Panel'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.person_outline),
                      selectedIcon: Icon(Icons.person),
                      label: Text('Perfil'),
                    ),
                  ],
                ),

                // Contenido principal sin restricciones de ancho
                Expanded(child: _screens[_selectedIndex]),
              ],
            ),
          ),
        );

        // Aplicar el layout responsivo
        return ResponsiveLayout(mobile: mobileContent, desktop: desktopContent);
      },
    );
  }
}
