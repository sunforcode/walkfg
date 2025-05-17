import 'package:flutter/material.dart';
import 'package:walk/model/base/base_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'route_model.g.dart';

/// 路线难度枚举
enum RouteDifficulty {
  /// 简单
  easy,

  /// 中等
  medium,

  /// 困难
  hard,

  /// 极难
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
  /// ID
  final String id;

  /// 名称
  final String name;

  /// 描述
  final String description;

  /// 距离(公里)
  final double distance;

  /// 持续时间(小时或天)
  final String duration;

  /// 难度
  final RouteDifficulty difficulty;

  /// 最佳季节
  final String bestSeason;

  /// 累计上升(米)
  final int elevationGain;

  /// 累计下降(米)
  final int elevationLoss;

  /// 最高点(米)
  final int highestPoint;

  /// 最低点(米)
  final int lowestPoint;

  /// 图片URL列表
  final List<String> imageUrls;

  /// GPX轨迹文件URL
  final String? gpxUrl;

  /// 地区
  final String region;

  /// 评分
  final double rating;

  /// 最佳季节列表
  final List<String> bestSeasons;

  final int reviewCount;

  /// 构造函数
  RouteModel({
    required this.id,
    required this.name,
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
    this.region = '',
    this.rating = 0.0,
    List<String>? bestSeasons,
  }) : this.bestSeasons = bestSeasons ?? const [];

  /// 从JSON创建
  factory RouteModel.fromJson(Map<String, dynamic> json) {
    return RouteModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      distance: json['distance'] as double,
      duration: json['duration'] as String,
      difficulty: RouteDifficulty.values[json['difficulty'] as int],
      bestSeason: json['bestSeason'] as String,
      elevationGain: json['elevationGain'] as int,
      elevationLoss: json['elevationLoss'] as int,
      highestPoint: json['highestPoint'] as int,
      lowestPoint: json['lowestPoint'] as int,
      imageUrls: (json['imageUrls'] as List).cast<String>(),
      gpxUrl: json['gpxUrl'] as String?,
      region: json['region'] as String? ?? '',
      rating: json['rating'] as double? ?? 0.0,
      bestSeasons: (json['bestSeasons'] as List?)?.cast<String>(),
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'distance': distance,
      'duration': duration,
      'difficulty': difficulty.index,
      'bestSeason': bestSeason,
      'elevationGain': elevationGain,
      'elevationLoss': elevationLoss,
      'highestPoint': highestPoint,
      'lowestPoint': lowestPoint,
      'imageUrls': imageUrls,
      'gpxUrl': gpxUrl,
      'region': region,
      'rating': rating,
      'bestSeasons': bestSeasons,
    };
  }

  /// 获取难度名称
  String getDifficultyName() {
    switch (difficulty) {
      case RouteDifficulty.easy:
        return '简单';
      case RouteDifficulty.medium:
        return '中等';
      case RouteDifficulty.hard:
        return '困难';
      case RouteDifficulty.extreme:
        return '极难';
    }
  }

  /// 获取难度颜色
  Color getDifficultyColor() {
    switch (difficulty) {
      case RouteDifficulty.easy:
        return Colors.green;
      case RouteDifficulty.medium:
        return Colors.orange;
      case RouteDifficulty.hard:
        return Colors.red;
      case RouteDifficulty.extreme:
        return Colors.purple;
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
class PlannedRouteModel {
  /// ID
  final String id;

  /// 路线ID
  final String routeId;

  /// 名称
  final String name;

  /// 日期
  final DateTime date;

  /// 天数
  final int days;

  /// 状态
  final RouteStatus status;

  /// 备注
  final String? notes;

  /// 构造函数
  const PlannedRouteModel({
    required this.id,
    required this.routeId,
    required this.name,
    required this.date,
    required this.days,
    required this.status,
    this.notes,
  });

  /// 从JSON创建
  factory PlannedRouteModel.fromJson(Map<String, dynamic> json) {
    return PlannedRouteModel(
      id: json['id'] as String,
      routeId: json['routeId'] as String,
      name: json['name'] as String,
      date: DateTime.parse(json['date'] as String),
      days: json['days'] as int,
      status: RouteStatus.values[json['status'] as int],
      notes: json['notes'] as String?,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'routeId': routeId,
      'name': name,
      'date': date.toIso8601String(),
      'days': days,
      'status': status.index,
      'notes': notes,
    };
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
