# Change: 重构网络请求层

## Why
现有网络请求层存在以下问题需要修复：

1. **代码重复**: `RetryConfig` 在 `app_config.dart` 和 `retry_interceptor.dart` 中重复定义
2. **硬编码问题**: `userProfile` 端点硬编码了用户ID，`_getDefaultBaseUrl()` 返回值被覆盖
3. **依赖注入不一致**: 部分服务使用单例，部分通过构造函数注入
4. **重试拦截器缺陷**: 重试时创建新 Dio 实例会丢失拦截器配置
5. **未使用的导入**: `network_manager.dart` 中有未使用的 `http` 包导入
6. **调试输出不一致**: 混用 `print()` 和 `debugPrint()`

## What Changes

### 1. 统一 RetryConfig 定义
- **BREAKING**: 移除 `retry_interceptor.dart` 中的 `RetryConfig` 类
- 统一使用 `app_config.dart` 中的 `RetryConfig`

### 2. 修复硬编码问题
- 移除 `ApiEndpoints.userProfile` 中的硬编码用户ID
- 修复 `_getDefaultBaseUrl()` 中被覆盖的 switch 语句

### 3. 修复重试拦截器
- 重试时复用原 Dio 实例而非创建新实例
- 保持拦截器链完整

### 4. 清理代码
- 移除未使用的 `import 'package:http/http.dart'`
- 统一使用 `debugPrint()` 替代 `print()`

### 5. 统一依赖注入模式
- 所有服务通过构造函数注入 `ApiClient`
- 移除服务内部对 `ApiClient.instance` 的直接依赖

## Impact
- Affected specs: 
  - `network-client`
  - `network-interceptors`
  - `api-endpoints`
- Affected code:
  - `lib/core/network/api_client.dart`
  - `lib/core/network/network_manager.dart`
  - `lib/core/network/api_endpoints.dart`
  - `lib/core/network/interceptors/retry_interceptor.dart`
  - `lib/core/config/app_config.dart`
  - `lib/service/impl/real_route_service.dart`
  - `lib/service/impl/real_user_service.dart`
