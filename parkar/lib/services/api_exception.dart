/// Custom exception for API errors
class ApiException implements Exception {
  /// HTTP status code
  final int statusCode;

  /// Error message
  final String message;

  /// Detailed errors
  final Map<String, dynamic>? errors;

  /// Indicates if this is a validation error (422)
  final bool isValidationError;

  /// Constructor
  ApiException({
    required this.statusCode,
    required this.message,
    this.errors,
    this.isValidationError = false,
  });

  // @override
  // String toString() => 'ApiException: $statusCode - $message';
  @override
  String toString() => message;
}
