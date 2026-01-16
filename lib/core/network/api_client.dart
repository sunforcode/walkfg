import 'dart:collection';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../service/cache/hive_service_cache.dart';
import '../../service/cache/service_cache.dart';
import 'cache_exception.dart';
import 'data_source.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'interceptors/mock_interceptor.dart';
import 'interceptors/retry_interceptor.dart';

/// HTTP客户端管理器
///
/// 提供统一的网络请求配置和管理，包括：
/// - 基础配置（超时、headers等）
/// - 拦截器管理（认证、日志、错误处理、重试）
/// - 单例模式确保全局唯一
class ApiClient {
  static ApiClient? _instance;
  late final Dio _dio;
  late final ServiceCache _cache;

  /// 获取单例实例
  static ApiClient get instance {
    _instance ??= ApiClient._internal();
    return _instance!;
  }

  /// 私有构造函数
  ApiClient._internal() {
    _dio = Dio();
    _cache = HiveServiceCache.instance;
  }

  /// 初始化HTTP客户端
  ///
  /// [baseUrl] 基础URL
  /// [connectTimeout] 连接超时时间（毫秒）
  /// [receiveTimeout] 接收超时时间（毫秒）
  /// [sendTimeout] 发送超时时间（毫秒）
  Future<void> initialize({
    required String baseUrl,
    int connectTimeout = 15000,
    int receiveTimeout = 15000,
    int sendTimeout = 15000,
    Map<String, String>? headers,
  }) async {
    // 基础配置
    _dio.options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: Duration(milliseconds: connectTimeout),
      receiveTimeout: Duration(milliseconds: receiveTimeout),
      sendTimeout: Duration(milliseconds: sendTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'Walk-App/1.0.0',
        ...?headers,
      },
      responseType: ResponseType.json,
      followRedirects: true,
      maxRedirects: 3,
    );

    // 清除现有拦截器
    _dio.interceptors.clear();

    // 添加拦截器（顺序很重要）
    _addInterceptors();

    // 初始化缓存
    await _cache.initialize();

