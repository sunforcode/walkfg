# Design: 网络层重构

## Context
Walk 应用的网络请求层已经具备基本功能，但在代码质量和架构一致性方面存在问题。本次重构旨在提高代码质量，统一架构模式，修复潜在的运行时问题。

## Goals / Non-Goals

### Goals
- 消除重复代码定义
- 修复硬编码导致的维护性问题
- 修复重试拦截器的运行时缺陷
- 统一代码风格和调试输出

### Non-Goals
- 不改变现有 API 接口签名（除必要的修复外）
- 不重构整体架构
- 不添加新功能

## Decisions

### Decision 1: RetryConfig 统一放置在 app_config.dart

**理由**：
- `RetryConfig` 是应用级配置，逻辑上属于 `app_config.dart`
- 避免循环依赖：拦截器依赖配置，而非配置依赖拦截器
- 集中管理便于环境切换

**替代方案**：
- 创建独立的 `retry_config.dart` 文件 → 增加文件数量，收益不大
- 保留两处定义 → 维护困难，容易不同步

### Decision 2: 重试使用 RequestInterceptorHandler 重发

**理由**：
- 创建新 Dio 实例会丢失原有的拦截器配置
- 使用 `handler.resolve()` 可以在拦截器链内完成重试
- 符合 Dio 拦截器的设计模式

**实现方式**：
```dart
// 修改前：创建新 Dio 实例
final dio = Dio();
final response = await dio.fetch(err.requestOptions);
handler.resolve(response);

// 修改后：使用原 Dio 实例
final response = await ApiClient.instance.dio.fetch(err.requestOptions);
handler.resolve(response);
```

### Decision 3: userProfile 端点保持当前用户语义

**理由**：
- `/user/profile` 应该返回当前登录用户的信息
- 用户ID通过 Token 在服务端识别，无需在路径中传递
- 查看其他用户信息应使用 `/users/{userId}` 端点

**修复方式**：
- 移除硬编码的用户ID
- 保持 `userProfile` 为常量：`$apiPrefix/user/profile`

## Risks / Trade-offs

### Risk 1: 重试拦截器修改可能影响现有行为
- **影响**: 中等
- **缓解**: 添加单元测试覆盖重试场景

### Risk 2: 移除 RetryConfig 重复定义可能导致编译错误
- **影响**: 低
- **缓解**: IDE 会立即提示，修复简单

## Migration Plan

1. **Phase 1**: 代码清理（任务 1, 4）
   - 低风险改动
   - 可独立部署

2. **Phase 2**: 硬编码修复（任务 2）
   - 需要确认后端 API 兼容性
   - 可能需要协调后端调整

3. **Phase 3**: 重试拦截器修复（任务 3）
   - 需要充分测试
   - 建议在测试环境验证

4. **Rollback**: 如发现问题，可逐个任务回滚

## Open Questions

1. ~~userProfile 端点是否需要改为动态方法？~~ 
   决定：保持常量，通过 Token 识别用户

2. 是否需要添加单元测试？
   建议：为重试拦截器添加测试
