/// 服务缓存接口
///
/// 定义服务层缓存的统一接口，支持多种缓存实现
abstract class ServiceCache {
  /// 初始化缓存
  ///
  /// 必须在使用缓存前调用
  Future<void> initialize();

  /// 从缓存获取数据
  ///
  /// [key] 缓存键
  /// 返回缓存的数据，如果不存在或已过期则返回 null
  Future<T?> get<T>(String key);

  /// 将数据写入缓存
  ///
  /// [key] 缓存键
  /// [value] 要缓存的数据
  /// [ttl] 缓存过期时间，可选
  Future<void> set<T>(String key, T value, {Duration? ttl});

  /// 删除指定键的缓存
  ///
  /// [key] 缓存键
  Future<void> remove(String key);

  /// 清除所有缓存
  Future<void> clear();

  /// 检查缓存是否存在且未过期
  ///
  /// [key] 缓存键
  Future<bool> has(String key);

  /// 获取缓存剩余过期时间
  ///
  /// [key] 缓存键
  /// 返回剩余时间，如果不存在或已过期则返回 null
  Future<Duration?> getTTL(String key);
}

/// 缓存条目元数据
///
/// 用于存储缓存数据的元信息
class CacheEntry<T> {
  /// 缓存的数据
  final T data;

  /// 缓存创建时间
  final DateTime createdAt;

  /// 缓存过期时间，null 表示永不过期
  final DateTime? expiresAt;

  CacheEntry({
    required this.data,
    required this.createdAt,
    this.expiresAt,
  });

  /// 检查缓存是否已过期
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// 获取剩余过期时间
  Duration? get remainingTTL {
    if (expiresAt == null) return null;
    final remaining = expiresAt!.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// 转换为 Map（用于序列化）
  Map<String, dynamic> toJson(dynamic Function(T) dataSerializer) {
    return {
      'data': dataSerializer(data),
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
    };
  }

  /// 从 Map 创建实例（用于反序列化）
  static CacheEntry<T> fromJson<T>(
    Map<String, dynamic> json,
    T Function(dynamic) dataDeserializer,
  ) {
    return CacheEntry<T>(
      data: dataDeserializer(json['data']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
    );
  }
}
