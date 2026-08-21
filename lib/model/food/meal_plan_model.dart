/// 膳食计划模型
///
/// 用于表示整个行程的膳食计划，包含多个每日膳食计划
///
/// MealPlanModel是食物模块的顶层模型，代表一个完整行程的膳食规划方案。
/// 它整合了多个每日膳食计划，并提供了整体层面的信息和计算功能，用于：
///
/// 1. 管理整个行程的膳食安排，包括多天的食物计划
/// 2. 计算行程的总重量、总卡路里和总营养成分
/// 3. 计算每人每日的平均摄入量，帮助评估膳食计划的合理性
/// 4. 存储行程和创建者信息，便于分享和查找
///
/// 在户外活动规划中，合理的膳食计划对于活动的成功至关重要。
/// 这个模型通过整合每日膳食计划，提供了全局视角的食物管理和分析功能，
/// 帮助用户在保证营养和能量供应的同时，优化食物的重量和成本。

import '../base/base_model.dart';
import 'package:json_annotation/json_annotation.dart';
import 'day_meal_plan_model.dart';
import 'food_item_model.dart';

part 'meal_plan_model.g.dart';

/// 食物计划状态枚举
enum MealPlanStatus {
  /// 草稿
  draft,
  /// 已确认
  confirmed,
}

MealPlanStatus _parseMealPlanStatus(dynamic value) {
  if (value is String) {
    switch (value.toLowerCase()) {
      case 'draft': return MealPlanStatus.draft;
      case 'confirmed': return MealPlanStatus.confirmed;
    }
  }
  return MealPlanStatus.draft;
}

String _mealPlanStatusToJson(MealPlanStatus status) {
  return status.name;
}

/// 膳食计划模型
@JsonSerializable()
class MealPlanModel extends BaseModel {
  /// 计划名称
  final String name;

  /// 计划描述
  final String description;

  /// 行程天数
  @JsonKey(name: 'trip_days')
  final int tripDays;

  /// 人数
  @JsonKey(name: 'person_count')
  final int personCount;

  /// 每日膳食计划
  @JsonKey(name: 'day_meal_plans')
  final List<DayMealPlanModel> dayMealPlans;

  /// 标签
  final List<String> tags;

  /// 创建者ID
  @JsonKey(name: 'creator_id')
  final String creatorId;

  /// 创建者名称
  @JsonKey(name: 'creator_name')
  final String creatorName;

  /// 计划状态
  @JsonKey(fromJson: _parseMealPlanStatus, toJson: _mealPlanStatusToJson)
  final MealPlanStatus status;

  /// 每日餐数
  @JsonKey(name: 'meals_per_day')
  final int? mealsPerDay;

  /// 构造函数
  MealPlanModel({
    required super.id,
    super.createdAt,
    super.updatedAt,
    required this.name,
    required this.description,
    required this.tripDays,
    required this.personCount,
    required this.dayMealPlans,
    this.tags = const [],
    required this.creatorId,
    required this.creatorName,
    this.status = MealPlanStatus.draft,
    this.mealsPerDay,
  });

  /// 从JSON创建
  factory MealPlanModel.fromJson(Map<String, dynamic> json) =>
      _$MealPlanModelFromJson(json);

  /// 转换为JSON
  @override
  Map<String, dynamic> toJson() => _$MealPlanModelToJson(this);

  /// 获取总重量(g)
  double get totalWeight {
    return dayMealPlans.fold(0.0, (sum, day) => sum + day.totalWeight);
  }

  /// 获取总卡路里
  double get totalCalories {
    return dayMealPlans.fold(0.0, (sum, day) => sum + day.totalCalories);
  }

  /// 获取总蛋白质(g)
  double get totalProtein {
    return dayMealPlans.fold(0.0, (sum, day) => sum + day.totalProtein);
  }

  /// 获取总脂肪(g)
  double get totalFat {
    return dayMealPlans.fold(0.0, (sum, day) => sum + day.totalFat);
  }

  /// 获取总碳水化合物(g)
  double get totalCarbs {
    return dayMealPlans.fold(0.0, (sum, day) => sum + day.totalCarbs);
  }

  /// 获取每人每日平均重量(g)
  double get weightPerPersonPerDay {
    return totalWeight / (personCount * tripDays);
  }

  /// 获取每人每日平均卡路里
  double get caloriesPerPersonPerDay {
    return totalCalories / (personCount * tripDays);
  }

  /// 获取每人每日平均蛋白质(g)
  double get proteinPerPersonPerDay {
    return totalProtein / (personCount * tripDays);
  }

  /// 获取每人每日平均脂肪(g)
  double get fatPerPersonPerDay {
    return totalFat / (personCount * tripDays);
  }

  /// 获取每人每日平均碳水化合物(g)
  double get carbsPerPersonPerDay {
    return totalCarbs / (personCount * tripDays);
  }

  /// 获取所有食物项目列表
  List<FoodItemModel> get allItems {
    final List<FoodItemModel> result = [];
    for (final dayPlan in dayMealPlans) {
      result.addAll(dayPlan.breakfast);
      result.addAll(dayPlan.lunch);
      result.addAll(dayPlan.dinner);
      result.addAll(dayPlan.snacks);
      result.addAll(dayPlan.drinks);
    }
    return result;
  }

  /// 获取总食物项目数
  int get totalItemCount => allItems.length;

  /// 获取总食物项目数（去重）
  int get uniqueItemCount {
    final uniqueItems = <String>{};
    for (final item in allItems) {
      uniqueItems.add(item.id);
    }
    return uniqueItems.length;
  }

  /// 获取总价格
  double get totalPrice {
    return allItems.fold(
        0.0, (sum, item) => sum + (item.price * item.quantity));
  }

  /// 获取每人平均价格
  double get pricePerPerson {
    return totalPrice / personCount;
  }

  /// 创建副本并更新指定字段
  MealPlanModel copyWith({
    String? id,
    String? name,
    String? description,
    int? tripDays,
    int? personCount,
    List<DayMealPlanModel>? dayMealPlans,
    List<String>? tags,
    String? creatorId,
    String? creatorName,
    MealPlanStatus? status,
    int? mealsPerDay,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MealPlanModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      tripDays: tripDays ?? this.tripDays,
      personCount: personCount ?? this.personCount,
      dayMealPlans: dayMealPlans ?? this.dayMealPlans,
      tags: tags ?? this.tags,
      creatorId: creatorId ?? this.creatorId,
      creatorName: creatorName ?? this.creatorName,
      status: status ?? this.status,
      mealsPerDay: mealsPerDay ?? this.mealsPerDay,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
