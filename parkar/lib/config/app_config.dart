/// Class to manage application configuration
class AppConfig {
  /// API base URL
  static String apiBaseUrl = '';

  /// WebSocket endpoint
  static String wsEndpoint = '';

  /// API timeout in seconds
  static int apiTimeout = 30;

  /// API endpoints
  static Map<String, String> apiEndpoints = {};

  /// Debug mode
  static bool debugMode = false;

  /// App version
  static String appVersion = '1.0.0';

  /// Initialize application configuration
  static void init({
    required String apiBaseUrl,
    String? wsEndpoint,
    required int apiTimeout,
    required Map<String, String> apiEndpoints,
    bool debugMode = false,
    String appVersion = '1.0.0',
  }) {
    AppConfig.apiBaseUrl = apiBaseUrl;
    AppConfig.wsEndpoint = wsEndpoint ?? apiBaseUrl.replaceAll('http', 'ws');
    AppConfig.apiTimeout = apiTimeout;
    AppConfig.apiEndpoints = apiEndpoints;
    AppConfig.debugMode = debugMode;
    AppConfig.appVersion = appVersion;
  }
}
