import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'about_screen.dart';
import 'change_password_screen.dart';
import 'edit_profile_screen.dart';
import 'help_screen.dart';
import 'language_screen.dart';
import 'notifications_settings_screen.dart';
import 'theme_screen.dart';

// Definición de rutas para el panel de control
class ControlPanelRoute {
  final String id;
  final String title;
  final IconData icon;
  final Widget Function(BuildContext) builder;
  final Color? textColor;
  final Color? iconColor;

  const ControlPanelRoute({
    required this.id,
    required this.title,
    required this.icon,
    required this.builder,
    this.textColor,
    this.iconColor,
  });
}

// Sección del panel de control
class ControlPanelSection {
  final String title;
  final List<ControlPanelRoute> routes;

  const ControlPanelSection({required this.title, required this.routes});
}

class UserControlPanel extends StatefulWidget {
  final String? userName;
  final String? userEmail;
  final VoidCallback onLogout;

  const UserControlPanel({
    super.key,
    this.userName,
    this.userEmail,
    required this.onLogout,
  });

  @override
  State<UserControlPanel> createState() => _UserControlPanelState();
}

class _UserControlPanelState extends State<UserControlPanel> {
  bool _initialized = false;

  // Estado para la página actual en el diseño responsivo
  String _currentPage = 'main';
  Widget? _currentPageWidget;

  // Definición de todas las rutas del panel de control
  late List<ControlPanelSection> _controlPanelSections;

  @override
  void initState() {
    super.initState();

    // Set preferred orientations for better Android experience
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Set system UI overlay style for Android
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;

      // Inicializar las secciones y rutas
      _initializeRoutes();
    }
  }

  void _initializeRoutes() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    _controlPanelSections = [
      // Sección de gestión de cuenta
      ControlPanelSection(
        title: 'Cuenta',
        routes: [
          ControlPanelRoute(
            id: 'edit_profile',
            title: 'Editar perfil',
            icon: Icons.person_outline,
            builder: (context) => EditProfileScreen(
              initialName: widget.userName,
              initialEmail: widget.userEmail,
            ),
          ),
          ControlPanelRoute(
            id: 'change_password',
            title: 'Cambiar contraseña',
            icon: Icons.lock_outline,
            builder: (context) => const ChangePasswordScreen(),
          ),
          ControlPanelRoute(
            id: 'notifications',
            title: 'Notificaciones',
            icon: Icons.notifications_outlined,
            builder: (context) => const NotificationsSettingsScreen(),
          ),
        ],
      ),

      // Sección de preferencias
      ControlPanelSection(
        title: 'Preferencias',
        routes: [
          ControlPanelRoute(
            id: 'theme',
            title: 'Personalizar tema',
            icon: isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
            builder: (context) => const ThemeScreen(),
          ),
          ControlPanelRoute(
            id: 'language',
            title: 'Idioma',
            icon: Icons.language_outlined,
            builder: (context) => const LanguageScreen(),
          ),
        ],
      ),

      // Sección de soporte y ayuda
      ControlPanelSection(
        title: 'Soporte',
        routes: [
          ControlPanelRoute(
            id: 'help',
            title: 'Ayuda',
            icon: Icons.help_outline,
            builder: (context) => const HelpScreen(),
          ),
          ControlPanelRoute(
            id: 'about',
            title: 'Acerca de',
            icon: Icons.info_outline,
            builder: (context) => const AboutScreen(),
          ),
          ControlPanelRoute(
            id: 'logout',
            title: 'Cerrar sesión',
            icon: Icons.logout_rounded,
            builder: (context) => const SizedBox(), // No se usa realmente
            textColor: Colors.red,
            iconColor: Colors.red,
          ),
        ],
      ),
    ];
  }

  @override
  void dispose() {
    // Reset system UI settings when disposing
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  // Método para cambiar la página actual
  void _navigateToRoute(ControlPanelRoute route) {
    if (route.id == 'logout') {
      widget.onLogout();
      return;
    }

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final textTheme = theme.textTheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;

    // Contenido principal del panel de opciones
    final mainContent = SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado con información del usuario
            _buildHeader(context, colorScheme, textTheme),

            const SizedBox(height: 18),

            // Construir todas las secciones definidas
            for (final section in _controlPanelSections) ...[
              _buildSection(
                context,
                section.title,
                section.routes
                    .map(
                      (route) => _buildMenuItem(
                        context,
                        route.title,
                        route.icon,
                        colorScheme,
                        onTap: () => _navigateToRoute(route),
                        textColor: route.textColor,
                        iconColor: route.iconColor,
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 14),
            ],
          ],
        ),
      ),
    );

    // En vista móvil, mostrar el contenido principal o la página seleccionada
    if (!isDesktop) {
      return Scaffold(
        body: SafeArea(
          child: _currentPage != 'main' && _currentPageWidget != null
              ? _currentPageWidget!
              : mainContent,
        ),
      );
    }

    // En vista de escritorio, mostrar el layout de dos columnas
    return Scaffold(
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Panel izquierdo (menú) - con ancho proporcional
            SizedBox(
              width:
                  screenWidth *
                  0.3, // 30% del ancho de pantalla, con mínimo y máximo
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  border: Border(
                    right: BorderSide(
                      color: colorScheme.outline.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título de Opciones
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Opciones',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: theme.brightness == Brightness.dark
                              ? Colors.white
                              : colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Expanded(child: mainContent),
                  ],
                ),
              ),
            ),

            // Panel derecho (contenido) - ocupa todo el espacio restante
            Expanded(
              child: _currentPage != 'main' && _currentPageWidget != null
                  ? Column(children: [Expanded(child: _currentPageWidget!)])
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.touch_app,
                            size: 64,
                            color: colorScheme.primary.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Selecciona una opción',
                            style: textTheme.titleLarge?.copyWith(
                              color: colorScheme.onSurfaceVariant.withOpacity(
                                0.7,
                              ),
                              fontWeight: FontWeight.w300,
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

  // Construir encabezado con información del usuario
  Widget _buildHeader(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Row(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                colorScheme.primary.withOpacity(0.7),
                colorScheme.primary,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.person_rounded,
              size: 40,
              color: colorScheme.onPrimary,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.userName ?? 'Usuario',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                widget.userEmail ?? 'usuario@ejemplo.com',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Construir sección con título
  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Text(
            title,
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Card(
          elevation: 0,
          color: colorScheme.surfaceContainerLowest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: colorScheme.outline.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  // Construir elemento de menú
  Widget _buildMenuItem(
    BuildContext context,
    String title,
    IconData icon,
    ColorScheme colorScheme, {
    VoidCallback? onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (iconColor ?? colorScheme.primary).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor ?? colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  color: textColor ?? colorScheme.onSurface,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: colorScheme.onSurfaceVariant.withOpacity(0.5),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
