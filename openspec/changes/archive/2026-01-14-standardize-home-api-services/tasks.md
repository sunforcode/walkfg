# Implementation Tasks

## 1. 改造 TripService

- [x] 1.1 移除 `_loadJsonData()` 辅助方法
- [x] 1.2 更新导入依赖(移除 `dart:convert`, `flutter/services.dart`,添加 `api_client.dart`, `api_endpoints.dart`, `api_exception.dart`)
- [x] 1.3 改造 `getUserTrips()` 方法使用 ApiClient
- [x] 1.4 改造 `getTripDetail()` 方法使用 ApiClient (原 `getTripById`)
- [x] 1.5 改造 `getPlannedTrips()` 方法使用 ApiClient
- [x] 1.6 改造 `getRelatedTrips()` 方法使用 ApiClient
- [x] 1.7 添加 `_parseTripsResponse()` 私有方法统一解析响应
- [x] 1.8 统一错误处理,捕获异常返回默认值

## 2. 改造 WeatherService

- [x] 2.1 移除 `_loadJsonData()` 辅助方法
- [x] 2.2 更新导入依赖(移除 `dart:convert`, `flutter/services.dart`,添加 `api_client.dart`, `api_endpoints.dart`, `api_exception.dart`)
- [x] 2.3 改造 `getWeather()` 方法使用 ApiClient
- [x] 2.4 改造 `getWeatherByCity()` 方法使用 ApiClient
- [x] 2.5 改造 `getForecast()` 方法使用 ApiClient
- [x] 2.6 统一错误处理,捕获异常返回默认值

## 3. 改造 GuideService

- [x] 3.1 移除 `_loadJsonData()` 辅助方法
- [x] 3.2 更新导入依赖(移除 `dart:convert`, `flutter/services.dart`,添加 `api_client.dart`, `api_endpoints.dart`, `api_exception.dart`)
- [x] 3.3 改造 `getGuides()` 方法使用 ApiClient
- [x] 3.4 改造 `getGuideById()` 方法使用 ApiClient
- [x] 3.5 改造 `getGuideWithDetails()` 方法(保持并行加载逻辑)
- [x] 3.6 改造 `getPopularGuides()` 方法使用 ApiClient
- [x] 3.7 改造 `getLatestGuides()` 方法使用 ApiClient
- [x] 3.8 改造 `getFavoriteGuides()` 方法使用 ApiClient
- [x] 3.9 改造写操作方法(likeGuide, createGuide, updateGuide, deleteGuide 等)使用 ApiClient
- [x] 3.10 添加 `_parseGuidesResponse()` 私有方法统一解析响应
- [x] 3.11 统一错误处理,捕获异常返回默认值

## 4. 验证和测试

- [x] 4.1 运行 `flutter analyze` 确保无编译错误
- [x] 4.2 运行应用验证首页加载(预期数据可能为空,符合预期)
- [x] 4.3 检查日志输出,确认错误处理正常
- [x] 4.4 验证 Service 静态方法签名未改变
- [x] 4.5 确认业务层调用代码无需修改

## 5. 文档更新

- [x] 5.1 更新 Service 类文档注释,说明已使用 ApiClient
- [x] 5.2 移除“当前使用本地 JSON 数据”等临时说明

## 注意事项

- **保持签名不变**: 所有公开静态方法的参数和返回值不变
- **统一错误处理**: 使用 try-catch 捕获所有异常,返回合理默认值
- **统一日志格式**: `debugPrint('ServiceName: 操作描述失败: $e')`
- **使用 cacheFirst**: 默认使用 `DataSource.cacheFirst` 策略
- **复用解析逻辑**: 对于相同数据结构的响应,提取为 `_parseXxxResponse()` 私有方法
