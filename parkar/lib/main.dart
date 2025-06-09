import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:system_theme/system_theme.dart';
import 'package:window_manager/window_manager.dart';
import 'routes/app_router.dart';
import 'services/service_locator.dart';
import 'state/app_state.dart';
import 'state/app_state_container.dart';
import 'di/di_container.dart';
import 'state/theme.dart';
import 'package:flutter/services.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/history/history_screen.dart';
import 'screens/home/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Clave global para el navegador, útil para acceder al contexto desde cualquier parte
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

bool get isDesktop {
  if (kIsWeb) return false;
  return [
    TargetPlatform.windows,
    TargetPlatform.linux,
    TargetPlatform.macOS,
  ].contains(defaultTargetPlatform);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configurar la aplicación en modo pantalla completa
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );

  // Configurar la orientación de la app (solo permitir modo retrato)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await SystemTheme.accentColor.load();

  if (isDesktop) {
    await windowManager.ensureInitialized();
    windowManager.waitUntilReadyToShow().then((_) async {
      await windowManager.setTitle('Parkar: sistema de parqueo');
      await windowManager.setSize(const Size(755, 545));
      await windowManager.center();
      await windowManager.show();
    });
  }

  final appState = AppState();
  await appState.loadState();
  ServiceLocator().registerAppState(appState);
  final diContainer = DIContainer();
  final appTheme = AppTheme();

  runApp(AppStateContainer(
    state: appState,
    diContainer: diContainer,
    appTheme: appTheme,
    child: const MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  // Método para cargar la preferencia de tema
  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeString = prefs.getString('theme_mode');

    if (themeModeString != null) {
      setState(() {
        if (themeModeString.contains('ThemeMode.light')) {
          _themeMode = ThemeMode.light;
        } else if (themeModeString.contains('ThemeMode.dark')) {
          _themeMode = ThemeMode.dark;
        } else {
          _themeMode = ThemeMode.system;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = AppStateContainer.theme(context);
    
    return MaterialApp.router(
      title: 'Parkar',
      routerConfig: router,
      theme: appTheme.getLightTheme(),
      darkTheme: appTheme.getDarkTheme(),
      themeMode: appTheme.mode,
      debugShowCheckedModeBanner: false,
    );
  }
}
