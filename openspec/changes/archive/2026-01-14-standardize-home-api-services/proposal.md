# Change: 规范首页服务层 - 统一使用 ApiClient

## Why

当前首页使用的三个服务(`TripService`、`WeatherService`、`GuideService`)仍然直接从本地 JSON 文件加载 Mock 数据,而项目中已经建立了统一的服务层规范:

1. **不一致**: `UserService` 和 `RouteService` 已经使用 `ApiClient` + 缓存策略,但 `TripService`、`WeatherService`、`GuideService` 仍使用 `rootBundle.loadString` 加载本地 JSON
2. **缺少缓存**: 没有使用统一的缓存机制,每次都重新加载 JSON 文件
3. **缺少策略**: 没有 `DataSource` 策略支持,无法灵活控制数据来源(缓存优先/网络优先等)
4. **Mock 方式不标准**: Mock 数据应该通过 `ApiClient` 的拦截器返回,而不是在 Service 层内部处理
5. **业务逻辑耦合**: Service 层混入了文件加载、延迟模拟等基础设施逻辑,违反单一职责原则

## What Changes

将 `TripService`、`WeatherService`、`GuideService` 改造为统一的服务层实现:

### 核心改造点

1. **使用 ApiClient 替代直接文件加载**:
   - 移除 `rootBundle.loadString` 和 `json.decode` 直接调用
   - 改用 `ApiClient.instance.get()` 发起网络请求
   - 使用 `ApiEndpoints` 类管理端点路径(如 `ApiEndpoints.trips` 对应 `/api/trips`)

2. **支持 DataSource 策略**:
   - 默认使用 `DataSource.cacheFirst` 策略
   - 根据业务场景选择合适的缓存策略

3. **统一错误处理**:
   - 使用 `ApiException` 和 `BusinessException`
   - 失败时返回默认值(空列表/空对象)而非抛出异常
   - 统一的日志输出格式

4. **Mock 数据迁移** (后续):
   - Mock 数据最终应该由后端 Mock Server 或 ApiClient 拦截器提供
   - Service 层只负责业务逻辑,不关心数据来源

### 具体修改的文件

- `lib/service/trip_service.dart` - 移除 `_loadJsonData()`,改用 `ApiClient.instance.get()`
- `lib/service/weather_service.dart` - 移除 `_loadJsonData()`,改用 `ApiClient.instance.get()`
- `lib/service/guide_service.dart` - 移除 `_loadJsonData()`,改用 `ApiClient.instance.get()`

### 不修改的部分

- API 端点已经在 `ApiEndpoints` 中定义,无需新增
- `DataSource` 枚举和 `ApiClient` 已经实现,无需修改
- Service 静态方法签名保持不变,业务层调用代码无需修改

## Impact

### Affected specs
- `specs/service-layer/spec.md` - 补充首页服务的实现规范

### Affected code
- `lib/service/trip_service.dart` - 核心改造
- `lib/service/weather_service.dart` - 核心改造
- `lib/service/guide_service.dart` - 核心改造

### 业务影响
- **无破坏性变更**: Service 静态方法签名不变,业务层无需修改
- **性能提升**: 通过缓存机制减少重复请求
- **更好的离线支持**: 通过 `DataSource.cacheFirst` 策略自动支持离线模式
- **统一体验**: 所有 Service 层都遵循相同的数据获取逻辑

### Mock 数据过渡方案

当前阶段:
- Service 改用 `ApiClient.get()` 调用 API 端点
- 如果后端 API 未就绪,`ApiClient` 会因网络错误返回缓存或默认值
- 临时可以通过 Mock 拦截器返回 Mock 数据

最终状态:
- 后端 API 就绪后,直接返回真实数据
- Mock 拦截器可以移除或仅在测试环境启用
