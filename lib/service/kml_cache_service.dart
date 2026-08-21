import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:walk/core/config/app_config.dart';
import 'package:walk/model/map/map_data_model.dart';
import 'package:walk/service/cache/hive_service_cache.dart';
import 'package:walk/service/cache/service_cache.dart';
import 'package:walk/ui/map/utils/kml_business_parser.dart';
import 'package:walk/utils/coordinate_transform_utils.dart';

/// KML缓存服务
///
/// 用于缓存KML原始数据（XML字符串），减少网络请求
/// 缓存策略：7天过期，使用HiveServiceCache作为底层存储
class KmlCacheService {
  /// 缓存TTL：7天
  static const Duration _cacheTTL = Duration(days: 7);

  /// 缓存Key前缀
  static const String _keyPrefix = 'kml:';

  /// 底层缓存存储
  final ServiceCache _cache;

  /// 单例实例
  static KmlCacheService? _instance;

  /// 获取单例实例
  static KmlCacheService get instance {
    _instance ??= KmlCacheService._internal();
    return _instance!;
  }

  KmlCacheService._internal() : _cache = HiveServiceCache.instance;

  /// 工厂构造函数
  factory KmlCacheService() => instance;

  /// 确保缓存已初始化
  Future<void> _ensureCacheInitialized() async {
    try {
      // 尝试调用一个简单的方法来检查是否已初始化
      // 如果未初始化，HiveServiceCache 会抛出 StateError
      await _cache.has('dummy_key_for_initialization_check');
    } catch (e) {
      // 如果未初始化，尝试初始化
      final hiveCache = HiveServiceCache.instance;
      await hiveCache.initialize();
    }
  }

  /// 生成缓存key
  ///
  /// 优先使用 routeId，否则使用 kmlUrl 的 hashCode
  String _generateCacheKey(String kmlUrl, String? routeId) {
    if (routeId != null && routeId.isNotEmpty) {
      return '$_keyPrefix$routeId';
    }
    return '$_keyPrefix${kmlUrl.hashCode}';
  }

  /// 构建完整的URL
  ///
  /// 如果 kmlUrl 是相对路径（如 /static/kml/xxx.kml），则拼接 baseUrl
  /// 如果是完整 URL（http/https 开头），则直接返回
  String _buildFullUrl(String kmlUrl) {
    if (kmlUrl.startsWith('http://') || kmlUrl.startsWith('https://')) {
      return kmlUrl;
    }
    
    // 相对路径，需要拼接 baseUrl
    final baseUrl = AppConfig.instance.baseUrl;
    
    // 确保 baseUrl 和 kmlUrl 正确拼接
    String fullUrl;
    if (baseUrl.endsWith('/') && kmlUrl.startsWith('/')) {
      // 都有 /，去掉一个
      fullUrl = baseUrl + kmlUrl.substring(1);
    } else if (!baseUrl.endsWith('/') && !kmlUrl.startsWith('/')) {
      // 都没有 /，添加一个
      fullUrl = '$baseUrl/$kmlUrl';
    } else {
      // 正常拼接
      fullUrl = baseUrl + kmlUrl;
    }
    
    return fullUrl;
  }

  /// 从网络下载KML原始内容
  ///
  /// [kmlUrl] KML文件URL（支持相对路径和完整URL）
  /// 返回 KML 原始 XML 字符串
  Future<String> _downloadKmlContent(String kmlUrl) async {
    final fullUrl = _buildFullUrl(kmlUrl);

    try {
      final response = await http.get(Uri.parse(fullUrl));

      if (response.statusCode == 200) {
        return response.body;
      } else {
        debugPrint('KmlCacheService: 下载失败，状态码: ${response.statusCode}');
        throw Exception('网络请求失败: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('KmlCacheService: 下载异常: $e');
      rethrow;
    }
  }

  /// 获取 KML 原始内容（优先缓存）
  ///
  /// [kmlUrl] KML文件URL或路径
  /// [routeId] 可选的路线ID，用于生成缓存Key
  /// 返回 KML 原始 XML 字符串
  Future<String> getKmlContent(String kmlUrl, {String? routeId}) async {
    // 确保缓存已初始化
    await _ensureCacheInitialized();
    
    final key = _generateCacheKey(kmlUrl, routeId);

    // 检查缓存是否存在且未过期
    final hasCache = await _cache.has(key);
    
    if (hasCache) {
      final cachedContent = await _cache.get<String>(key);
      if (cachedContent != null) {
        return cachedContent;
      }
    }

    // 缓存未命中，从网络下载
    final kmlContent = await _downloadKmlContent(kmlUrl);

    // 写入缓存
    await _cacheKmlContent(key, kmlContent);

    return kmlContent;
  }

  /// 解析 KML 内容为 MapDataModel
  ///
  /// [kmlContent] KML 原始 XML 字符串
  /// [sourceUrl] 可选的来源URL，用于日志和调试
  /// 返回解析后的 MapDataModel（轨迹点已经过 GCJ-02 → WGS-84 转换）
  MapDataModel parseKmlContent(String kmlContent, {String? sourceUrl}) {
    final result = KmlBusinessParser.parseFromString(kmlContent, sourceUrl: sourceUrl);

    // KML 标准要求使用 WGS-84 坐标，两步路等软件导出KML时同样遵循此标准
    // 无需做 GCJ-02 → WGS-84 转换，直接使用原始坐标
    return result;
  }

  /// 获取解析后的地图数据（优先缓存）
  ///
  /// [kmlUrl] KML文件URL或路径
  /// [routeId] 可选的路线ID，用于生成缓存Key
  /// 返回解析后的 MapDataModel
  Future<MapDataModel> getMapData(String kmlUrl, {String? routeId}) async {
    // 获取 KML 原始内容（优先缓存）
    final kmlContent = await getKmlContent(kmlUrl, routeId: routeId);
    
    // 解析 KML 内容
    return parseKmlContent(kmlContent, sourceUrl: kmlUrl);
  }

  /// 手动写入 KML 内容到缓存
  ///
  /// [key] 缓存key
  /// [kmlContent] KML 原始 XML 字符串
  Future<void> _cacheKmlContent(String key, String kmlContent) async {
    await _cache.set(key, kmlContent, ttl: _cacheTTL);
  }

  /// 手动写入缓存（外部调用）
  ///
  /// [routeId] 路线ID
  /// [kmlContent] KML 原始 XML 字符串
  Future<void> cacheKmlByRouteId(String routeId, String kmlContent) async {
    final key = '$_keyPrefix$routeId';
    await _cacheKmlContent(key, kmlContent);
  }

  /// 清除指定缓存
  ///
  /// [key] 缓存key
  Future<void> clearCache(String key) async {
    await _ensureCacheInitialized();
    await _cache.remove(key);
  }

  /// 清除所有KML缓存
  Future<void> clearAllCache() async {
    await _ensureCacheInitialized();
    await _cache.clear();
  }

  /// 强制标记缓存已过期（用于调试）
  ///
  /// [key] 缓存key
  Future<void> forceExpire(String key) async {
    await _ensureCacheInitialized();
    final cached = await _cache.get<String>(key);
    if (cached != null) {
      await _cache.remove(key);
    }
  }

  /// 获取剩余有效时间
  ///
  /// [key] 缓存key
  /// 返回剩余时间，如果不存在或已过期则返回null
  Future<Duration?> getRemainingTTL(String key) async {
    await _ensureCacheInitialized();
    return await _cache.getTTL(key);
  }
}
