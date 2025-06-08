import 'package:json_annotation/json_annotation.dart';
import '../map/track_point_model.dart';
import 'route_enums.dart';

part 'track_model.g.dart';

/// 轨迹类型枚举
enum TrackType {
  /// 推荐轨迹
  recommended,

  /// 挑战轨迹
  challenge,

  /// 季节性轨迹
  seasonal,

  /// 快速轨迹
  fast,

  /// 备选轨迹
  alternative,
}

/// 轨迹数据模型
@JsonSerializable()
class TrackModel {
  /// 轨迹ID
  final String id;

  /// 轨迹名称
  final String name;

  /// 轨迹描述
  final String description;

  /// 距离（公里）
  final double distance;

  /// 难度
  @JsonKey(fromJson: _parseDifficulty, toJson: _difficultyToJson)
  final RouteDifficulty difficulty;

  /// 轨迹类型
  @JsonKey(fromJson: _parseTrackType, toJson: _trackTypeToJson)
  final TrackType trackType;

  /// 是否推荐
  @JsonKey(name: 'is_recommended')
  final bool isRecommended;

  /// 是否挑战
  @JsonKey(name: 'is_challenge')
  final bool isChallenge;

  /// 是否季节性
  @JsonKey(name: 'is_seasonal')
  final bool isSeasonal;

  /// 适用季节
  @JsonKey(name: 'suitable_seasons')
  final List<String> suitableSeasons;

  /// 累计爬升（米）
  @JsonKey(name: 'elevation_gain')
  final double elevationGain;

  /// 累计下降（米）
  @JsonKey(name: 'elevation_loss')
  final double elevationLoss;

  /// 最高海拔（米）
  @JsonKey(name: 'max_elevation')
  final double? maxElevation;

  /// 最低海拔（米）
  @JsonKey(name: 'min_elevation')
  final double? minElevation;

  /// 预计用时（小时）
  @JsonKey(name: 'estimated_time')
  final double estimatedTime;

  /// 轨迹点列表
  @JsonKey(name: 'track_points')
  final List<TrackPointVO> trackPoints;

  /// GPX文件URL
  @JsonKey(name: 'gpx_url')
  final String? gpxUrl;

  /// KML文件URL
  @JsonKey(name: 'kml_url')
  final String? kmlUrl;

  /// 创建时间
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  /// 更新时间
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  /// 创建者ID
  @JsonKey(name: 'created_by')
  final String createdBy;

  /// 是否已验证
  @JsonKey(name: 'is_verified')
  final bool isVerified;

  /// 使用次数
  @JsonKey(name: 'usage_count')
  final int usageCount;

  /// 评分
  final double rating;

  /// 标签
  final List<String> tags;

  /// 构造函数
  const TrackModel({
    required this.id,
    required this.name,
    required this.description,
    required this.distance,
    required this.difficulty,
    this.trackType = TrackType.alternative,
    this.isRecommended = false,
    this.isChallenge = false,
    this.isSeasonal = false,
    this.suitableSeasons = const [],
    this.elevationGain = 0.0,
    this.elevationLoss = 0.0,
    this.maxElevation,
    this.minElevation,
    this.estimatedTime = 8.0,
    this.trackPoints = const [],
    this.gpxUrl,
    this.kmlUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    this.isVerified = false,
    this.usageCount = 0,
    this.rating = 0.0,
    this.tags = const [],
  });

  /// 从JSON创建
  factory TrackModel.fromJson(Map<String, dynamic> json) =>
      _$TrackModelFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$TrackModelToJson(this);

  /// 获取难度名称
  String getDifficultyName() {
    return difficulty.getName();
  }

  /// 获取轨迹类型名称
  String getTrackTypeName() {
    switch (trackType) {
      case TrackType.recommended:
        return '推荐';
      case TrackType.challenge:
        return '挑战';
      case TrackType.seasonal:
        return '季节性';
      case TrackType.fast:
        return '快速';
      case TrackType.alternative:
        return '备选';
    }
  }

  /// 获取轨迹特色标签
  String? getFeatureTag() {
    if (isRecommended) return '推荐';
    if (isChallenge) return '挑战';
    if (isSeasonal) return '季节性';
    return null;
  }

