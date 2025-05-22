import 'package:json_annotation/json_annotation.dart';
import 'campsite_model.dart';

part 'daily_plan_model.g.dart';

/// 每日计划模型
@JsonSerializable()
class DailyPlanModel {
  /// 第几天
  final int day;
  
  /// 标题
  final String title;
  
  /// 描述
  final String description;
  
  /// 起始点
  final String startPoint;
  
  /// 终点
  final String endPoint;
  
  /// 距离(km)
  final double distance;
  
  /// 爬升(m)
  final int elevationGain;
  
  /// 下降(m)
  final int elevationLoss;
  
  /// 预计时间(小时)
  final double estimatedTime;
  
  /// 难度(1-5)
  final int difficulty;
  
  /// 经过的关键点ID
  final List<String> waypoints;
  
  /// 包含的路段ID
  final List<String> segments;
  
  /// 亮点
  final List<String> highlights;
  
  /// 营地信息
  final CampsiteModel? campsite;
  
  /// 典型天气模式
  final Map<String, dynamic>? weatherPattern;
  
  /// 每日提示
  final String? tips;
  
  /// 构造函数
  DailyPlanModel({
    required this.day,
    required this.title,
    required this.description,
    required this.startPoint,
    required this.endPoint,
    required this.distance,
    required this.elevationGain,
    required this.elevationLoss,
    required this.estimatedTime,
    required this.difficulty,
    List<String>? waypoints,
    List<String>? segments,
    List<String>? highlights,
    this.campsite,
    this.weatherPattern,
    this.tips,
  })  : this.waypoints = waypoints ?? const [],
        this.segments = segments ?? const [],
        this.highlights = highlights ?? const [];
  
  /// 从JSON创建
  factory DailyPlanModel.fromJson(Map<String, dynamic> json) =>
      _$DailyPlanModelFromJson(json);
      
  /// 转换为JSON
  Map<String, dynamic> toJson() => _$DailyPlanModelToJson(this);
}