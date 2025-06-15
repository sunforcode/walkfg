# 网络层基础设施框架

这是一个完整的网络层基础设施框架，为Flutter应用提供统一的HTTP客户端管理、错误处理、拦截器和配置管理。

## 🏗️ 架构概览

```
lib/core/network/
├── api_client.dart           # HTTP客户端管理器
├── api_endpoints.dart        # API端点配置
├── api_response.dart         # 统一响应模型
├── api_exception.dart        # 异常处理
├── network_manager.dart      # 网络管理器
├── interceptors/             # 拦截器
│   ├── auth_interceptor.dart     # 认证拦截器
│   ├── error_interceptor.dart    # 错误处理拦截器
│   ├── logging_interceptor.dart  # 日志拦截器
│   └── retry_interceptor.dart    # 重试拦截器
└── README.md                 # 使用文档
```

## 🚀 快速开始

### 1. 初始化网络层

在应用启动时初始化网络层：

```dart
// main.dart
import 'package:walk/core/network/network_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 开发环境初始化
  await NetworkManagerExtension.initForDevelopment(
    baseUrl: 'http://localhost',
    useMockServices: true,
  );

  runApp(MyApp());
}
```

### 2. 使用API客户端

```dart
import 'package:walk/core/network/api_client.dart';
import 'package:walk/core/network/api_endpoints.dart';
import 'package:walk/core/network/api_response.dart';

class RouteRepository {
  final ApiClient _apiClient = ApiClient.instance;

  /// 获取路线列表
  Future<List<RouteModel>> getRoutes({
    String? season,
    int? limit,
  }) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.routes,
        queryParameters: {
          if (season != null) 'season': season,
          if (limit != null) 'limit': limit,
        },
      );

      // 解析响应
      final apiResponse = ApiResponse.fromJson(
        response.data!,
        (json) => json as Map<String, dynamic>,
      );

      if (apiResponse.isSuccess) {
        final List<dynamic> data = apiResponse.data['routes'];
        return data.map((json) => RouteModel.fromJson(json)).toList();
      } else {
        throw BusinessException(apiResponse.message);
      }
    } catch (e) {
      throw ApiExceptionFactory.fromException(e as Exception);
    }
  }
}
```

## 🔧 配置管理

### 环境配置

```dart
// 开发环境
AppConfig.instance.initialize(
  environment: AppEnvironment.development,
  baseUrl: 'http://localhost',
  useMockServices: true,
  enableLogging: true,
);

// 生产环境
AppConfig.instance.initialize(
  environment: AppEnvironment.production,
  baseUrl: 'https://api.walkapp.com',
  useMockServices: false,
  enableLogging: false,
);
```

### 网络超时配置

```dart
AppConfig.instance.initialize(
  timeoutConfig: NetworkTimeoutConfig(
    connectTimeout: 15000,  // 15秒
    receiveTimeout: 15000,  // 15秒
    sendTimeout: 15000,     // 15秒
  ),
);
```

### 重试配置

```dart
AppConfig.instance.initialize(
  retryConfig: RetryConfig(
    maxRetries: 3,
    retryDelay: 1000,
    enableExponentialBackoff: true,
    maxDelay: 10000,
  ),
);
```

## 🛡️ 错误处理

### 异常类型

框架提供了多种异常类型：

- `NetworkException` - 网络连接异常
- `TimeoutException` - 超时异常
- `ServerException` - 服务器异常
- `ClientException` - 客户端异常
- `AuthException` - 认证异常
- `PermissionException` - 权限异常
- `ValidationException` - 参数验证异常
- `BusinessException` - 业务逻辑异常

### 错误处理示例

```dart
try {
  final routes = await routeRepository.getRoutes();
  // 处理成功结果
} on AuthException catch (e) {
  // 处理认证错误，跳转到登录页
  Navigator.pushNamed(context, '/login');
} on NetworkException catch (e) {
  // 处理网络错误
  showSnackBar('网络连接失败，请检查网络设置');
} on ServerException catch (e) {
  // 处理服务器错误
  showSnackBar('服务器繁忙，请稍后重试');
} on ApiException catch (e) {
  // 处理其他API错误
  showSnackBar(e.message);
} catch (e) {
  // 处理未知错误
  showSnackBar('发生未知错误');
}
```

## 🔄 拦截器

### 认证拦截器

自动添加认证token到请求头，并处理token过期：

```dart
// 保存登录token
await AuthInterceptor.saveAuthTokens(accessToken, refreshToken);

// 检查登录状态
final isLoggedIn = await AuthInterceptor.isLoggedIn();

// 清除登录token
await AuthInterceptor.clearAuthTokens();
```

### 重试拦截器

自动重试失败的请求：

