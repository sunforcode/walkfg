/// 饮水计划模型
///
/// 用于表示整个行程的饮水计划，记录饮水需求和水源信息
///
/// WaterPlanModel是饮水模块的顶层模型，代表一个完整行程的饮水规划方案。
/// 它记录了行程的总饮水需求、可用水源和携带水量，帮助用户确保在户外活动中
/// 获得充足的饮用水。

import '../base/base_model.dart';
import 'package:json_annotation/json_annotation.dart';
import 'day_water_plan_model.dart';
import 'water_source_model.dart';

part 'water_plan_model.g.dart';

/// 饮水计划模型
@JsonSerializable()
class WaterPlanModel extends BaseModel {
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

  /// 每日饮水计划
  @JsonKey(name: 'day_water_plans')
  final List<DayWaterPlanModel> dayWaterPlans;

  /// 水源补给点
  @JsonKey(name: 'water_sources')
  final List<WaterSourceModel> waterSources;

  /// 标签
  final List<String> tags;

  /// 创建者ID
  @JsonKey(name: 'creator_id')
  final String creatorId;

  /// 创建者名称
  @JsonKey(name: 'creator_name')
  final String creatorName;

  /// 构造函数
  WaterPlanModel({
    required super.id,
    super.createdAt,
    super.updatedAt,
    required this.name,
    required this.description,
    required this.tripDays,
    required this.personCount,
    required this.dayWaterPlans,
    this.waterSources = const [],
    this.tags = const [],
    required this.creatorId,
    required this.creatorName,
  });

  /// 从JSON创建
  factory WaterPlanModel.fromJson(Map<String, dynamic> json) =>
      _$WaterPlanModelFromJson(json);

  /// 转换为JSON
  @override
  Map<String, dynamic> toJson() => _$WaterPlanModelToJson(this);

  /// 获取总饮水需求(ml)
  int get totalWaterNeed {
    return dayWaterPlans.fold(0, (sum, day) => sum + day.totalWaterNeed);
  }

  /// 获取每人每日平均饮水需求(ml)
  int get waterPerPersonPerDay {
    return totalWaterNeed ~/ (personCount * tripDays);
  }

  /// 创建副本并更新指定字段
  WaterPlanModel copyWith({
    String? id,
    String? name,
    String? description,
    int? tripDays,
    int? personCount,
    List<DayWaterPlanModel>? dayWaterPlans,
    List<WaterSourceModel>? waterSources,
    List<String>? tags,
    String? creatorId,
    String? creatorName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WaterPlanModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      tripDays: tripDays ?? this.tripDays,
      personCount: personCount ?? this.personCount,
      dayWaterPlans: dayWaterPlans ?? this.dayWaterPlans,
      waterSources: waterSources ?? this.waterSources,
      tags: tags ?? this.tags,
      creatorId: creatorId ?? this.creatorId,
      creatorName: creatorName ?? this.creatorName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
