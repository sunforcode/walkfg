# Design: 规范首页服务层 - 统一使用 ApiClient

## Context

Walk 应用的服务层分为两类实现方式:
1. **已规范的服务**: `UserService`、`RouteService` 使用 `ApiClient` + `DataSource` 策略
2. **未规范的服务**: `TripService`、`WeatherService`、`GuideService` 直接加载本地 JSON

项目早期为了快速原型验证,首页服务直接使用 `rootBundle.loadString()` 加载 Mock 数据,但随着项目成熟,这种方式已不再适用。

## Goals / Non-Goals

### Goals
- 将首页三个服务改造为使用 `ApiClient.instance.get()` 统一调用方式,移除直接加载本地 JSON 的代码
- 保持 Service 静态方法签名不变,业务层无需改动
- 支持 `DataSource` 缓存策略,提升性能和离线体验
- 为后续接入真实 API 做好准备

### Non-Goals
- **不**修改 ApiClient 核心逻辑
- **不**改变 Service 的公开接口签名
- **不**创建新的 Mock 拦截器(可后续添加)
- **不**修改首页 UI 调用代码

## Decisions

### 1. 使用 ApiClient.get() 替代 rootBundle.loadString()

**原因**:
- ApiClient 提供统一的错误处理、日志记录和缓存机制
- 业务层对数据来源无感知,符合依赖倒置原则
- 为后续接入真实 API 提供平滑过渡路径

**实现方式**:
```dart
// 旧方式
static Future<List<TripModel>> getUserTrips() async {
  final jsonString = await rootBundle.loadString('assets/mock_data/trips.json');
  final data = json.decode(jsonString);
  return data.map<TripModel>((json) => TripModel.fromJson(json)).toList();
}

// 新方式
static Future<List<TripModel>> getUserTrips() async {
  try {
    final response = await ApiClient.instance.get(
      ApiEndpoints.trips,
      dataSource: DataSource.cacheFirst,
    );
    return _parseTripsResponse(response.data);
  } catch (e) {
    debugPrint('TripService: 获取行程列表失败: $e');
    return []; // 返回默认值
  }
}
```

### 2. 默认使用 cacheFirst 策略

**原因**:
- 首页数据变更频率不高,缓存优先可提升加载速度
- 离线场景下自动降级到缓存数据
- 减少不必要的网络请求

**替代方案**:
- `networkFirst`: 首页需要最新数据(但会牺牲加载速度)
- `networkOnly`: 强制刷新(不适合首页常规加载)

**选择理由**: 首页加载体验优先,缓存优先策略最佳

### 3. 统一错误处理 - 返回默认值而非抛出异常

**原因**:
- 符合现有 `specs/service-layer/spec.md` 中的规范
- 业务层无需大量 try-catch,代码更简洁
- 部分数据加载失败不影响其他数据展示

**实现模式**:
```dart
try {
  // API 调用
  return await ApiClient.instance.get(...);
} catch (e) {
  debugPrint('ServiceName: 操作失败: $e');
  return []; // 或其他合理默认值
}
```

### 4. 移除 _loadJsonData 辅助方法

**原因**:
- ApiClient 统一处理数据获取,不再需要 Service 层手动加载 JSON
- 简化 Service 层代码,移除基础设施逻辑
- 减少依赖 `flutter/services.dart`

### 5. 保持静态方法签名不变

**原因**:
- 业务层已有大量调用代码
- 避免破坏性变更
- 内部实现改变对外部透明

**示例**:
```dart
// 公开接口保持不变
static Future<List<TripModel>> getUserTrips({String? status}) async { ... }

// 仅内部实现改变
```

## Risks / Trade-offs

### Risk 1: 后端 API 未就绪导致数据为空

**风险描述**: Service 改用 `ApiClient.instance.get()` 请求 `ApiEndpoints` 定义的端点(如 `/api/trips`),但如果后端接口尚未实现,会返回 404 错误,导致首页数据为空

**缓解方案**:
1. **短期**: 通过 ApiClient 拦截器返回 Mock 数据(可选)
2. **中期**: 后端提供 Mock Server 环境
3. **长期**: 真实 API 就绪后自动切换

**代码示例**:
```dart
// 可选: 在 ApiClient 中添加 Mock 拦截器
class MockInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (options.path == ApiEndpoints.trips) {
      // 返回本地 Mock 数据
      return handler.resolve(Response(
        requestOptions: options,
        data: mockTripsData,
      ));
    }
    super.onRequest(options, handler);
  }
}
```

### Risk 2: 缓存键冲突

**风险描述**: 不同参数的请求可能生成相同缓存键,导致数据混淆

**缓解方案**: ApiClient 已实现基于 URL + 参数的缓存键生成,参数按字母序排列,确保唯一性

### Trade-off: 失去延迟模拟能力

**说明**: 当前 Mock 实现通过 `Future.delayed()` 模拟网络延迟,改用 ApiClient 后此能力由网络层统一处理

**影响**: Service 层代码更干净,但无法单独控制延迟时间

**评估**: 可接受,网络延迟应该在网络层统一模拟,而非 Service 层

## Migration Plan

### 阶段 1: 改造 Service 实现(本次变更)

**步骤**:
1. 修改 `TripService` 所有方法,使用 ApiClient
2. 修改 `WeatherService` 所有方法,使用 ApiClient
3. 修改 `GuideService` 所有方法,使用 ApiClient
4. 移除 `_loadJsonData` 辅助方法
5. 更新导入依赖(移除 `flutter/services.dart`,添加 ApiClient 相关)

**验证**:
- 运行 `flutter analyze` 确保无编译错误
- 运行应用,验证首页数据加载正常(可能为空,符合预期)

### 阶段 2: 添加 Mock 拦截器(可选,后续变更)

如果需要在 API 就绪前继续使用 Mock 数据:
1. 创建 `MockInterceptor` 拦截指定端点
2. 在开发环境注册到 ApiClient
3. 拦截器返回本地 JSON 数据

### 阶段 3: 接入真实 API(后续)

后端 API 就绪后:
1. 移除或禁用 Mock 拦截器
2. 配置正确的 Base URL
3. 验证真实数据加载

**回滚方案**: 如果真实 API 有问题,重新启用 Mock 拦截器即可

## Open Questions

1. **是否需要立即实现 Mock 拦截器?**
   - 建议: 先完成 Service 改造,观察是否需要 Mock 数据支持
   - 如果首页开发需要稳定的 Mock 数据,可在后续单独添加拦截器

2. **缓存 TTL 设置多久合适?**
   - 当前 ApiClient 默认策略待确认
   - 建议: 首页数据缓存 10-15 分钟

3. **是否需要支持手动刷新?**
   - 当前通过下拉刷新可传入 `DataSource.networkFirst`
   - 无需额外改动
