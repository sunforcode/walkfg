import 'package:json_annotation/json_annotation.dart';

/// 基础模型类
abstract class BaseModel {
  /// ID
  final String id;

  /// 创建时间
  @JsonKey(
      name: 'created_at', fromJson: parseTimestamp, toJson: timestampToJson)
  final DateTime? createdAt;

  /// 更新时间
  @JsonKey(
      name: 'updated_at', fromJson: parseTimestamp, toJson: timestampToJson)
  final DateTime? updatedAt;

  /// 构造函数
  BaseModel({
    required this.id,
    this.createdAt,
    this.updatedAt,
  });

  /// 转换为JSON
  Map<String, dynamic> toJson();

  /// 解析时间戳（支持秒和毫秒）
  static DateTime parseTimestamp(dynamic timestamp) {

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
        return DateTime.now();
      }
    }

    return DateTime.now(); 
  }

  /// 时间戳转JSON（输出毫秒时间戳）
  static int? timestampToJson(DateTime? dateTime) {
    return dateTime?.millisecondsSinceEpoch;
  }

  /// 解析可空时间戳（支持秒和毫秒）
  static DateTime? parseTimestampNullable(dynamic timestamp) {
    if (timestamp == null) return null;
    return parseTimestamp(timestamp);
  }
}
