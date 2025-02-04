import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:parkar/models/user_model.dart';
import 'package:parkar/screens/home/game_screen.dart';
import 'package:parkar/screens/home/profile_screen.dart';
import 'package:parkar/state/app_state_container.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // Índice del elemento seleccionado

  // Lista de elementos de navegación
  final List<Widget> _screens = [
     const GameScreen(),
     const Text('Historial'),
     const Text('Ajustes'),
  ];

  @override
  Widget build(BuildContext context) {
    final appState = AppStateContainer.of(context); // Accede al estado global
    final UserModel? currentUser = appState.user; // Usuario actual
    final bool isMobile = MediaQuery.of(context).size.width < 600; // Detectar móvil

    setState(() {
        _screens.add(ProfileSettings(
        onEditProfile: ()=>{},
        onLogout: () {
          appState.logout();
          context.go('/login');
        },
        onToggleTheme: () {
          
        },
        userName: currentUser?.name,
        userEmail: currentUser?.email,
      ));
    });
    return Scaffold(
      body: Row(
        children: [
          if (!isMobile) // Sidebar para escritorio
            Container(
              // margin: const EdgeInsets.only(top: 16, bottom: 16),
              // decoration: BoxDecoration(
              //   border: Border(
              //     right: BorderSide(
              //       color: Theme.of(context).dividerColor.withAlpha(128),
              //       width: 1,
              //     ),
              //   ),
              // ),
              child: NavigationRail(
                labelType: NavigationRailLabelType.all,
                // indicatorColor: Theme.of(context).colorScheme,
                // extended: true,
                elevation: 2,
                groupAlignment: 0,
                selectedIndex: _selectedIndex,
                onDestinationSelected: (index) {
                  setState(() => _selectedIndex = index);
                },
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('Inicio'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.history),
                    label: Text('Historial'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.settings),
                    label: Text('Ajustes'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.person),
                    label: Text('perfil'),
                  ),
                ],
              ),
            ),
          Expanded(
            child: _screens[_selectedIndex],
          ),
        ],
      ),
      bottomNavigationBar: isMobile
          ? NavigationBar(
            // labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
      selectedIndex: _selectedIndex,
      onDestinationSelected: (index) {
        setState(() => _selectedIndex = index);
      },
      destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: 'Inicio',
                ),
                NavigationDestination(
                  icon: Icon(Icons.history_outlined),
                  selectedIcon: Icon(Icons.history),
                  label: 'Historial',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings),
                  label: 'Ajustes',
                ),
              ],
            )
          : null,
    );
  }

}