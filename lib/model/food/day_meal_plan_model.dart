/// 每日膳食计划模型
///
/// 用于表示一天的膳食安排，包括早餐、午餐、晚餐、零食和饮料
///
/// DayMealPlanModel是膳食计划的中间层，代表一天内的完整膳食安排。
/// 它将食物按照不同的膳食类型（早餐、午餐、晚餐、零食和饮料）进行组织，用于：
///
/// 1. 合理安排一天中的各餐食物，确保营养均衡和能量供应
/// 2. 计算一天内的总重量、总卡路里和总营养成分
/// 3. 方便按照膳食类型查找和管理食物
/// 4. 支持行程中按天取用食物，提高户外活动的组织效率
///
/// 在户外活动中，每日膳食计划需要考虑当天的活动强度和特点，
/// 例如，高强度徒步日可能需要更多的碳水化合物和总卡路里。
/// 这个模型通过分类存储和计算功能，帮助用户优化每日的食物安排。

import 'package:json_annotation/json_annotation.dart';
import 'food_item_model.dart';
import 'food_type.dart';

part 'day_meal_plan_model.g.dart';

/// 每日膳食计划模型
@JsonSerializable()
class DayMealPlanModel {
  /// 天数序号(从1开始)
  final int dayNumber;

  /// 早餐
  final List<FoodItemModel> breakfast;

  /// 午餐
  final List<FoodItemModel> lunch;

  /// 晚餐
  final List<FoodItemModel> dinner;

  /// 零食
  final List<FoodItemModel> snacks;

  /// 饮料
  final List<FoodItemModel> drinks;

  /// 构造函数
  DayMealPlanModel({
    required this.dayNumber,
    this.breakfast = const [],
    this.lunch = const [],
    this.dinner = const [],
    this.snacks = const [],
    this.drinks = const [],
  });

  /// 从JSON创建
  factory DayMealPlanModel.fromJson(Map<String, dynamic> json) =>
      _$DayMealPlanModelFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$DayMealPlanModelToJson(this);

  /// 获取所有食物项目
  List<FoodItemModel> get allFoodItems {
    return [...breakfast, ...lunch, ...dinner, ...snacks, ...drinks];
  }

  /// 获取总重量(g)
  double get totalWeight {
    return allFoodItems.fold(0.0, (sum, item) => sum + item.totalWeight);
  }

  /// 获取总卡路里
  double get totalCalories {
    return allFoodItems.fold(0.0, (sum, item) => sum + item.totalCalories);
  }

  /// 获取总蛋白质(g)
  double get totalProtein {
    return allFoodItems.fold(0.0, (sum, item) => sum + item.totalProtein);
  }

  /// 获取总脂肪(g)
  double get totalFat {
    return allFoodItems.fold(0.0, (sum, item) => sum + item.totalFat);
  }

  /// 获取总碳水化合物(g)
  double get totalCarbs {
    return allFoodItems.fold(0.0, (sum, item) => sum + item.totalCarbs);
  }

  /// 获取特定类型的食物
  List<FoodItemModel> getFoodByType(FoodType type) {
    switch (type) {
      case FoodType.breakfast:
        return breakfast;
      case FoodType.lunch:
        return lunch;
      case FoodType.dinner:
        return dinner;
      case FoodType.snack:
        return snacks;
      case FoodType.drink:
        return drinks;
    }
  }

  /// 创建副本并更新指定字段
  DayMealPlanModel copyWith({
    int? dayNumber,
    List<FoodItemModel>? breakfast,
    List<FoodItemModel>? lunch,
    List<FoodItemModel>? dinner,
    List<FoodItemModel>? snacks,
    List<FoodItemModel>? drinks,
  }) {
    return DayMealPlanModel(
      dayNumber: dayNumber ?? this.dayNumber,
      breakfast: breakfast ?? this.breakfast,
      lunch: lunch ?? this.lunch,
      dinner: dinner ?? this.dinner,
      snacks: snacks ?? this.snacks,
      drinks: drinks ?? this.drinks,
    );
  }
}
