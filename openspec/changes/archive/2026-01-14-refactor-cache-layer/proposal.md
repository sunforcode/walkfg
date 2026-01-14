# Change: 统一数据来源策略 - ApiClient 层集成 Cache/Network

## Why

当前架构存在三套 Service 实现（Mock/Cache/Real），导致：

1. **代码重复**：每种数据来源都要写一套 Service
2. **配置复杂**：ServiceManager 需要根据配置组装不同实现
3. **职责分散**：缓存逻辑在装饰器，Mock 逻辑在 MockService
4. **Mock 是临时的**：开发完成后 Mock 代码应该删除

## What Changes

### 核心思路

**将数据来源的选择下沉到 ApiClient 层**，通过参数控制数据从哪里来：

```dart
// Service 中固定策略
class RouteService {
  static final instance = RouteService._();
  
  Future<RouteModel> getRouteById(String id) async {
    return ApiClient.instance.get<RouteModel>(
      '/routes/$id',
      dataSource: DataSource.cacheFirst,  // 固定策略
      fromJson: RouteModel.fromJson,
    );
  }
}
```

### DataSource 枚举

```dart
enum DataSource {
  cacheFirst,   // 优先 Cache，没有再请求网络
  cacheOnly,    // 只从 Cache 读取（离线模式）
  networkFirst, // 优先网络，失败再用 Cache
  networkOnly,  // 只请求网络（强制刷新）
}
```

### 行为说明

| DataSource | 读取顺序 | 写入 Cache | 使用场景 |
|------------|----------|------------|----------|
| cacheFirst | Cache → Network | ✅ | 常规使用 |
| cacheOnly | Cache | ❌ | 离线模式 |
| networkFirst | Network → Cache | ✅ | 需要最新数据 |
| networkOnly | Network | ✅ | 强制刷新 |

### 具体改动

1. **新增 DataSource 枚举**
   - `lib/core/network/data_source.dart`

2. **改造 ApiClient**
   - 增加 `dataSource` 参数
   - 根据策略选择数据来源
   - 网络请求成功后自动写入 Cache

3. **简化 Service 层**
   - Service 自己管理单例（`RouteService.instance`）
   - 删除 MockService 目录（`lib/service/mock/`）
   - 删除 CachedService 目录（`lib/service/cached/`）
   - 只保留一套 Service 实现

4. **删除 ServiceManager**
   - 不再需要集中管理和组装
   - 删除 `lib/service/service_manager.dart`

5. **删除配置相关**
   - 删除 `lib/service/config/` 整个目录
   - 不再需要 `ServiceConfig`、`ServiceType`

## Impact

- **Affected code**:
  - `lib/core/network/api_client.dart` - 核心改造
  - `lib/core/network/data_source.dart` - 新增
  - `lib/service/mock/` - 删除整个目录
  - `lib/service/cached/` - 删除整个目录
  - `lib/service/config/` - 删除整个目录
  - `lib/service/service_manager.dart` - 删除
  - `lib/service/impl/` - 移动到 `lib/service/` 并简化
  - `lib/main.dart` - 移除 ServiceLocator 初始化

## Migration

1. **BREAKING**：移除所有 MockService、CachedService、ServiceManager
2. 原 `ServiceLocator.instance.getRouteService()` 改为 `RouteService.instance`
3. Mock 代码开发完成后删除，不进入生产
