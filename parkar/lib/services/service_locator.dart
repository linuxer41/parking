import '../state/app_state.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  AppState? _appState;

  void registerAppState(AppState appState) {
    _appState = appState;
  }

  AppState getAppState() {
    if (_appState == null) {
      throw Exception('AppState no ha sido registrado en el ServiceLocator');
    }
    return _appState!;
  }
}
