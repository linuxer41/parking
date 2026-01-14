import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:system_theme/system_theme.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:window_manager/window_manager.dart';

import 'config/app_config.dart';
import 'config/localization_config.dart';
import 'constants/constants.dart';
import 'di/di_container.dart';
import 'routes/app_router.dart';
import 'services/service_locator.dart';
import 'state/app_state.dart';
import 'state/app_state_container.dart';

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

  // Inicializar datos de localización para fechas
  await initializeDateFormatting('es');

  // Inicializar base de datos de zonas horarias
  tzdata.initializeTimeZones();

  // Configurar codificación UTF-8 para caracteres especiales
  LocalizationConfig.configureUtf8();

  AppConfig.init(
    // apiBaseUrl: 'http://localhost:3002',
    apiBaseUrl: 'http://192.168.100.8:3002',
    // apiBaseUrl: 'http://192.168.1.16:3002',
    // apiBaseUrl: 'http://192.168.1.13:3002',
    // apiBaseUrl: 'http://192.168.1.7:3002',
    // apiBaseUrl: 'https://parkar-api.iathings.com',
    enableWebSocket: false, // Disable WebSocket as it's not available
    apiTimeout: 30,
    apiEndpoints: {
      'auth': '/auth',
      'user': '/users',
      'employee': '/employees',
      'parking': '/parkings',
      'vehicle': '/vehicles',
      'booking': '/booking',
      'access': '/access',
      'subscription': '/subscriptions',
      'exit': '/exits',
      'cashRegister': '/cash-registers',
      'movement': '/movements',
    },
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
  print('DEBUG: AppState cargado ${appState.currentUser?.toJson()}');
  ServiceLocator().registerAppState(appState);
  final diContainer = DIContainer();


  // Crear una instancia de animación para forzar actualizaciones
  runApp(MyApp(appState: appState, diContainer: diContainer));
}

class MyApp extends StatelessWidget {
  final AppState appState;
  final DIContainer diContainer;

  const MyApp({super.key, required this.appState, required this.diContainer});

  @override
  Widget build(BuildContext context) {
    
    return AppStateContainer(
      state: appState,
      diContainer: diContainer,
      child: ListenableBuilder(
        listenable: appState,
        builder: (context, child) {
          return MaterialApp.router(
            title: 'Parking Control',
            debugShowCheckedModeBanner: false,
            locale: appState.locale ?? LocalizationConfig.defaultLocale,
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
            builder: (context, child) {
              final theme = Theme.of(context);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                SystemChrome.setSystemUIOverlayStyle(
                  SystemUiOverlayStyle(
                    statusBarColor: Colors.transparent,
                    statusBarIconBrightness: theme.brightness == Brightness.dark
                        ? Brightness.light
                        : Brightness.dark,
                    systemNavigationBarColor: theme.colorScheme.surface,
                    systemNavigationBarIconBrightness: theme.brightness == Brightness.dark
                        ? Brightness.light
                        : Brightness.dark,
                  ),
                );
              });
              return child ?? const SizedBox.shrink();
            },
          );
        },
      ),
    );
  }
}
