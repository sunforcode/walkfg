import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:walk/model/map/map_data_model.dart';
import 'package:walk/model/route/route_enums.dart';

import 'package:walk/model/route/segment_model.dart';
import 'package:walk/model/route/route_ratings.dart';
import 'package:walk/model/route/waypoint_model.dart';
import 'package:walk/model/route/daily_plan_model.dart';
import 'package:walk/model/route/weather_info.dart';
import 'package:walk/model/route/facilities.dart';
import '../base/base_model.dart';
import 'route_status.dart';

part 'route_model.g.dart';

/// 路线模型 - 户外路线的业务实体
@JsonSerializable()
class RouteModel extends BaseModel {
  /// 名称
  final String name;

  /// 描述
  final String description;

  /// 区域ID
  @JsonKey(name: 'region_id')
  final String regionId;

  @JsonKey(name: 'best_season')
  final List<String> bestSeason;

  /// 相关地图ID列表
  @JsonKey(name: 'related_map_ids')
  final List<String> relatedMapIds;

  /// 默认地图ID
  @JsonKey(name: 'default_map_id')
  final String defaultMapId;

  /// 当前地图数据模型（运行时设置，不从JSON获取）
  @JsonKey(ignore: true)
  final MapDataModel? defaultMap;

  /// 区域名称
  @JsonKey(name: 'region')
  final String region;

  /// 评分信息
  final RouteRatingsVO ratings;

  /// 标签列表
  final List<String> tags;

  /// 难度
  @JsonKey(
      name: 'difficulty', fromJson: _parseDifficulty, toJson: _difficultyToJson)
  final RouteDifficulty difficulty;

  /// 路径关键点
  final List<WaypointModel> waypoints;

  /// 路径分段
  final List<SegmentModel> segments;

  /// 每日行程计划
  @JsonKey(name: 'daily_plans')
  final List<DailyPlanModel> dailyPlans;

  /// 气候信息
  @JsonKey(name: 'weather_info')
  final WeatherInfoVO? weatherInfo;

  /// 设施信息
  final FacilitiesVO? facilities;

  /// 图片URL列表
  @JsonKey(name: 'image_urls')
  final List<String> imageUrls;

  /// 封面图片URL
  @JsonKey(name: 'cover_url')
  final String? coverUrl;

  /// 地图数据ID
  @JsonKey(name: 'map_data_id')
  final String mapDataId;

  /// 创建者ID
  @JsonKey(name: 'created_by')
  final String createdBy;

  /// 是否收藏
  @JsonKey(name: 'is_favorite')
  final bool isFavorite;

  /// 人气
  final int popularity;

  /// 相关路线ID列表
  @JsonKey(name: 'related_route_ids')
  final List<String>? relatedRouteIds;

  /// 状态
  @JsonKey(fromJson: _parseStatus, toJson: _statusToJson)
  final RouteStatus status;

  /// 构造函数
  RouteModel({
    required super.id,
    super.createdAt,
    super.updatedAt,
    required this.name,
    required this.description,
    required this.regionId,
    List<String>? bestSeason,
    List<String>? relatedMapIds,
    String? defaultMapId,
    this.defaultMap,
    required this.ratings,
    List<String>? tags,
    required this.difficulty,
    List<WaypointModel>? waypoints,
    List<SegmentModel>? segments,
    List<DailyPlanModel>? dailyPlans,
    this.weatherInfo,
    this.facilities,
    required this.imageUrls,
    this.coverUrl,
    required this.mapDataId,
    required this.createdBy,
    this.isFavorite = false,
    required this.popularity,
    this.relatedRouteIds,
    String? region,
    RouteStatus? status,
  })  : this.bestSeason = bestSeason ?? const [],
        this.relatedMapIds = relatedMapIds ?? const [],
        this.defaultMapId = defaultMapId ?? "",
        this.region = region ?? "未知区域",
        this.tags = tags ?? const [],
        this.waypoints = waypoints ?? const [],
        this.segments = segments ?? const [],
        this.dailyPlans = dailyPlans ?? const [],
        this.status = status ?? RouteStatus.planning;

  /// 从JSON创建
  factory RouteModel.fromJson(Map<String, dynamic> json) =>
      _$RouteModelFromJson(json);

  /// 转换为JSON
  @override
  Map<String, dynamic> toJson() => _$RouteModelToJson(this);

  /// 创建带有地图数据的路线模型
  factory RouteModel.withMap(RouteModel route, MapDataModel map) {
    return route.copyWith(defaultMap: map);
  }

  /// 解析难度
  static RouteDifficulty _parseDifficulty(dynamic difficulty) {
    if (difficulty is int &&
        difficulty >= 0 &&
        difficulty < RouteDifficulty.values.length) {
      return RouteDifficulty.values[difficulty];
    }
    return RouteDifficulty.medium; // 默认返回中等难度
  }

