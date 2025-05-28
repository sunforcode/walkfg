/// 食物项目模型
///
/// 用于表示单个食物项目的详细信息
///
/// FoodItemModel是食物模块的基础单元，代表一种具体的食物，如"即食燕麦片"、"能量棒"等。
/// 它包含了食物的基本信息、营养成分、重量和价格等关键数据，用于：
///
/// 1. 记录食物的详细属性，包括名称、重量、卡路里、蛋白质、脂肪和碳水化合物等
/// 2. 计算食物的总重量、总卡路里和总营养成分
/// 3. 计算食物的能量密度，帮助评估食物在户外活动中的效率
/// 4. 跟踪食物的准备状态，方便行前检查
///
/// 这个模型设计考虑了户外活动中对食物重量和营养平衡的特殊需求，
/// 营养成分按照每100克计算，便于与食品标签对照。

import '../base/base_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'food_item_model.g.dart';

/// 食物项目模型
@JsonSerializable()
class FoodItemModel extends BaseModel {
  /// 名称
  final String name;

  /// 描述
  final String? description;

  /// 重量(g)
  final double weight;

  /// 数量
  final int quantity;

  /// 卡路里(kcal/100g)
  final double calories;

  /// 蛋白质(g/100g)
  final double protein;

  /// 脂肪(g/100g)
  final double fat;

  /// 碳水化合物(g/100g)
  final double carbs;

  /// 单价(元)
  final double price;

  /// 是否已准备
  final bool prepared;

  /// 是否已拥有
  @JsonKey(name: 'is_owned')
  final bool isOwned;

  /// 备注
  final String? notes;

  /// 构造函数
  FoodItemModel({
    required super.id,
    super.createdAt,
    super.updatedAt,
    required this.name,
    this.description,
    required this.weight,
    this.quantity = 1,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
    required this.price,
    this.prepared = false,
    this.isOwned = false,
    this.notes,
  });

  /// 从JSON创建
  factory FoodItemModel.fromJson(Map<String, dynamic> json) =>
      _$FoodItemModelFromJson(json);

  /// 转换为JSON
  @override
  Map<String, dynamic> toJson() => _$FoodItemModelToJson(this);

  /// 获取总重量(g)
  double get totalWeight => weight * quantity;

  /// 获取总卡路里
  double get totalCalories => calories * totalWeight / 100;

  /// 获取总蛋白质(g)
  double get totalProtein => protein * totalWeight / 100;

  /// 获取总脂肪(g)
  double get totalFat => fat * totalWeight / 100;

  /// 获取总碳水化合物(g)
  double get totalCarbs => carbs * totalWeight / 100;

  /// 获取能量密度(kcal/g)
  double get energyDensity => calories / 100;

  /// 获取总价格(元)
  double get totalPrice => price * quantity;

  /// 获取重量文本
  String getWeightText() {
    if (totalWeight >= 1000) {
      return '${(totalWeight / 1000).toStringAsFixed(1)}kg';
    } else {
      return '${totalWeight.toStringAsFixed(0)}g';
    }
  }

  /// 获取价格文本
  String getPriceText() {
    return '¥${totalPrice.toStringAsFixed(2)}';
  }

  /// 创建副本并更新指定字段
  FoodItemModel copyWith({
    String? id,
    String? name,
    String? description,
    double? weight,
    int? quantity,
    double? calories,
    double? protein,
    double? fat,
    double? carbs,
    double? price,
    bool? prepared,
    bool? isOwned,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FoodItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      weight: weight ?? this.weight,
      quantity: quantity ?? this.quantity,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      fat: fat ?? this.fat,
      carbs: carbs ?? this.carbs,
      price: price ?? this.price,
      prepared: prepared ?? this.prepared,
      isOwned: isOwned ?? this.isOwned,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
