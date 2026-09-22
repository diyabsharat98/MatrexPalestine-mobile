import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/network/api_exception.dart';

DioException _requestOptionsError(DioExceptionType type) {
  return DioException(requestOptions: RequestOptions(path: '/sales'), type: type);
}

DioException _responseError({required int statusCode, required Map<String, dynamic> data}) {
  final requestOptions = RequestOptions(path: '/sales');
  return DioException(
    requestOptions: requestOptions,
    type: DioExceptionType.badResponse,
    response: Response(requestOptions: requestOptions, statusCode: statusCode, data: data),
  );
}

void main() {
  group('ApiException.fromDioException', () {
    test('maps a connection timeout to a friendly bilingual network error', () {
      final exception = ApiException.fromDioException(_requestOptionsError(DioExceptionType.connectionTimeout));

      expect(exception.errorCode, 'network_error');
      expect(exception.isNetworkError, isTrue);
      expect(exception.messageAr, isNotEmpty);
      expect(exception.messageEn, isNotEmpty);
    });

    test('surfaces the backend business error message and code as-is', () {
      final exception = ApiException.fromDioException(_responseError(
        statusCode: 422,
        data: {
          'message': 'Insufficient stock for Coca-Cola.',
          'message_ar': 'الكمية غير كافية لكوكا كولا.',
          'error_code': 'insufficient_stock',
          'context': {'available': 5, 'requested': 10},
        },
      ));

      expect(exception.errorCode, 'insufficient_stock');
      expect(exception.messageEn, 'Insufficient stock for Coca-Cola.');
      expect(exception.messageAr, 'الكمية غير كافية لكوكا كولا.');
      expect(exception.context?['available'], 5);
      expect(exception.isNetworkError, isFalse);
    });

    test('parses Laravel validation error field lists', () {
      final exception = ApiException.fromDioException(_responseError(
        statusCode: 422,
        data: {
          'message': 'The given data was invalid.',
          'errors': {
            'items': ['The items field is required.'],
          },
        },
      ));

      expect(exception.fieldErrors?['items'], ['The items field is required.']);
    });

    test('flags 401 as unauthenticated and 403 as forbidden', () {
      final unauthenticated = ApiException.fromDioException(_responseError(statusCode: 401, data: {}));
      final forbidden = ApiException.fromDioException(_responseError(statusCode: 403, data: {}));

      expect(unauthenticated.isUnauthenticated, isTrue);
      expect(forbidden.isForbidden, isTrue);
    });

    test('falls back to a generic message when the response has no known shape', () {
      final exception = ApiException.fromDioException(_responseError(statusCode: 500, data: {}));

      expect(exception.errorCode, 'server_error');
      expect(exception.messageEn, isNotEmpty);
      expect(exception.messageAr, isNotEmpty);
    });

    test('message() returns the Arabic or English text based on the flag', () {
      const exception = ApiException(messageEn: 'English', messageAr: 'عربي');

      expect(exception.message(true), 'عربي');
      expect(exception.message(false), 'English');
    });
  });
}
