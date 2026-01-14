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

Service 层 SHALL 使用静态方法模式,无需实例化,并统一使用 `ApiClient` 进行数据请求。

#### Scenario: Service 调用方式
- **WHEN** 业务代码需要获取路线数据
- **THEN** 直接调用 `RouteService.getRouteById(id)` 静态方法
- **AND** 无需获取 Service 实例

#### Scenario: Service 禁止实例化
- **GIVEN** Service 类定义了私有构造函数 `ServiceName._()`
- **WHEN** 尝试实例化 Service
- **THEN** 编译错误

#### Scenario: Service 使用 ApiClient 请求数据
- **GIVEN** Service 需要从网络或缓存获取数据
- **WHEN** 调用 Service 静态方法
- **THEN** Service 内部通过 `ApiClient.instance.get()` 发起请求
- **AND** 指定合适的 `DataSource` 策略
- **AND** 使用 `ApiEndpoints` 中定义的标准端点

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

### Requirement: 首页服务统一规范

首页使用的 `TripService`、`WeatherService`、`GuideService` SHALL:
- 使用静态方法模式,禁止实例化
- 通过 `ApiClient.instance.get()` 进行所有网络请求
- 使用 `ApiEndpoints` 类管理 API 端点路径
- 统一使用 `DataSource` 策略控制缓存行为
- 实现统一的响应解析和错误处理逻辑

#### Scenario: TripService 使用 ApiClient
- **WHEN** 调用 `TripService.getUserTrips()`
- **THEN** 内部通过 `ApiClient.instance.get(ApiEndpoints.trips)` 请求数据
- **AND** 使用 `DataSource.cacheFirst` 策略
- **AND** 失败时返回空列表 `[]`

#### Scenario: WeatherService 使用 ApiClient
- **WHEN** 调用 `WeatherService.getWeather(lat, lng)`
- **THEN** 内部通过 `ApiClient.instance.get(ApiEndpoints.weather)` 请求数据
- **AND** 使用 `DataSource.cacheFirst` 策略
- **AND** 失败时返回默认天气对象或空数据

#### Scenario: GuideService 使用 ApiClient
- **WHEN** 调用 `GuideService.getGuides()`
- **THEN** 内部通过 `ApiClient.instance.get(ApiEndpoints.guides)` 请求数据
- **AND** 使用 `DataSource.cacheFirst` 策略
- **AND** 失败时返回空列表 `[]`

---

### Requirement: Service 层统一响应解析

Service 层 SHALL 统一处理 API 响应格式,包括状态码检查和数据提取。

#### Scenario: 检查响应状态码
- **GIVEN** ApiClient 返回响应数据
- **WHEN** Service 解析响应
- **THEN** 首先检查 `responseData['code']` 是否为 200
- **AND** 非 200 时抛出 `BusinessException` 包含错误信息

#### Scenario: 提取响应数据
- **GIVEN** 响应状态码为 200
- **WHEN** Service 提取数据
- **THEN** 从 `responseData['data']` 中获取实际数据
- **AND** 对于列表接口,从 `data['content']` 获取列表

#### Scenario: 使用通用解析方法
- **GIVEN** Service 有多个返回相同类型列表的方法
- **WHEN** 需要解析响应
- **THEN** 使用私有静态方法 `_parseXxxResponse()` 统一处理
- **AND** 减少重复代码

---

### Requirement: Service 层禁止直接加载本地文件

Service 层 SHALL 不直接使用 `rootBundle.loadString()` 加载本地 JSON 文件。

#### Scenario: 禁止使用 rootBundle
- **GIVEN** Service 需要获取数据
- **WHEN** 实现 Service 方法
- **THEN** 不使用 `rootBundle.loadString()` 
- **AND** 不使用 `json.decode()` 手动解析
- **AND** 通过 `ApiClient` 统一获取数据

#### Scenario: 移除文件加载辅助方法
- **GIVEN** Service 中存在 `_loadJsonData()` 等辅助方法
- **WHEN** 改造为使用 ApiClient
- **THEN** 删除 `_loadJsonData()` 方法
- **AND** 移除 `dart:convert` 和 `flutter/services.dart` 导入
- **AND** 添加 `ApiClient` 和 `ApiEndpoints` 导入

---

### Requirement: Service 层统一缓存策略

Service 层 SHALL 为不同场景的请求选择合适的 `DataSource` 策略。

#### Scenario: 首页常规数据使用 cacheFirst
- **GIVEN** 首页需要加载常规数据(行程、天气、攻略等)
- **WHEN** Service 发起请求
- **THEN** 使用 `DataSource.cacheFirst` 策略
- **AND** 优先返回缓存数据,提升加载速度

#### Scenario: 详情页数据使用 cacheFirst
- **GIVEN** 用户查看详情页
- **WHEN** Service 请求详情数据
- **THEN** 使用 `DataSource.cacheFirst` 策略
- **AND** 避免重复请求相同数据

#### Scenario: 用户主动刷新使用 networkFirst
- **GIVEN** 用户下拉刷新
- **WHEN** Service 响应刷新操作
- **THEN** 可选择使用 `DataSource.networkFirst` 或 `networkOnly`
- **AND** 确保获取最新数据

