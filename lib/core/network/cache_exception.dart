/// 缓存未找到异常
///
/// 当使用 [DataSource.cacheOnly] 但缓存中没有数据时抛出
class CacheNotFoundException implements Exception {
  /// 缓存键
  final String cacheKey;

  /// 提示信息
  final String message;

  CacheNotFoundException(this.cacheKey, [String? message])
      : message = message ?? '缓存未找到: $cacheKey';

  @override
  String toString() => 'CacheNotFoundException: $message';
}
