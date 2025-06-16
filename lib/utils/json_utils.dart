/// JSON 工具类
///
/// 提供统一的 JSON 序列化和反序列化工具方法
class JsonUtils {
  /// 解析时间戳（支持秒和毫秒）
  ///
  /// 支持的输入格式：
  /// - int: 时间戳（秒或毫秒）
  /// - String: 时间戳字符串或 ISO 8601 格式
  /// - null: 返回 null
  static DateTime? parseTimestamp(dynamic timestamp) {
    if (timestamp == null) return null;

    if (timestamp is int) {
      // 判断是秒还是毫秒（毫秒数通常大于10位数）
      if (timestamp > 9999999999) {
        // 毫秒时间戳
        return DateTime.fromMillisecondsSinceEpoch(timestamp);
      } else {
        // 秒时间戳
        return DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
      }
    }

    if (timestamp is String) {
      // 尝试解析字符串形式的时间戳
      final int? parsed = int.tryParse(timestamp);
      if (parsed != null) {
        return parseTimestamp(parsed);
      }
      // 如果不是时间戳，尝试ISO 8601格式
      try {
        return DateTime.parse(timestamp);
      } catch (e) {
        return null;
      }
    }

    return null;
  }

  /// 时间戳转JSON（输出毫秒时间戳）
  ///
  /// 将 DateTime 对象转换为毫秒时间戳，用于 JSON 序列化
  static int? timestampToJson(DateTime? dateTime) {
    return dateTime?.millisecondsSinceEpoch;
  }

  /// 解析布尔值
  ///
  /// 支持多种格式的布尔值解析
  static bool parseBool(dynamic value, {bool defaultValue = false}) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is String) {
      final lowerValue = value.toLowerCase();
      return lowerValue == 'true' || lowerValue == '1' || lowerValue == 'yes';
    }
    if (value is int) return value != 0;
    return defaultValue;
  }

  /// 解析双精度浮点数
  ///
  /// 支持多种格式的数值解析
  static double parseDouble(dynamic value, {double defaultValue = 0.0}) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? defaultValue;
    }
    return defaultValue;
  }

  /// 解析整数
  ///
  /// 支持多种格式的整数解析
  static int parseInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? defaultValue;
    }
    return defaultValue;
  }

  /// 解析字符串
  ///
  /// 安全的字符串解析，处理 null 值
  static String? parseString(dynamic value) {
    if (value == null) return null;
    return value.toString();
  }

  /// 解析字符串列表
  ///
  /// 将动态类型转换为字符串列表
  static List<String> parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((e) => e?.toString() ?? '').toList();
    }
    return [];
  }
}