    debugPrint('ApiClient initialized with baseUrl: $baseUrl');
  }

  /// 添加拦截器
  void _addInterceptors() {
    // 1. Mock拦截器（返回Mock数据，仅Mock模式）
    _dio.interceptors.add(MockInterceptor());

    // 2. 认证拦截器（请求前添加token）
    _dio.interceptors.add(AuthInterceptor());

    // 3. 重试拦截器（网络失败时重试）
    _dio.interceptors.add(RetryInterceptor());

    // 4. 日志拦截器（开发环境下打印请求日志）
    if (kDebugMode) {
      _dio.interceptors.add(LoggingInterceptor());
    }

    // 5. 错误处理拦截器（统一处理错误）
    _dio.interceptors.add(ErrorInterceptor());
  }

  /// 获取Dio实例
  Dio get dio => _dio;

  /// GET请求（带缓存支持）
  ///
  /// [path] 请求路径
  /// [queryParameters] 查询参数
  /// [dataSource] 数据来源策略，默认 networkOnly（向后兼容）
  /// [cacheTTL] 缓存过期时间
  /// [fromJson] JSON 反序列化函数
  /// [options] Dio 请求选项
  /// [cancelToken] 取消令牌
  /// [onReceiveProgress] 接收进度回调
  Future<T> getData<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    DataSource dataSource = DataSource.networkOnly,
    Duration? cacheTTL,
    required T Function(Map<String, dynamic>) fromJson,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    final cacheKey = _generateCacheKey(path, queryParameters);

    switch (dataSource) {
      case DataSource.cacheFirst:
        // 优先读缓存
        final cached = await _cache.get<Map<String, dynamic>>(cacheKey);
        if (cached != null) {
          debugPrint('ApiClient: 缓存命中 [$cacheKey]');
          return fromJson(cached);
        }
        // 缓存没有，请求网络
        return _fetchAndCache<T>(
          path,
          queryParameters: queryParameters,
          cacheKey: cacheKey,
          cacheTTL: cacheTTL,
          fromJson: fromJson,
          options: options,
          cancelToken: cancelToken,
          onReceiveProgress: onReceiveProgress,
        );

      case DataSource.cacheOnly:
        // 只读缓存
        final cached = await _cache.get<Map<String, dynamic>>(cacheKey);
        if (cached == null) {
          throw CacheNotFoundException(cacheKey);
        }
        debugPrint('ApiClient: 缓存命中 [$cacheKey]');
        return fromJson(cached);

      case DataSource.networkFirst:
        // 优先网络，失败再读缓存
        try {
          return await _fetchAndCache<T>(
            path,
            queryParameters: queryParameters,
            cacheKey: cacheKey,
            cacheTTL: cacheTTL,
            fromJson: fromJson,
            options: options,
            cancelToken: cancelToken,
            onReceiveProgress: onReceiveProgress,
          );
        } catch (e) {
          final cached = await _cache.get<Map<String, dynamic>>(cacheKey);
          if (cached != null) {
            debugPrint('ApiClient: 网络失败，使用缓存 [$cacheKey]');
            return fromJson(cached);
          }
          rethrow;
        }

      case DataSource.networkOnly:
        // 只请求网络
        return _fetchAndCache<T>(
          path,
          queryParameters: queryParameters,
          cacheKey: cacheKey,
          cacheTTL: cacheTTL,
          fromJson: fromJson,
          options: options,
          cancelToken: cancelToken,
          onReceiveProgress: onReceiveProgress,
        );
    }
  }

  /// GET请求（原始版本，返回 Response）
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    return await _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// 请求网络并缓存结果
  Future<T> _fetchAndCache<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required String cacheKey,
    Duration? cacheTTL,
    required T Function(Map<String, dynamic>) fromJson,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );

    final data = response.data!;

    // 写入缓存
    await _cache.set(cacheKey, data, ttl: cacheTTL);
    debugPrint('ApiClient: 缓存写入 [$cacheKey], TTL: $cacheTTL');

    return fromJson(data);
  }

  /// 生成缓存键
  ///
  /// 基于路径和查询参数生成唯一的缓存键
  String _generateCacheKey(String path, Map<String, dynamic>? params) {
    if (params == null || params.isEmpty) {
      return path;
    }
    // 使用 SplayTreeMap 保证参数顺序一致
    final sortedParams = SplayTreeMap<String, dynamic>.from(params);
    final paramString = sortedParams.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');
    return '$path?$paramString';
  }

  /// POST请求
  ///
  /// [invalidateCacheKeys] 请求成功后需要失效的缓存键列表
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    List<String>? invalidateCacheKeys,
  }) async {
    final response = await _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
    // 失效相关缓存
    await _invalidateCaches(invalidateCacheKeys);
    return response;
  }

  /// PUT请求
  ///
  /// [invalidateCacheKeys] 请求成功后需要失效的缓存键列表
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    List<String>? invalidateCacheKeys,
  }) async {
    final response = await _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
    // 失效相关缓存
    await _invalidateCaches(invalidateCacheKeys);
    return response;
  }

  /// DELETE请求
  ///
  /// [invalidateCacheKeys] 请求成功后需要失效的缓存键列表
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    List<String>? invalidateCacheKeys,
  }) async {
    final response = await _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
    // 失效相关缓存
    await _invalidateCaches(invalidateCacheKeys);
    return response;
  }

  /// 失效指定的缓存键
  Future<void> _invalidateCaches(List<String>? keys) async {
    if (keys == null || keys.isEmpty) return;
    for (final key in keys) {
      await _cache.remove(key);
      debugPrint('ApiClient: 缓存失效 [$key]');
    }
  }

  /// 清除所有缓存
  Future<void> clearCache() async {
    await _cache.clear();
    debugPrint('ApiClient: 所有缓存已清除');
  }

  /// 移除指定缓存
  Future<void> removeCache(String key) async {
    await _cache.remove(key);
  }

  /// PATCH请求
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return await _dio.patch<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// 文件上传
  Future<Response<T>> upload<T>(
    String path,
    FormData formData, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
  }) async {
    return await _dio.post<T>(
      path,
      data: formData,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
    );
  }

  /// 文件下载
  Future<Response> download(
    String urlPath,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    bool deleteOnError = true,
    String lengthHeader = Headers.contentLengthHeader,
    Options? options,
  }) async {
    return await _dio.download(
      urlPath,
      savePath,
      onReceiveProgress: onReceiveProgress,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
      deleteOnError: deleteOnError,
      lengthHeader: lengthHeader,
      options: options,
    );
  }

  /// 更新基础URL
  void updateBaseUrl(String baseUrl) {
    _dio.options.baseUrl = baseUrl;
    debugPrint('ApiClient baseUrl updated to: $baseUrl');
  }

  /// 更新headers
  void updateHeaders(Map<String, String> headers) {
    _dio.options.headers.addAll(headers);
    debugPrint('ApiClient headers updated: $headers');
  }

  /// 清除所有headers
  void clearHeaders() {
    _dio.options.headers.clear();
    debugPrint('ApiClient headers cleared');
  }

  /// 设置认证token
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
    debugPrint('ApiClient auth token set');
  }

  /// 清除认证token
  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
    debugPrint('ApiClient auth token cleared');
  }

  /// 关闭客户端
  void close() {
    _dio.close();
    debugPrint('ApiClient closed');
  }
}
