import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../base/base_model.dart';
import '../../enums/route_status.dart';

part 'route_model.g.dart';

/// 路线类型枚举
enum RouteType {
  /// 环线
  circular,

  /// 单向
  oneWay,

  /// 往返
  roundTrip,
}

/// 路线方向枚举
enum RouteDirection {
  /// 顺时针
  clockwise,

  /// 逆时针
  counterClockwise,
}

/// 路线难度枚举
enum RouteDifficulty {
  /// 简单
  easy,

  /// 中等
  medium,

  /// 困难
  hard,

  /// 极限
  extreme;

  /// 获取难度名称
  String getName() {
    switch (this) {
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
  Color getColor() {
    switch (this) {
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
}

/// 路线基本信息值对象
@JsonSerializable()
class RouteBasicInfoVO {
  /// 距离（公里）
  final double distance;

  /// 预计时长
  final String duration;

  /// 爬升（米）
  @JsonKey(name: 'elevation_gain')
  final int elevationGain;

  /// 下降（米）
  @JsonKey(name: 'elevation_loss')
  final double? elevationLoss;

  /// 难度
  @JsonKey(fromJson: _parseDifficulty, toJson: _difficultyToJson)
  final RouteDifficulty difficulty;

  /// 路线类型
  @JsonKey(
      name: 'route_type', fromJson: _parseRouteType, toJson: _routeTypeToJson)
  final RouteType routeType;

  /// 路线方向
  @JsonKey(
      name: 'route_direction',
      fromJson: _parseRouteDirection,
      toJson: _routeDirectionToJson)
  final RouteDirection? routeDirection;

  /// 最佳季节
  @JsonKey(name: 'best_season')
  final List<String> bestSeason;

  /// 构造函数
  RouteBasicInfoVO({
    required this.distance,
    required this.duration,
    required this.elevationGain,
    this.elevationLoss,
    required this.difficulty,
    required this.routeType,
    this.routeDirection,
    required this.bestSeason,
  });

  /// 从JSON创建
  factory RouteBasicInfoVO.fromJson(Map<String, dynamic> json) =>
      _$RouteBasicInfoVOFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$RouteBasicInfoVOToJson(this);

  /// 解析难度
  static RouteDifficulty _parseDifficulty(dynamic value) {
    if (value is int && value >= 0 && value < RouteDifficulty.values.length) {
      return RouteDifficulty.values[value];
    }

    if (value is String) {
      switch (value.toLowerCase()) {
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

    return RouteDifficulty.medium;
  }

  /// 难度转JSON
  static int _difficultyToJson(RouteDifficulty difficulty) {
    return difficulty.index;
  }

  /// 解析路线类型
  static RouteType _parseRouteType(dynamic value) {
    if (value is int && value >= 0 && value < RouteType.values.length) {
      return RouteType.values[value];
    }

    if (value is String) {
      switch (value.toLowerCase()) {
        case 'circular':
          return RouteType.circular;
        case 'oneway':
          return RouteType.oneWay;
        case 'roundtrip':
          return RouteType.roundTrip;
        default:
          return RouteType.circular;
      }
    }

    return RouteType.circular;
  }

  /// 路线类型转JSON
  static int _routeTypeToJson(RouteType routeType) {
    return routeType.index;
  }

  /// 解析路线方向
  static RouteDirection? _parseRouteDirection(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is int && value >= 0 && value < RouteDirection.values.length) {
      return RouteDirection.values[value];
    }

    if (value is String) {
      switch (value.toLowerCase()) {
        case 'clockwise':
          return RouteDirection.clockwise;
        case 'counterclockwise':
          return RouteDirection.counterClockwise;
        default:
          return RouteDirection.clockwise;
      }
    }

    return RouteDirection.clockwise;
  }

  /// 路线方向转JSON
  static int? _routeDirectionToJson(RouteDirection? routeDirection) {
    return routeDirection?.index;
  }
}

/// 路线评分值对象
@JsonSerializable()
class RouteRatingsVO {
  /// 总体评分
  final double overall;

  /// 风景评分
  final double scenery;

  /// 难度评分
  final double difficulty;

  /// 体验评分
  final double experience;

  /// 设施评分
  final double facilities;

  /// 评分人数
  @JsonKey(name: 'rating_count')
  final int ratingCount;

  /// 构造函数
  RouteRatingsVO({
    required this.overall,
    required this.scenery,
    required this.difficulty,
    required this.experience,
    required this.facilities,
    required this.ratingCount,
  });

  /// 从JSON创建
  factory RouteRatingsVO.fromJson(Map<String, dynamic> json) =>
      _$RouteRatingsVOFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$RouteRatingsVOToJson(this);
}

/// 路线关键点模型
@JsonSerializable()
class WaypointModel {
  /// ID
  final String id;

  /// 名称
  final String name;

  /// 描述
  final String description;

  /// 纬度
  final double latitude;

  /// 经度
  final double longitude;

  /// 海拔
  final double? elevation;

  /// 类型
  final String type;

  /// 图标URL
  @JsonKey(name: 'icon_url')
  final String? iconUrl;

  /// 图片URL
  @JsonKey(name: 'image_url')
  final String? imageUrl;

  /// 序号
  @JsonKey(name: 'sequence_number')
  final int sequenceNumber;

  /// 构造函数
  WaypointModel({
    required this.id,
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    this.elevation,
    required this.type,
    this.iconUrl,
    this.imageUrl,
    required this.sequenceNumber,
  });

  /// 从JSON创建
  factory WaypointModel.fromJson(Map<String, dynamic> json) =>
      _$WaypointModelFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$WaypointModelToJson(this);
}

/// 路线分段模型
@JsonSerializable()
class SegmentModel {
  /// ID
  final String id;

  /// 名称
  final String name;

  /// 描述
  final String description;

  /// 起点ID
  @JsonKey(name: 'start_waypoint_id')
  final String startWaypointId;

  /// 终点ID
  @JsonKey(name: 'end_waypoint_id')
  final String endWaypointId;

  /// 距离（公里）
  final double distance;

  /// 预计时长
  final String duration;

  /// 爬升（米）
  @JsonKey(name: 'elevation_gain')
  final int elevationGain;

  /// 下降（米）
  @JsonKey(name: 'elevation_loss')
  final double? elevationLoss;

  /// 难度
  @JsonKey(
      fromJson: RouteBasicInfoVO._parseDifficulty,
      toJson: RouteBasicInfoVO._difficultyToJson)
  final RouteDifficulty difficulty;

  /// 地形类型
  @JsonKey(name: 'terrain_type')
  final String terrainType;

  /// 序号
  @JsonKey(name: 'sequence_number')
  final int sequenceNumber;

  /// 构造函数
  SegmentModel({
    required this.id,
    required this.name,
    required this.description,
    required this.startWaypointId,
    required this.endWaypointId,
    required this.distance,
    required this.duration,
    required this.elevationGain,
    this.elevationLoss,
    required this.difficulty,
    required this.terrainType,
    required this.sequenceNumber,
  });

  /// 从JSON创建
  factory SegmentModel.fromJson(Map<String, dynamic> json) =>
      _$SegmentModelFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$SegmentModelToJson(this);
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

  /// 包含的分段ID列表
  @JsonKey(name: 'segment_ids')
  final List<String> segmentIds;

  /// 住宿信息
  final String? accommodation;

  /// 构造函数
  DailyPlanModel({
    required this.id,
    required this.dayNumber,
    required this.title,
    required this.description,
    required this.distance,
    required this.duration,
    required this.elevationGain,
    this.elevationLoss,
    required this.startWaypointId,
    required this.endWaypointId,
    required this.segmentIds,
    this.accommodation,
  });

  /// 从JSON创建
  factory DailyPlanModel.fromJson(Map<String, dynamic> json) =>
      _$DailyPlanModelFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$DailyPlanModelToJson(this);
}

/// 气候信息值对象
@JsonSerializable()
class WeatherInfoVO {
  /// 气候描述
  final String description;

  /// 季节性信息
  final Map<String, String> seasonal;

  /// 最佳季节
  @JsonKey(name: 'best_seasons')
  final List<String> bestSeasons;

  /// 注意事项
  final String? precautions;

  /// 构造函数
  WeatherInfoVO({
    required this.description,
    required this.seasonal,
    required this.bestSeasons,
    this.precautions,
  });

  /// 从JSON创建
  factory WeatherInfoVO.fromJson(Map<String, dynamic> json) =>
      _$WeatherInfoVOFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$WeatherInfoVOToJson(this);
}

/// 设施信息值对象
@JsonSerializable()
class FacilitiesVO {
  /// 水源
  final String water;

  /// 食物
  final String food;

  /// 住宿
  final String accommodation;

  /// 厕所
  final String toilets;

  /// 信号覆盖
  @JsonKey(name: 'signal_coverage')
  final String signalCoverage;

  /// 构造函数
  FacilitiesVO({
    required this.water,
    required this.food,
    required this.accommodation,
    required this.toilets,
    required this.signalCoverage,
  });

  /// 从JSON创建
  factory FacilitiesVO.fromJson(Map<String, dynamic> json) =>
      _$FacilitiesVOFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$FacilitiesVOToJson(this);
}

/// 安全信息值对象
@JsonSerializable()
class SafetyInfoVO {
  /// 风险描述
  final String risks;

  /// 紧急联系方式
  @JsonKey(name: 'emergency_contacts')
  final String emergencyContacts;

  /// 安全建议
  @JsonKey(name: 'safety_tips')
  final String safetyTips;

  /// 构造函数
  SafetyInfoVO({
    required this.risks,
    required this.emergencyContacts,
    required this.safetyTips,
  });

  /// 从JSON创建
  factory SafetyInfoVO.fromJson(Map<String, dynamic> json) =>
      _$SafetyInfoVOFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$SafetyInfoVOToJson(this);
}

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

  /// 区域ID
  @JsonKey(name: 'region')
  final String region;

  /// 基本信息
  @JsonKey(name: 'basic_info')
  final RouteBasicInfoVO basicInfo;

  /// 评分信息
  final RouteRatingsVO ratings;

  /// 标签列表
  final List<String> tags;

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

  /// 安全信息
  @JsonKey(name: 'safety_info')
  final SafetyInfoVO? safetyInfo;

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
    required this.basicInfo,
    required this.ratings,
    List<String>? tags,
    List<WaypointModel>? waypoints,
    List<SegmentModel>? segments,
    List<DailyPlanModel>? dailyPlans,
    this.weatherInfo,
    this.facilities,
    this.safetyInfo,
    required this.imageUrls,
    this.coverUrl,
    required this.mapDataId,
    required this.createdBy,
    this.isFavorite = false,
    required this.popularity,
    this.relatedRouteIds,
    this.region = "未知区域",
    RouteStatus? status,
  })  : this.tags = tags ?? const [],
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

  /// 获取难度名称
  String getDifficultyName() {
    return basicInfo.difficulty.getName();
  }

  /// 获取难度颜色
  Color getDifficultyColor() {
    return basicInfo.difficulty.getColor();
  }

  /// 创建副本并更新部分属性
  RouteModel copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? name,
    String? description,
    String? regionId,
    RouteBasicInfoVO? basicInfo,
    RouteRatingsVO? ratings,
    List<String>? tags,
    List<WaypointModel>? waypoints,
    List<SegmentModel>? segments,
    List<DailyPlanModel>? dailyPlans,
    WeatherInfoVO? weatherInfo,
    FacilitiesVO? facilities,
    SafetyInfoVO? safetyInfo,
    List<String>? imageUrls,
    String? coverUrl,
    String? mapDataId,
    String? createdBy,
    bool? isFavorite,
    int? popularity,
    List<String>? relatedRouteIds,
    RouteStatus? status,
  }) {
    return RouteModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      name: name ?? this.name,
      description: description ?? this.description,
      regionId: regionId ?? this.regionId,
      basicInfo: basicInfo ?? this.basicInfo,
      ratings: ratings ?? this.ratings,
      tags: tags ?? this.tags,
      waypoints: waypoints ?? this.waypoints,
      segments: segments ?? this.segments,
      dailyPlans: dailyPlans ?? this.dailyPlans,
      weatherInfo: weatherInfo ?? this.weatherInfo,
      facilities: facilities ?? this.facilities,
      safetyInfo: safetyInfo ?? this.safetyInfo,
      imageUrls: imageUrls ?? this.imageUrls,
      coverUrl: coverUrl ?? this.coverUrl,
      mapDataId: mapDataId ?? this.mapDataId,
      createdBy: createdBy ?? this.createdBy,
      isFavorite: isFavorite ?? this.isFavorite,
      popularity: popularity ?? this.popularity,
      relatedRouteIds: relatedRouteIds ?? this.relatedRouteIds,
      status: status ?? this.status,
    );
  }
}
