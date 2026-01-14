## Context

Walk 应用的服务层需要支持：
1. 开发阶段：部分服务使用 Mock，部分使用 Real（根据后端 API 就绪情况）
2. 生产阶段：全部使用 Real 服务
3. 性能优化：部分服务需要缓存（如天气、路线）

当前架构无法灵活满足这些需求，需要重构以支持：
- 细粒度的 Mock/Real 切换
- 可选的缓存层
- 清晰的职责分离

## Goals / Non-Goals

### Goals
- 支持每个服务独立配置 Mock/Real 模式
- 支持每个服务独立配置是否启用缓存
- 保持现有服务接口不变，向后兼容
- 架构清晰，便于后续扩展（如添加日志、监控装饰器）

### Non-Goals
- 不实现所有服务的 Real 版本（保持现状，按需实现）
- 不实现复杂的缓存策略（如 LRU、分布式缓存）
- 不实现运行时动态切换（仅支持启动时配置）

## Decisions

### Decision 1: 使用装饰器模式实现缓存层

**选择**：装饰器模式

**理由**：
- 遵循开闭原则，不修改现有服务实现
- 职责分离，缓存逻辑独立于业务逻辑
- 灵活组合，可按需添加/移除缓存层
- 便于测试，可单独测试缓存逻辑

**替代方案**：
1. Repository 模式 - 层级过多，过度设计
2. 在每个服务内部实现缓存 - 代码重复，难以统一管理

### Decision 2: 配置驱动的服务组装

**选择**：通过配置对象控制服务组装

```dart
final config = ServiceLayerConfig(
  defaultConfig: ServiceConfig(useMock: false, enableCache: false),
  services: {
    ServiceType.weather: ServiceConfig(useMock: false, enableCache: true, cacheTTL: Duration(minutes: 30)),
    ServiceType.trip: ServiceConfig(useMock: true, enableCache: false),
  },
);
```

**理由**：
- 配置集中管理，一目了然
- 便于不同环境使用不同配置
- 支持从外部配置文件或环境变量加载

### Decision 3: 缓存键策略

**选择**：方法名 + 参数哈希

```dart
String _cacheKey(String method, List<dynamic> args) {
  return '${runtimeType}_${method}_${args.hashCode}';
}
```

**理由**：
- 简单直接
- 自动避免不同服务/方法的键冲突
- 参数变化自动产生新键

### Decision 4: 缓存存储实现

**选择**：基于 Hive 的本地缓存

**理由**：
- 项目已使用 Hive
- 支持复杂对象序列化
- 支持 TTL（通过元数据实现）

## Architecture

### 目录结构

```
lib/service/
├── config/
│   ├── service_config.dart       # 服务配置模型
│   └── service_type.dart         # 服务类型枚举
├── cache/
│   ├── service_cache.dart        # 缓存接口
│   ├── hive_service_cache.dart   # Hive 缓存实现
│   └── cached_service_mixin.dart # 缓存装饰器 Mixin
├── cached/
│   ├── cached_weather_service.dart
│   ├── cached_route_service.dart
│   └── ...
├── impl/
│   ├── real_xxx_service.dart
│   └── ...
├── mock/
│   ├── mock_xxx_service.dart
│   └── ...
├── xxx_service.dart              # 服务接口
└── service_manager.dart          # 服务管理器
```

### 服务组装流程

```
1. 读取 ServiceLayerConfig
2. 遍历 ServiceType
3. 对于每个服务：
   a. 根据 useMock 选择 RealService 或 MockService
   b. 如果 enableCache 且有对应的 CachedService，包装一层
   c. 注册到 ServiceManager
4. 提供 getXxxService() 方法供外部获取
```

### 缓存装饰器示例

```dart
class CachedWeatherService implements WeatherService {
  final WeatherService _delegate;
  final ServiceCache _cache;
  final Duration _ttl;

  CachedWeatherService(this._delegate, this._cache, {Duration? ttl})
      : _ttl = ttl ?? const Duration(minutes: 30);

  @override
  Future<WeatherModel> getWeather(double latitude, double longitude) async {
    final key = 'getWeather_${latitude}_$longitude';
    
    // 尝试从缓存获取
    final cached = await _cache.get<WeatherModel>(key);
    if (cached != null) return cached;
    
    // 调用实际服务
    final result = await _delegate.getWeather(latitude, longitude);
    
    // 写入缓存
    await _cache.set(key, result, ttl: _ttl);
    
    return result;
  }
  
  // ... 其他方法类似
}
```

## Risks / Trade-offs

| 风险 | 影响 | 缓解措施 |
|------|------|----------|
| 装饰器导致调用链变长 | 轻微性能影响 | 缓存命中时反而更快；可通过 profiling 验证 |
| 缓存数据过期不一致 | 用户看到旧数据 | 提供手动刷新机制；合理设置 TTL |
| 配置复杂度增加 | 开发者需要理解更多配置 | 提供合理默认值；文档说明 |
| Mock 服务长期存在 | 代码冗余 | 当 Real 实现完成后，删除对应 Mock 和配置 |

## Migration Plan

### Phase 1: 基础架构
1. 新增服务配置模型 (`ServiceConfig`, `ServiceLayerConfig`, `ServiceType`)
2. 新增缓存接口和 Hive 实现
3. 重构 `ServiceManager` 支持配置驱动的服务组装

### Phase 2: 缓存装饰器
4. 为 `WeatherService` 实现缓存装饰器（作为示例）
5. 为 `RouteService` 实现缓存装饰器

### Phase 3: 全面应用
6. 根据需要为其他服务添加缓存装饰器
7. 逐步实现 Real 服务，替换 Mock

### Rollback
- 配置中将所有服务设为 `useMock: true, enableCache: false` 即可回退到当前行为

## Open Questions

1. ~~缓存是否需要支持离线模式（网络不可用时返回缓存数据）？~~ → 后续考虑
2. ~~是否需要缓存预热机制？~~ → 后续考虑
3. ~~是否需要缓存监控/统计？~~ → 后续考虑
