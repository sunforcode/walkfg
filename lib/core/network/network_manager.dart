import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import '../config/app_config.dart';
import 'api_client.dart';

/// 网络管理器
///
/// 统一管理网络层的初始化和配置
class NetworkManager {
  static NetworkManager? _instance;
  static NetworkManager get instance =>
      _instance ??= NetworkManager._internal();

  NetworkManager._internal();

  /// 是否已初始化
  bool _isInitialized = false;

  /// 初始化网络层
  ///
  /// 应在应用启动时调用
  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('NetworkManager: Already initialized');
      return;
    }

    try {
      // 获取应用配置
      final config = AppConfig.instance;
      print("初始化的baseurla $config.baseUrl");
      // 初始化API客户端
      ApiClient.instance.initialize(
        baseUrl: config.baseUrl,
        connectTimeout: config.timeoutConfig.connectTimeout,
        receiveTimeout: config.timeoutConfig.receiveTimeout,
        sendTimeout: config.timeoutConfig.sendTimeout,
        headers: {
          'X-App-Version': AppConstants.appVersion,
          'X-Platform': defaultTargetPlatform.name,
          'X-Environment': config.environment.name,
        },
      );

      _isInitialized = true;
      debugPrint('NetworkManager: Initialized successfully');

      // 打印网络配置信息
      _logNetworkConfig();
    } catch (e) {
      debugPrint('NetworkManager: Initialization failed: $e');
      rethrow;
    }
  }

  /// 更新基础URL
  ///
  /// 用于动态切换服务器环境
  void updateBaseUrl(String newBaseUrl) {
    if (!_isInitialized) {
      throw StateError('NetworkManager not initialized');
    }

    ApiClient.instance.updateBaseUrl(newBaseUrl);
    AppConfig.instance.updateBaseUrl(newBaseUrl);

    debugPrint('NetworkManager: Base URL updated to $newBaseUrl');
  }

  /// 设置认证token
  void setAuthToken(String token) {
    if (!_isInitialized) {
      throw StateError('NetworkManager not initialized');
    }

    ApiClient.instance.setAuthToken(token);
    debugPrint('NetworkManager: Auth token set');
  }

  /// 清除认证token
  void clearAuthToken() {
    if (!_isInitialized) {
      throw StateError('NetworkManager not initialized');
    }

    ApiClient.instance.clearAuthToken();
    debugPrint('NetworkManager: Auth token cleared');
  }

  /// 检查网络状态
  Future<bool> checkNetworkStatus() async {
    try {
      final response =
          await ApiClient.instance.get('/walkbg/api/system/health');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('NetworkManager: Network check failed: $e');
      return false;
    }
  }

  /// 获取网络配置信息
  Map<String, dynamic> getNetworkInfo() {
    final config = AppConfig.instance;
    return {
      'isInitialized': _isInitialized,
      'baseUrl': config.baseUrl,
      'environment': config.environment.name,
      'useMockServices': config.useMockServices,
      'enableLogging': config.enableLogging,
      'timeoutConfig': {
        'connect': config.timeoutConfig.connectTimeout,
        'receive': config.timeoutConfig.receiveTimeout,
        'send': config.timeoutConfig.sendTimeout,
      },
      'retryConfig': {
        'maxRetries': config.retryConfig.maxRetries,
        'retryDelay': config.retryConfig.retryDelay,
        'exponentialBackoff': config.retryConfig.enableExponentialBackoff,
      },
    };
  }

  /// 记录网络配置信息
  void _logNetworkConfig() {
    if (!kDebugMode) return;

    final info = getNetworkInfo();
    final buffer = StringBuffer();

    buffer.writeln('=== Network Configuration ===');
    buffer.writeln('Base URL: ${info['baseUrl']}');
    buffer.writeln('Environment: ${info['environment']}');
    buffer.writeln('Use Mock Services: ${info['useMockServices']}');
    buffer.writeln('Enable Logging: ${info['enableLogging']}');
    buffer.writeln('Timeout Config:');
    buffer.writeln('  Connect: ${info['timeoutConfig']['connect']}ms');
    buffer.writeln('  Receive: ${info['timeoutConfig']['receive']}ms');
    buffer.writeln('  Send: ${info['timeoutConfig']['send']}ms');
    buffer.writeln('Retry Config:');
    buffer.writeln('  Max Retries: ${info['retryConfig']['maxRetries']}');
    buffer.writeln('  Retry Delay: ${info['retryConfig']['retryDelay']}ms');
    buffer.writeln(
        '  Exponential Backoff: ${info['retryConfig']['exponentialBackoff']}');
    buffer.writeln('=============================');

    debugPrint(buffer.toString());
  }

  /// 关闭网络管理器
  void dispose() {
    if (_isInitialized) {
      ApiClient.instance.close();
      _isInitialized = false;
      debugPrint('NetworkManager: Disposed');
    }
  }
}

/// 网络管理器扩展
///
/// 提供便捷的静态方法
extension NetworkManagerExtension on NetworkManager {
  /// 快速初始化（使用默认配置）
  static Future<void> quickInit({
    String? baseUrl,
    bool? useMockServices,
  }) async {
    // 初始化应用配置
    AppConfig.instance.initialize(
      baseUrl: baseUrl,
      useMockServices: useMockServices,
    );

    // 初始化网络管理器
    await NetworkManager.instance.initialize();
  }

  /// 开发环境快速初始化
  static Future<void> initForDevelopment({
    String baseUrl = 'http://localhost',
    bool useMockServices = true,
  }) async {
    AppConfig.instance.initialize(
      environment: AppEnvironment.development,
      baseUrl: baseUrl,
      useMockServices: useMockServices,
      enableLogging: true,
    );

    await NetworkManager.instance.initialize();
  }

  /// 生产环境快速初始化
  static Future<void> initForProduction({
    required String baseUrl,
    bool useMockServices = false,
  }) async {
    AppConfig.instance.initialize(
      environment: AppEnvironment.production,
      baseUrl: baseUrl,
      useMockServices: useMockServices,
      enableLogging: false,
    );

    await NetworkManager.instance.initialize();
  }
}
