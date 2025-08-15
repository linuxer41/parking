import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import 'api_exception.dart';
import 'service_locator.dart';

/// Base class for all services
class BaseService {
  /// HTTP client for making requests
  final http.Client httpClient = http.Client();

  /// Base API URL
  String get baseUrl => AppConfig.apiBaseUrl;

  /// Base path for the service
  final String path;

  /// Maximum number of retries for failed requests
  static const int maxRetries = 3;

  /// Delay between retries in milliseconds
  static const int retryDelayMs = 1000;

  /// Constructor
  BaseService({required this.path});

  /// Log error details
  void _logError(String message, Object error, [StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('⚠️ ERROR: $message');
      print('🔴 Exception: ${error.runtimeType} - $error');
      if (stackTrace != null) {
        print('📚 Stack trace: $stackTrace');
      }
    }
  }

  /// Log request details
  void _logRequest(String method, Uri uri, Map<String, String> headers,
      [dynamic body]) {
    if (kDebugMode) {
      print('📤 REQUEST: $method ${uri.toString()}');
      print('📋 Headers: $headers');
      if (body != null) {
        try {
          final prettyBody = const JsonEncoder.withIndent('  ')
              .convert(body is String ? json.decode(body) : body);
          print('📦 Body: $prettyBody');
        } catch (e) {
          print('📦 Body: $body');
        }
      }
    }
  }

  /// Log response details
  void _logResponse(http.Response response) {
    if (kDebugMode) {
      print('📥 RESPONSE: ${response.statusCode} ${response.reasonPhrase}');
      print('📋 Headers: ${response.headers}');
      try {
        final prettyBody = const JsonEncoder.withIndent('  ')
            .convert(json.decode(response.body));
        print('📦 Body: $prettyBody');
      } catch (e) {
        print('📦 Body: ${response.body}');
      }
    }
  }

  /// Build headers for requests
  Map<String, String> buildHeaders([Map<String, String>? additionalHeaders]) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final parkingId = _getParkingId();
    if (parkingId != null) {
      headers['parking-id'] = parkingId;
    }

