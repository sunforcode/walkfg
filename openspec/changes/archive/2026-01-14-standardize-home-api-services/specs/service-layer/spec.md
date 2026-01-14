# service-layer Specification Delta

## MODIFIED Requirements

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

## ADDED Requirements

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
