import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:walk/model/map/marker_point_model.dart';
import 'package:walk/model/map/track_point_model.dart';
import 'package:walk/model/route/route_enums.dart';
import 'package:walk/model/route/segment_model.dart';
import 'package:walk/model/route/route_ratings.dart';
import 'package:walk/model/route/supply_point_model.dart';
import 'package:walk/model/route/track_model.dart';
import 'package:walk/model/route/daily_plan_model.dart';
import 'package:walk/model/route/weather_info.dart';
import 'package:walk/model/route/campsite_model.dart';
import 'package:walk/model/route/hitchhike_contact_model.dart';
import 'package:walk/model/user/user_model.dart';
import 'package:walk/model/water/water_source_model.dart';
import '../base/base_model.dart';
part 'route_model.g.dart';

/// 路线模型 - 户外路线的业务实体
@JsonSerializable()
class RouteModel extends BaseModel {
  /// 名称
  final String name;

  /// 使用次数（默认值）
  @JsonKey(name: 'usage_count', defaultValue: 0)
  final int usageCount;

  /// 描述
  final String description;

  /// 区域ID
  @JsonKey(name: 'region_id')
  final String? regionId;

  /// 区域名称
  @JsonKey(name: 'region')
  final String region;

  /// 默认地图ID
  @JsonKey(name: 'default_map_id')
  final String defaultMapId;

  /// 评分信息
  final RouteRatingsVO? ratings;

  /// 标签列表
  final List<String>? tags;

  /// 难度
  @JsonKey(
      name: 'difficulty', fromJson: _parseDifficulty, toJson: _difficultyToJson)
  final RouteDifficulty difficulty;

  /// 图片URL列表
  @JsonKey(name: 'image_urls')
  final List<String>? imageUrls;

  /// 封面图片URL
  @JsonKey(name: 'cover_url')
  final String? coverUrl;

  /// 是否收藏
  @JsonKey(name: 'is_favorite', defaultValue: false)
  final bool isFavorite;

  /// 人气
  @JsonKey(defaultValue: 0)
  final int popularity;

  /// 是否为环线
  @JsonKey(name: 'is_loop', defaultValue: false)
  final bool route_type;

  /// 状态
  @JsonKey(fromJson: _parseStatus, toJson: _statusToJson)
  final RouteStatus status;

  /// 是否为多日路线（根据daily_plans计算）
  @JsonKey(includeFromJson: false, includeToJson: false)
  bool get isMultiDay => (dailyPlans?.length ?? 0) > 1;

  /// 路径分段，ai根据 某些信息将地图分段
  final List<SegmentModel>? segments;

  /// 水源点列表
  @JsonKey(name: 'water_sources')
  final List<WaterSourceModel>? waterSources;

  /// 补给点列表
  @JsonKey(name: 'supplies')
  final List<SupplyPointModel>? supplyPoints;

  /// 营地资源列表
  @JsonKey(name: 'campsites')
  final List<CampsiteModel>? campsites;

  /// 每日行程计划， 可能执行多个路径分端，两者无关
  @JsonKey(name: 'daily_plans')
  final List<DailyPlanModel>? dailyPlans;

  /// 气候信息
  @JsonKey(name: 'weather_info')
  final WeatherInfoVO? weatherInfo;

  /// 搭车联系方式列表
  @JsonKey(name: 'hitchhike_contacts')
  final List<HitchhikeContactModel>? hitchhikeContacts;

  /// 标记点列表
  @JsonKey(name: 'marker_points', defaultValue: <MarkerPointModel>[])
  final List<MarkerPointModel>? markerPoints;

  /// 创建用户信息
  @JsonKey(name: 'creator')
  final UserModel? createUser;

  /// KML 文件 URL
  @JsonKey(name: 'kml_url')
  final String? kmlUrl;

  /// GPX 文件 URL
  @JsonKey(name: 'gpx_url')
  final String? gpxUrl;

  /// 轨迹点数据(从 API 获取)
  @JsonKey(name: 'track_points', defaultValue: <TrackPointVO>[])
  final List<TrackPointVO> trackPoints;

  /// 当前地图数据模型（运行时设置，不从 JSON 获取）
  @JsonKey(includeFromJson: false, includeToJson: false)
  final TrackModel? defaultMap;

