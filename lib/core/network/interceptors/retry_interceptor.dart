import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// 重试拦截器
///
/// 在网络失败或服务器错误时自动重试请求
class RetryInterceptor extends Interceptor {
  /// 最大重试次数
  final int maxRetries;

  /// 重试延迟（毫秒）
  final int retryDelay;

  /// 是否使用指数退避
  final bool useExponentialBackoff;

  /// 最大延迟时间（毫秒）
  final int maxDelay;

  RetryInterceptor({
    this.maxRetries = 3,
    this.retryDelay = 1000,
    this.useExponentialBackoff = true,
    this.maxDelay = 10000,
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // 获取当前重试次数
    final retryCount = err.requestOptions.extra['retry_count'] ?? 0;

    // 检查是否应该重试
    if (_shouldRetry(err, retryCount)) {
      debugPrint(
          'RetryInterceptor: Retrying request (${retryCount + 1}/$maxRetries) for ${err.requestOptions.path}');

      try {
        // 计算延迟时间
        final delay = _calculateDelay(retryCount);
        await Future.delayed(Duration(milliseconds: delay));

        // 更新重试次数
        err.requestOptions.extra['retry_count'] = retryCount + 1;

        // 创建新的Dio实例进行重试
        final dio = Dio();

        // 复制原始配置
        dio.options = err.requestOptions.copyWith() as BaseOptions;

        // 发送重试请求
        final response = await dio.fetch(err.requestOptions);

        debugPrint(
            'RetryInterceptor: Retry successful for ${err.requestOptions.path}');
        handler.resolve(response);
        return;
      } catch (e) {
        debugPrint(
            'RetryInterceptor: Retry failed for ${err.requestOptions.path}: $e');

        // 如果重试也失败了，继续检查是否还能重试
        if (retryCount + 1 < maxRetries &&
            _shouldRetry(e as DioException, retryCount + 1)) {
          // 递归调用重试
          onError(e, handler);
          return;
        }
      }
    }

    // 不重试或重试次数已达上限
    debugPrint(
        'RetryInterceptor: No more retries for ${err.requestOptions.path}');
    handler.next(err);
  }

  /// 判断是否应该重试
  bool _shouldRetry(DioException error, int retryCount) {
    // 检查重试次数
    if (retryCount >= maxRetries) {
      return false;
    }

    // 检查错误类型
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return true;

      case DioExceptionType.badResponse:
        // 只对服务器错误进行重试
        final statusCode = error.response?.statusCode;
        return statusCode != null && statusCode >= 500;

      case DioExceptionType.cancel:
      case DioExceptionType.badCertificate:
        return false;

      case DioExceptionType.unknown:
        return _isNetworkError(error);
    }
  }

  /// 判断是否为网络错误
  bool _isNetworkError(DioException error) {
    final message = error.message?.toLowerCase() ?? '';
    return message.contains('network') ||
        message.contains('connection') ||
        message.contains('timeout') ||
        message.contains('unreachable') ||
        message.contains('failed host lookup');
  }

  /// 计算延迟时间
  int _calculateDelay(int retryCount) {
    if (!useExponentialBackoff) {
      return retryDelay;
    }

    // 指数退避算法：delay * (2^retryCount) + 随机抖动
    final exponentialDelay = retryDelay * pow(2, retryCount).toInt();

    // 添加随机抖动（±25%）
    final jitter =
        (exponentialDelay * 0.25 * (Random().nextDouble() - 0.5)).toInt();
    final finalDelay = exponentialDelay + jitter;

    // 限制最大延迟时间
    return min(finalDelay, maxDelay);
  }
}

/// 智能重试拦截器
///
/// 根据不同的错误类型采用不同的重试策略
class SmartRetryInterceptor extends Interceptor {
  /// 网络错误重试配置
  final RetryConfig networkRetryConfig;

  /// 服务器错误重试配置
  final RetryConfig serverRetryConfig;

  /// 超时错误重试配置
  final RetryConfig timeoutRetryConfig;

  SmartRetryInterceptor({
    RetryConfig? networkRetryConfig,
    RetryConfig? serverRetryConfig,
    RetryConfig? timeoutRetryConfig,
  })  : networkRetryConfig =
            networkRetryConfig ?? RetryConfig(maxRetries: 3, retryDelay: 1000),
        serverRetryConfig =
            serverRetryConfig ?? RetryConfig(maxRetries: 2, retryDelay: 2000),
        timeoutRetryConfig =
            timeoutRetryConfig ?? RetryConfig(maxRetries: 2, retryDelay: 1500);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final retryConfig = _getRetryConfig(err);
    if (retryConfig == null) {
      handler.next(err);
      return;
    }

    final retryCount = err.requestOptions.extra['retry_count'] ?? 0;

    if (retryCount >= retryConfig.maxRetries) {
      debugPrint(
          'SmartRetryInterceptor: Max retries reached for ${err.requestOptions.path}');
      handler.next(err);
      return;
    }

    debugPrint(
        'SmartRetryInterceptor: Retrying request (${retryCount + 1}/${retryConfig.maxRetries}) for ${err.requestOptions.path}');

    try {
      // 计算延迟时间
      final delay = retryConfig.useExponentialBackoff
          ? _calculateExponentialDelay(retryCount, retryConfig)
          : retryConfig.retryDelay;

      await Future.delayed(Duration(milliseconds: delay));

      // 更新重试次数
      err.requestOptions.extra['retry_count'] = retryCount + 1;

      // 创建新的Dio实例进行重试
      final dio = Dio();
      dio.options = err.requestOptions.copyWith() as BaseOptions;

      final response = await dio.fetch(err.requestOptions);

      debugPrint(
          'SmartRetryInterceptor: Retry successful for ${err.requestOptions.path}');
      handler.resolve(response);
    } catch (e) {
      debugPrint(
          'SmartRetryInterceptor: Retry failed for ${err.requestOptions.path}: $e');

      // 递归重试
      if (e is DioException) {
        onError(e, handler);
      } else {
        handler.next(err);
      }
    }
  }

  /// 根据错误类型获取重试配置
  RetryConfig? _getRetryConfig(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return timeoutRetryConfig;

      case DioExceptionType.connectionError:
        return networkRetryConfig;

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode != null && statusCode >= 500) {
          return serverRetryConfig;
        }
        return null;

      default:
        return null;
    }
  }

  /// 计算指数退避延迟
  int _calculateExponentialDelay(int retryCount, RetryConfig config) {
    final exponentialDelay = config.retryDelay * pow(2, retryCount).toInt();
    final jitter =
        (exponentialDelay * 0.25 * (Random().nextDouble() - 0.5)).toInt();
    final finalDelay = exponentialDelay + jitter;
    return min(finalDelay, config.maxDelay);
  }
}

/// 重试配置
class RetryConfig {
  /// 最大重试次数
  final int maxRetries;

  /// 重试延迟（毫秒）
  final int retryDelay;

  /// 是否使用指数退避
  final bool useExponentialBackoff;

  /// 最大延迟时间（毫秒）
  final int maxDelay;

  const RetryConfig({
    required this.maxRetries,
    required this.retryDelay,
    this.useExponentialBackoff = true,
    this.maxDelay = 10000,
  });
}
