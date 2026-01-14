import 'weather_config.dart';

/// 天气缓存服务 - 负责管理天气数据的缓存
class WeatherCacheService {
  /// 单例实例
  static WeatherCacheService? _instance;

  /// 获取单例实例
  static WeatherCacheService get instance {
    _instance ??= WeatherCacheService._internal();
    return _instance!;
  }

  /// 私有构造函数
  WeatherCacheService._internal();

  /// 天气数据缓存 - 使用标记点ID或坐标作为键
  final Map<String, dynamic> _weatherCache = {};

  /// 缓存时间戳 - 记录每个天气数据的获取时间
  final Map<String, int> _cacheTimestamps = {};

  /// 检查天气缓存是否有效
  ///
  /// [key] 缓存键
  /// 返回缓存是否有效
  bool isWeatherCacheValid(String key) {
    if (!_weatherCache.containsKey(key) || !_cacheTimestamps.containsKey(key)) {
      return false;
    }

    final timestamp = _cacheTimestamps[key]!;
    final now = DateTime.now().millisecondsSinceEpoch;

    // 检查缓存是否过期
    return (now - timestamp) < WeatherConfig.cacheExpiryTime;
  }

  /// 更新天气缓存
  ///
  /// [key] 缓存键
  /// [data] 天气数据
  void updateWeatherCache(String key, dynamic data) {
    _weatherCache[key] = data;
    _cacheTimestamps[key] = DateTime.now().millisecondsSinceEpoch;
  }

  /// 获取缓存数据
  ///
  /// [key] 缓存键
  /// 返回缓存的数据
  T? getCachedData<T>(String key) {
    if (isWeatherCacheValid(key)) {
      return _weatherCache[key] as T?;
    }
    return null;
  }

  /// 清除所有缓存
  void clearCache() {
    _weatherCache.clear();
    _cacheTimestamps.clear();
  }

  /// 清除特定标记点的缓存
  ///
  /// [markerPointId] 标记点ID
  void clearMarkerPointCache(String markerPointId) {
    _weatherCache.remove(markerPointId);
    _cacheTimestamps.remove(markerPointId);

    // 同时清除预报缓存
    final forecastKey = '${markerPointId}_forecast';
    _weatherCache.remove(forecastKey);
    _cacheTimestamps.remove(forecastKey);
  }

  /// 清除特定缓存项
  ///
  /// [key] 缓存键
  void clearCacheItem(String key) {
    _weatherCache.remove(key);
    _cacheTimestamps.remove(key);
  }

  /// 获取缓存统计信息
  Map<String, dynamic> getCacheStats() {
    return {
      'totalItems': _weatherCache.length,
      'cacheKeys': _weatherCache.keys.toList(),
      'oldestTimestamp': _cacheTimestamps.values.isEmpty
          ? null
          : _cacheTimestamps.values.reduce((a, b) => a < b ? a : b),
      'newestTimestamp': _cacheTimestamps.values.isEmpty
          ? null
          : _cacheTimestamps.values.reduce((a, b) => a > b ? a : b),
    };
  }
}