  /// 获取预计用时文本
  String getEstimatedTimeText() {
    final hours = estimatedTime.floor();
    final minutes = ((estimatedTime - hours) * 60).round();
    if (minutes == 0) {
      return '${hours}小时';
    }
    return '${hours}小时${minutes}分钟';
  }

  /// 获取海拔信息文本
  String getElevationText() {
    if (maxElevation != null && minElevation != null) {
      return '${minElevation!.toInt()}m - ${maxElevation!.toInt()}m';
    }
    return '海拔信息待补充';
  }

  /// 是否有轨迹数据
  bool get hasTrackData => trackPoints.isNotEmpty;

  /// 是否有GPS文件
  bool get hasGpsFile => gpxUrl != null || kmlUrl != null;

  /// 创建副本
  TrackModel copyWith({
    String? id,
    String? name,
    String? description,
    double? distance,
    RouteDifficulty? difficulty,
    TrackType? trackType,
    bool? isRecommended,
    bool? isChallenge,
    bool? isSeasonal,
    List<String>? suitableSeasons,
    double? elevationGain,
    double? elevationLoss,
    double? maxElevation,
    double? minElevation,
    double? estimatedTime,
    List<TrackPointVO>? trackPoints,
    List<TrackPointVO>? waypoints,
    String? gpxUrl,
    String? kmlUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    bool? isVerified,
    int? usageCount,
    double? rating,
    List<String>? tags,
  }) {
    return TrackModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      distance: distance ?? this.distance,
      difficulty: difficulty ?? this.difficulty,
      trackType: trackType ?? this.trackType,
      isRecommended: isRecommended ?? this.isRecommended,
      isChallenge: isChallenge ?? this.isChallenge,
      isSeasonal: isSeasonal ?? this.isSeasonal,
      suitableSeasons: suitableSeasons ?? this.suitableSeasons,
      elevationGain: elevationGain ?? this.elevationGain,
      elevationLoss: elevationLoss ?? this.elevationLoss,
      maxElevation: maxElevation ?? this.maxElevation,
      minElevation: minElevation ?? this.minElevation,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      trackPoints: trackPoints ?? this.trackPoints,
      gpxUrl: gpxUrl ?? this.gpxUrl,
      kmlUrl: kmlUrl ?? this.kmlUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      isVerified: isVerified ?? this.isVerified,
      usageCount: usageCount ?? this.usageCount,
      rating: rating ?? this.rating,
      tags: tags ?? this.tags,
    );
  }

  // JSON转换辅助方法
  static RouteDifficulty _parseDifficulty(dynamic difficulty) {
    if (difficulty is int &&
        difficulty >= 0 &&
        difficulty < RouteDifficulty.values.length) {
      return RouteDifficulty.values[difficulty];
    } else if (difficulty is String) {
      switch (difficulty.toLowerCase()) {
        case 'easy':
        case '简单':
          return RouteDifficulty.easy;
        case 'medium':
        case '中等':
          return RouteDifficulty.medium;
        case 'hard':
        case '困难':
          return RouteDifficulty.hard;
        case 'extreme':
        case '极限':
          return RouteDifficulty.extreme;
        default:
          return RouteDifficulty.medium;
      }
    }
    return RouteDifficulty.medium;
  }

  static int _difficultyToJson(RouteDifficulty difficulty) {
    return difficulty.index;
  }

  static TrackType _parseTrackType(dynamic trackType) {
    if (trackType is int &&
        trackType >= 0 &&
        trackType < TrackType.values.length) {
      return TrackType.values[trackType];
    } else if (trackType is String) {
      switch (trackType.toLowerCase()) {
        case 'recommended':
        case '推荐':
          return TrackType.recommended;
        case 'challenge':
        case '挑战':
          return TrackType.challenge;
        case 'seasonal':
        case '季节性':
          return TrackType.seasonal;
        case 'fast':
        case '快速':
          return TrackType.fast;
        case 'alternative':
        case '备选':
          return TrackType.alternative;
        default:
          return TrackType.alternative;
      }
    }
    return TrackType.alternative;
  }

  static int _trackTypeToJson(TrackType trackType) {
    return trackType.index;
  }

  /// 获取起点名称
  String get startPoint {
    if (trackPoints.isNotEmpty) {
      return '起点';
    }
    return '起点待确定';
  }

  /// 获取终点名称
  String get endPoint {
    if (trackPoints.isNotEmpty) {
      return '终点';
    }
    return '终点待确定';
  }
}
