import 'package:json_annotation/json_annotation.dart';
import '../base/base_model.dart';
import 'equipment_necessity.dart';
import 'equipment_category.dart';
import 'equipment_condition.dart';
import 'weight_unit.dart';

part 'equipment_item_model.g.dart';

/// 装备项目模型 - 统一的装备项目表示
@JsonSerializable()
class EquipmentItemModel extends BaseModel {
  /// 名称
  final String name;

  /// 分类
  @JsonKey(fromJson: _categoryFromJson, toJson: _categoryToJson)
  final EquipmentCategory category;

  /// 描述
  final String? description;

  /// 重量(g)
  final double weight;

  /// 重量单位
  @JsonKey(
      name: 'weight_unit',
      fromJson: _weightUnitFromJson,
      toJson: _weightUnitToJson)
  final WeightUnit weightUnit;

  /// 数量
  final int quantity;

  /// 必要性
  @JsonKey(fromJson: _necessityFromJson, toJson: _necessityToJson)
  final EquipmentNecessity necessity;

  /// 是否已准备
  final bool prepared;

  /// 品牌
  final String? brand;

  /// 型号
  final String? model;

  /// 价格
  final double? price;

  /// 备注
  final String? notes;

  /// 是否拥有
  @JsonKey(name: 'is_owned')
  final bool isOwned;

  /// 是否共享装备
  @JsonKey(name: 'is_shared')
  final bool isShared;

  /// 共享人数
  @JsonKey(name: 'shared_person_count')
  final int? sharedPersonCount;

  /// 购买链接
  @JsonKey(name: 'purchase_link')
  final String? purchaseLink;

  /// 购买日期
  @JsonKey(name: 'purchase_date')
  final DateTime? purchaseDate;

  /// 使用次数
  @JsonKey(name: 'usage_count')
  final int usageCount;

  /// 使用状态
  @JsonKey(fromJson: _conditionFromJson, toJson: _conditionToJson)
  final EquipmentCondition condition;

  /// 替代品列表（可替代此装备的其他装备ID）
  @JsonKey(name: 'alternative_ids')
  final List<String> alternativeIds;

  /// 装备图片URL
  @JsonKey(name: 'image_url')
  final String? imageUrl;

  /// 构造函数
  EquipmentItemModel({
    required super.id,
    super.createdAt,
    super.updatedAt,
    required this.name,
    required this.category,
    this.description,
    this.weight = 0,
    this.weightUnit = WeightUnit.gram,
    this.quantity = 1,
    this.necessity = EquipmentNecessity.recommended,
    this.prepared = false,
    this.brand,
    this.model,
    this.price,
    this.notes,
    this.isOwned = true,
    this.isShared = false,
    this.sharedPersonCount,
    this.purchaseLink,
    this.purchaseDate,
    this.usageCount = 0,
    this.condition = EquipmentCondition.good,
    this.alternativeIds = const [],
    this.imageUrl,
  });

  /// 从JSON创建
  factory EquipmentItemModel.fromJson(Map<String, dynamic> json) =>
      _$EquipmentItemModelFromJson(json);

  /// 转换为JSON
  @override
  Map<String, dynamic> toJson() => _$EquipmentItemModelToJson(this);

  /// 解析分类
  static EquipmentCategory _categoryFromJson(dynamic category) {
    if (category is String) {
      return parseCategoryFromString(category);
    } else if (category is int &&
        category >= 0 &&
        category < EquipmentCategory.values.length) {
      return EquipmentCategory.values[category];
    }
    return EquipmentCategory.other;
  }

  /// 分类转JSON
  static String _categoryToJson(EquipmentCategory category) {
    return getCategoryName(category);
  }

  /// 解析必要性
  static EquipmentNecessity _necessityFromJson(dynamic necessity) {
    if (necessity is int &&
        necessity >= 0 &&
        necessity < EquipmentNecessity.values.length) {
      return EquipmentNecessity.values[necessity];
    } else if (necessity is bool) {
      // 兼容旧版本的isEssential字段
      return necessity
          ? EquipmentNecessity.essential
          : EquipmentNecessity.recommended;
    }
    return EquipmentNecessity.recommended;
  }

