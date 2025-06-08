import 'dart:math';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:walk/model/map/marker_point_model.dart';
import 'package:walk/model/route/route_enums.dart';
import 'package:walk/model/route/segment_model.dart';
import 'package:walk/model/route/route_ratings.dart';
import 'package:walk/model/route/supply_point_model.dart';
import 'package:walk/model/route/track_model.dart';
import 'package:walk/model/route/daily_plan_model.dart';
import 'package:walk/model/route/weather_info.dart';
import 'package:walk/model/route/waypoint_model.dart';
import 'package:walk/model/route/facilities_model.dart';
import 'package:walk/model/route/campsite_model.dart';
import 'package:walk/model/route/hitchhike_contact_model.dart';
import 'package:walk/model/user/user_model.dart';
import 'package:walk/model/water/water_source_model.dart';
import '../base/base_model.dart';
import 'route_status.dart';
part 'route_model.g.dart';

/// 路线模型 - 户外路线的业务实体
@JsonSerializable()
class RouteModel extends BaseModel {
  /// 名称
  final String name;

  /// 创建者ID
  @JsonKey(name: 'created_by')
  final String createdBy;

  /// 创建者信息（可选，运行时设置）
  @JsonKey(includeFromJson: false, includeToJson: false)
  final UserModel? createUser;

  /// 使用次数（默认值）
  @JsonKey(name: 'usage_count', defaultValue: 0)
  final int usageCount;

  /// 描述
  final String description;

  /// 区域ID
  @JsonKey(name: 'region_id')
  final String regionId;

  /// 区域名称
  @JsonKey(name: 'region')
  final String region;

  /// 最佳季节
  @JsonKey(name: 'best_season')
  final List<String> bestSeason;

  /// 相关地图ID列表
  @JsonKey(name: 'related_map_ids')
  final List<String> relatedMapIds;

  /// 默认地图ID
  @JsonKey(name: 'default_map_id')
  final String defaultMapId;

  /// 评分信息
  final RouteRatingsVO ratings;

  /// 标签列表
  final List<String> tags;

  /// 难度
  @JsonKey(
      name: 'difficulty', fromJson: _parseDifficulty, toJson: _difficultyToJson)
  final RouteDifficulty difficulty;

  /// 路标点列表
  final List<WaypointModel> waypoints;

  /// 路径分段，ai根据 某些信息将地图分段
  final List<SegmentModel> segments;

  /// 每日行程计划， 可能执行多个路径分端，两者无关
  @JsonKey(name: 'daily_plans')
  final List<DailyPlanModel> dailyPlans;

  /// 气候信息
  @JsonKey(name: 'weather_info')
  final WeatherInfoVO? weatherInfo;

  /// 设施信息
  final FacilitiesModel? facilities;

  /// 图片URL列表
  @JsonKey(name: 'image_urls')
  final List<String> imageUrls;

  /// 封面图片URL
  @JsonKey(name: 'cover_url')
  final String? coverUrl;

  /// 地图数据ID
  @JsonKey(name: 'map_data_id')
  final String mapDataId;

  /// 当前地图数据模型（运行时设置，不从JSON获取）
  @JsonKey(includeFromJson: false, includeToJson: false)
  final TrackModel? defaultMap;

  /// 是否收藏
  @JsonKey(name: 'is_favorite')
  final bool isFavorite;

  /// 人气
  final int popularity;

  /// 相关路线ID列表
  @JsonKey(name: 'related_route_ids')
  final List<String> relatedRouteIds;

  /// 状态
  @JsonKey(fromJson: _parseStatus, toJson: _statusToJson)
  final RouteStatus status;

  /// 是否为多日路线（根据daily_plans计算）
  @JsonKey(includeFromJson: false, includeToJson: false)
  bool get isMultiDay => dailyPlans.length > 1;

  /// 是否为环线（根据waypoints判断）
  @JsonKey(includeFromJson: false, includeToJson: false)
  bool get isLoop {
    if (waypoints.length < 2) return false;
    final start = waypoints.first;
    final end = waypoints.last;
    // 简单判断：起点终点距离小于100米认为是环线
    final distance = _calculateDistance(
      start.latitude,
      start.longitude,
      end.latitude,
      end.longitude,
    );
    return distance < 0.1; // 100米
  }

  /// 水源点列表
  @JsonKey(name: 'water_sources')
  final List<WaterSourceModel> waterSources;

  /// 补给点列表
  @JsonKey(name: 'supply_points')
  final List<SupplyPointModel> supplyPoints;

  /// 营地资源列表
  @JsonKey(name: 'campsites')
  final List<CampsiteModel> campsites;

  /// 搭车联系方式列表
  @JsonKey(name: 'hitchhike_contacts')
  final List<HitchhikeContactModel> hitchhikeContacts;

  /// 标记点列表（从waypoints转换而来）
  @JsonKey(includeFromJson: false, includeToJson: false)
  List<MarkerPointModel> get markerPoints {
    return waypoints
        .map((waypoint) => MarkerPointModel.fromWaypoint(waypoint))
        .toList();
  }

