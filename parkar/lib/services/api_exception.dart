/// Custom exception for API errors
class ApiException implements Exception {
  /// HTTP status code
  final int statusCode;

  /// Error message
  final String message;

  /// Detailed errors
  final Map<String, dynamic>? errors;

  /// Constructor
  ApiException({
    required this.statusCode,
    required this.message,
    this.errors,
  });

  // @override
  // String toString() => 'ApiException: $statusCode - $message';
  @override
  String toString() => message;
}
