import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:system_theme/system_theme.dart';
import 'package:window_manager/window_manager.dart';
import 'config/app_config.dart';
import 'routes/app_router.dart';
import 'services/service_locator.dart';
import 'state/app_state.dart';
import 'state/app_state_container.dart';
import 'di/di_container.dart';
import 'package:flutter/services.dart';


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
  final data = MediaQueryData.fromView(WidgetsBinding.instance.window);
  final size = data.size;
  final diagonal =
      (size.width * size.width + size.height * size.height) / 10000;
  return diagonal >= 70; // Diagonal de 7 pulgadas o más
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AppConfig.init(
    // apiBaseUrl: 'http://localhost:3002',
    apiBaseUrl: 'http://192.168.100.8:3002',
    apiTimeout: 30,
    apiEndpoints: {
      'auth': '/auth',
      'user': '/users',
      'employee': '/employees',
      'parking': '/parkings',
      'area': '/areas',
      'vehicle': '/vehicles',
      'subscription': '/subscriptions',
      'entry': '/entries',
      'exit': '/exits',
      'cashRegister': '/cash_registers',
      'movement': '/movements',
      'reservation': '/reservations',
      'access': '/accesses',
    },
  );

  // Configurar la aplicación en modo pantalla completa
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );
  
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

  // Cargar tema del sistema solo si no estamos en web
  if (!kIsWeb) {
    await SystemTheme.accentColor.load();
  }

  // Configurar ventana solo para escritorio y no web
  if (isDesktop && !kIsWeb) {
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

  // Añadir listener para depuración
  appState.addListener(() {
    print(
        'DEBUG main: AppState cambió - modo: ${appState.mode}, color: ${appState.color}');
  });

  // Crear una instancia de animación para forzar actualizaciones
  runApp(MyApp(appState: appState, diContainer: diContainer));
}

class MyApp extends StatelessWidget {
  final AppState appState;
  final DIContainer diContainer;

  const MyApp({
    super.key,
    required this.appState,
    required this.diContainer,
  });

  @override
  Widget build(BuildContext context) {
    print('DEBUG: MyApp.build() ejecutado');
    return AppStateContainer(
      state: appState,
      diContainer: diContainer,
      child: ListenableBuilder(
        listenable: appState,
        builder: (context, child) {
          print(
              'DEBUG: ListenableBuilder reconstruido - appState.mode: ${appState.mode}, color: ${appState.color}');
          return MaterialApp.router(
            title: 'Parking Control',
            debugShowCheckedModeBanner: false,
            locale: appState.locale,
            themeMode: appState.mode,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: appState.color,
                brightness: Brightness.light,
              ),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: appState.color,
                brightness: Brightness.dark,
              ),
            ),
            routerConfig: router,
          );
        },
      ),
    );
  }
}
