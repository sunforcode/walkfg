import 'package:json_annotation/json_annotation.dart';
import 'package:walk/model/route/segment_model.dart';

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
  @JsonKey(defaultValue: 0)
  final double distance;

  /// 预计时间（小时数）
  @JsonKey(name: 'estimated_time')
  final double estimatedTime;

  /// 爬升（米）
  @JsonKey(name: 'elevation_gain', defaultValue: 0)
  final int elevationGain;

  /// 下降（米）
  @JsonKey(name: 'elevation_loss')
  final double elevationLoss;

  /// 最高海拔
  @JsonKey(name: 'max_elevation')
  final double maxElevation;

  /// 最低海拔
  @JsonKey(name: 'min_elevation')
  final double? minElevation;

  /// 包含的分段列表
  @JsonKey(name: 'segments', defaultValue: <SegmentModel>[])
  final List<SegmentModel> segments;

  /// 住宿信息
  final String? accommodation;

  /// 备注
  final String? notes;

  /// 构造函数
  DailyPlanModel({
    required this.id,
    required this.dayNumber,
    required this.title,
    required this.description,
    this.distance = 0,
    this.estimatedTime = 8.0, // 默认8小时
    this.elevationGain = 0,
    this.elevationLoss = 0,
    this.maxElevation = 0,
    this.minElevation,
    this.segments = const <SegmentModel>[],
    this.accommodation,
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
    return title;
  }

  /// 格式化统计信息
  String get formattedStats {
    final List<String> stats = [];
    if (distance > 0) {
      stats.add('徒步${distance.toStringAsFixed(1)}km');
    }
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

  /// 获取难度描述
  String get difficultyDescription {
    return '中等'; // 默认返回中等难度
  }

  /// 获取海拔变化描述
  String get elevationDescription {
    if (minElevation != null) {
      return '海拔${minElevation!.toInt()}m - ${maxElevation.toInt()}m';
    }
    return '';
  }

  /// 是否是今天的计划
  bool get isToday {
    return false; // 默认返回false
  }

  /// 是否是未来的计划
  bool get isFuture {
    return false; // 默认返回false
  }

  /// 是否是过去的计划
  bool get isPast {
    return false; // 默认返回false
  }

  /// 创建副本
  DailyPlanModel copyWith({
    String? id,
    int? dayNumber,
    String? title,
    String? description,
    double? distance,
    double? estimatedTime,
    int? elevationGain,
    double? elevationLoss,
    double? maxElevation,
    double? minElevation,
    List<SegmentModel>? segments,
    String? accommodation,
    String? notes,
  }) {
    return DailyPlanModel(
      id: id ?? this.id,
      dayNumber: dayNumber ?? this.dayNumber,
      title: title ?? this.title,
      description: description ?? this.description,
      distance: distance ?? this.distance,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      elevationGain: elevationGain ?? this.elevationGain,
      elevationLoss: elevationLoss ?? this.elevationLoss,
      maxElevation: maxElevation ?? this.maxElevation,
      minElevation: minElevation ?? this.minElevation,
      segments: segments ?? this.segments,
      accommodation: accommodation ?? this.accommodation,
      notes: notes ?? this.notes,
    );
  }

  @override
  String toString() {
    return 'DailyPlanModel(id: $id, dayNumber: $dayNumber, title: $title, distance: $distance)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DailyPlanModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
