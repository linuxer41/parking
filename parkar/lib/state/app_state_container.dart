import 'package:flutter/material.dart';
import 'package:parkar/di/di_container.dart';
import 'app_state.dart';

class AppStateContainer extends StatefulWidget {
  final AppState state;
  final DIContainer diContainer;
  final Widget child;

  const AppStateContainer({
    super.key,
    required this.state,
    required this.diContainer,
    required this.child,
  });

  @override
  State<AppStateContainer> createState() => _AppStateContainerState();

  static AppState of(BuildContext context) {
    final state = context.findAncestorStateOfType<_AppStateContainerState>();
    if (state == null) {
      throw FlutterError(
          'AppStateContainer no encontrado en el árbol de widgets');
    }
    return state.widget.state;
  }

  static DIContainer di(BuildContext context) {
    final state = context.findAncestorStateOfType<_AppStateContainerState>();
    if (state == null) {
      throw FlutterError(
          'AppStateContainer no encontrado en el árbol de widgets');
    }
    return state.widget.diContainer;
  }

  static AppState theme(BuildContext context) {
    return of(context);
  }
}

class _AppStateContainerState extends State<AppStateContainer> {
  @override
  void initState() {
    super.initState();
    widget.state.addListener(_onStateChanged);
  }

  @override
  void didUpdateWidget(AppStateContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) {
      oldWidget.state.removeListener(_onStateChanged);
      widget.state.addListener(_onStateChanged);
    }
  }

  @override
  void dispose() {
    widget.state.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
