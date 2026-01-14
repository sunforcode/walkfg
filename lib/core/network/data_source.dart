/// 数据来源策略枚举
///
/// 用于控制 API 请求的数据获取方式，支持缓存和网络的灵活组合
enum DataSource {
  /// 优先从 Cache 读取，没有则请求网络
  /// 网络请求成功后写入 Cache
  cacheFirst,

  /// 只从 Cache 读取，没有则抛出 [CacheNotFoundException]
  /// 适用于离线模式
  cacheOnly,

  /// 优先请求网络，失败则从 Cache 读取
  /// 网络请求成功后写入 Cache
  networkFirst,

  /// 只请求网络，忽略 Cache
  /// 请求成功后写入 Cache
  /// 适用于强制刷新场景
  networkOnly,
}
