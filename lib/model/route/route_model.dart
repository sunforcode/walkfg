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
import 'package:walk/model/route/gear_item_model.dart';
import 'package:walk/model/trip/trip_summary_model.dart';
import 'package:walk/model/route/poi_point_model.dart';
import 'package:walk/model/route/segment_scheme_model.dart';
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
  @JsonKey(defaultValue: '')
  final String description;

  /// 区域ID
  @JsonKey(name: 'region_id')
  final String? regionId;

  /// 区域名称
  @JsonKey(name: 'region')
  final String region;

  /// 默认地图ID
  @JsonKey(name: 'default_map_id')
  final String? defaultMapId;

  /// 评分信息
  final RouteRatingsVO? ratings;

  /// 标签列表
  @JsonKey(defaultValue: <String>[])
  final List<String> tags;

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

  /// 是否为环线（后端字段 is_loop）
  @JsonKey(name: 'is_loop', defaultValue: false)
  final bool isLoop;

  /// 路线类型（后端字段 route_type）
  @JsonKey(name: 'route_type')
  final int? routeType;

  /// 路线总距离（公里，来自后端 distance 字段）
  @JsonKey(name: 'distance')
  final double? distanceKm;

  /// 总爬升（米，来自后端 elevation_gain 字段）
  @JsonKey(name: 'elevation_gain', defaultValue: null)
  final double? elevationGainM;

  /// 总下降（米，来自后端 elevation_loss 字段）
  @JsonKey(name: 'elevation_loss', defaultValue: null)
  final double? elevationLossM;

  /// 预计时长（分钟，来自后端 duration 字段）
  @JsonKey(name: 'duration')
  final int? durationMinutes;

  /// 状态
  @JsonKey(fromJson: _parseStatus, toJson: _statusToJson)
  final RouteStatus status;

  /// 是否为多日路线（根据daily_plans计算）
  @JsonKey(includeFromJson: false, includeToJson: false)
  bool get isMultiDay => (dailyPlans?.length ?? 0) > 1;

  /// 路径分段，ai根据 某些信息将地图分段
  final List<SegmentModel>? segments;

  /// 分段方案列表（后台返回 segment_schemes，每套方案包含内部分段）
  @JsonKey(name: 'segment_schemes', defaultValue: <SegmentSchemeModel>[])
  final List<SegmentSchemeModel> segmentSchemes;

  /// 统一附属信息点列表（后台返回 poi_points，替代 marker_points）
  @JsonKey(name: 'poi_points', defaultValue: <PoiPointModel>[])
  final List<PoiPointModel> poiPoints;

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

  /// 最高海拔（米）
  @JsonKey(name: 'max_altitude')
  final double? maxAltitude;

  /// 最佳季节
  @JsonKey(name: 'best_season')
  final String? bestSeason;

  /// 交通信息
  @JsonKey(name: 'traffic_info')
  final String? trafficInfo;

  /// 信号覆盖信息
  @JsonKey(name: 'signal_info')
  final String? signalInfo;

  /// 季节性装备建议
  @JsonKey(name: 'seasonal_gear')
  final List<GearItemModel>? seasonalGear;

  /// 相关路线
  @JsonKey(name: 'related_routes')
  final List<RouteModel>? relatedRoutes;

  /// 相关行程摘要
  @JsonKey(name: 'related_trips')
  final List<TripSummaryModel>? relatedTrips;

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
    this.description = '',
    required this.regionId,
    this.region = "未知区域",
    this.defaultMapId,
    this.kmlUrl,
    this.gpxUrl,
    this.trackPoints = const <TrackPointVO>[],
    this.defaultMap,
    this.ratings,
    this.tags = const <String>[],
    required this.difficulty,
    this.segments,
    this.segmentSchemes = const <SegmentSchemeModel>[],
    this.poiPoints = const <PoiPointModel>[],
    this.dailyPlans,
    this.weatherInfo,
    this.imageUrls,
    this.coverUrl,
    this.isFavorite = false,
    required this.popularity,
    this.isLoop = false,
    this.routeType,
    this.distanceKm,
    this.elevationGainM,
    this.elevationLossM,
    this.durationMinutes,
    RouteStatus? status,
    this.waterSources,
    this.supplyPoints,
    this.campsites,
    this.hitchhikeContacts,
    this.maxAltitude,
    this.bestSeason,
    this.trafficInfo,
    this.signalInfo,
    this.seasonalGear,
    this.relatedRoutes,
    this.relatedTrips,
    this.markerPoints = const <MarkerPointModel>[],
  }) : this.status = status ?? RouteStatus.planning;

  /// 从JSON创建
  factory RouteModel.fromJson(Map<String, dynamic> json) =>
      _$RouteModelFromJson(json);

  /// 转换为JSON
  @override
  Map<String, dynamic> toJson() => _$RouteModelToJson(this);

  /// 解析难度
  ///
  /// 后端 difficulty 为 1-5 的整数编码（1=最简单，5=最难），
  /// 前端 [RouteDifficulty] 只有 4 档，映射关系为：
  /// 1 -> easy, 2 -> medium, 3 -> hard, 4/5 -> extreme。
  /// 注意：这不是简单的数组下标索引，避免 1-5 与 0-3 的偏移错位。
  static RouteDifficulty _parseDifficulty(dynamic difficulty) {
    if (difficulty is int) {
      switch (difficulty) {
        case 1:
          return RouteDifficulty.easy;
        case 2:
          return RouteDifficulty.medium;
        case 3:
          return RouteDifficulty.hard;
        case 4:
        case 5:
          return RouteDifficulty.extreme;
      }
    }
    return RouteDifficulty.medium; // 默认返回中等难度
  }

  /// 难度转JSON
  ///
  /// 与 [_parseDifficulty] 对应的反向映射，输出后端期望的 1-5 编码。
  static int _difficultyToJson(RouteDifficulty difficulty) {
    switch (difficulty) {
      case RouteDifficulty.easy:
        return 1;
      case RouteDifficulty.medium:
        return 2;
      case RouteDifficulty.hard:
        return 3;
      case RouteDifficulty.extreme:
        return 5;
    }
  }

  /// 解析状态（支持 int 和 String）
  static RouteStatus _parseStatus(dynamic status) {
    if (status is int &&
        status >= 0 &&
        status < RouteStatus.values.length) {
      return RouteStatus.values[status];
    }
    if (status is String) {
      return parseRouteStatus(status);
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
    List<SegmentSchemeModel>? segmentSchemes,
    List<PoiPointModel>? poiPoints,
    List<DailyPlanModel>? dailyPlans,
    WeatherInfoVO? weatherInfo,
    List<String>? imageUrls,
    String? coverUrl,
    bool? isFavorite,
    int? popularity,
    bool? isLoop,
    int? routeType,
    double? distanceKm,
    double? elevationGainM,
    double? elevationLossM,
    int? durationMinutes,
    RouteStatus? status,
    List<WaterSourceModel>? waterSources,
    List<SupplyPointModel>? supplyPoints,
    List<CampsiteModel>? campsites,
    List<HitchhikeContactModel>? hitchhikeContacts,
    double? maxAltitude,
    String? bestSeason,
    String? trafficInfo,
    String? signalInfo,
    List<GearItemModel>? seasonalGear,
    List<RouteModel>? relatedRoutes,
    List<TripSummaryModel>? relatedTrips,
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
      segmentSchemes: segmentSchemes ?? this.segmentSchemes,
      poiPoints: poiPoints ?? this.poiPoints,
      dailyPlans: dailyPlans ?? this.dailyPlans,
      weatherInfo: weatherInfo ?? this.weatherInfo,
      imageUrls: imageUrls ?? this.imageUrls,
      coverUrl: coverUrl ?? this.coverUrl,
      isFavorite: isFavorite ?? this.isFavorite,
      popularity: popularity ?? this.popularity,
      isLoop: isLoop ?? this.isLoop,
      routeType: routeType ?? this.routeType,
      distanceKm: distanceKm ?? this.distanceKm,
      elevationGainM: elevationGainM ?? this.elevationGainM,
      elevationLossM: elevationLossM ?? this.elevationLossM,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      status: status ?? this.status,
      waterSources: waterSources ?? this.waterSources,
      supplyPoints: supplyPoints ?? this.supplyPoints,
      campsites: campsites ?? this.campsites,
      hitchhikeContacts: hitchhikeContacts ?? this.hitchhikeContacts,
      maxAltitude: maxAltitude ?? this.maxAltitude,
      bestSeason: bestSeason ?? this.bestSeason,
      trafficInfo: trafficInfo ?? this.trafficInfo,
      signalInfo: signalInfo ?? this.signalInfo,
      seasonalGear: seasonalGear ?? this.seasonalGear,
      relatedRoutes: relatedRoutes ?? this.relatedRoutes,
      relatedTrips: relatedTrips ?? this.relatedTrips,
      markerPoints: markerPoints ?? this.markerPoints,
    );
  }

  // === 便捷方法 ===

  /// 获取评分
  double get rating => ratings?.overall ?? 0.0;

  /// 获取路线距离（公里）：优先取接口直接返回的值，fallback 到地图数据或分段计算
  double get distance {
    if (distanceKm != null) return distanceKm!;
    if (defaultMap != null) return defaultMap!.distance;
    return 0;
  }

  /// 获取路线爬升（米）：优先取接口直接返回的值，fallback 到地图数据或分段计算
  double get elevationGain {
    if (elevationGainM != null) return elevationGainM!;
    if (defaultMap != null) return defaultMap!.elevationGain;
    final defaultSegments = defaultSegmentScheme?.segments ?? segments;
    if (defaultSegments == null || defaultSegments.isEmpty) return 0.0;
    return defaultSegments.fold<double>(
        0.0, (sum, segment) => sum + (segment.elevationGain ?? 0.0));
  }

  /// 获取路线下降（米）：优先取接口直接返回的值，fallback 到地图数据
  double get elevationLoss {
    if (elevationLossM != null) return elevationLossM!;
    if (defaultMap != null) return defaultMap!.elevationLoss;
    return 0;
  }

  /// 获取默认分段方案（is_default=true 的方案，或第一个方案）
  SegmentSchemeModel? get defaultSegmentScheme {
    if (segmentSchemes.isEmpty) return null;
    return segmentSchemes.firstWhere(
      (s) => s.isDefault,
      orElse: () => segmentSchemes.first,
    );
  }

  /// 获取所有分段（优先从默认方案取，否则从 segments 字段取）
  List<SegmentModel> get allSegments {
    final schemeSegments = defaultSegmentScheme?.segments;
    if (schemeSegments != null && schemeSegments.isNotEmpty) {
      return schemeSegments;
    }
    return segments ?? [];
  }

  /// 获取预计时长字符串（优先用后端 duration 字段，fallback 按距离估算）
  String get durationText {
    int? mins = durationMinutes;
    if (mins == null && dailyPlans?.isNotEmpty == true) {
      mins = (dailyPlans!
              .fold(0.0, (sum, plan) => sum + plan.estimatedTime) *
          60).round();
    }
    if (mins != null && mins > 0) {
      final hours = mins ~/ 60;
      final minutes = mins % 60;
      return '$hours:${minutes.toString().padLeft(2, '0')}';
    }
    // 按距离估算（3km/h）
    final estimatedHours = distance / 3;
    final hours = estimatedHours.floor();
    final minutes = ((estimatedHours - hours) * 60).round();
    return '$hours:${minutes.toString().padLeft(2, '0')}';
  }
}