  /// 必要性转JSON
  static int _necessityToJson(EquipmentNecessity necessity) {
    return necessity.index;
  }

  /// 解析重量单位
  static WeightUnit _weightUnitFromJson(dynamic unit) {
    if (unit is String) {
      return parseWeightUnitFromString(unit);
    } else if (unit is int && unit >= 0 && unit < WeightUnit.values.length) {
      return WeightUnit.values[unit];
    }
    return WeightUnit.gram;
  }

  /// 重量单位转JSON
  static String _weightUnitToJson(WeightUnit unit) {
    return getWeightUnitName(unit);
  }

  /// 解析使用状态
  static EquipmentCondition _conditionFromJson(dynamic condition) {
    if (condition is String) {
      return parseConditionFromString(condition);
    } else if (condition is int &&
        condition >= 0 &&
        condition < EquipmentCondition.values.length) {
      return EquipmentCondition.values[condition];
    }
    return EquipmentCondition.good;
  }

  /// 使用状态转JSON
  static String _conditionToJson(EquipmentCondition condition) {
    return getConditionName(condition);
  }

  /// 获取总重量
  double get totalWeight => weight * quantity;

  /// 获取每人分摊重量
  double get weightPerPerson => isShared && (sharedPersonCount ?? 0) > 0
      ? totalWeight / sharedPersonCount!
      : totalWeight;

  /// 获取重量文本
  String getWeightText() {
    if (weight >= 1000) {
      return '${(weight / 1000).toStringAsFixed(1)}kg';
    } else {
      return '${weight.toStringAsFixed(0)}g';
    }
  }

  /// 获取总重量文本
  String getTotalWeightText() {
    final total = totalWeight;
    if (total >= 1000) {
      return '${(total / 1000).toStringAsFixed(1)}kg';
    } else {
      return '${total.toStringAsFixed(0)}g';
    }
  }

  /// 获取价格文本
  String? getPriceText() {
    if (price == null) return null;
    return '¥${price!.toStringAsFixed(2)}';
  }

  /// 获取品牌型号文本
  String? getBrandModelText() {
    if (brand != null && model != null) {
      return '$brand $model';
    } else if (brand != null) {
      return brand;
    } else if (model != null) {
      return model;
    } else {
      return null;
    }
  }

  /// 获取必要性名称
  String getNecessityText() {
    return getNecessityName(necessity);
  }

  /// 获取分类名称
  String getCategoryText() {
    return getCategoryName(category);
  }

  /// 获取使用状态文本
  String getConditionText() {
    return getConditionName(condition);
  }

  /// 获取装备是否需要更换
  bool get needsReplacement =>
      condition == EquipmentCondition.poor ||
      condition == EquipmentCondition.damaged;

  /// 创建副本并更新部分属性
  EquipmentItemModel copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? name,
    EquipmentCategory? category,
    String? description,
    double? weight,
    WeightUnit? weightUnit,
    int? quantity,
    EquipmentNecessity? necessity,
    bool? prepared,
    String? brand,
    String? model,
    double? price,
    String? notes,
    bool? isOwned,
    bool? isShared,
    int? sharedPersonCount,
    String? purchaseLink,
    DateTime? purchaseDate,
    int? usageCount,
    EquipmentCondition? condition,
    List<String>? alternativeIds,
    String? imageUrl,
  }) {
    return EquipmentItemModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      weight: weight ?? this.weight,
      weightUnit: weightUnit ?? this.weightUnit,
      quantity: quantity ?? this.quantity,
      necessity: necessity ?? this.necessity,
      prepared: prepared ?? this.prepared,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      price: price ?? this.price,
      notes: notes ?? this.notes,
      isOwned: isOwned ?? this.isOwned,
      isShared: isShared ?? this.isShared,
      sharedPersonCount: sharedPersonCount ?? this.sharedPersonCount,
      purchaseLink: purchaseLink ?? this.purchaseLink,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      usageCount: usageCount ?? this.usageCount,
      condition: condition ?? this.condition,
      alternativeIds: alternativeIds ?? this.alternativeIds,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
