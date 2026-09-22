import 'package:dio/dio.dart';

/// A clean, presentable failure surfaced from the API — never a raw
/// exception. Mirrors the backend's `{message, message_ar, error_code}`
/// shape (see `App\Exceptions\BusinessException` on the Laravel side).
class ApiException implements Exception {
  const ApiException({
    required this.messageEn,
    required this.messageAr,
    this.errorCode = 'unknown_error',
    this.statusCode,
    this.fieldErrors,
    this.context,
  });

  final String messageEn;
  final String messageAr;
  final String errorCode;
  final int? statusCode;

  /// Laravel validation errors: field name -> list of messages.
  final Map<String, List<String>>? fieldErrors;
  final Map<String, dynamic>? context;

  String message(bool arabic) => arabic ? messageAr : messageEn;

  bool get isNetworkError => errorCode == 'network_error';

  bool get isUnauthenticated => statusCode == 401;

  bool get isForbidden => statusCode == 403;

  factory ApiException.fromDioException(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.connectionError) {
      return const ApiException(
        messageEn: 'No internet connection. Please check your network and try again.',
        messageAr: 'لا يوجد اتصال بالإنترنت. الرجاء التحقق من الشبكة والمحاولة مرة أخرى.',
        errorCode: 'network_error',
      );
    }

    final response = e.response;
    final statusCode = response?.statusCode;
    final data = response?.data;

    if (data is Map<String, dynamic>) {
      Map<String, List<String>>? fieldErrors;
      if (data['errors'] is Map) {
        fieldErrors = (data['errors'] as Map).map(
          (key, value) => MapEntry(key.toString(), List<String>.from(value as List)),
        );
      }

      return ApiException(
        messageEn: data['message']?.toString() ?? _genericMessageEn,
        messageAr: data['message_ar']?.toString() ?? _genericMessageAr,
        errorCode: data['error_code']?.toString() ?? 'server_error',
        statusCode: statusCode,
        fieldErrors: fieldErrors,
        context: data['context'] is Map<String, dynamic> ? data['context'] as Map<String, dynamic> : null,
      );
    }

    return ApiException(
      messageEn: _genericMessageEn,
      messageAr: _genericMessageAr,
      errorCode: 'server_error',
      statusCode: statusCode,
    );
  }

  static const _genericMessageEn = 'Something went wrong. Please try again.';
  static const _genericMessageAr = 'حدث خطأ ما. الرجاء المحاولة مرة أخرى.';
}
