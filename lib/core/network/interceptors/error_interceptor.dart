import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../api_exception.dart';

/// 错误处理拦截器
///
/// 统一处理网络请求中的错误，将DioException转换为ApiException
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint(
        'ErrorInterceptor: Handling error for ${err.requestOptions.path}');
    debugPrint('ErrorInterceptor: Error type: ${err.type}');
    debugPrint('ErrorInterceptor: Status code: ${err.response?.statusCode}');
    debugPrint('ErrorInterceptor: Error message: ${err.message}');

    // 将DioException转换为ApiException
    final apiException = ApiExceptionFactory.fromDioException(err);

    // 创建新的DioException，包含转换后的ApiException
    final newError = DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: apiException,
      message: apiException.message,
    );

    // 记录错误详情（仅在调试模式下）
    if (kDebugMode) {
      _logErrorDetails(err, apiException);
    }

    handler.next(newError);
  }

  /// 记录错误详情
  void _logErrorDetails(DioException dioError, ApiException apiException) {
    final buffer = StringBuffer();
    buffer.writeln('=== API Error Details ===');
    buffer.writeln('URL: ${dioError.requestOptions.uri}');
    buffer.writeln('Method: ${dioError.requestOptions.method}');
    buffer.writeln('Status Code: ${dioError.response?.statusCode}');
    buffer.writeln('Error Type: ${apiException.runtimeType}');
    buffer.writeln('Error Code: ${apiException.code}');
    buffer.writeln('Error Message: ${apiException.message}');

    // 请求头信息
    if (dioError.requestOptions.headers.isNotEmpty) {
      buffer.writeln('Request Headers:');
      dioError.requestOptions.headers.forEach((key, value) {
        // 隐藏敏感信息
        if (key.toLowerCase().contains('authorization')) {
          buffer.writeln('  $key: [HIDDEN]');
        } else {
          buffer.writeln('  $key: $value');
        }
      });
    }

    // 请求参数
    if (dioError.requestOptions.queryParameters.isNotEmpty) {
      buffer.writeln('Query Parameters:');
      dioError.requestOptions.queryParameters.forEach((key, value) {
        buffer.writeln('  $key: $value');
      });
    }

    // 请求体
    if (dioError.requestOptions.data != null) {
      buffer.writeln('Request Body: ${dioError.requestOptions.data}');
    }

    // 响应数据
    if (dioError.response?.data != null) {
      buffer.writeln('Response Data: ${dioError.response?.data}');
    }

    // 响应头
    if (dioError.response?.headers != null) {
      buffer.writeln('Response Headers:');
      dioError.response!.headers.forEach((key, values) {
        buffer.writeln('  $key: ${values.join(', ')}');
      });
    }

    buffer.writeln('========================');
    debugPrint(buffer.toString());
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // 检查响应状态码，即使HTTP状态码是200，业务状态码可能表示错误
    if (response.data is Map<String, dynamic>) {
      final data = response.data as Map<String, dynamic>;
      final code = data['code'];
      final message = data['message'];

      // 如果业务状态码表示错误
      if (code != null && code != 200 && code != 0) {
        debugPrint(
            'ErrorInterceptor: Business error detected - Code: $code, Message: $message');

        final businessException = BusinessException(
          message?.toString() ?? '业务处理失败',
          code: code.toString(),
          statusCode: response.statusCode,
        );

        final dioError = DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: businessException,
          message: businessException.message,
        );

        handler.reject(dioError);
        return;
      }
    }

    handler.next(response);
  }
}
