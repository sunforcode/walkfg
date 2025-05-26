import 'package:json_annotation/json_annotation.dart';
import '../base/base_model.dart';
import 'equipment_item_model.dart';
import 'equipment_category.dart';
import 'equipment_condition.dart';

part 'user_equipment_inventory_model.g.dart';

/// 用户装备库模型
@JsonSerializable()
class UserEquipmentInventoryModel extends BaseModel {
  /// 用户ID
  final String userId;
  
  /// 用户拥有的装备列表
  @JsonKey(fromJson: _equipmentsFromJson, toJson: _equipmentsToJson)
  final List<EquipmentItemModel> equipments;
  
  /// 最后更新时间
  final DateTime lastUpdatedAt;
  
  /// 构造函数
  UserEquipmentInventoryModel({
    required super.id,
    super.createdAt,
    super.updatedAt,
    required this.userId,
    required this.equipments,
    required this.lastUpdatedAt,
  });
  
  /// 从JSON创建
  factory UserEquipmentInventoryModel.fromJson(Map<String, dynamic> json) =>
      _$UserEquipmentInventoryModelFromJson(json);
  
  /// 转换为JSON
  @override
  Map<String, dynamic> toJson() => _$UserEquipmentInventoryModelToJson(this);
  
  /// 装备列表从JSON转换
  static List<EquipmentItemModel> _equipmentsFromJson(List<dynamic> list) {
    return list
        .map((i) => EquipmentItemModel.fromJson(i as Map<String, dynamic>))
        .toList();
  }

  /// 装备列表转JSON
  static List<Map<String, dynamic>> _equipmentsToJson(
      List<EquipmentItemModel> equipments) {
    return equipments.map((e) => e.toJson()).toList();
  }
  
  /// 获取总装备数
  int get totalItems => equipments.length;
  
  /// 获取装备总价值
  double get totalValue => equipments.fold(
      0, (sum, item) => sum + (item.price ?? 0) * item.quantity);
  
  /// 获取分类分布
  List<CategoryDistribution> getCategoryDistribution() {
    final Map<EquipmentCategory, CategoryDistribution> distribution = {};
    
    for (final item in equipments) {
      if (!distribution.containsKey(item.category)) {
        distribution[item.category] = CategoryDistribution(
          category: item.category,
          count: 0,
          value: 0,
        );
      }
      
      distribution[item.category]!.count++;
      distribution[item.category]!.value += (item.price ?? 0) * item.quantity;
    }
    
    return distribution.values.toList();
  }
  
  /// 获取状态分布
  List<ConditionDistribution> getConditionDistribution() {
    final Map<EquipmentCondition, ConditionDistribution> distribution = {};
    
    for (final item in equipments) {
      if (!distribution.containsKey(item.condition)) {
        distribution[item.condition] = ConditionDistribution(
          condition: item.condition,
          count: 0,
        );
      }
      
      distribution[item.condition]!.count++;
    }
    
    return distribution.values.toList();
  }
  
  /// 获取需要维护的装备
  List<EquipmentItemModel> getItemsNeedingMaintenance() {
    return equipments.where((item) => 
        item.condition == EquipmentCondition.poor || 
        item.condition == EquipmentCondition.damaged).toList();
  }
  
  /// 获取按分类筛选的装备
  List<EquipmentItemModel> getItemsByCategory(EquipmentCategory category) {
    return equipments.where((item) => item.category == category).toList();
  }
  
  /// 获取按状态筛选的装备
  List<EquipmentItemModel> getItemsByCondition(EquipmentCondition condition) {
    return equipments.where((item) => item.condition == condition).toList();
  }
  
  /// 搜索装备
  List<EquipmentItemModel> searchItems(String keyword) {
    final lowerKeyword = keyword.toLowerCase();
    return equipments.where((item) => 
        item.name.toLowerCase().contains(lowerKeyword) ||
        (item.description?.toLowerCase().contains(lowerKeyword) ?? false) ||
        (item.brand?.toLowerCase().contains(lowerKeyword) ?? false) ||
        (item.model?.toLowerCase().contains(lowerKeyword) ?? false) ||
        (item.notes?.toLowerCase().contains(lowerKeyword) ?? false)
    ).toList();
  }
  
  /// 创建副本并更新指定字段
  UserEquipmentInventoryModel copyWith({
    String? id,
    String? userId,
    List<EquipmentItemModel>? equipments,
    DateTime? lastUpdatedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserEquipmentInventoryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      equipments: equipments ?? this.equipments,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// 分类分布
class CategoryDistribution {
  /// 装备分类
  final EquipmentCategory category;
  
  /// 装备数量
  int count;
  
  /// 装备总价值
  double value;
  
  /// 构造函数
  CategoryDistribution({
    required this.category,
    this.count = 0,
    this.value = 0,
  });
  
  /// 获取分类名称
  String get categoryName => getCategoryName(category);
  
  /// 转换为JSON
  Map<String, dynamic> toJson() => {
    'category': category.index,
    'category_name': categoryName,
    'count': count,
    'value': value,
  };
}

/// 状态分布
class ConditionDistribution {
  /// 装备状态
  final EquipmentCondition condition;
  
  /// 装备数量
  int count;
  
  /// 构造函数
  ConditionDistribution({
    required this.condition,
    this.count = 0,
  });
  
  /// 获取状态名称
  String get conditionName => getConditionName(condition);
  
  /// 转换为JSON
  Map<String, dynamic> toJson() => {
    'condition': condition.index,
    'condition_name': conditionName,
    'count': count,
  };
}