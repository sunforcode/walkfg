import 'package:json_annotation/json_annotation.dart';
import 'waypoint_model.dart';
import 'campsite_model.dart';

part 'daily_itinerary_model.g.dart';

/// 每日行程模型 - 用于API服务
@JsonSerializable()
class DailyItinerary {
  /// 起点
  final String startPoint;

  /// 终点
  final String endPoint;

  /// 距离(公里)
  final double distance;

  /// 爬升(米)
  final int elevationGain;

  /// 下降(米)
  final int elevationLoss;

  /// 预计时间(小时)
  final double estimatedTime;

  /// 途经点
  final List<WaypointModel> waypoints;

  /// 推荐营地
  final CampsiteModel? recommendedCampsite;

  /// 备选营地
  final List<CampsiteModel> alternateCampsites;

  /// 构造函数
  DailyItinerary({
    required this.startPoint,
    required this.endPoint,
    required this.distance,
    required this.elevationGain,
    required this.elevationLoss,
    required this.estimatedTime,
    List<WaypointModel>? waypoints,
    this.recommendedCampsite,
    List<CampsiteModel>? alternateCampsites,
  })  : this.waypoints = waypoints ?? const [],
        this.alternateCampsites = alternateCampsites ?? const [];

  /// 从JSON创建
  factory DailyItinerary.fromJson(Map<String, dynamic> json) =>
      _$DailyItineraryFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$DailyItineraryToJson(this);
}
