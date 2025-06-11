import 'package:flutter/material.dart';
import 'package:parkar/di/di_container.dart';
import 'package:parkar/state/theme.dart';
import 'app_state.dart';

/// Contenedor global que mantiene el estado de la aplicación
/// Este widget hereda de InheritedNotifier para propagar automáticamente
/// los cambios en el estado de la aplicación a los widgets hijos
class AppStateContainer extends InheritedWidget {
  final AppState state;
  final DIContainer diContainer;
  final AppTheme appTheme;

  const AppStateContainer({
    super.key,
    required this.state,
    required this.diContainer,
    required super.child,
    required this.appTheme,
  });

  /// Notifica a los widgets dependientes cuando el estado cambia
  @override
  bool updateShouldNotify(AppStateContainer oldWidget) {
    // Comparar tanto el estado como el tema para actualizar correctamente
    final shouldUpdate = oldWidget.state != state ||
        oldWidget.appTheme != appTheme ||
        oldWidget.appTheme.mode != appTheme.mode;
    return shouldUpdate;
  }

  /// Obtener el estado de la aplicación desde cualquier widget
  static AppState of(BuildContext context) {
    final container =
        context.dependOnInheritedWidgetOfExactType<AppStateContainer>();
    if (container == null) {
      throw FlutterError(
          'AppStateContainer no encontrado en el árbol de widgets');
    }
    return container.state;
  }

  /// Obtener el contenedor de dependencias desde cualquier widget
  static DIContainer di(BuildContext context) {
    final container =
        context.dependOnInheritedWidgetOfExactType<AppStateContainer>();
    if (container == null) {
      throw FlutterError(
          'AppStateContainer no encontrado en el árbol de widgets');
    }
    return container.diContainer;
  }

  /// Obtener el tema de la aplicación desde cualquier widget
  static AppTheme theme(BuildContext context) {
    final container =
        context.dependOnInheritedWidgetOfExactType<AppStateContainer>();
    if (container == null) {
      throw FlutterError(
          'AppStateContainer no encontrado en el árbol de widgets');
    }
    return container.appTheme;
  }
}
