import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'service_cache.dart';

/// 基于 Hive 的服务缓存实现
///
/// 使用 Hive 作为底层存储，支持 TTL 过期机制
class HiveServiceCache implements ServiceCache {
  /// Hive Box 名称
  static const String _boxName = 'service_cache';

  /// 元数据 Box 名称（存储过期时间等）
  static const String _metaBoxName = 'service_cache_meta';

  /// 缓存数据 Box
  Box<String>? _cacheBox;

  /// 缓存元数据 Box
  Box<String>? _metaBox;

  /// 单例实例
  static HiveServiceCache? _instance;

  /// 获取单例实例
  static HiveServiceCache get instance {
    _instance ??= HiveServiceCache._internal();
    return _instance!;
  }

  HiveServiceCache._internal();

  /// 工厂构造函数
  factory HiveServiceCache() => instance;

  /// 初始化缓存
  ///
  /// 必须在使用缓存前调用
  Future<void> initialize() async {
    if (_cacheBox != null && _metaBox != null) return;

    try {
      _cacheBox = await Hive.openBox<String>(_boxName);
      _metaBox = await Hive.openBox<String>(_metaBoxName);
      debugPrint('HiveServiceCache: 初始化成功');
    } catch (e) {
      debugPrint('HiveServiceCache: 初始化失败 - $e');
      rethrow;
    }
  }

  /// 确保缓存已初始化
  void _ensureInitialized() {
    if (_cacheBox == null || _metaBox == null) {
      throw StateError('HiveServiceCache 未初始化，请先调用 initialize()');
    }
  }

  @override
  Future<T?> get<T>(String key) async {
    _ensureInitialized();

    try {
      // 检查是否过期
      if (await _isExpired(key)) {
        await remove(key);
        return null;
      }

      final jsonString = _cacheBox!.get(key);
      if (jsonString == null) return null;

      final decoded = json.decode(jsonString);
      return decoded as T?;
    } catch (e) {
      debugPrint('HiveServiceCache: 获取缓存失败 [$key] - $e');
      return null;
    }
  }

  @override
  Future<void> set<T>(String key, T value, {Duration? ttl}) async {
    _ensureInitialized();

    try {
      // 存储数据
      final jsonString = json.encode(value);
      await _cacheBox!.put(key, jsonString);

      // 存储元数据（过期时间）
      if (ttl != null) {
        final expiresAt = DateTime.now().add(ttl);
        await _metaBox!.put(key, expiresAt.toIso8601String());
      } else {
        // 如果没有 TTL，删除之前的过期时间记录
        await _metaBox!.delete(key);
      }

      debugPrint('HiveServiceCache: 缓存写入成功 [$key], TTL: $ttl');
    } catch (e) {
      debugPrint('HiveServiceCache: 缓存写入失败 [$key] - $e');
      rethrow;
    }
  }

  @override
  Future<void> remove(String key) async {
    _ensureInitialized();

    try {
      await _cacheBox!.delete(key);
      await _metaBox!.delete(key);
      debugPrint('HiveServiceCache: 缓存删除成功 [$key]');
    } catch (e) {
      debugPrint('HiveServiceCache: 缓存删除失败 [$key] - $e');
    }
  }

  @override
  Future<void> clear() async {
    _ensureInitialized();

    try {
      await _cacheBox!.clear();
      await _metaBox!.clear();
      debugPrint('HiveServiceCache: 缓存已清空');
    } catch (e) {
      debugPrint('HiveServiceCache: 清空缓存失败 - $e');
    }
  }

  @override
  Future<bool> has(String key) async {
    _ensureInitialized();

    if (!_cacheBox!.containsKey(key)) return false;
    if (await _isExpired(key)) {
      await remove(key);
      return false;
    }
    return true;
  }

  @override
  Future<Duration?> getTTL(String key) async {
    _ensureInitialized();

    final expiresAtString = _metaBox!.get(key);
    if (expiresAtString == null) return null;

    try {
      final expiresAt = DateTime.parse(expiresAtString);
      final remaining = expiresAt.difference(DateTime.now());
      return remaining.isNegative ? Duration.zero : remaining;
    } catch (e) {
      return null;
    }
  }

  /// 检查缓存是否已过期
  Future<bool> _isExpired(String key) async {
    final expiresAtString = _metaBox!.get(key);
    if (expiresAtString == null) return false; // 没有设置过期时间，永不过期

    try {
      final expiresAt = DateTime.parse(expiresAtString);
      return DateTime.now().isAfter(expiresAt);
    } catch (e) {
      return false;
    }
  }

  /// 清理所有过期的缓存
  ///
  /// 可以定期调用此方法清理过期数据
  Future<void> cleanExpired() async {
    _ensureInitialized();

    final keys = _cacheBox!.keys.toList();
    int cleanedCount = 0;

    for (final key in keys) {
      if (await _isExpired(key as String)) {
        await remove(key);
        cleanedCount++;
      }
    }

    if (cleanedCount > 0) {
      debugPrint('HiveServiceCache: 清理了 $cleanedCount 条过期缓存');
    }
  }

  /// 获取缓存统计信息
  Future<Map<String, dynamic>> getStats() async {
    _ensureInitialized();

    final totalKeys = _cacheBox!.keys.length;
    int expiredKeys = 0;

    for (final key in _cacheBox!.keys) {
      if (await _isExpired(key as String)) {
        expiredKeys++;
      }
    }

    return {
      'totalKeys': totalKeys,
      'expiredKeys': expiredKeys,
      'activeKeys': totalKeys - expiredKeys,
    };
  }

  /// 关闭缓存
  Future<void> close() async {
    await _cacheBox?.close();
    await _metaBox?.close();
    _cacheBox = null;
    _metaBox = null;
    debugPrint('HiveServiceCache: 已关闭');
  }
}