  /// 难度转JSON
  static int _difficultyToJson(RouteDifficulty difficulty) {
    return difficulty.index;
  }

  /// 解析状态
  static RouteStatus _parseStatus(dynamic status) {
    if (status is String) {
      return parseRouteStatus(status);
    } else if (status is int &&
        status >= 0 &&
        status < RouteStatus.values.length) {
      return RouteStatus.values[status];
    }
    return RouteStatus.planning;
  }

  /// 状态转JSON
  static String _statusToJson(RouteStatus status) {
    return routeStatusToString(status);
  }

  /// 获取状态名称
  String getStatusName() {
    return getRouteStatusName(status);
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
      case RouteStatus.inProgress:
        return Colors.green;
    }
  }

  /// 获取路线距离（公里）
  double get distance {
    if (defaultMap != null) {
      return defaultMap!.distance;
    }
    // 如果没有地图数据，则从分段计算
    return segments.fold(0.0, (sum, segment) => sum + segment.distance);
  }

  /// 获取路线爬升（米）
  int get elevationGain {
    if (defaultMap != null) {
      return defaultMap!.elevationGain;
    }
    // 如果没有地图数据，则从分段计算
    return segments.fold(0, (sum, segment) => sum + segment.elevationGain);
  }

  /// 获取路线下降（米）
  double get elevationLoss {
    if (defaultMap != null) {
      return defaultMap!.elevationLoss;
    }
    // 如果没有地图数据，则从分段计算
    return segments.fold(
        0.0, (sum, segment) => sum + (segment.elevationLoss ?? 0));
  }

  /// 获取预计时长
  String get duration {
    // 从每日计划计算总时长
    if (dailyPlans.isNotEmpty) {
      final totalHours = dailyPlans.fold(0.0, (sum, plan) {
        final parts = plan.duration.split(':');
        if (parts.length == 2) {
          return sum +
              (int.tryParse(parts[0]) ?? 0) +
              (int.tryParse(parts[1]) ?? 0) / 60;
        }
        return sum;
      });

      final hours = totalHours.floor();
      final minutes = ((totalHours - hours) * 60).round();

      return '$hours:${minutes.toString().padLeft(2, '0')}';
    }

    // 如果没有每日计划，则估算时长（假设平均步行速度为3km/h）
    final estimatedHours = distance / 3;
    final hours = estimatedHours.floor();
    final minutes = ((estimatedHours - hours) * 60).round();

    return '$hours:${minutes.toString().padLeft(2, '0')}';
  }

  /// 创建副本并更新部分属性
  RouteModel copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? name,
    String? description,
    String? regionId,
    List<String>? bestSeason,
    List<String>? relatedMapIds,
    String? defaultMapId,
    MapDataModel? defaultMap,
    RouteRatingsVO? ratings,
    List<String>? tags,
    RouteDifficulty? difficulty,
    List<WaypointModel>? waypoints,
    List<SegmentModel>? segments,
    List<DailyPlanModel>? dailyPlans,
    WeatherInfoVO? weatherInfo,
    FacilitiesVO? facilities,
    List<String>? imageUrls,
    String? coverUrl,
    String? mapDataId,
    String? createdBy,
    bool? isFavorite,
    int? popularity,
    List<String>? relatedRouteIds,
    String? region,
    RouteStatus? status,
  }) {
    return RouteModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      name: name ?? this.name,
      description: description ?? this.description,
      regionId: regionId ?? this.regionId,
      bestSeason: bestSeason ?? this.bestSeason,
      relatedMapIds: relatedMapIds ?? this.relatedMapIds,
      defaultMapId: defaultMapId ?? this.defaultMapId,
      defaultMap: defaultMap ?? this.defaultMap,
      ratings: ratings ?? this.ratings,
      tags: tags ?? this.tags,
      difficulty: difficulty ?? this.difficulty,
      waypoints: waypoints ?? this.waypoints,
      segments: segments ?? this.segments,
      dailyPlans: dailyPlans ?? this.dailyPlans,
      weatherInfo: weatherInfo ?? this.weatherInfo,
      facilities: facilities ?? this.facilities,
      imageUrls: imageUrls ?? this.imageUrls,
      coverUrl: coverUrl ?? this.coverUrl,
      mapDataId: mapDataId ?? this.mapDataId,
      createdBy: createdBy ?? this.createdBy,
      isFavorite: isFavorite ?? this.isFavorite,
      popularity: popularity ?? this.popularity,
      relatedRouteIds: relatedRouteIds ?? this.relatedRouteIds,
      region: region ?? this.region,
      status: status ?? this.status,
    );
  }
}
