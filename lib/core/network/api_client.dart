import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
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

  /// 获取单例实例
  static ApiClient get instance {
    _instance ??= ApiClient._internal();
    return _instance!;
  }

  /// 私有构造函数
  ApiClient._internal() {
    _dio = Dio();
  }

  /// 初始化HTTP客户端
  ///
  /// [baseUrl] 基础URL
  /// [connectTimeout] 连接超时时间（毫秒）
  /// [receiveTimeout] 接收超时时间（毫秒）
  /// [sendTimeout] 发送超时时间（毫秒）
  void initialize({
    required String baseUrl,
    int connectTimeout = 15000,
    int receiveTimeout = 15000,
    int sendTimeout = 15000,
    Map<String, String>? headers,
  }) {
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

    debugPrint('ApiClient initialized with baseUrl: $baseUrl');
  }

  /// 添加拦截器
  void _addInterceptors() {
    // 1. 认证拦截器（请求前添加token）
    _dio.interceptors.add(AuthInterceptor());

    // 2. 重试拦截器（网络失败时重试）
    _dio.interceptors.add(RetryInterceptor());

    // 3. 日志拦截器（开发环境下打印请求日志）
    if (kDebugMode) {
      _dio.interceptors.add(LoggingInterceptor());
    }

    // 4. 错误处理拦截器（统一处理错误）
    _dio.interceptors.add(ErrorInterceptor());
  }

  /// 获取Dio实例
  Dio get dio => _dio;

  /// GET请求
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

  /// POST请求
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return await _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// PUT请求
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return await _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// DELETE请求
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
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
