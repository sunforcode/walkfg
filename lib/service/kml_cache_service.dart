import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:walk/core/config/app_config.dart';
import 'package:walk/model/map/map_data_model.dart';
import 'package:walk/service/cache/hive_service_cache.dart';
import 'package:walk/service/cache/service_cache.dart';
import 'package:walk/ui/map/utils/kml_business_parser.dart';

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
      debugPrint('KmlCacheService: HiveServiceCache 已初始化');
    } catch (e) {
      // 如果未初始化，尝试初始化
      debugPrint('KmlCacheService: HiveServiceCache 未初始化，尝试初始化...');
      final hiveCache = HiveServiceCache.instance;
      await hiveCache.initialize();
      debugPrint('KmlCacheService: HiveServiceCache 初始化成功');
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
    debugPrint('KmlCacheService: 原始 kmlUrl: $kmlUrl');
    
    if (kmlUrl.startsWith('http://') || kmlUrl.startsWith('https://')) {
      debugPrint('KmlCacheService: kmlUrl 是完整 URL，直接使用');
      return kmlUrl;
    }
    
    // 相对路径，需要拼接 baseUrl
    final baseUrl = AppConfig.instance.baseUrl;
    debugPrint('KmlCacheService: baseUrl: $baseUrl');
    
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
    
    debugPrint('KmlCacheService: 拼接后的完整 URL: $fullUrl');
    return fullUrl;
  }

  /// 从网络下载KML原始内容
  ///
  /// [kmlUrl] KML文件URL（支持相对路径和完整URL）
  /// 返回 KML 原始 XML 字符串
  Future<String> _downloadKmlContent(String kmlUrl) async {
    final fullUrl = _buildFullUrl(kmlUrl);
    debugPrint('KmlCacheService: 开始从网络下载KML，url: $fullUrl');

    try {
      final response = await http.get(Uri.parse(fullUrl));
      debugPrint('KmlCacheService: HTTP 响应状态码: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        debugPrint('KmlCacheService: 下载成功，内容长度: ${response.body.length} 字节');
        // 打印前100个字符用于调试
        if (response.body.isNotEmpty) {
          final preview = response.body.length > 200 
              ? '${response.body.substring(0, 200)}...' 
              : response.body;
          debugPrint('KmlCacheService: 内容预览: $preview');
        }
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
    debugPrint('KmlCacheService: 获取 KML 内容，key: $key, routeId: $routeId');

    // 检查缓存是否存在且未过期
    final hasCache = await _cache.has(key);
    debugPrint('KmlCacheService: 缓存是否存在: $hasCache');
    
    if (hasCache) {
      final cachedContent = await _cache.get<String>(key);
      if (cachedContent != null) {
        debugPrint('KmlCacheService: 使用缓存数据，key: $key, 内容长度: ${cachedContent.length} 字节');
        return cachedContent;
      }
    }

    // 缓存未命中，从网络下载
    debugPrint('KmlCacheService: 缓存未命中，从网络下载');
    final kmlContent = await _downloadKmlContent(kmlUrl);

    // 写入缓存
    await _cacheKmlContent(key, kmlContent);
    debugPrint('KmlCacheService: 写入缓存成功，key: $key');

    return kmlContent;
  }

  /// 解析 KML 内容为 MapDataModel
  ///
  /// [kmlContent] KML 原始 XML 字符串
  /// [sourceUrl] 可选的来源URL，用于日志和调试
  /// 返回解析后的 MapDataModel
  MapDataModel parseKmlContent(String kmlContent, {String? sourceUrl}) {
    debugPrint('KmlCacheService: 开始解析 KML 内容，长度: ${kmlContent.length}');
    final result = KmlBusinessParser.parseFromString(kmlContent, sourceUrl: sourceUrl);
    debugPrint('KmlCacheService: 解析完成，轨迹点: ${result.trackPoints.length} 个, 路标点: ${result.waypoints.length} 个');
    return result;
  }

  /// 获取解析后的地图数据（优先缓存）
  ///
  /// [kmlUrl] KML文件URL或路径
  /// [routeId] 可选的路线ID，用于生成缓存Key
  /// 返回解析后的 MapDataModel
  Future<MapDataModel> getMapData(String kmlUrl, {String? routeId}) async {
    debugPrint('KmlCacheService: getMapData 被调用，kmlUrl: $kmlUrl, routeId: $routeId');
    
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
    debugPrint('KmlCacheService: 写入缓存，key: $key, 长度: ${kmlContent.length}, TTL: $_cacheTTL');
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
    debugPrint('KmlCacheService: 清除缓存，key: $key');
    await _cache.remove(key);
  }

  /// 清除所有KML缓存
  Future<void> clearAllCache() async {
    await _ensureCacheInitialized();
    debugPrint('KmlCacheService: 清除所有缓存');
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
      debugPrint('KmlCacheService: 已删除缓存 key: $key，将在下一次请求时重新获取');
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
