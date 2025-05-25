/// 每日饮水计划模型
///
/// 用于表示一天的饮水安排，包括基础饮水量和活动饮水量
/// 
/// DayWaterPlanModel记录了一天中的饮水需求，根据活动强度和环境条件
/// 计算所需的饮水量，帮助用户合理安排每日饮水。

import 'package:json_annotation/json_annotation.dart';
import 'water_source_model.dart';
import 'water_types.dart';

part 'day_water_plan_model.g.dart';

/// 每日饮水计划模型
@JsonSerializable()
class DayWaterPlanModel {
  /// 天数序号(从1开始)
  final int dayNumber;
  
  /// 基础饮水量(ml)
  final int baseWaterIntake;
  
  /// 活动饮水量(ml)
  final int activityWaterIntake;
  
  /// 环境温度(°C)
  final double temperature;
  
  /// 活动强度
  final ActivityIntensity activityIntensity;
  
  /// 当天可用水源
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
    if (temperature > 30) return 1.5;      // 高温
    if (temperature > 25) return 1.3;      // 温暖
    if (temperature > 15) return 1.0;      // 适中
    if (temperature > 5) return 0.8;       // 凉爽
    return 0.7;                            // 寒冷
  }
  
  /// 获取活动强度调整系数
  double get intensityFactor {
    switch (activityIntensity) {
      case ActivityIntensity.low: return 0.8;
      case ActivityIntensity.moderate: return 1.0;
      case ActivityIntensity.high: return 1.3;
      case ActivityIntensity.veryHigh: return 1.5;
    }
  }
  
  /// 获取调整后的饮水需求(ml)
  int get adjustedWaterNeed {
    return (totalWaterNeed * temperatureFactor * intensityFactor).toInt();
  }
  
  /// 获取可用水源总量(ml)
  int get availableSourceWater {
    return availableSources.fold(0, (sum, source) => sum + source.estimatedVolume);
  }
  
  /// 获取活动强度文本
  String getIntensityText() {
    switch (activityIntensity) {
      case ActivityIntensity.low: return '低强度';
      case ActivityIntensity.moderate: return '中等强度';
      case ActivityIntensity.high: return '高强度';
      case ActivityIntensity.veryHigh: return '极高强度';
    }
  }
  
  /// 创建副本并更新指定字段
  DayWaterPlanModel copyWith({
    int? dayNumber,
    int? baseWaterIntake,
    int? activityWaterIntake,
    double? temperature,
    ActivityIntensity? activityIntensity,
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