import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// 日志拦截器
///
/// 在开发环境下记录详细的请求和响应信息，便于调试
class LoggingInterceptor extends Interceptor {
  /// 是否启用详细日志
  final bool enableDetailedLog;

  /// 是否记录请求体
  final bool logRequestBody;

  /// 是否记录响应体
  final bool logResponseBody;

  /// 最大日志长度
  final int maxLogLength;

  LoggingInterceptor({
    this.enableDetailedLog = true,
    this.logRequestBody = true,
    this.logResponseBody = true,
    this.maxLogLength = 1000,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      _logRequest(options);
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      _logResponse(response);
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      _logError(err);
    }
    handler.next(err);
  }

  /// 记录请求信息
  void _logRequest(RequestOptions options) {
    final buffer = StringBuffer();

    // 基本信息
    buffer.writeln('┌─── HTTP Request ───');
    buffer.writeln('│ ${options.method.toUpperCase()} ${options.uri}');

    // 请求头
    if (enableDetailedLog && options.headers.isNotEmpty) {
      buffer.writeln('│ Headers:');
      options.headers.forEach((key, value) {
        // 隐藏敏感信息
        if (_isSensitiveHeader(key)) {
          buffer.writeln('│   $key: [HIDDEN]');
        } else {
          buffer.writeln('│   $key: $value');
        }
      });
    }

    // 查询参数
    if (enableDetailedLog && options.queryParameters.isNotEmpty) {
      buffer.writeln('│ Query Parameters:');
      options.queryParameters.forEach((key, value) {
        buffer.writeln('│   $key: $value');
      });
    }

    // 请求体
    if (logRequestBody && options.data != null) {
      buffer.writeln('│ Body:');
      final bodyStr = _formatData(options.data);
      buffer.writeln('│   ${_truncateString(bodyStr, maxLogLength)}');
    }

    buffer.writeln('└────────────────────');
    debugPrint(buffer.toString());
  }

  /// 记录响应信息
  void _logResponse(Response response) {
    final buffer = StringBuffer();
    final duration = DateTime.now().millisecondsSinceEpoch -
        (response.requestOptions.extra['start_time'] ??
            DateTime.now().millisecondsSinceEpoch);

    // 基本信息
    buffer.writeln('┌─── HTTP Response ───');
    buffer.writeln(
        '│ ${response.requestOptions.method.toUpperCase()} ${response.requestOptions.uri}');
    buffer
        .writeln('│ Status: ${response.statusCode} ${response.statusMessage}');
    buffer.writeln('│ Duration: ${duration}ms');

    // 响应头
    if (enableDetailedLog && response.headers.map.isNotEmpty) {
      buffer.writeln('│ Headers:');
      response.headers.forEach((key, values) {
        buffer.writeln('│   $key: ${values.join(', ')}');
      });
    }

    // 响应体
    if (logResponseBody && response.data != null) {
      buffer.writeln('│ Body:');
      final bodyStr = _formatData(response.data);
      buffer.writeln('│   ${_truncateString(bodyStr, maxLogLength)}');
    }

    buffer.writeln('└─────────────────────');
    debugPrint(buffer.toString());
  }

  /// 记录错误信息
  void _logError(DioException err) {
    final buffer = StringBuffer();

    buffer.writeln('┌─── HTTP Error ───');
    buffer.writeln(
        '│ ${err.requestOptions.method.toUpperCase()} ${err.requestOptions.uri}');
    buffer.writeln('│ Error Type: ${err.type}');
    buffer.writeln('│ Status Code: ${err.response?.statusCode}');
    buffer.writeln('│ Message: ${err.message}');

    // 错误响应体
    if (err.response?.data != null) {
      buffer.writeln('│ Error Response:');
      final errorStr = _formatData(err.response!.data);
      buffer.writeln('│   ${_truncateString(errorStr, maxLogLength)}');
    }

    buffer.writeln('└──────────────────');
    debugPrint(buffer.toString());
  }

  /// 格式化数据
  String _formatData(dynamic data) {
    if (data == null) return 'null';

    if (data is String) {
      return data;
    } else if (data is Map || data is List) {
      try {
        return data.toString();
      } catch (e) {
        return 'Failed to format data: $e';
      }
    } else {
      return data.toString();
    }
  }

  /// 截断字符串
  String _truncateString(String str, int maxLength) {
    if (str.length <= maxLength) {
      return str;
    }
    return '${str.substring(0, maxLength)}... (truncated)';
  }

  /// 判断是否为敏感请求头
  bool _isSensitiveHeader(String key) {
    final lowerKey = key.toLowerCase();
    return lowerKey.contains('authorization') ||
        lowerKey.contains('token') ||
        lowerKey.contains('password') ||
        lowerKey.contains('secret') ||
        lowerKey.contains('key');
  }
}

/// 简化版日志拦截器
///
/// 只记录基本的请求和响应信息
class SimpleLoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('🚀 ${options.method.toUpperCase()} ${options.uri}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint(
          '✅ ${response.statusCode} ${response.requestOptions.method.toUpperCase()} ${response.requestOptions.uri}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint(
          '❌ ${err.response?.statusCode ?? 'NO_STATUS'} ${err.requestOptions.method.toUpperCase()} ${err.requestOptions.uri}');
      debugPrint('   Error: ${err.message}');
    }
    handler.next(err);
  }
}
