import 'package:json_annotation/json_annotation.dart';
import '../base/base_model.dart';

part 'gear_recommendation_model.g.dart';

/// 装备推荐模型
@JsonSerializable()
class GearRecommendationModel {
  /// 路线ID
  final String routeId;
  
  /// 季节装备
  final SeasonalGearModel seasonalGear;
  
  /// 必备装备
  final List<GearItemModel> essentialGear;
  
  /// 可选装备
  final List<GearItemModel> optionalGear;
  
  /// 专业装备
  final List<GearItemModel> specializedGear;

  /// 构造函数
  GearRecommendationModel({
    required this.routeId,
    required this.seasonalGear,
    required this.essentialGear,
    required this.optionalGear,
    required this.specializedGear,
  });

  /// 从JSON创建
  factory GearRecommendationModel.fromJson(Map<String, dynamic> json) => _$GearRecommendationModelFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$GearRecommendationModelToJson(this);
}

/// 季节装备模型
@JsonSerializable()
class SeasonalGearModel {
  /// 春季装备
  final List<GearItemModel> spring;
  
  /// 夏季装备
  final List<GearItemModel> summer;
  
  /// 秋季装备
  final List<GearItemModel> autumn;
  
  /// 冬季装备
  final List<GearItemModel> winter;

  /// 构造函数
  SeasonalGearModel({
    required this.spring,
    required this.summer,
    required this.autumn,
    required this.winter,
  });

  /// 从JSON创建
  factory SeasonalGearModel.fromJson(Map<String, dynamic> json) => _$SeasonalGearModelFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$SeasonalGearModelToJson(this);
}

/// 装备必要性枚举
enum GearNecessity {
  /// 必需
  essential,
  
  /// 推荐
  recommended,
  
  /// 可选
  optional
}

/// 装备项目模型 (合并了GearItemModel和EquipmentItem)
@JsonSerializable()
class GearItemModel extends BaseModel {
  /// 类别
  final String category;
  
  /// 名称
  final String name;
  
  /// 描述
  final String? description;
  
  /// 重要性
  @JsonKey(fromJson: _parseNecessity, toJson: _necessityToJson)
  final GearNecessity necessity;
  
  /// 重量范围(g)
  final WeightRangeModel weight;
  
  /// 估计成本范围(元)
  final CostRangeModel estimatedCost;
  
  /// 是否可租赁
  final bool rentalAvailability;
  
  /// 是否可共享
  final bool sharable;
  
  /// 品牌
  final String? brand;
  
  /// 型号
  final String? model;
  
  /// 数量
  final int quantity;
  
  /// 价格
  final double? price;
  
  /// 备注
  final String? notes;
  
  /// 替代品ID列表
  final List<String>? alternatives;

  /// 构造函数
  GearItemModel({
    required super.id,
    super.createdAt,
    super.updatedAt,
    required this.category,
    required this.name,
    this.description,
    required this.necessity,
    required this.weight,
    required this.estimatedCost,
    required this.rentalAvailability,
    required this.sharable,
    this.brand,
    this.model,
    this.quantity = 1,
    this.price,
    this.notes,
    this.alternatives,
  });

  /// 从JSON创建
  factory GearItemModel.fromJson(Map<String, dynamic> json) => _$GearItemModelFromJson(json);

  /// 转换为JSON
  @override
  Map<String, dynamic> toJson() => _$GearItemModelToJson(this);
  
  /// 解析必要性
  static GearNecessity _parseNecessity(dynamic necessity) {
    if (necessity is int && necessity >= 0 && necessity < GearNecessity.values.length) {
      return GearNecessity.values[necessity];
    } else if (necessity is String) {
      switch (necessity.toLowerCase()) {
        case 'essential':
          return GearNecessity.essential;
        case 'recommended':
          return GearNecessity.recommended;
        case 'optional':
          return GearNecessity.optional;
        default:
          return GearNecessity.optional;
      }
    }
    return GearNecessity.optional;
  }
  
  /// 必要性转JSON
  static int _necessityToJson(GearNecessity necessity) {
    return necessity.index;
  }
  
  /// 获取总重量
  double get totalWeight => weight.average.toDouble() * quantity;
  
  /// 获取总成本
  double get totalCost => estimatedCost.average.toDouble() * quantity;
  
  /// 获取必要性名称
  String getNecessityName() {
    switch (necessity) {
      case GearNecessity.essential:
        return '必需';
      case GearNecessity.recommended:
        return '推荐';
      case GearNecessity.optional:
        return '可选';
    }
  }
  
  /// 获取必要性颜色代码
  int getNecessityColor() {
    switch (necessity) {
      case GearNecessity.essential:
        return 0xFFF44336; // 红色
      case GearNecessity.recommended:
        return 0xFFFF9800; // 橙色
      case GearNecessity.optional:
        return 0xFF2196F3; // 蓝色
    }
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
  
  /// 获取价格文本
  String? getPriceText() {
    if (price == null) return null;
    return '¥${price!.toStringAsFixed(2)}';
  }
}

/// 重量范围模型
@JsonSerializable()
class WeightRangeModel {
  /// 最小重量(g)
  final int min;
  
  /// 最大重量(g)
  final int max;

  /// 构造函数
  WeightRangeModel({
    required this.min,
    required this.max,
  });

  /// 从JSON创建
  factory WeightRangeModel.fromJson(Map<String, dynamic> json) => _$WeightRangeModelFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$WeightRangeModelToJson(this);
  
  /// 获取平均重量
  int get average => (min + max) ~/ 2;
  
  /// 获取重量范围文本
  String getWeightRangeText() {
    if (min >= 1000 && max >= 1000) {
      return '${(min / 1000).toStringAsFixed(1)}-${(max / 1000).toStringAsFixed(1)}kg';
    } else if (min >= 1000) {
      return '${(min / 1000).toStringAsFixed(1)}kg-${max}g';
    } else if (max >= 1000) {
      return '${min}g-${(max / 1000).toStringAsFixed(1)}kg';
    } else {
      return '$min-${max}g';
    }
  }
}

/// 成本范围模型
@JsonSerializable()
class CostRangeModel {
  /// 最小成本(元)
  final int min;
  
  /// 最大成本(元)
  final int max;

  /// 构造函数
  CostRangeModel({
    required this.min,
    required this.max,
  });

  /// 从JSON创建
  factory CostRangeModel.fromJson(Map<String, dynamic> json) => _$CostRangeModelFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$CostRangeModelToJson(this);
  
  /// 获取平均成本
  int get average => (min + max) ~/ 2;
  
  /// 获取成本范围文本
  String getCostRangeText() {
    return '¥$min-¥$max';
  }
}
