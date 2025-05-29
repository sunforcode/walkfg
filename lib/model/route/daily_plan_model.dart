import 'package:json_annotation/json_annotation.dart';

part 'daily_plan_model.g.dart';

/// 每日计划模型
@JsonSerializable()
class DailyPlanModel {
  /// ID
  final String id;

  /// 天数
  @JsonKey(name: 'day_number')
  final int dayNumber;

  /// 标题
  final String title;

  /// 描述
  final String description;

  /// 距离（公里）
  final double distance;

  /// 预计时长
  final String duration;

  /// 预计时间（小时数）
  @JsonKey(name: 'estimated_time')
  final double estimatedTime;

  /// 爬升（米）
  @JsonKey(name: 'elevation_gain')
  final int elevationGain;

  /// 下降（米）
  @JsonKey(name: 'elevation_loss')
  final double? elevationLoss;

  /// 起点ID
  @JsonKey(name: 'start_waypoint_id')
  final String startWaypointId;

  /// 终点ID
  @JsonKey(name: 'end_waypoint_id')
  final String endWaypointId;

  /// 起点名称（从TripDayPlanModel合并）
  @JsonKey(name: 'start_point')
  final String? startPoint;

  /// 终点名称（从TripDayPlanModel合并）
  @JsonKey(name: 'end_point')
  final String? endPoint;

  /// 包含的分段ID列表
  @JsonKey(name: 'segment_ids')
  final List<String> segmentIds;

  /// 住宿信息
  final String? accommodation;

  /// 关键点列表
  @JsonKey(name: 'key_points')
  final List<String> keyPoints;

  /// 备注（从TripDayPlanModel合并）
  final String? notes;

  /// 构造函数
  DailyPlanModel({
    required this.id,
    required this.dayNumber,
    required this.title,
    required this.description,
    required this.distance,
    required this.duration,
    this.estimatedTime = 8.0, // 默认8小时
    required this.elevationGain,
    this.elevationLoss,
    required this.startWaypointId,
    required this.endWaypointId,
    this.startPoint,
    this.endPoint,
    required this.segmentIds,
    this.accommodation,
    this.keyPoints = const [],
    this.notes,
  });

  /// 从JSON创建
  factory DailyPlanModel.fromJson(Map<String, dynamic> json) =>
      _$DailyPlanModelFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$DailyPlanModelToJson(this);

  /// 兼容性访问器 - 与TripDayPlanModel保持一致
  int get day => dayNumber;

  /// 获取交通方式
  String? get transportation => null;

  /// 获取日期
  DateTime? get date => null;

  /// 格式化路线显示
  String get formattedRoute {
    if (startPoint != null && endPoint != null) {
      return '$startPoint → $endPoint';
    }
    return title;
  }

  /// 格式化统计信息
  String get formattedStats {
    final List<String> stats = [];
    stats.add('徒步${distance.toStringAsFixed(1)}km');
    if (elevationGain > 0) {
      stats.add('爬升${elevationGain}m');
    }
    final hours = estimatedTime.floor();
    final minutes = ((estimatedTime - hours) * 60).round();
    if (hours > 0) {
      stats.add('${hours}小时${minutes > 0 ? '${minutes}分钟' : ''}');
    } else {
      stats.add('${minutes}分钟');
    }
    return stats.join('，');
  }

  /// 获取格式化的预计时间
  String getFormattedEstimatedTime() {
    final hours = estimatedTime.floor();
    final minutes = ((estimatedTime - hours) * 60).round();
    if (minutes == 0) {
      return '${hours}小时';
    }
    return '${hours}小时${minutes}分钟';
  }

  /// 创建副本
  DailyPlanModel copyWith({
    String? id,
    int? dayNumber,
    String? title,
    String? description,
    double? distance,
    String? duration,
    double? estimatedTime,
    int? elevationGain,
    double? elevationLoss,
    String? startWaypointId,
    String? endWaypointId,
    String? startPoint,
    String? endPoint,
    List<String>? segmentIds,
    String? accommodation,
    List<String>? keyPoints,
    String? notes,
  }) {
    return DailyPlanModel(
      id: id ?? this.id,
      dayNumber: dayNumber ?? this.dayNumber,
      title: title ?? this.title,
      description: description ?? this.description,
      distance: distance ?? this.distance,
      duration: duration ?? this.duration,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      elevationGain: elevationGain ?? this.elevationGain,
      elevationLoss: elevationLoss ?? this.elevationLoss,
      startWaypointId: startWaypointId ?? this.startWaypointId,
      endWaypointId: endWaypointId ?? this.endWaypointId,
      startPoint: startPoint ?? this.startPoint,
      endPoint: endPoint ?? this.endPoint,
      segmentIds: segmentIds ?? this.segmentIds,
      accommodation: accommodation ?? this.accommodation,
      keyPoints: keyPoints ?? this.keyPoints,
      notes: notes ?? this.notes,
    );
  }
}
