/// 基础模型类
///
/// 所有模型类的基类，提供通用属性和方法

/// 基础模型
class BaseModel {
  /// ID
  final String? id;

  /// 创建时间
  final DateTime? createdAt;

  /// 更新时间
  final DateTime? updatedAt;

  /// 构造函数
  BaseModel({
    this.id,
    this.createdAt,
    this.updatedAt,
  });

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}