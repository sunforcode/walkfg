# Design: 统一数据来源策略

## Context

Walk 应用需要支持多种数据来源：
- **Cache**：离线模式或加速加载
- **Network**：从服务器获取最新数据

当前实现将这些策略分散在不同的 Service 实现中（MockService、CachedService、RealService），导致代码冗余和维护困难。

**关于 Mock**：Mock 是开发阶段的临时代码，开发完成后应该删除，不进入生产。因此新架构不包含 Mock 支持。

## Goals / Non-Goals

### Goals
- 统一数据来源策略到 ApiClient 层
- 每个请求可以灵活指定数据来源（Cache/Network）
- 自动缓存网络响应
- 删除 ServiceManager，Service 使用静态方法

### Non-Goals
- 不实现复杂的缓存失效策略（如依赖关系）
- 不实现缓存预加载
- 不保留 Mock 支持（Mock 代码开发完删除）

## Decisions

### Decision 1: DataSource 枚举设计

```dart
enum DataSource {
  /// 优先从 Cache 读取，没有则请求网络
  /// 网络请求成功后写入 Cache
  cacheFirst,
  
  /// 只从 Cache 读取，没有则抛出异常
  cacheOnly,
  
  /// 优先请求网络，失败则从 Cache 读取
  /// 网络请求成功后写入 Cache
  networkFirst,
  
  /// 只请求网络，忽略 Cache
  /// 请求成功后写入 Cache
  networkOnly,
}
```

### Decision 2: ApiClient 改造

```dart
class ApiClient {
  final ServiceCache _cache;
  
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    DataSource dataSource = DataSource.cacheFirst,
    Duration? cacheTTL,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    final cacheKey = _generateCacheKey(path, queryParameters);
    
    switch (dataSource) {
      case DataSource.cacheFirst:
        final cached = await _cache.get<Map<String, dynamic>>(cacheKey);
        if (cached != null) {
          return fromJson!(cached);
        }
        return _fetchAndCache<T>(path, queryParameters, cacheKey, cacheTTL, fromJson);
        
      case DataSource.cacheOnly:
        final cached = await _cache.get<Map<String, dynamic>>(cacheKey);
        if (cached == null) {
          throw CacheNotFoundException(cacheKey);
        }
        return fromJson!(cached);
        
      case DataSource.networkFirst:
        try {
          return await _fetchAndCache<T>(path, queryParameters, cacheKey, cacheTTL, fromJson);
        } catch (e) {
          final cached = await _cache.get<Map<String, dynamic>>(cacheKey);
          if (cached != null) {
            return fromJson!(cached);
          }
          rethrow;
        }
        
      case DataSource.networkOnly:
        return _fetchAndCache<T>(path, queryParameters, cacheKey, cacheTTL, fromJson);
    }
  }
  
  Future<T> _fetchAndCache<T>(...) async {
    final response = await _dio.get(path, queryParameters: queryParameters);
    await _cache.set(cacheKey, response.data, ttl: cacheTTL);
    return fromJson!(response.data);
  }
}
```

### Decision 3: Cache Key 生成

```dart
String _generateCacheKey(String path, Map<String, dynamic>? params) {
  if (params == null || params.isEmpty) {
    return path;
  }
  final sortedParams = SplayTreeMap<String, dynamic>.from(params);
  final paramString = sortedParams.entries
      .map((e) => '${e.key}=${e.value}')
      .join('&');
  return '$path?$paramString';
}
```

示例：
- `/api/routes/123` → `/api/routes/123`
- `/api/routes?limit=10&offset=0` → `/api/routes?limit=10&offset=0`

### Decision 4: Service 层简化 - 静态方法

Service 使用静态方法，无需实例化：

```dart
class RouteService {
  // 禁止实例化
  RouteService._();
  
  static Future<RouteModel> getRouteById(String id) {
    return ApiClient.instance.get<RouteModel>(
      '/api/routes/$id',
      dataSource: DataSource.cacheFirst,
      cacheTTL: Duration(hours: 1),
      fromJson: RouteModel.fromJson,
    );
  }
  
  /// 强制刷新
  static Future<RouteModel> getRouteByIdForceRefresh(String id) {
    return ApiClient.instance.get<RouteModel>(
      '/api/routes/$id',
      dataSource: DataSource.networkOnly,
      fromJson: RouteModel.fromJson,
    );
  }
}

// 使用
final route = await RouteService.getRouteById('123');
```

### Decision 5: 删除 ServiceManager

ServiceManager 不再需要，因为：
- Service 使用静态方法，无状态
- 不需要运行时切换 Mock/Real
- 不需要配置驱动的服务组装

main.dart 简化为：

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化 ApiClient（包含 Cache）
  await ApiClient.instance.initialize();
  
  runApp(const App());
}
```

## Risks / Trade-offs

| 风险 | 缓解措施 |
|------|----------|
| Mock 数据与 API 结构不一致 | 使用相同的 Model 类，编译时即可发现问题 |
| 大量删除现有代码 | 分阶段实施，先新增再删除 |
| fromJson 参数增加调用复杂度 | 可以在 Service 层封装，业务代码无感知 |

## Migration Plan

1. **Phase 1**：新增 `DataSource` 枚举和 `MockDataProvider`
2. **Phase 2**：改造 `ApiClient`，支持 `dataSource` 参数
3. **Phase 3**：改造 Service 层使用新 API
4. **Phase 4**：删除 `lib/service/mock/` 目录
5. **Phase 5**：删除 `lib/service/cached/` 目录
6. **Phase 6**：简化 `ServiceManager` 和 `ServiceConfig`

## Open Questions

1. **Mock 数据的动态参数处理**：如 `/routes/{id}` 怎么匹配？
   - 建议：使用路径模板匹配或统一返回列表数据

2. **POST/PUT/DELETE 请求的缓存处理**：
   - 建议：写操作不走缓存，但成功后可以失效相关缓存
