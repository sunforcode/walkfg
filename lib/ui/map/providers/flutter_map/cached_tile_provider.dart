import 'dart:io';
import 'dart:typed_data';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:path_provider/path_provider.dart';
import 'package:walk/model/model/map/map_bounds.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'dart:convert';

/// 缓存瓦片提供者
class CachedTileProvider extends TileProvider {
  final Map<String, Uint8List> _memoryCache = {};
  final http.Client _httpClient = http.Client();

  CachedTileProvider();

  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    final String tileUrl = getTileUrl(coordinates, options);
    final String cacheKey = _getCacheKey(tileUrl);

    // 1. 尝试从内存缓存获取
    if (_memoryCache.containsKey(cacheKey)) {
      return MemoryImage(_memoryCache[cacheKey]!);
    }

    // 2. 从网络获取并返回一个网络图片提供者
    return NetworkImage(tileUrl);
  }

  /// 获取瓦片URL
  String getTileUrl(TileCoordinates coordinates, TileLayer options) {
    if (options.urlTemplate == null || options.urlTemplate!.isEmpty) {
      debugPrint('警告: urlTemplate 为空');
      return '';
    }

    String url = options.urlTemplate!;

    // 选择子域名
    final String subdomain = _getSubdomain(coordinates, options.subdomains);

    // 替换URL模板中的变量
    url = url
        .replaceAll('{z}', coordinates.z.toString())
        .replaceAll('{x}', coordinates.x.toString())
        .replaceAll('{y}', coordinates.y.toString())
        .replaceAll('{s}', subdomain);

    debugPrint('生成瓦片URL: $url');
    return url;
  }

  /// 获取子域名
  String _getSubdomain(TileCoordinates coordinates, List<String> subdomains) {
    if (subdomains.isEmpty) {
      return '';
    }
    final index = (coordinates.x + coordinates.y) % subdomains.length;
    return subdomains[index];
  }

  /// 获取缓存键
  String _getCacheKey(String url) {
    return md5.convert(utf8.encode(url)).toString();
  }

  /// 获取缓存瓦片文件
  Future<File?> _getCachedTileFile(String cacheKey) async {
    try {
      final Directory cacheDir = await _getCacheDirectory();
      return File('${cacheDir.path}/$cacheKey.png');
    } catch (e) {
      debugPrint('获取缓存目录失败: $e');
      return null;
    }
  }

  /// 保存瓦片到缓存
  Future<void> _saveTileToCache(String cacheKey, Uint8List bytes) async {
    try {
      final File? cacheFile = await _getCachedTileFile(cacheKey);
      if (cacheFile != null) {
        await cacheFile.writeAsBytes(bytes);
      }
    } catch (e) {
      debugPrint('保存瓦片到缓存失败: $e');
    }
  }

  /// 获取缓存目录
  Future<Directory> _getCacheDirectory() async {
    final Directory appCacheDir = await getTemporaryDirectory();
    final Directory cacheDir = Directory('${appCacheDir.path}/map_tiles');

    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }

    return cacheDir;
  }

  /// 检查离线地图是否可用
  Future<bool> isOfflineAvailable(MapBoundsVO bounds, int zoom) async {
    // 简单实现：检查一个中心点瓦片是否存在
    final centerLat = (bounds.north + bounds.south) / 2;
    final centerLng = (bounds.east + bounds.west) / 2;

    final x = _longitudeToTileX(centerLng, zoom);
    final y = _latitudeToTileY(centerLat, zoom);

    final tileUrl = 'https://a.tile.openstreetmap.org/$zoom/$x/$y.png';
    final cacheKey = _getCacheKey(tileUrl);

    final File? cachedFile = await _getCachedTileFile(cacheKey);
    return cachedFile != null && await cachedFile.exists();
  }

  /// 下载区域瓦片
  Future<void> downloadRegion(MapBoundsVO bounds, int minZoom, int maxZoom,
      void Function(double) progressCallback) async {
    // 计算需要下载的瓦片
    final tiles = _calculateTileRange(bounds, minZoom, maxZoom);
    final totalTiles = tiles.length;
    int downloadedTiles = 0;

    for (final tile in tiles) {
      final x = tile['x'] as int;
      final y = tile['y'] as int;
      final z = tile['z'] as int;

      final tileUrl = 'https://a.tile.openstreetmap.org/$z/$x/$y.png';
      final cacheKey = _getCacheKey(tileUrl);

      // 检查是否已存在
      final File? cachedFile = await _getCachedTileFile(cacheKey);
      if (cachedFile != null && await cachedFile.exists()) {
        downloadedTiles++;
        progressCallback(downloadedTiles / totalTiles);
        continue;
      }

      try {
        final http.Response response =
            await _httpClient.get(Uri.parse(tileUrl));

        if (response.statusCode == 200) {
          final Uint8List bytes = response.bodyBytes;
          await _saveTileToCache(cacheKey, bytes);
        }
      } catch (e) {
        debugPrint('下载瓦片失败: $tileUrl, $e');
      }

      downloadedTiles++;
      progressCallback(downloadedTiles / totalTiles);
    }
  }

  /// 计算瓦片范围
  List<Map<String, int>> _calculateTileRange(
      MapBoundsVO bounds, int minZoom, int maxZoom) {
    final tiles = <Map<String, int>>[];

    for (int z = minZoom; z <= maxZoom; z++) {
      // 计算瓦片坐标范围
      final minX = _longitudeToTileX(bounds.west, z);
      final maxX = _longitudeToTileX(bounds.east, z);
      final minY = _latitudeToTileY(bounds.north, z);
      final maxY = _latitudeToTileY(bounds.south, z);

      for (int x = minX; x <= maxX; x++) {
        for (int y = minY; y <= maxY; y++) {
          tiles.add({'x': x, 'y': y, 'z': z});
        }
      }
    }

    return tiles;
  }

  /// 经度转瓦片X坐标
  int _longitudeToTileX(double longitude, int zoom) {
    return ((longitude + 180.0) / 360.0 * (1 << zoom)).floor();
  }

  /// 纬度转瓦片Y坐标
  int _latitudeToTileY(double latitude, int zoom) {
    final latRad = latitude * pi / 180.0;
    return ((1.0 - log(tan(latRad) + 1.0 / cos(latRad)) / pi) /
            2.0 *
            (1 << zoom))
        .floor();
  }

  /// 清除缓存
  Future<void> clearCache() async {
    _memoryCache.clear();

    try {
      final Directory cacheDir = await _getCacheDirectory();
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
        await cacheDir.create(recursive: true);
      }
    } catch (e) {
      debugPrint('清除缓存失败: $e');
    }
  }

  /// 释放资源
  void dispose() {
    _httpClient.close();
  }
}
