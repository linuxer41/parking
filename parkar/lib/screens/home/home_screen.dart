import 'package:fluent_ui/fluent_ui.dart';
import 'package:go_router/go_router.dart';
import '../../models/user_model.dart';
import '../../state/app_state_container.dart';
import '../../infinite_canvas/widgets/canvas.dart' as infinity_canvas;

class MenuItem {
  final String title;
  final IconData icon;
  final Widget? body;

  const MenuItem({
    required this.title,
    required this.icon,
    this.body,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int topIndex = 0; // Índice del elemento seleccionado
  PaneDisplayMode displayMode =
      PaneDisplayMode.auto; // Modo de visualización del panel

  @override
  Widget build(BuildContext context) {
    final appState = AppStateContainer.of(context); // Accede al estado global
    final UserModel? currentUser = appState.user; // Usuario actual
    final String currentParking =
        appState.currentParking?.name ?? "No seleccionado"; // Parqueo actual
    final theme = FluentTheme.of(context); // Tema actual


    // Lista de elementos de navegación
    final List<NavigationPaneItem> items = [
      PaneItem(
        icon: const Icon(FluentIcons.home),
        title: const Text(
          'Inicio',
          overflow: TextOverflow.ellipsis,
        ),
        body: const infinity_canvas.InfiniteCanvas(),
      ),

      PaneItemSeparator(),
      PaneItem(
        icon: const Icon(FluentIcons.history),
        title: const Text(
          'Historial',
          overflow: TextOverflow.ellipsis,
        ),
        body: const Text('Historial'),
      ),
      PaneItem(
        icon: const Icon(FluentIcons.settings),
        title: const Text(
          'Ajustes',
          overflow: TextOverflow.ellipsis,
        ),
        body: const Text('Ajustes'),
      ),
    ];
    return NavigationView(
      pane: NavigationPane(
        selected: topIndex,
        onChanged: (index) => setState(() => topIndex = index),
        displayMode: displayMode,
        items: items,
        header: Column(
          children: [
            // Tarjeta para mostrar el usuario actual
            Card(
              backgroundColor: theme.accentColor
                  .withOpacity(0.1), // Fondo con color de acento
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(FluentIcons.contact,
                      size: 32, color: Color.fromARGB(255, 231, 8, 8)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Usuario actual',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.inactiveColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          currentUser?.name ?? "No autenticado",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: theme.accentColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(FluentIcons.sign_out),
                    onPressed: () {
                      // Lógica para cerrar sesión
                      appState
                          .logout(); // Suponiendo que tienes un método `logout` en tu estado global
                      GoRouter.of(context).go("/login"); // Redirigir al login
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8), // Espacio entre las tarjetas
            // Tarjeta para mostrar el parqueo actual
            Card(
              backgroundColor: theme.accentColor
                  .withOpacity(0.1), // Fondo con color de acento
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(FluentIcons.parking_location,
                      size: 32, color: Color.fromARGB(255, 31, 235, 13)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Parqueo actual',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.inactiveColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          currentParking,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: theme.accentColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(FluentIcons.edit),
                    onPressed: () {
                      // Navegar a la pantalla de selección de parqueo
                      GoRouter.of(context).go("/init");
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
