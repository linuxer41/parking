/// Class to manage application configuration
class AppConfig {
  /// API base URL
  static String apiBaseUrl = 'http://localhost:3000';

  /// WebSocket endpoint
  static String wsEndpoint = '';

  /// API timeout in seconds
  static int apiTimeout = 30;

  /// API endpoints
  static Map<String, String> apiEndpoints = {
    'booking': '/booking',
    'access': '/entry-exit',
    'subscription': '/subscription',
    'parking': '/parking',
    'vehicle': '/vehicle',
    'employee': '/employee',
    'user': '/user',
    'auth': '/auth',
    'cashRegister': '/cash-register',
  };

  /// Debug mode
  static bool debugMode = false;

  /// App version
  static String appVersion = '1.0.0';

  /// Initialize application configuration
  static void init({
    required String apiBaseUrl,
    String? wsEndpoint,
    required int apiTimeout,
    Map<String, String>? apiEndpoints,
    bool debugMode = false,
    String appVersion = '1.0.0',
  }) {
    AppConfig.apiBaseUrl = apiBaseUrl;
    AppConfig.wsEndpoint = wsEndpoint ?? apiBaseUrl.replaceAll('http', 'ws');
    AppConfig.apiTimeout = apiTimeout;
    AppConfig.apiEndpoints = apiEndpoints ?? AppConfig.apiEndpoints;
    AppConfig.debugMode = debugMode;
    AppConfig.appVersion = appVersion;
  }
}
