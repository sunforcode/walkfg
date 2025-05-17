/// 装备模型类
///
/// 用于存储装备清单、分类和项目信息

import '../base/base_model.dart';

/// 装备必要性
enum EquipmentNecessity {
  essential,
  recommended,
  optional
}

/// 装备季节适用性
enum SeasonSuitability {
  spring,
  summer,
  autumn,
  winter,
  allSeasons
}

/// 装备清单模型
class EquipmentListModel extends BaseModel {
  /// 清单名称
  final String name;

  /// 清单描述
  final String description;

  /// 路线ID
  final String? routeId;

  /// 路线名称
  final String? routeName;

  /// 行程天数
  final int tripDays;

  /// 季节
  final List<SeasonSuitability> seasons;

  /// 装备分类列表
  final List<EquipmentCategory> categories;

  /// 总重量(g)
  final double totalWeight;

  /// 基础重量(g)
  final double baseWeight;

  /// 消耗品重量(g)
  final double consumableWeight;

  /// 穿着重量(g)
  final double wornWeight;

  /// 创建者ID
  final String creatorId;

  /// 创建者名称
  final String creatorName;

  /// 标签
  final List<String> tags;

  /// 是否官方推荐
  final bool isOfficial;

  /// 构造函数
  EquipmentListModel({
    super.id,
    super.createdAt,
    super.updatedAt,
    required this.name,
    required this.description,
    this.routeId,
    this.routeName,
    required this.tripDays,
    required this.seasons,
    required this.categories,
    required this.totalWeight,
    required this.baseWeight,
    required this.consumableWeight,
    required this.wornWeight,
    required this.creatorId,
    required this.creatorName,
    required this.tags,
    this.isOfficial = false,
  });

  /// 获取每人每日平均重量
  double get weightPerPersonPerDay => totalWeight / tripDays;

  /// 获取总装备数
  int get totalItems => categories.fold(0, (sum, category) => sum + category.itemCount);

  /// 获取必需装备数
  int get essentialItems => categories.fold(0, (sum, category) => sum + category.essentialItems);

  /// 获取推荐装备数
  int get recommendedItems => categories.fold(0, (sum, category) => sum + category.recommendedItems);

  /// 获取可选装备数
  int get optionalItems => categories.fold(0, (sum, category) => sum + category.optionalItems);

  /// 获取季节名称列表
  List<String> getSeasonNames() {
    final seasonNames = <String>[];
    for (final season in seasons) {
      switch (season) {
        case SeasonSuitability.spring:
          seasonNames.add('春季');
          break;
        case SeasonSuitability.summer:
          seasonNames.add('夏季');
          break;
        case SeasonSuitability.autumn:
          seasonNames.add('秋季');
          break;
        case SeasonSuitability.winter:
          seasonNames.add('冬季');
          break;
        case SeasonSuitability.allSeasons:
          seasonNames.add('四季');
          break;
      }
    }
    return seasonNames;
  }

  /// 创建副本并更新指定字段
  EquipmentListModel copyWith({
    String? id,
    String? name,
    String? description,
    String? routeId,
    String? routeName,
    int? tripDays,
    List<SeasonSuitability>? seasons,
    List<EquipmentCategory>? categories,
    double? totalWeight,
    double? baseWeight,
    double? consumableWeight,
    double? wornWeight,
    String? creatorId,
    String? creatorName,
    List<String>? tags,
    bool? isOfficial,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EquipmentListModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      routeId: routeId ?? this.routeId,
      routeName: routeName ?? this.routeName,
      tripDays: tripDays ?? this.tripDays,
      seasons: seasons ?? this.seasons,
      categories: categories ?? this.categories,
      totalWeight: totalWeight ?? this.totalWeight,
      baseWeight: baseWeight ?? this.baseWeight,
      consumableWeight: consumableWeight ?? this.consumableWeight,
      wornWeight: wornWeight ?? this.wornWeight,
      creatorId: creatorId ?? this.creatorId,
      creatorName: creatorName ?? this.creatorName,
      tags: tags ?? this.tags,
      isOfficial: isOfficial ?? this.isOfficial,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// 装备分类
class EquipmentCategory {
  /// 分类名称
  final String name;

  /// 分类图标
  final String? icon;

  /// 分类描述
  final String? description;

  /// 装备项目列表
  final List<EquipmentItem> items;

  /// 构造函数
  EquipmentCategory({
    required this.name,
    this.icon,
    this.description,
    required this.items,
  });

  /// 获取装备项目数量
  int get itemCount => items.length;

  /// 获取总重量
  double get totalWeight => items.fold(0.0, (sum, item) => sum + item.totalWeight);

  /// 获取必需装备数
  int get essentialItems => items.where((item) => item.necessity == EquipmentNecessity.essential).length;

  /// 获取推荐装备数
  int get recommendedItems => items.where((item) => item.necessity == EquipmentNecessity.recommended).length;

  /// 获取可选装备数
  int get optionalItems => items.where((item) => item.necessity == EquipmentNecessity.optional).length;
}

/// 装备项目
class EquipmentItem {
  /// 项目名称
  final String name;

  /// 项目描述
  final String? description;

  /// 重量(g)
  final double weight;

  /// 数量
  final int quantity;

  /// 必要性
  final EquipmentNecessity necessity;

  /// 品牌
  final String? brand;

  /// 型号
  final String? model;

  /// 价格
  final double? price;

  /// 备注
  final String? notes;

  /// 构造函数
  EquipmentItem({
    required this.name,
    this.description,
    required this.weight,
    required this.quantity,
    required this.necessity,
    this.brand,
    this.model,
    this.price,
    this.notes,
  });

  /// 获取总重量
  double get totalWeight => weight * quantity;

  /// 获取重量文本
  String getWeightText() {
    if (weight >= 1000) {
      return '${(weight / 1000).toStringAsFixed(2)}kg';
    } else {
      return '${weight.toStringAsFixed(0)}g';
    }
  }

  /// 获取总重量文本
  String getTotalWeightText() {
    if (totalWeight >= 1000) {
      return '${(totalWeight / 1000).toStringAsFixed(2)}kg';
    } else {
      return '${totalWeight.toStringAsFixed(0)}g';
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
  String getNecessityName() {
    switch (necessity) {
      case EquipmentNecessity.essential:
        return '必需';
      case EquipmentNecessity.recommended:
        return '推荐';
      case EquipmentNecessity.optional:
        return '可选';
    }
  }

  /// 获取必要性颜色
  int getNecessityColor() {
    switch (necessity) {
      case EquipmentNecessity.essential:
        return 0xFFF44336; // 红色
      case EquipmentNecessity.recommended:
        return 0xFFFF9800; // 橙色
      case EquipmentNecessity.optional:
        return 0xFF2196F3; // 蓝色
    }
  }
}