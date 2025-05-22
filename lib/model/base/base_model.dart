import 'package:json_annotation/json_annotation.dart';

/// 基础模型类
abstract class BaseModel {
  /// ID
  final String id;

  /// 创建时间
  final DateTime? createdAt;

  /// 更新时间
  final DateTime? updatedAt;

  /// 构造函数
  BaseModel({
    required this.id,
    this.createdAt,
    this.updatedAt,
  });

  /// 转换为JSON
  Map<String, dynamic> toJson();
}
