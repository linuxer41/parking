import 'package:flutter/material.dart';
import 'package:parkar/di/di_container.dart';
import 'app_state.dart';

class AppStateContainer extends InheritedWidget {
  final AppState state;
  final DIContainer diContainer;

  const AppStateContainer({
    super.key,
    required this.state,
    required this.diContainer,
    required super.child,
  });

  @override
  bool updateShouldNotify(AppStateContainer oldWidget) {
    // Debemos notificar si state o diContainer cambian
    return oldWidget.state != state || oldWidget.diContainer != diContainer;
  }

  static AppState of(BuildContext context) {
    final container =
        context.dependOnInheritedWidgetOfExactType<AppStateContainer>();
    if (container == null) {
      throw FlutterError(
          'AppStateContainer no encontrado en el árbol de widgets');
    }
    return container.state;
  }

  static DIContainer di(BuildContext context) {
    final container =
        context.dependOnInheritedWidgetOfExactType<AppStateContainer>();
    if (container == null) {
      throw FlutterError(
          'AppStateContainer no encontrado en el árbol de widgets');
    }
    return container.diContainer;
  }

  static AppState theme(BuildContext context) {
    // Ahora devolvemos directamente AppState ya que contiene la funcionalidad de theme
    return of(context);
  }
}
