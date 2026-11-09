// lib/features/admin_web/shared/data/api_exception.dart

class ApiException implements Exception {
  const ApiException({
    required this.code,
    required this.message,
    required this.statusCode,
    this.fields = const {},
  });

  final String code;
  final String message;
  final int statusCode;
  final Map<String, dynamic> fields;

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;
  bool get isValidationError => statusCode == 422;
  bool get isServerError => statusCode >= 500;

  @override
  String toString() => 'ApiException($code, $statusCode): $message';
}
