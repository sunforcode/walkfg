# Tasks: 统一数据来源策略

## 1. 基础设施

- [x] 1.1 新增 `lib/core/network/data_source.dart`（DataSource 枚举）
- [x] 1.2 新增 `lib/core/network/cache_exception.dart`（CacheNotFoundException）

## 2. ApiClient 改造

- [x] 2.1 ApiClient 注入 ServiceCache
- [x] 2.2 新增 `getData()` 方法支持 `dataSource` 参数
- [x] 2.3 实现 `_generateCacheKey()` 方法
- [x] 2.4 实现各 DataSource 策略的数据获取逻辑
- [x] 2.5 改造 `post()`、`put()`、`delete()` 方法支持缓存失效

## 3. Service 层改造

- [x] 3.1 改造 Service 为静态方法模式（如 `RouteService.getRouteById(...)`）
- [x] 3.2 改造所有 Service 使用静态方法
- [x] 3.3 将 `lib/service/impl/` 中的文件合并到 `lib/service/` 根目录
- [x] 3.4 删除 `lib/service/impl/` 目录

## 4. 清理旧代码

- [x] 4.1 删除 `lib/service/mock/` 整个目录
- [x] 4.2 删除 `lib/service/cached/` 整个目录
- [x] 4.3 删除 `lib/service/config/` 整个目录
- [x] 4.4 删除 `lib/service/service_manager.dart`（如存在）

## 5. 更新业务代码引用

- [x] 5.1 替换 `MockXxxService.instance` 为 `XxxService` 静态方法调用
- [x] 5.2 替换 `XxxServiceImpl.instance` 为 `XxxService` 静态方法调用

## 6. 验证

- [x] 6.1 运行 `flutter analyze` 确保无 error 级别编译错误
