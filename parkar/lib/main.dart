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
  await SystemTheme.accentColor.load();

  if (isDesktop) {
    await windowManager.ensureInitialized();
    windowManager.waitUntilReadyToShow().then((_) async {
      await windowManager.setTitle('Parkar: sistema de parqueo');
      // await windowManager.setBackgroundColor(const Color(0xFF202020));
      // await windowManager.setBrightness(Brightness.light);
      // await windowManager.maximize();
      await windowManager.setSize(const Size(755, 545));
      // await windowManager.setMinimumSize(const Size(755, 545));
      await windowManager.center();
      await windowManager.show();
      // await windowManager.setSkipTaskbar(false);
    });
  }

  final appState = AppState();
  await appState.loadState();
  ServiceLocator().registerAppState(appState); // Registra el AppState
  final diContainer = DIContainer();
  final appTheme = AppTheme();

  // set widnow title bar color

  runApp(MyApp(appState: appState, diContainer: diContainer, appTheme: appTheme));
}

class MyApp extends StatelessWidget {
  final AppState appState;
  final DIContainer diContainer;
  final AppTheme appTheme;

  const MyApp({super.key, required this.appState, required this.diContainer, required this.appTheme});

  @override
  Widget build(BuildContext context) {
    // final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark || appTheme.mode == ThemeMode.dark;
    // if (isDark) {
    //   windowManager.setBrightness(Brightness.dark);
    // } else {
    //   windowManager.setBrightness(Brightness.light);
    // }
    return AppStateContainer(
      state: appState,
      diContainer: diContainer,
      appTheme: appTheme,
      child: ListenableBuilder(
        listenable: appState,
        builder: (context, child) {
          return MaterialApp.router(
            title: 'Parking Control',
            debugShowCheckedModeBanner: false,
            locale: appTheme.locale,
            themeMode: appTheme.mode,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: appTheme.color,
                brightness: Brightness.light,
                // primary: appTheme.color,
              ),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: appTheme.color,
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