  /// 构造函数
  RouteModel({
    required super.id,
    super.createdAt,
    super.updatedAt,
    required this.name,
    this.createUser,
    this.usageCount = 0,
    required this.description,
    required this.regionId,
    this.region = "未知区域",
    this.defaultMapId = "",
    this.kmlUrl,
    this.gpxUrl,
    this.trackPoints = const <TrackPointVO>[],
    this.defaultMap,
    this.ratings,
    this.tags,
    required this.difficulty,
    this.segments,
    this.dailyPlans,
    this.weatherInfo,
    this.imageUrls,
    this.coverUrl,
    this.isFavorite = false,
    required this.popularity,
    this.route_type = false,
    RouteStatus? status,
    this.waterSources,
    this.supplyPoints,
    this.campsites,
    this.hitchhikeContacts,
    this.markerPoints = const <MarkerPointModel>[],
  }) : this.status = status ?? RouteStatus.planning;

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
    String? defaultMapId,
    String? kmlUrl,
    String? gpxUrl,
    List<TrackPointVO>? trackPoints,
    TrackModel? defaultMap,
    RouteRatingsVO? ratings,
    List<String>? tags,
    RouteDifficulty? difficulty,
    List<SegmentModel>? segments,
    List<DailyPlanModel>? dailyPlans,
    WeatherInfoVO? weatherInfo,
    List<String>? imageUrls,
    String? coverUrl,
    bool? isFavorite,
    int? popularity,
    bool? isLoop,
    RouteStatus? status,
    List<WaterSourceModel>? waterSources,
    List<SupplyPointModel>? supplyPoints,
    List<CampsiteModel>? campsites,
    List<HitchhikeContactModel>? hitchhikeContacts,
    List<MarkerPointModel>? markerPoints,
  }) {
    return RouteModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      name: name ?? this.name,
      createUser: createUser ?? this.createUser,
      usageCount: usageCount ?? this.usageCount,
      description: description ?? this.description,
      regionId: regionId ?? this.regionId,
      region: region ?? this.region,
      defaultMapId: defaultMapId ?? this.defaultMapId,
      kmlUrl: kmlUrl ?? this.kmlUrl,
      gpxUrl: gpxUrl ?? this.gpxUrl,
      trackPoints: trackPoints ?? this.trackPoints,
      defaultMap: defaultMap,
      ratings: ratings ?? this.ratings,
      tags: tags ?? this.tags,
      difficulty: difficulty ?? this.difficulty,
      segments: segments ?? this.segments,
      dailyPlans: dailyPlans ?? this.dailyPlans,
      weatherInfo: weatherInfo ?? this.weatherInfo,
      imageUrls: imageUrls ?? this.imageUrls,
      coverUrl: coverUrl ?? this.coverUrl,
      isFavorite: isFavorite ?? this.isFavorite,
      popularity: popularity ?? this.popularity,
      status: status ?? this.status,
      waterSources: waterSources ?? this.waterSources,
      supplyPoints: supplyPoints ?? this.supplyPoints,
      campsites: campsites ?? this.campsites,
      hitchhikeContacts: hitchhikeContacts ?? this.hitchhikeContacts,
      markerPoints: markerPoints ?? this.markerPoints,
    );
  }

  // === 便捷方法 ===

  /// 获取评分
  double get rating => ratings?.overall ?? 0.0;

  /// 获取路线距离（公里）
  double get distance {
    if (defaultMap != null) {
      return defaultMap!.distance;
    }
    // 如果没有地图数据，则从分段计算
    return 0;
  }

  /// 获取路线爬升（米）
  double get elevationGain {
    if (defaultMap != null) {
      return defaultMap!.elevationGain;
    }
    // 如果没有地图数据，则从分段计算
    if (segments == null) return 0.0;
    return segments!.fold<double>(0.0, (sum, segment) => sum + (segment.elevationGain ?? 0.0));
  }

  /// 获取路线下降（米）
  double get elevationLoss {
    if (defaultMap != null) {
      return defaultMap!.elevationLoss;
    }
    return 0;
  }

  /// 获取预计时长
  String get duration {
    // 从每日计划计算总时长
    if (dailyPlans?.isNotEmpty == true) {
      final totalHours = dailyPlans!.fold(0.0, (sum, plan) {
        return sum + plan.estimatedTime;
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
}
