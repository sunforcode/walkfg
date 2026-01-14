## Purpose

本变更完善服务层架构规范，引入服务类型枚举、配置模型、缓存装饰器和配置驱动的服务组装机制，提供灵活的服务管理能力。

## ADDED Requirements

### Requirement: Service Type Enumeration

系统 SHALL 提供服务类型枚举，用于标识和配置各个服务。

#### Scenario: 枚举包含所有服务类型
- **WHEN** 开发者需要配置服务
- **THEN** 可以使用 `ServiceType` 枚举引用任意服务
- **AND** 枚举值包括：route, user, trip, weather, guide, equipment, tripPlan, recommendation, searchHistory, trackFormat

---

### Requirement: Service Configuration Model

系统 SHALL 提供服务配置模型，支持为每个服务独立配置 Mock/Real 模式和缓存策略。

#### Scenario: 单个服务配置
- **GIVEN** 一个 `ServiceConfig` 实例
- **WHEN** 配置 `useMock: true, enableCache: false`
- **THEN** 该服务使用 Mock 实现且不启用缓存

#### Scenario: 服务配置支持缓存 TTL
- **GIVEN** 一个 `ServiceConfig` 实例
- **WHEN** 配置 `enableCache: true, cacheTTL: Duration(minutes: 30)`
- **THEN** 该服务的缓存数据在 30 分钟后过期

#### Scenario: 全局服务配置
- **GIVEN** 一个 `ServiceLayerConfig` 实例
- **WHEN** 配置 `defaultConfig` 和特定服务的覆盖配置
- **THEN** 未显式配置的服务使用 `defaultConfig`
- **AND** 显式配置的服务使用其特定配置

---

### Requirement: Service Cache Interface

系统 SHALL 提供统一的缓存接口，支持服务层的缓存需求。

#### Scenario: 缓存数据存取
- **WHEN** 调用 `cache.set('key', value, ttl: Duration(minutes: 10))`
- **THEN** 数据被缓存
- **AND** 在 10 分钟内调用 `cache.get('key')` 返回缓存的值
- **AND** 超过 10 分钟后调用 `cache.get('key')` 返回 null

#### Scenario: 缓存清除
- **WHEN** 调用 `cache.remove('key')`
- **THEN** 指定键的缓存被删除
- **WHEN** 调用 `cache.clear()`
- **THEN** 所有缓存被清除

---

### Requirement: Cached Service Decorator

系统 SHALL 支持通过装饰器模式为服务添加缓存能力。

#### Scenario: 缓存命中
- **GIVEN** `CachedWeatherService` 包装了 `RealWeatherService`
- **AND** 之前已调用过 `getWeather(30.0, 120.0)` 且缓存未过期
- **WHEN** 再次调用 `getWeather(30.0, 120.0)`
- **THEN** 直接返回缓存数据
- **AND** 不调用底层的 `RealWeatherService`

#### Scenario: 缓存未命中
- **GIVEN** `CachedWeatherService` 包装了 `RealWeatherService`
- **AND** 缓存中没有对应数据
- **WHEN** 调用 `getWeather(30.0, 120.0)`
- **THEN** 调用底层的 `RealWeatherService` 获取数据
- **AND** 将结果写入缓存
- **AND** 返回结果

#### Scenario: 装饰器透明性
- **GIVEN** 服务消费者通过接口获取服务
- **WHEN** ServiceManager 返回 `CachedWeatherService` 实例
- **THEN** 消费者无需感知缓存层的存在
- **AND** 可以像使用普通 `WeatherService` 一样使用

---

### Requirement: Configuration-Driven Service Assembly

`ServiceManager` SHALL 根据配置动态组装服务实例。

#### Scenario: Mock 服务组装
- **GIVEN** `ServiceLayerConfig` 中 `weather` 服务配置为 `useMock: true`
- **WHEN** `ServiceManager` 初始化
- **THEN** `getWeatherService()` 返回 `MockWeatherService` 实例

#### Scenario: Real 服务组装
- **GIVEN** `ServiceLayerConfig` 中 `route` 服务配置为 `useMock: false`
- **WHEN** `ServiceManager` 初始化
- **THEN** `getRouteService()` 返回 `RealRouteService` 实例

#### Scenario: 带缓存的服务组装
- **GIVEN** `ServiceLayerConfig` 中 `weather` 服务配置为 `useMock: false, enableCache: true`
- **WHEN** `ServiceManager` 初始化
- **THEN** `getWeatherService()` 返回 `CachedWeatherService` 实例
- **AND** `CachedWeatherService` 内部包装 `RealWeatherService`

#### Scenario: 无 Real 实现时的降级
- **GIVEN** `guide` 服务没有 Real 实现
- **AND** `ServiceLayerConfig` 中 `guide` 服务配置为 `useMock: false`
- **WHEN** `ServiceManager` 初始化
- **THEN** 自动降级使用 `MockGuideService`
- **AND** 输出警告日志

---

### Requirement: Backward Compatibility

重构 SHALL 保持向后兼容，现有代码无需修改即可正常工作。

#### Scenario: 现有服务获取方式兼容
- **GIVEN** 现有代码通过 `ServiceLocator.instance.getWeatherService()` 获取服务
- **WHEN** 重构完成后
- **THEN** 相同代码仍然正常工作
- **AND** 返回的服务实例行为一致

#### Scenario: 默认配置兼容当前行为
- **GIVEN** 未提供自定义 `ServiceLayerConfig`
- **WHEN** `ServiceManager` 使用默认配置初始化
- **THEN** 行为与重构前一致
