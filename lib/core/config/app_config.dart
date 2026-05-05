import 'package:flutter/foundation.dart';

/// 应用环境枚举
enum AppEnvironment {
  /// 开发环境
  development,

  /// 测试环境
  staging,

  /// 生产环境
  production,
}

/// 应用配置管理
///
/// 统一管理应用的各种配置，包括环境配置、网络配置等
class AppConfig {
  static AppConfig? _instance;

  /// 当前环境
  late final AppEnvironment _environment;

  /// 基础URL
  late final String _baseUrl;

  /// API版本
  late final String _apiVersion;

  /// 是否启用Mock服务
  late final bool _useMockServices;

  /// 是否启用日志
  late final bool _enableLogging;

  /// 网络超时配置
  late final NetworkTimeoutConfig _timeoutConfig;

  /// 重试配置
  late final RetryConfig _retryConfig;

  /// 私有构造函数
  AppConfig._internal();

  /// 获取单例实例
  static AppConfig get instance {
    _instance ??= AppConfig._internal();
    return _instance!;
  }

  /// 初始化配置
  void initialize({
    AppEnvironment? environment,
    String? baseUrl,
    String? apiVersion,
    bool? useMockServices,
    bool? enableLogging,
    NetworkTimeoutConfig? timeoutConfig,
    RetryConfig? retryConfig,
  }) {
    _environment = environment ?? _getEnvironmentFromString();
    _baseUrl = baseUrl ?? _getDefaultBaseUrl();
    _apiVersion = apiVersion ?? 'v1';
    _useMockServices = useMockServices ?? _getDefaultUseMockServices();
    _enableLogging = enableLogging ?? _getDefaultEnableLogging();
    _timeoutConfig = timeoutConfig ?? NetworkTimeoutConfig.defaultConfig();
    _retryConfig = retryConfig ?? RetryConfig.defaultConfig();

    debugPrint('AppConfig initialized:');
    debugPrint('  Environment: $_environment');
    debugPrint('  Base URL: $_baseUrl');
    debugPrint('  API Version: $_apiVersion');
    debugPrint('  Use Mock Services: $_useMockServices');
    debugPrint('  Enable Logging: $_enableLogging');
  }

  /// 获取当前环境
  AppEnvironment get environment => _environment;

  /// 获取基础URL
  String get baseUrl => _baseUrl;

  /// 获取API版本
  String get apiVersion => _apiVersion;

  /// 是否使用Mock服务
  bool get useMockServices => _useMockServices;

  /// 是否启用日志
  bool get enableLogging => _enableLogging;

  /// 获取网络超时配置
  NetworkTimeoutConfig get timeoutConfig => _timeoutConfig;

  /// 获取重试配置
  RetryConfig get retryConfig => _retryConfig;

  /// 是否为开发环境
  bool get isDevelopment => _environment == AppEnvironment.development;

  /// 是否为测试环境
  bool get isStaging => _environment == AppEnvironment.staging;

  /// 是否为生产环境
  bool get isProduction => _environment == AppEnvironment.production;

  /// 是否为调试模式
  bool get isDebugMode => kDebugMode;

  /// 从环境变量获取环境类型
  AppEnvironment _getEnvironmentFromString() {
    const env = String.fromEnvironment('ENV', defaultValue: 'development');
    switch (env.toLowerCase()) {
      case 'production':
      case 'prod':
        return AppEnvironment.production;
      case 'staging':
      case 'test':
        return AppEnvironment.staging;
      case 'development':
      case 'dev':
      default:
        return AppEnvironment.development;
    }
  }

  /// 获取默认基础URL
  String _getDefaultBaseUrl() {
    switch (_environment) {
      case AppEnvironment.production:
        return const String.fromEnvironment('PROD_BASE_URL',
            defaultValue: 'https://api.walkapp.com');
      case AppEnvironment.staging:
        return const String.fromEnvironment('STAGING_BASE_URL',
            defaultValue: 'https://staging-api.walkapp.com');
      case AppEnvironment.development:
        return const String.fromEnvironment('DEV_BASE_URL',
            defaultValue: 'http://127.0.0.1:8080'); // api_endpoints.dart 中已包含 /walkbg 前缀
    }
  }

  /// 获取默认是否使用Mock服务
  bool _getDefaultUseMockServices() {
    switch (_environment) {
      case AppEnvironment.production:
        return false;
      case AppEnvironment.staging:
        return const bool.fromEnvironment('USE_MOCK', defaultValue: false);
      case AppEnvironment.development:
        // 开发环境默认使用真实API,如需使用Mock数据请设置环境变量 USE_MOCK=true
        return const bool.fromEnvironment('USE_MOCK', defaultValue: false);
    }
  }

  /// 获取默认是否启用日志
  bool _getDefaultEnableLogging() {
    switch (_environment) {
      case AppEnvironment.production:
        return false;
      case AppEnvironment.staging:
      case AppEnvironment.development:
        return kDebugMode;
    }
  }

  /// 更新基础URL
  void updateBaseUrl(String newBaseUrl) {
    _baseUrl = newBaseUrl;
    debugPrint('AppConfig: Base URL updated to $newBaseUrl');
  }

