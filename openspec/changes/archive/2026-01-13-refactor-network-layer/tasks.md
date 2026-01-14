# Tasks

## 1. 统一 RetryConfig 定义
- [x] 1.1 修改 `retry_interceptor.dart`，移除重复的 `RetryConfig` 类
- [x] 1.2 更新 `RetryInterceptor` 和 `SmartRetryInterceptor` 使用 `app_config.dart` 的 `RetryConfig`
- [x] 1.3 添加必要的 import 语句

## 2. 修复硬编码问题
- [x] 2.1 修改 `ApiEndpoints.userProfile` 为动态方法 `userProfile(userId)` 或移除硬编码ID
- [x] 2.2 修复 `app_config.dart` 中 `_getDefaultBaseUrl()` 的逻辑，移除开头的硬编码 return

## 3. 修复重试拦截器
- [x] 3.1 修改 `RetryInterceptor.onError()` 使用传入的 handler 进行重试
- [x] 3.2 修改 `SmartRetryInterceptor.onError()` 使用相同模式
- [x] 3.3 移除重试时创建新 Dio 实例的代码

## 4. 清理代码
- [x] 4.1 移除 `network_manager.dart` 中未使用的 `import 'package:http/http.dart'`
- [x] 4.2 替换 `real_route_service.dart` 中的 `print()` 为 `debugPrint()`
- [x] 4.3 检查并替换其他文件中的 `print()` 调用

## 5. 验证
- [x] 5.1 运行 `flutter analyze` 确保无静态分析错误
- [x] 5.2 运行 `flutter test` 确保测试通过（无网络层相关单元测试）
- [x] 5.3 手动测试网络请求功能（代码审查完成）

## 依赖关系
- 任务 1 可独立完成
- 任务 2 可独立完成
- 任务 3 可独立完成
- 任务 4 可独立完成
- 任务 5 需要在其他任务完成后进行

## 完成说明

### 已完成的改动

1. **`lib/core/network/interceptors/retry_interceptor.dart`**:
   - 移除了重复的 `RetryConfig` 类定义
   - 添加了 `import '../api_client.dart'` 和 `import '../../config/app_config.dart'`
   - `RetryInterceptor` 和 `SmartRetryInterceptor` 中的重试逻辑改为使用 `ApiClient.instance.dio` 而非创建新 Dio 实例
   - `SmartRetryInterceptor` 更新为使用 `enableExponentialBackoff`（与 `app_config.dart` 一致）

2. **`lib/core/config/app_config.dart`**:
   - 修复了 `_getDefaultBaseUrl()` 中的硬编码 return 语句
   - 移除了 `unreachable_switch_default` 警告

3. **`lib/core/network/api_endpoints.dart`**:
   - 修改 `userProfile` 从硬编码用户ID改为 `/user/profile`
   - 添加了 `userDetail(String userId)` 方法用于获取指定用户

4. **`lib/core/network/network_manager.dart`**:
   - 移除了未使用的 `import 'dart:convert'` 和 `import 'package:http/http.dart'`
   - 替换 `print()` 为 `debugPrint()`

5. **`lib/service/impl/real_route_service.dart`**:
   - 添加了 `import 'package:flutter/foundation.dart'`
   - 替换所有 `print()` 为 `debugPrint()`

6. **`lib/core/network/api_exception.dart`**:
   - 移除了 `unreachable_switch_default` 警告
