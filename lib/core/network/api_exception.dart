import 'package:dio/dio.dart';

/// API异常基类
///
/// 统一处理网络请求中的各种异常情况
abstract class ApiException implements Exception {
  /// 错误消息
  final String message;

  /// 错误代码
  final String? code;

  /// HTTP状态码
  final int? statusCode;

  /// 原始异常
  final dynamic originalException;

  const ApiException(
    this.message, {
    this.code,
    this.statusCode,
    this.originalException,
  });

  @override
  String toString() => 'ApiException: $message';
}

/// 网络连接异常
class NetworkException extends ApiException {
  const NetworkException(
    String message, {
    String? code,
    dynamic originalException,
  }) : super(
          message,
          code: code,
          originalException: originalException,
        );
}

/// 超时异常
class TimeoutException extends ApiException {
  const TimeoutException(
    String message, {
    String? code,
    dynamic originalException,
  }) : super(
          message,
          code: code,
          originalException: originalException,
        );
}

/// 服务器异常
class ServerException extends ApiException {
  const ServerException(
    String message, {
    String? code,
    int? statusCode,
    dynamic originalException,
  }) : super(
          message,
          code: code,
          statusCode: statusCode,
          originalException: originalException,
        );
}

/// 客户端异常
class ClientException extends ApiException {
  const ClientException(
    String message, {
    String? code,
    int? statusCode,
    dynamic originalException,
  }) : super(
          message,
          code: code,
          statusCode: statusCode,
          originalException: originalException,
        );
}

/// 认证异常
class AuthException extends ApiException {
  const AuthException(
    String message, {
    String? code,
    int? statusCode,
    dynamic originalException,
  }) : super(
          message,
          code: code,
          statusCode: statusCode,
          originalException: originalException,
        );
}

/// 权限异常
class PermissionException extends ApiException {
  const PermissionException(
    String message, {
    String? code,
    int? statusCode,
    dynamic originalException,
  }) : super(
          message,
          code: code,
          statusCode: statusCode,
          originalException: originalException,
        );
}

/// 资源不存在异常
class NotFoundException extends ApiException {
  const NotFoundException(
    String message, {
    String? code,
    int? statusCode,
    dynamic originalException,
  }) : super(
          message,
          code: code,
          statusCode: statusCode,
          originalException: originalException,
        );
}

/// 参数验证异常
class ValidationException extends ApiException {
  /// 验证错误详情
  final Map<String, List<String>>? errors;

  const ValidationException(
    String message, {
    String? code,
    int? statusCode,
    this.errors,
    dynamic originalException,
  }) : super(
          message,
          code: code,
          statusCode: statusCode,
          originalException: originalException,
        );
}

/// 业务逻辑异常
class BusinessException extends ApiException {
  const BusinessException(
    String message, {
    String? code,
    int? statusCode,
    dynamic originalException,
  }) : super(
          message,
          code: code,
          statusCode: statusCode,
          originalException: originalException,
        );
}

/// 取消请求异常
class CancelException extends ApiException {
  const CancelException(
    String message, {
    String? code,
    dynamic originalException,
  }) : super(
          message,
          code: code,
          originalException: originalException,
        );
}

/// 未知异常
class UnknownException extends ApiException {
  const UnknownException(
    String message, {
    String? code,
    dynamic originalException,
  }) : super(
          message,
          code: code,
          originalException: originalException,
        );
}

/// API异常工厂类
///
/// 根据不同的错误类型创建对应的异常实例
class ApiExceptionFactory {
  /// 从DioException创建ApiException
  static ApiException fromDioException(DioException dioException) {
    switch (dioException.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException(
          _getTimeoutMessage(dioException.type),
          code: 'TIMEOUT',
          originalException: dioException,
        );

      case DioExceptionType.connectionError:
        return NetworkException(
          '网络连接失败，请检查网络设置',
          code: 'NETWORK_ERROR',
          originalException: dioException,
        );

      case DioExceptionType.badResponse:
        return _createResponseException(dioException);

      case DioExceptionType.cancel:
        return CancelException(
          '请求已取消',
          code: 'CANCELLED',
          originalException: dioException,
        );

      case DioExceptionType.badCertificate:
        return NetworkException(
          'SSL证书验证失败',
          code: 'SSL_ERROR',
          originalException: dioException,
        );

      case DioExceptionType.unknown:
      default:
        return UnknownException(
          dioException.message ?? '未知网络错误',
          code: 'UNKNOWN',
          originalException: dioException,
        );
    }
  }

