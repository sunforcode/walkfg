# Change: 服务层架构重构 - 支持细粒度 Mock 切换与可选缓存

## Why

当前服务层存在以下问题：
1. **全局 Mock 切换**：只能通过 `AppConfig.useMockServices` 全局控制，无法针对单个服务灵活切换
2. **Mock 与 Real 混用**：`_registerMockServices()` 中部分服务实际使用 Real 实现，逻辑混乱
3. **缺乏缓存机制**：服务层没有统一的缓存策略，后续添加困难
4. **架构不清晰**：ServiceManager 职责不明确，难以扩展

## What Changes

### 1. 引入装饰器模式重构服务层架构

```
┌──────────────────────────────────────────────────┐
│                 ServiceManager                    │
│  职责：服务组装、配置管理、实例生命周期管理          │
└──────────────────────────────────────────────────┘
                        │
                        ▼
┌──────────────────────────────────────────────────┐
│              CachedXxxService (可选)              │
│  职责：缓存装饰器，透明地为服务添加缓存能力          │
└──────────────────────────────────────────────────┘
                        │
                        ▼
┌──────────────────────────────────────────────────┐
│         RealXxxService / MockXxxService          │
│  职责：实际的业务实现                              │
└──────────────────────────────────────────────────┘
```

### 2. 新增服务配置模型

```dart
/// 单个服务的配置
class ServiceConfig {
  final bool useMock;       // 是否使用 Mock
  final bool enableCache;   // 是否启用缓存
  final Duration? cacheTTL; // 缓存过期时间（可选）
}

/// 全局服务配置
class ServiceLayerConfig {
  final Map<ServiceType, ServiceConfig> services;
  final ServiceConfig defaultConfig;
}
```

### 3. 服务类型枚举

```dart
enum ServiceType {
  route,
  user,
  trip,
  weather,
  guide,
  equipment,
  tripPlan,
  recommendation,
  searchHistory,
  trackFormat,
}
```

### 4. 缓存接口抽象

```dart
abstract class ServiceCache {
  Future<T?> get<T>(String key);
  Future<void> set<T>(String key, T value, {Duration? ttl});
  Future<void> remove(String key);
  Future<void> clear();
}
```

## Impact

- **Affected specs**: 无现有 spec 受影响（新增 capability）
- **Affected code**:
  - `lib/service/service_manager.dart` - 重构服务注册和组装逻辑
  - `lib/core/config/app_config.dart` - 新增服务层配置
  - `lib/service/` - 新增缓存装饰器基类和具体实现
- **Breaking changes**: 无，保持现有 API 兼容
