/// 每日饮水计划模型
///
/// 用于表示一天的饮水需求和水源规划
///
/// DayWaterPlanModel是饮水计划的中间层，代表一天内的饮水安排。
/// 它记录了一天的基础饮水需求、活动饮水需求和可用水源，用于：
///
/// 1. 计算一天内的总饮水需求
/// 2. 记录当天的温度和活动强度，帮助评估饮水需求
/// 3. 记录当天可用的水源，帮助规划补水点
/// 4. 支持行程中按天规划饮水策略，确保水分供应

import 'package:json_annotation/json_annotation.dart';
import 'water_source_model.dart';
import 'water_types.dart';

part 'day_water_plan_model.g.dart';

/// 每日饮水计划模型
@JsonSerializable()
class DayWaterPlanModel {
  /// 天数序号(从1开始)
  @JsonKey(name: 'day_number')
  final int dayNumber;

  /// 基础饮水量(ml)
  @JsonKey(name: 'base_water_intake')
  final int baseWaterIntake;

  /// 活动饮水量(ml)
  @JsonKey(name: 'activity_water_intake')
  final int activityWaterIntake;

  /// 温度(°C)
  final double temperature;

  /// 活动强度
  @JsonKey(name: 'activity_intensity')
  final String activityIntensity;

  /// 可用水源
  @JsonKey(name: 'available_sources')
  final List<WaterSourceModel> availableSources;

  /// 构造函数
  DayWaterPlanModel({
    required this.dayNumber,
    required this.baseWaterIntake,
    required this.activityWaterIntake,
    required this.temperature,
    required this.activityIntensity,
    this.availableSources = const [],
  });

  /// 从JSON创建
  factory DayWaterPlanModel.fromJson(Map<String, dynamic> json) =>
      _$DayWaterPlanModelFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$DayWaterPlanModelToJson(this);

  /// 获取总饮水需求(ml)
  int get totalWaterNeed => baseWaterIntake + activityWaterIntake;

  /// 获取温度调整系数
  double get temperatureFactor {
    if (temperature > 30) return 1.5; // 高温
    if (temperature > 25) return 1.3; // 温暖
    if (temperature > 15) return 1.0; // 适中
    if (temperature > 5) return 0.8; // 凉爽
    return 0.7; // 寒冷
  }

  /// 获取活动强度调整系数
  double get intensityFactor {
    switch (getActivityIntensityLevel()) {
      case ActivityIntensity.low:
        return 0.8;
      case ActivityIntensity.medium:
        return 1.0;
      case ActivityIntensity.high:
        return 1.3;
      case ActivityIntensity.extreme:
        return 1.5;
    }
  }

  /// 获取调整后的饮水需求(ml)
  int get adjustedWaterNeed {
    return (totalWaterNeed * temperatureFactor * intensityFactor).toInt();
  }

  /// 获取活动强度级别
  ActivityIntensity getActivityIntensityLevel() {
    switch (activityIntensity.toLowerCase()) {
      case 'low':
        return ActivityIntensity.low;
      case 'medium':
        return ActivityIntensity.medium;
      case 'high':
        return ActivityIntensity.high;
      case 'extreme':
        return ActivityIntensity.extreme;
      default:
        return ActivityIntensity.medium;
    }
  }

  /// 获取活动强度文本
  String getIntensityText() {
    switch (getActivityIntensityLevel()) {
      case ActivityIntensity.low:
        return '低强度';
      case ActivityIntensity.medium:
        return '中等强度';
      case ActivityIntensity.high:
        return '高强度';
      case ActivityIntensity.extreme:
        return '极高强度';
    }
  }

  /// 创建副本并更新指定字段
  DayWaterPlanModel copyWith({
    int? dayNumber,
    int? baseWaterIntake,
    int? activityWaterIntake,
    double? temperature,
    String? activityIntensity,
    List<WaterSourceModel>? availableSources,
  }) {
    return DayWaterPlanModel(
      dayNumber: dayNumber ?? this.dayNumber,
      baseWaterIntake: baseWaterIntake ?? this.baseWaterIntake,
      activityWaterIntake: activityWaterIntake ?? this.activityWaterIntake,
      temperature: temperature ?? this.temperature,
      activityIntensity: activityIntensity ?? this.activityIntensity,
      availableSources: availableSources ?? this.availableSources,
    );
  }
}
