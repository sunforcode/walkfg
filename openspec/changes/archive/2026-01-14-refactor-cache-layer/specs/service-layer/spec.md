## ADDED Requirements

### Requirement: DataSource Strategy

ApiClient SHALL 支持通过 `dataSource` 参数指定数据来源策略：

| DataSource | 行为 |
|------------|------|
| mock | 返回本地 Mock JSON 数据 |
| cacheFirst | 先查 Cache，没有再请求网络，请求成功后写入 Cache |
| cacheOnly | 只从 Cache 读取，没有则抛出 CacheNotFoundException |
| networkFirst | 先请求网络，失败再查 Cache，请求成功后写入 Cache |
| networkOnly | 只请求网络，请求成功后写入 Cache |

#### Scenario: 使用 mock 策略
- **WHEN** 调用 `apiClient.get('/routes/123', dataSource: DataSource.mock)`
- **THEN** 返回 `assets/mock_data/routes/123.json` 的内容

#### Scenario: 使用 cacheFirst 策略且缓存命中
- **GIVEN** Cache 中存在 key 为 `/routes/123` 的数据
- **WHEN** 调用 `apiClient.get('/routes/123', dataSource: DataSource.cacheFirst)`
- **THEN** 返回缓存数据，不发起网络请求

#### Scenario: 使用 cacheFirst 策略且缓存未命中
- **GIVEN** Cache 中不存在 key 为 `/routes/123` 的数据
- **WHEN** 调用 `apiClient.get('/routes/123', dataSource: DataSource.cacheFirst)`
- **THEN** 发起网络请求，返回响应数据，并将数据写入 Cache

#### Scenario: 使用 cacheOnly 策略且缓存未命中
- **GIVEN** Cache 中不存在 key 为 `/routes/456` 的数据
- **WHEN** 调用 `apiClient.get('/routes/456', dataSource: DataSource.cacheOnly)`
- **THEN** 抛出 `CacheNotFoundException` 异常

#### Scenario: 使用 networkFirst 策略且网络失败
- **GIVEN** Cache 中存在 key 为 `/routes/123` 的数据
- **AND** 网络请求失败
- **WHEN** 调用 `apiClient.get('/routes/123', dataSource: DataSource.networkFirst)`
- **THEN** 返回缓存数据

#### Scenario: 使用 networkOnly 策略强制刷新
- **GIVEN** Cache 中存在旧数据
- **WHEN** 调用 `apiClient.get('/routes/123', dataSource: DataSource.networkOnly)`
- **THEN** 发起网络请求，返回最新数据，并更新 Cache

---

### Requirement: Cache Key Generation

缓存 key SHALL 基于 URL 路径和查询参数生成，参数按字母排序。

#### Scenario: 无参数的请求
- **WHEN** 请求路径为 `/routes/123`，无查询参数
- **THEN** 缓存 key 为 `/routes/123`

#### Scenario: 有参数的请求
- **WHEN** 请求路径为 `/routes`，查询参数为 `{limit: 10, offset: 0}`
- **THEN** 缓存 key 为 `/routes?limit=10&offset=0`（参数按字母排序）

---

### Requirement: Global Default DataSource

应用 SHALL 支持配置全局默认 DataSource，每个请求可覆盖。

#### Scenario: 使用全局默认策略
- **GIVEN** `AppConfig.defaultDataSource` 设置为 `DataSource.mock`
- **WHEN** 调用 `apiClient.get('/routes/123')` 不指定 dataSource
- **THEN** 使用 `DataSource.mock` 策略

#### Scenario: 覆盖全局默认策略
- **GIVEN** `AppConfig.defaultDataSource` 设置为 `DataSource.mock`
- **WHEN** 调用 `apiClient.get('/routes/123', dataSource: DataSource.networkOnly)`
- **THEN** 使用 `DataSource.networkOnly` 策略

---

### Requirement: Mock Data Provider

Mock 数据 SHALL 按 API 路径组织在 `assets/mock_data/` 目录下。

#### Scenario: 加载 Mock 数据
- **GIVEN** 存在文件 `assets/mock_data/routes/list.json`
- **WHEN** 请求 `/routes` 使用 `DataSource.mock`
- **THEN** 返回该 JSON 文件的内容

---

## REMOVED Requirements

### Requirement: MockService Implementation

**Reason**: Mock 逻辑移至 ApiClient 层，不再需要单独的 MockService 类。

**Migration**: 原 MockService 的逻辑由 `DataSource.mock` + `MockDataProvider` 替代。

删除的文件：
- `lib/service/mock/mock_route_service.dart`
- `lib/service/mock/mock_user_service.dart`
- `lib/service/mock/mock_weather_service.dart`
- （及其他 mock 目录下的文件）

---

### Requirement: Cached Service Decorator

**Reason**: 缓存逻辑移至 ApiClient 层，不再需要装饰器模式。

**Migration**: 原 `enableCache: true` 配置改为 `dataSource: DataSource.cacheFirst`。

删除的文件：
- `lib/service/cached/cached_route_service.dart`
- `lib/service/cached/cached_weather_service.dart`
- `lib/service/cache/cached_service_mixin.dart`

---

### Requirement: Service Mode Configuration

**Reason**: `ServiceConfig.useMock` 和 `ServiceConfig.enableCache` 被 `DataSource` 枚举替代。

**Migration**: 
- `useMock: true` → `defaultDataSource: DataSource.mock`
- `enableCache: true` → `defaultDataSource: DataSource.cacheFirst`