```dart
// 使用默认重试配置
final retryInterceptor = RetryInterceptor();

// 自定义重试配置
final customRetryInterceptor = RetryInterceptor(
  maxRetries: 5,
  retryDelay: 2000,
  useExponentialBackoff: true,
);

// 智能重试（不同错误类型使用不同策略）
final smartRetryInterceptor = SmartRetryInterceptor(
  networkRetryConfig: RetryConfig(maxRetries: 3, retryDelay: 1000),
  serverRetryConfig: RetryConfig(maxRetries: 2, retryDelay: 2000),
  timeoutRetryConfig: RetryConfig(maxRetries: 2, retryDelay: 1500),
);
```

### 日志拦截器

在开发环境下记录详细的请求和响应信息：

```dart
// 详细日志
final loggingInterceptor = LoggingInterceptor(
  enableDetailedLog: true,
  logRequestBody: true,
  logResponseBody: true,
  maxLogLength: 1000,
);

// 简化日志
final simpleLoggingInterceptor = SimpleLoggingInterceptor();
```

## 📡 API端点管理

使用 `ApiEndpoints` 类统一管理所有API路径：

```dart
// 基础路线API
final routes = await apiClient.get(ApiEndpoints.routes);
final routeDetail = await apiClient.get(ApiEndpoints.routeDetail('123'));

// 带查询参数的API
final searchUrl = ApiEndpoints.buildUrl(
  ApiEndpoints.searchRoutes,
  {'keyword': 'hiking', 'limit': 20},
);

// 分页API
final paginatedUrl = ApiEndpoints.buildPaginatedUrl(
  ApiEndpoints.routes,
  page: 2,
  limit: 20,
  additionalParams: {'season': 'summer'},
);
```

## 📦 响应模型

使用统一的响应模型处理API响应：

```dart
// 单个对象响应
final response = ApiResponse<RouteModel>.fromJson(
  responseData,
  (json) => RouteModel.fromJson(json as Map<String, dynamic>),
);

// 列表响应
final listResponse = ListResponse<RouteModel>.fromJson(
  responseData,
  (json) => RouteModel.fromJson(json as Map<String, dynamic>),
);

// 检查响应状态
if (response.isSuccess) {
  final route = response.data;
  // 处理数据
} else {
  // 处理错误
  print('Error: ${response.message}');
}
```

## 🔧 高级用法

### 文件上传

```dart
final formData = FormData.fromMap({
  'file': await MultipartFile.fromFile(filePath),
  'description': 'Route GPX file',
});

final response = await apiClient.upload(
  ApiEndpoints.uploadGpx,
  formData,
  onSendProgress: (sent, total) {
    print('Upload progress: ${(sent / total * 100).toStringAsFixed(1)}%');
  },
);
```

### 文件下载

```dart
await apiClient.download(
  'https://example.com/route.gpx',
  '/path/to/save/route.gpx',
  onReceiveProgress: (received, total) {
    if (total != -1) {
      print('Download progress: ${(received / total * 100).toStringAsFixed(1)}%');
    }
  },
);
```

### 请求取消

```dart
final cancelToken = CancelToken();

// 发送请求
final future = apiClient.get(
  ApiEndpoints.routes,
  cancelToken: cancelToken,
);

// 取消请求
cancelToken.cancel('User cancelled');
```

## 🧪 测试

### Mock服务切换

```dart
// 切换到Mock服务
AppConfig.instance.updateUseMockServices(true);

// 切换到真实服务
AppConfig.instance.updateUseMockServices(false);
```

### 网络状态检查

```dart
final isNetworkAvailable = await NetworkManager.instance.checkNetworkStatus();
if (!isNetworkAvailable) {
  showSnackBar('网络不可用，请检查网络连接');
}
```

## 📊 监控和调试

### 获取网络配置信息

```dart
final networkInfo = NetworkManager.instance.getNetworkInfo();
print('Network Config: $networkInfo');
```

### 获取应用配置摘要

```dart
final configSummary = AppConfig.instance.getConfigSummary();
print('App Config: $configSummary');
```

## 🎯 最佳实践

1. **统一错误处理**: 在Repository层统一处理API异常
2. **合理使用重试**: 只对网络错误和服务器错误进行重试
3. **敏感信息保护**: 日志中自动隐藏认证信息
4. **环境隔离**: 不同环境使用不同的配置
5. **请求取消**: 长时间请求提供取消功能
6. **进度反馈**: 文件上传下载提供进度回调
7. **缓存策略**: 合理使用HTTP缓存和应用缓存

## 🔄 与ServiceLocator集成

在 `ServiceLocator` 中使用网络层：

```dart
// lib/service/service_manager.dart
void _registerRealServices() {
  // 使用真实的网络服务
  _routeService = RealRouteService(ApiClient.instance);
  // ... 其他服务
}

void initialize({bool useMock = false}) {
  // 初始化网络层
  NetworkManager.instance.initialize();

  if (useMock) {
    _registerMockServices();
  } else {
    _registerRealServices();
  }
}
```

这个网络层基础设施框架提供了完整的HTTP客户端管理、错误处理、拦截器和配置管理功能，可以满足大部分Flutter应用的网络需求。
