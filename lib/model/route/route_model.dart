import 'package:flutter/material.dart';
import 'package:walk/model/base/base_model.dart';
import 'package:json_annotation/json_annotation.dart';
import 'track_point_model.dart';

part 'route_model.g.dart';

/// 路线难度枚举
enum RouteDifficulty {
  /// 初级
  easy,

  /// 中级
  medium,

  /// 高级
  hard,

  /// 专业级
  extreme,
}

/// 路线状态枚举
enum RouteStatus {
  /// 规划中
  planning,

  /// 已完成
  completed,

  /// 已取消
  cancelled,
}

/// 路线模型
@JsonSerializable()
class RouteModel extends BaseModel {
  /// 名称
  final String name;

  /// 地区
  final String region;

  /// 描述
  final String description;

  /// 距离(公里)
  final double distance;

  /// 持续时间(小时或天)
  final String duration;

  /// 难度
  @JsonKey(fromJson: _parseDifficulty, toJson: _difficultyToString)
  final RouteDifficulty difficulty;

  /// 最佳季节
  @JsonKey(name: 'best_season')
  final String bestSeason;

  /// 累计上升(米)
  @JsonKey(name: 'elevation_gain')
  final int elevationGain;

  /// 累计下降(米)
  @JsonKey(name: 'elevation_loss')
  final int elevationLoss;

  /// 最高点(米)
  @JsonKey(name: 'highest_point')
  final int highestPoint;

  /// 最低点(米)
  @JsonKey(name: 'lowest_point')
  final int lowestPoint;

  /// 图片URL列表
  @JsonKey(name: 'image_urls')
  final List<String> imageUrls;

  /// GPX轨迹文件URL
  @JsonKey(name: 'gpx_url')
  final String? gpxUrl;

  /// 评分
  final double rating;

  /// 最佳季节列表
  @JsonKey(name: 'best_seasons')
  final List<String> bestSeasons;

  /// 评论数量
  @JsonKey(name: 'review_count')
  final int reviewCount;

  /// 轨迹点列表
  @JsonKey(name: 'track_points')
  final List<TrackPointModel> trackPoints;

  /// 构造函数
  RouteModel({
    required super.id,
    super.createdAt,
    super.updatedAt,
    required this.name,
    required this.region,
    required this.description,
    required this.distance,
    required this.duration,
    required this.difficulty,
    required this.bestSeason,
    required this.elevationGain,
    required this.elevationLoss,
    required this.highestPoint,
    required this.lowestPoint,
    required this.imageUrls,
    this.gpxUrl,
    this.reviewCount = 0,
    this.rating = 0.0,
    List<String>? bestSeasons,
    List<TrackPointModel>? trackPoints,
  })  : this.bestSeasons = bestSeasons ?? const [],
        this.trackPoints = trackPoints ?? [];

  /// 从JSON创建
  factory RouteModel.fromJson(Map<String, dynamic> json) =>
      _$RouteModelFromJson(json);

  /// 转换为JSON
  @override
  Map<String, dynamic> toJson() => _$RouteModelToJson(this);

  /// 解析难度字符串为枚举值
  static RouteDifficulty _parseDifficulty(String? difficultyStr) {
    switch (difficultyStr?.toLowerCase()) {
      case 'easy':
        return RouteDifficulty.easy;
      case 'medium':
        return RouteDifficulty.medium;
      case 'hard':
        return RouteDifficulty.hard;
      case 'extreme':
        return RouteDifficulty.extreme;
      default:
        return RouteDifficulty.medium;
    }
  }

  /// 将难度枚举转换为字符串
  static String _difficultyToString(RouteDifficulty difficulty) {
    return difficulty.toString().split('.').last;
  }

  /// 获取难度名称
  String getDifficultyName() {
    switch (difficulty) {
      case RouteDifficulty.easy:
        return '初级';
      case RouteDifficulty.medium:
        return '中级';
      case RouteDifficulty.hard:
        return '高级';
      case RouteDifficulty.extreme:
        return '专业级';
    }
  }

  /// 获取难度颜色
  Color getDifficultyColor() {
    switch (difficulty) {
      case RouteDifficulty.easy:
        return Colors.green;
      case RouteDifficulty.extreme:
        return Colors.purple;
      case RouteDifficulty.medium:
        return Colors.orange;
      case RouteDifficulty.hard:
        return Colors.red;
    }
  }

  /// 获取行程天数
  int get durationDays {
    // 如果duration是"X天"格式，提取数字
    if (duration.contains('天')) {
      return int.tryParse(duration.split('天')[0]) ?? 1;
    }
    // 如果duration是"X小时"格式，转换为天数（假设8小时为1天）
    else if (duration.contains('小时')) {
      final hours = int.tryParse(duration.split('小时')[0]) ?? 0;
      return (hours / 8).ceil();
    }
    // 默认返回1天
    return 1;
  }
}

/// 计划路线模型
@JsonSerializable()
class PlannedRouteModel extends BaseModel {
  /// 路线ID
  @JsonKey(name: 'route_id')
  final String routeId;

  /// 名称
  final String name;

  /// 日期
  final DateTime date;

  /// 天数
  final int days;

  /// 状态
  @JsonKey(fromJson: _parseStatus, toJson: _statusToJson)
  final RouteStatus status;

  /// 备注
  final String? notes;

  /// 构造函数
  PlannedRouteModel({
    required super.id,
    super.createdAt,
    super.updatedAt,
    required this.routeId,
    required this.name,
    required this.date,
    required this.days,
    required this.status,
    this.notes,
  });

  /// 从JSON创建
  factory PlannedRouteModel.fromJson(Map<String, dynamic> json) =>
      _$PlannedRouteModelFromJson(json);

  /// 转换为JSON
  @override
  Map<String, dynamic> toJson() => _$PlannedRouteModelToJson(this);

  /// 解析状态
  static RouteStatus _parseStatus(dynamic status) {
    if (status is int && status >= 0 && status < RouteStatus.values.length) {
      return RouteStatus.values[status];
    }
    return RouteStatus.planning;
  }

  /// 状态转JSON
  static int _statusToJson(RouteStatus status) {
    return status.index;
  }

  /// 获取状态名称
  String getStatusName() {
    switch (status) {
      case RouteStatus.planning:
        return '规划中';
      case RouteStatus.completed:
        return '已完成';
      case RouteStatus.cancelled:
        return '已取消';
    }
  }

  /// 获取状态颜色
  Color getStatusColor() {
    switch (status) {
      case RouteStatus.planning:
        return Colors.blue;
      case RouteStatus.completed:
        return Colors.green;
      case RouteStatus.cancelled:
        return Colors.red;
    }
  }

  /// 格式化日期为字符串
  String getFormattedDate() {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
