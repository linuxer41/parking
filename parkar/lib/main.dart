import 'package:flutter/foundation.dart';
import 'package:window_manager/window_manager.dart';
import 'routes/app_router.dart';
import 'services/service_locator.dart';
import 'state/app_state.dart';
import 'state/app_state_container.dart';
import 'di/di_container.dart';
import 'package:fluent_ui/fluent_ui.dart' hide Page;

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
   //const FlutterSecureStorage().toString();

  if (isDesktop) {
    await windowManager.ensureInitialized();
    windowManager.waitUntilReadyToShow().then((_) async {
      await windowManager.setTitle('Parkar: sistema de parqueo');
      await windowManager.setTitleBarStyle(TitleBarStyle.normal);
      // await windowManager.setBackgroundColor(Colors.transparent);
      await windowManager.setBrightness(Brightness.light);
      await windowManager.setSize(const Size(755, 545));
      await windowManager.setMinimumSize(const Size(755, 545));
      await windowManager.center();
      await windowManager.show();
      await windowManager.setSkipTaskbar(false);
    });
  }

  final appState = AppState();
  await appState.loadState();
  ServiceLocator().registerAppState(appState); // Registra el AppState
  final diContainer = DIContainer();
  final appTheme = AppTheme();

  runApp(MyApp(appState: appState, diContainer: diContainer, appTheme: appTheme));
}

class MyApp extends StatelessWidget {
  final AppState appState;
  final DIContainer diContainer;
  final AppTheme appTheme;

  const MyApp({super.key, required this.appState, required this.diContainer, required this.appTheme});

  @override
  Widget build(BuildContext context) {
    return AppStateContainer(
      state: appState,
      diContainer: diContainer,
      appTheme: appTheme,
      child: ListenableBuilder(
        listenable: appState,
        builder: (context, child) {
          return FluentApp.router(
            title: 'Parking Control',
            debugShowCheckedModeBanner: false,
            locale: appTheme.locale,
            themeMode: appTheme.mode,
            theme: FluentThemeData(
              brightness: Brightness.light,
              // accentColor: SystemTheme.accentColor.accent.toAccentColor(),
              accentColor: appTheme.color,
            ),
            darkTheme: FluentThemeData(
              brightness: Brightness.dark,
              accentColor: appTheme.color,
              // accentColor: SystemTheme.accentColor.accent.toAccentColor(),
            ),
            routerConfig: router,
          );
        },
      ),
    );
  }
}
