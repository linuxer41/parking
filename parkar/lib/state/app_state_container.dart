import 'package:flutter/material.dart';
import 'package:parkar/di/di_container.dart';
import 'package:parkar/state/theme.dart';
import 'app_state.dart';

class AppStateContainer extends InheritedWidget {
  final AppState state;
  final DIContainer diContainer;
  final AppTheme appTheme;

  const AppStateContainer({super.key, 
    required this.state,
    required this.diContainer,
    required super.child,
    required this.appTheme,
  });

  @override
  bool updateShouldNotify(AppStateContainer oldWidget) {
    return oldWidget.state != state;
  }

  static AppState of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppStateContainer>()!.state;
  }

  static DIContainer di(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppStateContainer>()!.diContainer;
  }

  static AppTheme theme(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppStateContainer>()!.appTheme;
  }
}