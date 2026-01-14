## 1. 基础架构

- [x] 1.1 创建服务类型枚举 `ServiceType` (`lib/service/config/service_type.dart`)
- [x] 1.2 创建服务配置模型 `ServiceConfig` 和 `ServiceLayerConfig` (`lib/service/config/service_config.dart`)
- [x] 1.3 创建缓存接口 `ServiceCache` (`lib/service/cache/service_cache.dart`)
- [x] 1.4 实现 Hive 缓存 `HiveServiceCache` (`lib/service/cache/hive_service_cache.dart`)
- [x] 1.5 重构 `ServiceManager`，支持配置驱动的服务组装

## 2. 缓存装饰器实现

- [x] 2.1 创建缓存装饰器基类/Mixin (`lib/service/cache/cached_service_mixin.dart`)
- [x] 2.2 实现 `CachedWeatherService` (`lib/service/cached/cached_weather_service.dart`)
- [x] 2.3 实现 `CachedRouteService` (`lib/service/cached/cached_route_service.dart`)

## 3. 配置集成

- [x] 3.1 在 `AppConfig` 中集成 `ServiceLayerConfig`
- [x] 3.2 提供开发环境默认配置（部分 Mock，部分 Real）
- [x] 3.3 提供生产环境默认配置（全部 Real + 缓存）

## 4. 验证

- [x] 4.1 验证现有功能不受影响
- [x] 4.2 验证 Mock/Real 切换正常工作
- [x] 4.3 验证缓存功能正常工作
