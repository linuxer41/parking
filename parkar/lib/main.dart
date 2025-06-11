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

bool get isTablet {
  // Determinar si es una tablet basado en el tamaño físico
  final data = MediaQueryData.fromWindow(WidgetsBinding.instance.window);
  final size = data.size;
  final diagonal =
      (size.width * size.width + size.height * size.height) / 10000;
  return diagonal >= 70; // Diagonal de 7 pulgadas o más
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

  // Configurar la orientación de la app
  // Solo permitir modo retrato en dispositivos móviles
  // Permitir todas las orientaciones en tablets y escritorio
  if (!isTablet && !isDesktop) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  } else {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  await SystemTheme.accentColor.load();

  if (isDesktop) {
    await windowManager.ensureInitialized();
    windowManager.waitUntilReadyToShow().then((_) async {
      await windowManager.setTitle('Parkar: sistema de parqueo');
      await windowManager.setSize(const Size(1200, 800));
      await windowManager.center();
      await windowManager.show();
    });
  }

  final appState = AppState();
  await appState.loadState();
  ServiceLocator().registerAppState(appState);
  final diContainer = DIContainer();
  final appTheme = AppTheme();

  // Crear una instancia de animación para forzar actualizaciones
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

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  AppTheme? _currentTheme;

  @override
  void initState() {
    super.initState();
    // Registrar para escuchar cambios en el sistema (como cambio de tema del sistema)
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    // Forzar actualización cuando cambia el brillo del sistema
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Usar directamente el tema del AppStateContainer y comparar con el tema anterior
    final container =
        context.dependOnInheritedWidgetOfExactType<AppStateContainer>();
    if (container == null) {
      throw FlutterError(
          'AppStateContainer no encontrado en el árbol de widgets');
    }

    final appTheme = container.appTheme;

    // Si el tema ha cambiado, forzamos una reconstrucción
    if (_currentTheme == null ||
        _currentTheme!.mode != appTheme.mode ||
        _currentTheme!.color.value != appTheme.color.value) {
      _currentTheme = appTheme;
      // No es necesario llamar a setState() aquí porque dependOnInheritedWidgetOfExactType
      // ya disparará una reconstrucción si el contenedor ha cambiado
    }

    // Reconstruir MaterialApp con el tema actual
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