  /// 构造函数
  RouteModel({
    required super.id,
    super.createdAt,
    super.updatedAt,
    required this.name,
    required this.createdBy,
    this.createUser,
    this.usageCount = 0,
    required this.description,
    required this.regionId,
    String? region,
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
    this.isFavorite = false,
    required this.popularity,
    List<String>? relatedRouteIds,
    RouteStatus? status,
    List<WaterSourceModel>? waterSources,
    List<SupplyPointModel>? supplyPoints,
    List<CampsiteModel>? campsites,
    List<HitchhikeContactModel>? hitchhikeContacts,
  })  : this.region = region ?? "未知区域",
        this.bestSeason = bestSeason ?? const [],
        this.relatedMapIds = relatedMapIds ?? const [],
        this.tags = tags ?? const [],
        this.waypoints = waypoints ?? const [],
        this.segments = segments ?? const [],
        this.dailyPlans = dailyPlans ?? const [],
        this.relatedRouteIds = relatedRouteIds ?? const [],
        this.status = status ?? RouteStatus.planning,
        this.defaultMapId = defaultMapId ?? "",
        this.waterSources = waterSources ?? const [],
        this.supplyPoints = supplyPoints ?? const [],
        this.campsites = campsites ?? const [],
        this.hitchhikeContacts = hitchhikeContacts ?? const [];

  /// 从JSON创建
  factory RouteModel.fromJson(Map<String, dynamic> json) =>
      _$RouteModelFromJson(json);

  /// 转换为JSON
  @override
  Map<String, dynamic> toJson() => _$RouteModelToJson(this);

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

  /// 计算两点间距离（公里）
  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371.0; // 地球半径（公里）
    final double dLat = (lat2 - lat1) * (pi / 180);
    final double dLon = (lon2 - lon1) * (pi / 180);
    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * (pi / 180)) *
            cos(lat2 * (pi / 180)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
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

  /// 创建副本并更新部分属性
  RouteModel copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? name,
    String? createdBy,
    UserModel? createUser,
    int? usageCount,
    String? description,
    String? regionId,
    String? region,
    List<String>? bestSeason,
    List<String>? relatedMapIds,
    String? defaultMapId,
    TrackModel? defaultMap,
    RouteRatingsVO? ratings,
    List<String>? tags,
    RouteDifficulty? difficulty,
    List<WaypointModel>? waypoints,
    List<SegmentModel>? segments,
    List<DailyPlanModel>? dailyPlans,
    WeatherInfoVO? weatherInfo,
    FacilitiesModel? facilities,
    List<String>? imageUrls,
    String? coverUrl,
    String? mapDataId,
    bool? isFavorite,
    int? popularity,
    List<String>? relatedRouteIds,
    RouteStatus? status,
    List<WaterSourceModel>? waterSources,
    List<SupplyPointModel>? supplyPoints,
    List<CampsiteModel>? campsites,
    List<HitchhikeContactModel>? hitchhikeContacts,
  }) {
    return RouteModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      name: name ?? this.name,
      createdBy: createdBy ?? this.createdBy,
      createUser: createUser ?? this.createUser,
      usageCount: usageCount ?? this.usageCount,
      description: description ?? this.description,
      regionId: regionId ?? this.regionId,
      region: region ?? this.region,
      bestSeason: bestSeason ?? this.bestSeason,
      relatedMapIds: relatedMapIds ?? this.relatedMapIds,
      defaultMapId: defaultMapId ?? this.defaultMapId,
      defaultMap: defaultMap,
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
      isFavorite: isFavorite ?? this.isFavorite,
      popularity: popularity ?? this.popularity,
      relatedRouteIds: relatedRouteIds ?? this.relatedRouteIds,
      status: status ?? this.status,
      waterSources: waterSources ?? this.waterSources,
      supplyPoints: supplyPoints ?? this.supplyPoints,
      campsites: campsites ?? this.campsites,
      hitchhikeContacts: hitchhikeContacts ?? this.hitchhikeContacts,
    );
  }

  // === 便捷方法 ===

  /// 获取评分
  double get rating => ratings.overall;

  /// 获取最佳季节文本
  String? get bestSeasonText {
    if (bestSeason.isEmpty) return null;
    return bestSeason.join('、');
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
  double get elevationGain {
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

  /// 获取起点
  WaypointModel? get startPoint {
    if (waypoints.isEmpty) return null;
    return waypoints.firstWhere(
      (wp) => wp.type == 'start',
      orElse: () => waypoints.first,
    );
  }

  /// 获取终点
  WaypointModel? get endPoint {
    if (waypoints.isEmpty) return null;
    return waypoints.firstWhere(
      (wp) => wp.type == 'end',
      orElse: () => waypoints.last,
    );
  }

  /// 获取景点列表
  List<WaypointModel> get attractions {
    return waypoints.where((wp) => wp.type == 'attraction').toList();
  }

  /// 获取休息点列表
  List<WaypointModel> get restPoints {
    return waypoints.where((wp) => wp.type == 'rest').toList();
  }

  /// 获取山峰列表
  List<WaypointModel> get peaks {
    return waypoints.where((wp) => wp.type == 'peak').toList();
  }
}
