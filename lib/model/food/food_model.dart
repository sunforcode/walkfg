/// 食物模型类
///
/// 用于存储食物和膳食计划的信息

import 'package:json_annotation/json_annotation.dart';
import '../base/base_model.dart';

part 'food_model.g.dart';

/// 食物类型
enum FoodType {
  breakfast,
  lunch,
  dinner,
  snack,
  drink
}

/// 食物模型
@JsonSerializable()
class FoodModel extends BaseModel {
  /// 食物ID
  final String id;

  /// 食物名称
  final String name;

  /// 食物描述
  final String description;

  /// 食物类型
  final FoodType type;

  /// 卡路里(kcal/100g)
  final double calories;

  /// 蛋白质(g/100g)
  final double protein;

  /// 脂肪(g/100g)
  final double fat;

  /// 碳水化合物(g/100g)
  final double carbs;

  /// 重量(g)
  final double weight;

  /// 单价(元)
  final double price;

  /// 创建时间
  final DateTime? createdAt;

  /// 更新时间
  final DateTime? updatedAt;

  /// 构造函数
  FoodModel({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
    required this.weight,
    required this.price,
    this.createdAt,
    this.updatedAt,
  });

  /// 从JSON创建食物模型
  factory FoodModel.fromJson(Map<String, dynamic> json) =>
      _$FoodModelFromJson(json);

  /// 转换为JSON
  @override
  Map<String, dynamic> toJson() => _$FoodModelToJson(this);

  /// 创建副本并更新指定字段
  FoodModel copyWith({
    String? id,
    String? name,
    String? description,
    FoodType? type,
    double? calories,
    double? protein,
    double? fat,
    double? carbs,
    double? weight,
    double? price,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FoodModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      fat: fat ?? this.fat,
      carbs: carbs ?? this.carbs,
      weight: weight ?? this.weight,
      price: price ?? this.price,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 获取总卡路里
  double get totalCalories => calories * weight / 100;

  /// 获取总蛋白质
  double get totalProtein => protein * weight / 100;

  /// 获取总脂肪
  double get totalFat => fat * weight / 100;

  /// 获取总碳水化合物
  double get totalCarbs => carbs * weight / 100;

  /// 获取食物类型名称
  String getTypeName() {
    switch (type) {
      case FoodType.breakfast:
        return '早餐';
      case FoodType.lunch:
        return '午餐';
      case FoodType.dinner:
        return '晚餐';
      case FoodType.snack:
        return '零食';
      case FoodType.drink:
        return '饮料';
      default:
        return '其他';
    }
  }
}