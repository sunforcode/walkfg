/// 基础模型类
///
/// 所有模型类的基类，提供通用属性和方法
/// 包含ID、创建时间和更新时间等基础字段

/// 基础模型
class BaseModel {
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

  /// 从JSON创建
  factory BaseModel.fromJson(Map<String, dynamic> json) {
    return BaseModel(
      id: json['id'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