    // Add auth token if available
    final token = _getAuthToken();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    // Add additional headers
    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }

    return headers;
  }

  /// Get authentication token
  String? _getAuthToken() {
    return ServiceLocator().getAppState().authToken;
  }

  String? _getParkingId() {
    return ServiceLocator().getAppState().currentParking?.id;
  }

  /// Generic method to handle HTTP requests with retry logic
  Future<T> _handleRequest<T>({
    required Future<http.Response> Function() request,
    required T Function(dynamic) parser,
    required String method,
    required Uri uri,
    dynamic body,
    int retryCount = 0,
  }) async {
    try {
      _logRequest(method, uri, buildHeaders(), body);

      final response = await request().timeout(
        Duration(seconds: AppConfig.apiTimeout),
        onTimeout: () {
          final error = TimeoutException(
              'Request timed out after ${AppConfig.apiTimeout} seconds');
          _logError('Request timeout', error);
          throw error;
        },
      );

      // _logResponse(response);
      return handleResponse<T>(response, parser);
    } on TimeoutException catch (e, stackTrace) {
      _logError('Timeout exception', e, stackTrace);

      if (retryCount < maxRetries) {
        _logError('Retrying request (${retryCount + 1}/$maxRetries)', e);
        await Future.delayed(const Duration(milliseconds: retryDelayMs));
        return _handleRequest(
          request: request,
          parser: parser,
          method: method,
          uri: uri,
          body: body,
          retryCount: retryCount + 1,
        );
      }

      final exception = ApiException(
        statusCode: 408,
        message: 'Request timed out after $maxRetries retries',
      );
      _logError('Max retries exceeded', exception);
      throw exception;
    } on http.ClientException catch (e, stackTrace) {
      _logError('HTTP client exception', e, stackTrace);

      if (retryCount < maxRetries) {
        _logError('Retrying request (${retryCount + 1}/$maxRetries)', e);
        await Future.delayed(const Duration(milliseconds: retryDelayMs));
        return _handleRequest(
          request: request,
          parser: parser,
          method: method,
          uri: uri,
          body: body,
          retryCount: retryCount + 1,
        );
      }

      final exception = ApiException(
        statusCode: 503,
        message: 'Network error: ${e.message}',
      );
      _logError('Max retries exceeded', exception);
      throw exception;
    } catch (e, stackTrace) {
      _logError('Unexpected error during request', e, stackTrace);
      rethrow;
    }
  }

  /// Handle API response with type safety
  T handleResponse<T>(http.Response response, T Function(dynamic) parser) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        // Handle empty response
        if (response.body.isEmpty) {
          // For void return types, just return null
          return null as T;
        }

        // Decode the JSON response
        dynamic decoded;
        try {
          if (response.body.contains('{')) {
            decoded = json.decode(response.body);
          } else {
            decoded = response.body;
          }
        } catch (e) {
          print(e);
          decoded = response.body;
        }

        // Apply the parser function to convert to the expected type
        try {
          return parser(decoded);
        } catch (e, stackTrace) {
          _logError(
            'Error parsing response',
            e,
            stackTrace,
          );
          _logError('Response data', {
            'statusCode': response.statusCode,
            'body': response.body,
            'headers': response.headers,
          });

          throw ApiException(
            statusCode: 500,
            message: 'Failed to parse response: ${e.toString()}',
          );
        }
      } catch (e, stackTrace) {
        _logError(
          'Error decoding JSON response',
          e,
          stackTrace,
        );
        _logError('Response data', {
          'statusCode': response.statusCode,
          'body': response.body,
          'headers': response.headers,
        });

        throw ApiException(
          statusCode: 500,
          message: 'Failed to decode response: ${e.toString()}',
        );
      }
    }

    // Handle error response
    Map<String, dynamic> errorData = {};
    try {
      if (response.body.contains('{')) {
        errorData = json.decode(response.body) as Map<String, dynamic>;
      } else {
        errorData = {'message': response.body};
      }
    } catch (e, stackTrace) {
      _logError('Failed to parse error response', e, stackTrace);
      errorData = {
        'error': 'Failed to parse error response',
        'details': response.body,
      };
    }

    final exception = ApiException(
      statusCode: response.statusCode,
      message: errorData['message'] as String? ?? 'Unknown error',
      errors:
          errorData['errors'] as Map<String, dynamic>? ?? {'error': errorData},
    );

    _logError('API error response', exception);
    throw exception;
  }

  /// Generic GET request
  Future<T> get<T>({
    required String endpoint,
    required T Function(dynamic) parser,
    Map<String, String>? additionalHeaders,
  }) async {
    final uri = Uri.parse('$baseUrl$path$endpoint');
    return _handleRequest<T>(
      request: () => httpClient.get(
        uri,
        headers: buildHeaders(additionalHeaders),
      ),
      parser: parser,
      method: 'GET',
      uri: uri,
    );
  }

  /// Generic POST request
  Future<T> post<T>({
    required String endpoint,
    required dynamic body,
    required T Function(dynamic) parser,
    Map<String, String>? additionalHeaders,
  }) async {
    final uri = Uri.parse('$baseUrl$path$endpoint');
    final processedBody = removeNulls(body is Map ? body : body.toJson());
    final encodedBody = jsonEncode(processedBody);

    return _handleRequest<T>(
      request: () => httpClient.post(
        uri,
        headers: buildHeaders(additionalHeaders),
        body: encodedBody,
      ),
      parser: parser,
      method: 'POST',
      uri: uri,
      body: processedBody,
    );
  }

  /// Generic PUT request
  Future<T> put<T>({
    required String endpoint,
    required dynamic body,
    required T Function(dynamic) parser,
    Map<String, String>? additionalHeaders,
  }) async {
    final uri = Uri.parse('$baseUrl$path$endpoint');
    final processedBody = removeNulls(body is Map ? body : body.toJson());
    final encodedBody = jsonEncode(processedBody);

    return _handleRequest<T>(
      request: () => httpClient.put(
        uri,
        headers: buildHeaders(additionalHeaders),
        body: encodedBody,
      ),
      parser: parser,
      method: 'PUT',
      uri: uri,
      body: processedBody,
    );
  }

  /// Generic PATCH request
  Future<T> patch<T>({
    required String endpoint,
    required dynamic body,
    required T Function(dynamic) parser,
    Map<String, String>? additionalHeaders,
  }) async {
    final uri = Uri.parse('$baseUrl$path$endpoint');
    final processedBody = removeNulls(body is Map ? body : body.toJson());
    final encodedBody = jsonEncode(processedBody);

    return _handleRequest<T>(
      request: () => httpClient.patch(
        uri,
        headers: buildHeaders(additionalHeaders),
        body: encodedBody,
      ),
      parser: parser,
      method: 'PATCH',
      uri: uri,
      body: processedBody,
    );
  }

  /// Generic DELETE request
  Future<T> delete<T>({
    required String endpoint,
    required T Function(dynamic) parser,
    Map<String, String>? additionalHeaders,
  }) async {
    final uri = Uri.parse('$baseUrl$path$endpoint');
    return _handleRequest<T>(
      request: () => httpClient.delete(
        uri,
        headers: buildHeaders(additionalHeaders),
      ),
      parser: parser,
      method: 'DELETE',
      uri: uri,
    );
  }

  /// Remove null values from a map
  Map<String, dynamic> removeNulls(Map<String, dynamic> map) {
    final result = <String, dynamic>{};
    map.forEach((key, value) {
      if (value != null) {
        result[key] = value;
      }
    });
    return result;
  }

  /// Dispose the HTTP client
  void dispose() {
    httpClient.close();
  }
}
