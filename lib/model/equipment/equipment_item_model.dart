import 'equipment_enums.dart';

/// 装备单品模型
///
/// 严格对齐后端 `org.example.equipment.dto.EquipmentItemResponse`。
///
/// 重要提示：该响应体的字段命名并不是全蛇形（与本项目 route/guide/trip
/// 等模块的响应体不同）——只有 `created_by`/`created_at`/`updated_at`
/// 三个字段有 `@JsonProperty` 蛇形映射，其余字段（`categoryName`、
/// `weightUnit`、`weightUnitName` 等）均为驼峰命名，解析时必须逐字段核对。
class EquipmentItemModel {
  /// ID
  final String id;

  /// 名称
  final String name;

  /// 分类（0-10）
  final EquipmentCategory category;

  /// 分类展示名称（后端直接返回的中文名，非本地拼接）
  final String categoryName;

  /// 重量（数值，单位见 [weightUnit]）
  final double weight;

  /// 重量单位（0-3）
  final EquipmentWeightUnit weightUnit;

  /// 重量单位展示名称（后端直接返回）
  final String weightUnitName;

  /// 数量
  final int quantity;

  /// 创建者用户ID（装备单品没有归属校验，创建时后端未注入身份，可能为 null）
  final String? createdBy;

  /// 创建时间（毫秒时间戳）
  final DateTime createdAt;

  /// 更新时间（毫秒时间戳）
  final DateTime updatedAt;

  const EquipmentItemModel({
    required this.id,
    required this.name,
    required this.category,
    required this.categoryName,
    required this.weight,
    required this.weightUnit,
    required this.weightUnitName,
    required this.quantity,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 从后端响应 JSON 创建
  factory EquipmentItemModel.fromJson(Map<String, dynamic> json) {
    return EquipmentItemModel(
      id: json['id'] as String,
      name: json['name'] as String,
      category: equipmentCategoryFromCode(json['category']),
      categoryName: json['categoryName'] as String? ?? '',
      weight: _parseDouble(json['weight']),
      weightUnit: equipmentWeightUnitFromCode(json['weightUnit']),
      weightUnitName: json['weightUnitName'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      createdBy: json['created_by'] as String?,
      createdAt: _parseTimestamp(json['created_at']),
      updatedAt: _parseTimestamp(json['updated_at']),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  static DateTime _parseTimestamp(dynamic value) {
    if (value is int) {
      return value > 9999999999
          ? DateTime.fromMillisecondsSinceEpoch(value)
          : DateTime.fromMillisecondsSinceEpoch(value * 1000);
    }
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) return _parseTimestamp(parsed);
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }

  /// 获取重量展示文本，如 "500g" / "1.5kg"
  String get weightText => '${_formatNumber(weight)}${weightUnit.shortLabel}';

  /// 获取总重量（weight * quantity）展示文本
  String get totalWeightText =>
      '${_formatNumber(weight * quantity)}${weightUnit.shortLabel}';

  static String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(1);
  }
}

/// 创建/更新装备单品的请求体
///
/// 对齐后端 `org.example.equipment.dto.EquipmentCreateRequest`。
/// 注意：`description` 字段虽然存在于该 DTO，但后端 `EquipmentItem`
/// 实体没有对应列，传了也会被静默丢弃，因此这里不暴露该字段，
/// 避免用户误以为描述会被保存。
class EquipmentItemUpsertRequest {
  /// 装备名称（必填，非空）
  final String name;

  /// 分类（0-10）
  final EquipmentCategory category;

  /// 重量
  final double weight;

  /// 重量单位
  final EquipmentWeightUnit weightUnit;

  /// 数量（必须 > 0）
  final int quantity;

  const EquipmentItemUpsertRequest({
    required this.name,
    required this.category,
    required this.weight,
    required this.weightUnit,
    this.quantity = 1,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'category': category.toCode(),
        'weight': weight,
        'weightUnit': weightUnit.toCode(),
        'quantity': quantity,
      };
}