  /// 更新Mock服务使用状态
  void updateUseMockServices(bool useMock) {
    _useMockServices = useMock;
    debugPrint('AppConfig: Use mock services updated to $useMock');
  }

  /// 获取完整的API URL
  String getApiUrl(String endpoint) {
    if (endpoint.startsWith('http')) {
      return endpoint;
    }

    String url = _baseUrl;
    if (!url.endsWith('/')) {
      url += '/';
    }

    if (endpoint.startsWith('/')) {
      endpoint = endpoint.substring(1);
    }

    return url + endpoint;
  }

  /// 获取环境显示名称
  String get environmentDisplayName {
    switch (_environment) {
      case AppEnvironment.development:
        return '开发环境';
      case AppEnvironment.staging:
        return '测试环境';
      case AppEnvironment.production:
        return '生产环境';
    }
  }

  /// 获取配置摘要
  Map<String, dynamic> getConfigSummary() {
    return {
      'environment': _environment.name,
      'baseUrl': _baseUrl,
      'apiVersion': _apiVersion,
      'useMockServices': _useMockServices,
      'enableLogging': _enableLogging,
      'isDevelopment': isDevelopment,
      'isStaging': isStaging,
      'isProduction': isProduction,
      'isDebugMode': isDebugMode,
    };
  }
}

/// 网络超时配置
class NetworkTimeoutConfig {
  /// 连接超时时间（毫秒）
  final int connectTimeout;

  /// 接收超时时间（毫秒）
  final int receiveTimeout;

  /// 发送超时时间（毫秒）
  final int sendTimeout;

  const NetworkTimeoutConfig({
    required this.connectTimeout,
    required this.receiveTimeout,
    required this.sendTimeout,
  });

  /// 默认配置
  factory NetworkTimeoutConfig.defaultConfig() {
    return const NetworkTimeoutConfig(
      connectTimeout: 15000, // 15秒
      receiveTimeout: 15000, // 15秒
      sendTimeout: 15000, // 15秒
    );
  }

  /// 快速配置（较短超时时间）
  factory NetworkTimeoutConfig.fast() {
    return const NetworkTimeoutConfig(
      connectTimeout: 5000, // 5秒
      receiveTimeout: 10000, // 10秒
      sendTimeout: 10000, // 10秒
    );
  }

  /// 慢速配置（较长超时时间）
  factory NetworkTimeoutConfig.slow() {
    return const NetworkTimeoutConfig(
      connectTimeout: 30000, // 30秒
      receiveTimeout: 30000, // 30秒
      sendTimeout: 30000, // 30秒
    );
  }
}

/// 重试配置
class RetryConfig {
  /// 最大重试次数
  final int maxRetries;

  /// 重试延迟（毫秒）
  final int retryDelay;

  /// 是否启用指数退避
  final bool enableExponentialBackoff;

  /// 最大延迟时间（毫秒）
  final int maxDelay;

  const RetryConfig({
    required this.maxRetries,
    required this.retryDelay,
    required this.enableExponentialBackoff,
    required this.maxDelay,
  });

  /// 默认配置
  factory RetryConfig.defaultConfig() {
    return const RetryConfig(
      maxRetries: 3,
      retryDelay: 1000,
      enableExponentialBackoff: true,
      maxDelay: 10000,
    );
  }

  /// 激进重试配置
  factory RetryConfig.aggressive() {
    return const RetryConfig(
      maxRetries: 5,
      retryDelay: 500,
      enableExponentialBackoff: true,
      maxDelay: 8000,
    );
  }

  /// 保守重试配置
  factory RetryConfig.conservative() {
    return const RetryConfig(
      maxRetries: 2,
      retryDelay: 2000,
      enableExponentialBackoff: false,
      maxDelay: 5000,
    );
  }

  /// 禁用重试
  factory RetryConfig.disabled() {
    return const RetryConfig(
      maxRetries: 0,
      retryDelay: 0,
      enableExponentialBackoff: false,
      maxDelay: 0,
    );
  }
}

/// 应用常量
class AppConstants {
  /// 应用名称
  static const String appName = 'Walk';

  /// 应用版本
  static const String appVersion = '1.0.0';

  /// 构建号
  static const String buildNumber = '1';

  /// 用户协议URL
  static const String termsOfServiceUrl = 'https://walkapp.com/terms';

  /// 隐私政策URL
  static const String privacyPolicyUrl = 'https://walkapp.com/privacy';

  /// 帮助中心URL
  static const String helpCenterUrl = 'https://walkapp.com/help';

  /// 反馈邮箱
  static const String feedbackEmail = 'feedback@walkapp.com';

  /// 客服电话
  static const String supportPhone = '400-123-4567';

  /// 默认分页大小
  static const int defaultPageSize = 20;

  /// 最大分页大小
  static const int maxPageSize = 100;

  /// 缓存过期时间（毫秒）
  static const int cacheExpireTime = 30 * 60 * 1000; // 30分钟

  /// 图片缓存过期时间（毫秒）
  static const int imageCacheExpireTime = 7 * 24 * 60 * 60 * 1000; // 7天
}