  /// 从HTTP响应创建异常
  static ApiException _createResponseException(DioException dioException) {
    final response = dioException.response;
    final statusCode = response?.statusCode ?? 0;
    final data = response?.data;

    // 尝试解析错误消息
    String message = '请求失败';
    String? code;

    if (data is Map<String, dynamic>) {
      message = data['message'] ?? data['error'] ?? message;
      code = data['code']?.toString() ?? data['error_code']?.toString();
    }

    // 根据状态码创建不同类型的异常
    switch (statusCode) {
      case 400:
        return ClientException(
          message.isEmpty ? '请求参数错误' : message,
          code: code ?? 'BAD_REQUEST',
          statusCode: statusCode,
          originalException: dioException,
        );

      case 401:
        return AuthException(
          message.isEmpty ? '未授权，请重新登录' : message,
          code: code ?? 'UNAUTHORIZED',
          statusCode: statusCode,
          originalException: dioException,
        );

      case 403:
        return PermissionException(
          message.isEmpty ? '权限不足' : message,
          code: code ?? 'FORBIDDEN',
          statusCode: statusCode,
          originalException: dioException,
        );

      case 404:
        return NotFoundException(
          message.isEmpty ? '请求的资源不存在' : message,
          code: code ?? 'NOT_FOUND',
          statusCode: statusCode,
          originalException: dioException,
        );

      case 422:
        return ValidationException(
          message.isEmpty ? '请求参数验证失败' : message,
          code: code ?? 'VALIDATION_ERROR',
          statusCode: statusCode,
          errors: _parseValidationErrors(data),
          originalException: dioException,
        );

      case 429:
        return ClientException(
          message.isEmpty ? '请求过于频繁，请稍后再试' : message,
          code: code ?? 'TOO_MANY_REQUESTS',
          statusCode: statusCode,
          originalException: dioException,
        );

      case 500:
      case 502:
      case 503:
      case 504:
        return ServerException(
          message.isEmpty ? '服务器错误，请稍后再试' : message,
          code: code ?? 'SERVER_ERROR',
          statusCode: statusCode,
          originalException: dioException,
        );

      default:
        if (statusCode >= 400 && statusCode < 500) {
          return ClientException(
            message,
            code: code ?? 'CLIENT_ERROR',
            statusCode: statusCode,
            originalException: dioException,
          );
        } else if (statusCode >= 500) {
          return ServerException(
            message,
            code: code ?? 'SERVER_ERROR',
            statusCode: statusCode,
            originalException: dioException,
          );
        } else {
          return UnknownException(
            message,
            code: code ?? 'UNKNOWN',
            originalException: dioException,
          );
        }
    }
  }

  /// 获取超时错误消息
  static String _getTimeoutMessage(DioExceptionType type) {
    switch (type) {
      case DioExceptionType.connectionTimeout:
        return '连接超时，请检查网络';
      case DioExceptionType.sendTimeout:
        return '发送超时，请重试';
      case DioExceptionType.receiveTimeout:
        return '响应超时，请重试';
      default:
        return '请求超时';
    }
  }

  /// 解析验证错误详情
  static Map<String, List<String>>? _parseValidationErrors(dynamic data) {
    if (data is! Map<String, dynamic>) return null;

    final errors = data['errors'];
    if (errors is! Map<String, dynamic>) return null;

    final Map<String, List<String>> result = {};
    errors.forEach((key, value) {
      if (value is List) {
        result[key] = value.map((e) => e.toString()).toList();
      } else if (value is String) {
        result[key] = [value];
      }
    });

    return result.isEmpty ? null : result;
  }

  /// 从通用异常创建ApiException
  static ApiException fromException(Exception exception) {
    if (exception is DioException) {
      return fromDioException(exception);
    } else if (exception is ApiException) {
      return exception;
    } else {
      return UnknownException(
        exception.toString(),
        code: 'UNKNOWN',
        originalException: exception,
      );
    }
  }
}

/// 异常处理工具类
class ExceptionHandler {
  /// 处理异常并返回用户友好的错误消息
  static String getErrorMessage(dynamic error) {
    if (error is ApiException) {
      return error.message;
    } else if (error is DioException) {
      final apiException = ApiExceptionFactory.fromDioException(error);
      return apiException.message;
    } else {
      return '发生未知错误，请稍后重试';
    }
  }

  /// 判断是否为网络错误
  static bool isNetworkError(dynamic error) {
    return error is NetworkException ||
        error is TimeoutException ||
        (error is DioException &&
            (error.type == DioExceptionType.connectionError ||
                error.type == DioExceptionType.connectionTimeout ||
                error.type == DioExceptionType.sendTimeout ||
                error.type == DioExceptionType.receiveTimeout));
  }

  /// 判断是否为认证错误
  static bool isAuthError(dynamic error) {
    return error is AuthException ||
        (error is DioException && error.response?.statusCode == 401);
  }

  /// 判断是否为权限错误
  static bool isPermissionError(dynamic error) {
    return error is PermissionException ||
        (error is DioException && error.response?.statusCode == 403);
  }

  /// 判断是否为服务器错误
  static bool isServerError(dynamic error) {
    return error is ServerException ||
        (error is DioException &&
            error.response != null &&
            error.response!.statusCode! >= 500);
  }

  /// 判断是否需要重试
  static bool shouldRetry(dynamic error) {
    if (error is NetworkException || error is TimeoutException) {
      return true;
    }

    if (error is ServerException) {
      return true;
    }

    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      return statusCode == null ||
          statusCode >= 500 ||
          error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout;
    }

    return false;
  }
}
