# service-layer Specification

## Purpose

定义 Walk 应用的服务层架构，包括数据来源策略、缓存机制和 Service 调用方式，实现业务逻辑与网络层的解耦和数据的统一管理。
## Requirements
### Requirement: DataSource 策略枚举

系统 SHALL 提供 `DataSource` 枚举，用于控制数据获取策略。

#### Scenario: 枚举值定义
- **WHEN** 开发者需要指定数据来源
- **THEN** 可以使用以下策略：
  - `cacheFirst`: 优先 Cache，没有再请求网络
  - `cacheOnly`: 只从 Cache 读取（离线模式）
  - `networkFirst`: 优先网络，失败再用 Cache
  - `networkOnly`: 只请求网络（强制刷新）

---

### Requirement: ApiClient 缓存集成

`ApiClient` SHALL 集成缓存逻辑，支持基于 `DataSource` 策略的数据获取。

#### Scenario: cacheFirst 策略
- **GIVEN** 调用 `getData()` 方法并指定 `dataSource: DataSource.cacheFirst`
- **WHEN** 缓存中存在未过期的数据
- **THEN** 直接返回缓存数据，不请求网络

#### Scenario: cacheFirst 缓存未命中
- **GIVEN** 调用 `getData()` 方法并指定 `dataSource: DataSource.cacheFirst`
- **WHEN** 缓存中没有对应数据
- **THEN** 请求网络获取数据
- **AND** 将结果写入缓存

#### Scenario: networkOnly 策略
- **GIVEN** 调用 `getData()` 方法并指定 `dataSource: DataSource.networkOnly`
- **WHEN** 执行请求
- **THEN** 强制请求网络，忽略缓存
- **AND** 请求成功后写入缓存

#### Scenario: 缓存键生成
- **GIVEN** 请求路径为 `/api/routes` 参数为 `{limit: 10, offset: 0}`
- **WHEN** 生成缓存键
- **THEN** 缓存键为 `/api/routes?limit=10&offset=0`（参数按字母序排列）

---

### Requirement: Service Cache 接口

系统 SHALL 提供统一的缓存接口 `ServiceCache`。

#### Scenario: 缓存数据存取
- **WHEN** 调用 `cache.set('key', value, ttl: Duration(minutes: 10))`
- **THEN** 数据被缓存
- **AND** 在 10 分钟内调用 `cache.get('key')` 返回缓存的值
- **AND** 超过 10 分钟后调用 `cache.get('key')` 返回 null

#### Scenario: 缓存清除
- **WHEN** 调用 `cache.remove('key')`
- **THEN** 指定键的缓存被删除

---

### Requirement: Service 静态方法模式

Service 层 SHALL 使用静态方法模式，无需实例化。

#### Scenario: Service 调用方式
- **WHEN** 业务代码需要获取路线数据
- **THEN** 直接调用 `RouteService.getRouteById(id)` 静态方法
- **AND** 无需获取 Service 实例

#### Scenario: Service 禁止实例化
- **GIVEN** Service 类定义了私有构造函数 `ServiceName._()`
- **WHEN** 尝试实例化 Service
- **THEN** 编译错误

---

### Requirement: 写操作缓存失效

POST/PUT/DELETE 请求 SHALL 支持缓存失效机制。

#### Scenario: 写操作后失效缓存
- **GIVEN** 调用 `post()` 方法并指定 `invalidateCacheKeys: ['/api/routes']`
- **WHEN** 请求成功
- **THEN** 指定的缓存键被删除

### Requirement: 并行数据请求

业务层 SHALL 支持并行发起多个独立的 Service 请求以提升性能。

#### Scenario: 多个独立请求并行执行
- **GIVEN** Home 页面需要加载用户天气、行程、路线、攻略四种数据
- **WHEN** 使用 `Future.wait` 同时发起四个独立的 Service 请求
- **THEN** 所有请求并行执行
- **AND** 总加载时间等于最慢的单个请求时间
- **AND** 不等于所有请求时间之和

#### Scenario: 单个请求失败不影响其他请求
- **GIVEN** 并行发起多个请求
- **WHEN** 其中一个请求失败
- **THEN** 该请求返回默认值（空列表或空对象）
- **AND** 其他请求正常完成
- **AND** 错误信息被记录到日志

---

### Requirement: Service 层统一错误处理

Service 层方法 SHALL 捕获所有异常并返回合理的默认值，而非向上抛出异常。

#### Scenario: Service 方法内部错误处理
- **GIVEN** Service 方法调用失败（网络错误、解析错误等）
- **WHEN** 业务代码调用该 Service 方法
- **THEN** 方法返回合理的默认值（如空列表 `[]`）
- **AND** 不抛出异常到业务层
- **AND** 错误详情记录到日志中

#### Scenario: 业务代码无需处理 Service 异常
- **GIVEN** 业务代码调用 `TripService.getPlannedTrips()`
- **WHEN** Service 内部发生任何错误
- **THEN** 业务代码无需 try-catch
- **AND** 获得空列表或默认数据结构

---

### Requirement: 业务层数据源无感知

业务层代码 SHALL 对数据来源（Mock 或 API）保持无感知，仅调用 Service 方法获取数据。

#### Scenario: 业务代码统一调用方式
- **GIVEN** Service 层可能使用 Mock 数据或真实 API
- **WHEN** 业务代码需要获取数据
- **THEN** 仅调用 `ServiceName.method()` 即可
- **AND** 无需判断或处理数据来源
- **AND** 无需模拟网络延迟或处理 Mock 逻辑

#### Scenario: Service 层封装数据来源
- **GIVEN** TripService 内部使用本地 JSON Mock 数据
- **WHEN** 业务代码调用 `TripService.getPlannedTrips()`
- **THEN** Service 内部处理数据加载和延迟模拟
- **AND** 业务代码获得统一格式的返回数据

