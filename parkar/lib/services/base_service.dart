import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import 'api_exception.dart';
import 'auth_manager.dart';

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
  void _logRequest(
    String method,
    Uri uri,
    Map<String, String> headers, [
    dynamic body,
  ]) {
    if (kDebugMode) {
      print('📤 REQUEST: $method ${uri.toString()}');
      print('📋 Headers: $headers');
      if (body != null) {
        try {
          final prettyBody = const JsonEncoder.withIndent(
            '  ',
          ).convert(body is String ? json.decode(body) : body);
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
        final prettyBody = const JsonEncoder.withIndent(
          '  ',
        ).convert(json.decode(response.body));
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

    // Add auth token if available (JWT contains tenant and employee info)
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
    return AuthManager().token;
  }

  String? _getParkingId() {
    return AuthManager().parkingId;
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
            'Request timed out after ${AppConfig.apiTimeout} seconds',
          );
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

        // Decode the JSON response with proper validation
        dynamic decoded;
        try {
          // Validate if response body is valid JSON
          if (_isValidJson(response.body)) {
            decoded = json.decode(response.body);
          } else {
            // Handle non-JSON responses (plain text, etc.)
            decoded = response.body;
          }
        } catch (e, stackTrace) {
          _logError('JSON decoding failed', e, stackTrace);
          _logError('Response body', response.body);

          // If JSON decoding fails, treat as plain text
          decoded = response.body;
        }

        // Apply the parser function to convert to the expected type
        try {
          return parser(decoded);
        } catch (e, stackTrace) {
          _logError('Error parsing response', e, stackTrace);
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
        _logError('Error processing response', e, stackTrace);
        _logError('Response data', {
          'statusCode': response.statusCode,
          'body': response.body,
          'headers': response.headers,
        });

        throw ApiException(
          statusCode: 500,
          message: 'Failed to process response: ${e.toString()}',
        );
      }
    }

    // Handle error response
    Map<String, dynamic> errorData = {};
    try {
      if (_isValidJson(response.body)) {
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

    // Extract error message from nested structure if present
    String errorMessage = 'Unknown error';
    Map<String, dynamic> errorDetails = {};

    if (errorData.containsKey('error') && errorData['error'] is Map<String, dynamic>) {
      final nestedError = errorData['error'] as Map<String, dynamic>;
      errorMessage = nestedError['message'] as String? ?? errorMessage;
      errorDetails = nestedError;
    } else {
      errorMessage = errorData['message'] as String? ?? errorMessage;
      errorDetails = errorData['errors'] as Map<String, dynamic>? ?? {'error': errorData};
    }

    // Special handling for 422 validation errors
    if (response.statusCode == 422) {
      final exception = ApiException(
        statusCode: response.statusCode,
        message: errorDetails['summary'] as String? ?? errorMessage,
        errors: errorDetails,
        isValidationError: true,
      );
      _logError('Validation error response', exception);
      throw exception;
    }

    final exception = ApiException(
      statusCode: response.statusCode,
      message: errorMessage,
      errors: errorDetails,
    );

    _logError('API error response', exception);
    throw exception;
  }

  /// Validate if a string is valid JSON
  bool _isValidJson(String str) {
    if (str.trim().isEmpty) {
      return false;
    }

    try {
      json.decode(str);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Professional model parsing utilities
  /// Parse a single model with validation
  T parseModel<T>(dynamic data, T Function(Map<String, dynamic>) fromJson) {
    try {
      if (data == null) {
        throw ApiException(statusCode: 500, message: 'Response data is null');
      }

      if (data is Map<String, dynamic>) {
        return fromJson(data);
      }

      if (data is String) {
        // Try to parse as JSON if it's a string
        try {
          final jsonData = json.decode(data) as Map<String, dynamic>;
          return fromJson(jsonData);
        } catch (e) {
          throw ApiException(
            statusCode: 500,
            message: 'Invalid JSON string for model parsing: $data',
          );
        }
      }

      throw ApiException(
        statusCode: 500,
        message: 'Invalid data type for model parsing: ${data.runtimeType}',
      );
    } catch (e) {
      if (e is ApiException) rethrow;

      _logError('Model parsing failed', e);
      throw ApiException(
        statusCode: 500,
        message: 'Failed to parse model: ${e.toString()}',
      );
    }
  }

  /// Parse a list of models with validation
  List<T> parseModelList<T>(
    dynamic data,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    try {
      if (data == null) {
        return [];
      }

      if (data is List) {
        return data.map((item) {
          if (item is Map<String, dynamic>) {
            return fromJson(item);
          } else if (item is String) {
            // Handle case where items might be JSON strings
            try {
              final jsonItem = json.decode(item) as Map<String, dynamic>;
              return fromJson(jsonItem);
            } catch (e) {
              _logError('Failed to parse list item as JSON', e);
              throw ApiException(
                statusCode: 500,
                message: 'Invalid JSON in list item: $item',
              );
            }
          } else {
            throw ApiException(
              statusCode: 500,
              message: 'Invalid item type in list: ${item.runtimeType}',
            );
          }
        }).toList();
      }

      if (data is String) {
        // Try to parse as JSON array if it's a string
        try {
          final jsonData = json.decode(data) as List;
          return parseModelList(jsonData, fromJson);
        } catch (e) {
          throw ApiException(
            statusCode: 500,
            message: 'Invalid JSON string for list parsing: $data',
          );
        }
      }

      throw ApiException(
        statusCode: 500,
        message: 'Invalid data type for list parsing: ${data.runtimeType}',
      );
    } catch (e) {
      if (e is ApiException) rethrow;

      _logError('Model list parsing failed', e);
      throw ApiException(
        statusCode: 500,
        message: 'Failed to parse model list: ${e.toString()}',
      );
    }
  }

  /// Parse a paginated response with validation
  Map<String, dynamic> parsePaginatedResponse<T>(
    dynamic data,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    try {
      if (data == null) {
        throw ApiException(
          statusCode: 500,
          message: 'Paginated response data is null',
        );
      }

      if (data is! Map<String, dynamic>) {
        throw ApiException(
          statusCode: 500,
          message:
              'Invalid data type for paginated response: ${data.runtimeType}',
        );
      }

      final items = data['items'] ?? data['data'] ?? [];
      final parsedItems = parseModelList(items, fromJson);

      return {
        'items': parsedItems,
        'total': data['total'] ?? parsedItems.length,
        'page': data['page'] ?? 1,
        'limit': data['limit'] ?? parsedItems.length,
        'hasMore': data['hasMore'] ?? false,
      };
    } catch (e) {
      if (e is ApiException) rethrow;

      _logError('Paginated response parsing failed', e);
      throw ApiException(
        statusCode: 500,
        message: 'Failed to parse paginated response: ${e.toString()}',
      );
    }
  }

  /// Parse a response that might be a single model or a list
  dynamic parseFlexibleResponse<T>(
    dynamic data,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    try {
      if (data == null) {
        return null;
      }

      if (data is List) {
        return parseModelList(data, fromJson);
      }

      if (data is Map<String, dynamic>) {
        // Check if it's a paginated response
        if (data.containsKey('items') || data.containsKey('data')) {
          return parsePaginatedResponse(data, fromJson);
        }

        // Single model
        return parseModel(data, fromJson);
      }

      if (data is String) {
        try {
          final jsonData = json.decode(data);
          return parseFlexibleResponse(jsonData, fromJson);
        } catch (e) {
          throw ApiException(
            statusCode: 500,
            message: 'Invalid JSON string for flexible parsing: $data',
          );
        }
      }

      throw ApiException(
        statusCode: 500,
        message: 'Invalid data type for flexible parsing: ${data.runtimeType}',
      );
    } catch (e) {
      if (e is ApiException) rethrow;

      _logError('Flexible response parsing failed', e);
      throw ApiException(
        statusCode: 500,
        message: 'Failed to parse flexible response: ${e.toString()}',
      );
    }
  }

  /// Safe JSON parsing with detailed error information
  Map<String, dynamic> safeJsonDecode(String jsonString) {
    try {
      if (jsonString.trim().isEmpty) {
        return {};
      }

      final decoded = json.decode(jsonString);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      throw ApiException(
        statusCode: 500,
        message: 'Decoded JSON is not a Map: ${decoded.runtimeType}',
      );
    } catch (e) {
      if (e is ApiException) rethrow;

      _logError('JSON decode failed', e);
      _logError('JSON string', jsonString);

      throw ApiException(
        statusCode: 500,
        message: 'Invalid JSON format: ${e.toString()}',
      );
    }
  }

  /// Generic GET request
  Future<T> get<T>({
    required String endpoint,
    required T Function(dynamic) parser,
    Map<String, String>? additionalHeaders,
  }) async {
    final uri = Uri.parse('$baseUrl$path$endpoint');
    return _handleRequest<T>(
      request: () =>
          httpClient.get(uri, headers: buildHeaders(additionalHeaders)),
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
    final processedBody = removeNulls(body is Map ? body : body?.toJson());
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
      request: () =>
          httpClient.delete(uri, headers: buildHeaders(additionalHeaders)),
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
