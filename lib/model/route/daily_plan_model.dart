import 'package:json_annotation/json_annotation.dart';

part 'daily_plan_model.g.dart';

/// 兴趣点模型
@JsonSerializable()
class PointOfInterestModel {
  /// ID
  final String id;

  /// 名称
  final String name;

  /// 描述
  final String? description;

  /// 纬度
  final double latitude;

  /// 经度
  final double longitude;

  /// 类型（景点、休息点、补给点等）
  final String type;

  /// 海拔
  final double? elevation;

  /// 预计到达时间
  @JsonKey(name: 'estimated_arrival_time')
  final String? estimatedArrivalTime;

  PointOfInterestModel({
    required this.id,
    required this.name,
    this.description,
    required this.latitude,
    required this.longitude,
    required this.type,
    this.elevation,
    this.estimatedArrivalTime,
  });

  factory PointOfInterestModel.fromJson(Map<String, dynamic> json) =>
      _$PointOfInterestModelFromJson(json);

  Map<String, dynamic> toJson() => _$PointOfInterestModelToJson(this);
}

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

  /// 计划日期
  @JsonKey(name: 'planned_date')
  final DateTime? plannedDate;

  /// 兴趣点列表
  @JsonKey(name: 'points_of_interest')
  final List<PointOfInterestModel> pointsOfInterest;

  /// 起点位置
  @JsonKey(name: 'start_location')
  final String? startLocation;

  /// 终点位置
  @JsonKey(name: 'end_location')
  final String? endLocation;

  /// 难度等级（1-5）
  @JsonKey(name: 'difficulty_level')
  final int? difficultyLevel;

  /// 最高海拔
  @JsonKey(name: 'max_elevation')
  final double? maxElevation;

  /// 最低海拔
  @JsonKey(name: 'min_elevation')
  final double? minElevation;

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
    this.plannedDate,
    this.pointsOfInterest = const [],
    this.startLocation,
    this.endLocation,
    this.difficultyLevel,
    this.maxElevation,
    this.minElevation,
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
  DateTime? get date => plannedDate;

  /// 格式化路线显示
  String get formattedRoute {
    if (startPoint != null && endPoint != null) {
      return '$startPoint → $endPoint';
    }
    if (startLocation != null && endLocation != null) {
      return '$startLocation → $endLocation';
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

  /// 获取难度描述
  String get difficultyDescription {
    switch (difficultyLevel) {
      case 1:
        return '简单';
      case 2:
        return '容易';
      case 3:
        return '中等';
      case 4:
        return '困难';
      case 5:
        return '极难';
      default:
        return '未知';
    }
  }

  /// 获取海拔变化描述
  String get elevationDescription {
    if (maxElevation != null && minElevation != null) {
      return '海拔${minElevation!.toInt()}m - ${maxElevation!.toInt()}m';
    }
    return '';
  }

  /// 获取兴趣点按类型分组
  Map<String, List<PointOfInterestModel>> get pointsOfInterestByType {
    final Map<String, List<PointOfInterestModel>> grouped = {};
    for (final poi in pointsOfInterest) {
      if (!grouped.containsKey(poi.type)) {
        grouped[poi.type] = [];
      }
      grouped[poi.type]!.add(poi);
    }
    return grouped;
  }

  /// 获取景点列表
  List<PointOfInterestModel> get scenicSpots {
    return pointsOfInterest.where((poi) => poi.type == '景点').toList();
  }

  /// 获取休息点列表
  List<PointOfInterestModel> get restPoints {
    return pointsOfInterest.where((poi) => poi.type == '休息点').toList();
  }

  /// 获取补给点列表
  List<PointOfInterestModel> get supplyPoints {
    return pointsOfInterest.where((poi) => poi.type == '补给点').toList();
  }

  /// 是否是今天的计划
  bool get isToday {
    if (plannedDate == null) return false;
    final now = DateTime.now();
    return plannedDate!.year == now.year &&
        plannedDate!.month == now.month &&
        plannedDate!.day == now.day;
  }

  /// 是否是未来的计划
  bool get isFuture {
    if (plannedDate == null) return false;
    return plannedDate!.isAfter(DateTime.now());
  }

  /// 是否是过去的计划
  bool get isPast {
    if (plannedDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final planDate =
        DateTime(plannedDate!.year, plannedDate!.month, plannedDate!.day);
    return planDate.isBefore(today);
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
    DateTime? plannedDate,
    List<PointOfInterestModel>? pointsOfInterest,
    String? startLocation,
    String? endLocation,
    int? difficultyLevel,
    double? maxElevation,
    double? minElevation,
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
      plannedDate: plannedDate ?? this.plannedDate,
      pointsOfInterest: pointsOfInterest ?? this.pointsOfInterest,
      startLocation: startLocation ?? this.startLocation,
      endLocation: endLocation ?? this.endLocation,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      maxElevation: maxElevation ?? this.maxElevation,
      minElevation: minElevation ?? this.minElevation,
    );
  }
}
