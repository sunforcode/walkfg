import 'package:json_annotation/json_annotation.dart';
import 'package:walk/model/route/segment_model.dart';
import 'map_bounds.dart';
import 'track_point_model.dart';

part 'map_data_model.g.dart';

/// 地图数据类型
enum MapDataType {
  /// KML 格式
  kml,

  /// GPX 格式
  gpx,

  /// GeoJSON 格式
  geoJson,

  /// 自定义格式
  custom,
}

/// 地图数据模型
@JsonSerializable()
class MapDataModel {
  /// ID
  final String id;

  /// 数据类型
  final MapDataType dataType;

  /// 源URL
  final String? sourceUrl;

  /// 原始内容
  final String? rawContent;

  /// 边界
  final MapBoundsVO bounds;

  /// 总距离（米）
  @JsonKey(name: 'total_distance')
  final double totalDistance;

  /// 总时长（秒）
  @JsonKey(name: 'total_duration')
  final int? totalDuration;

  /// 累计上升（米）
  @JsonKey(name: 'total_ascent')
  final double totalAscent;

  /// 累计下降（米）
  @JsonKey(name: 'total_descent')
  final double totalDescent;

  /// 最高海拔（米）
  @JsonKey(name: 'max_elevation')
  final double maxElevation;

  /// 最低海拔（米）
  @JsonKey(name: 'min_elevation')
  final double minElevation;

  /// 平均速度（米/秒）
  @JsonKey(name: 'average_speed')
  final double? averageSpeed;

  /// 轨迹点
  final List<TrackPointVO> trackPoints;

  /// 路标点
  final List<TrackPointVO> waypoints;

  /// 最高点
  final TrackPointVO highestPoint;

  /// 最低点
  final TrackPointVO lowestPoint;

  /// 起点
  final TrackPointVO startPoint;

  /// 终点
  final TrackPointVO endPoint;

  /// 点数量
  final int pointCount;

  /// 段数量
  final int segmentCount;

  /// 分段列表
  @JsonKey(defaultValue: <SegmentModel>[])
  final List<SegmentModel> segments;

  /// 记录时间
  final DateTime recordedAt;

  /// 处理状态
  final String processingStatus;

  /// 构造函数
  MapDataModel({
    required this.id,
    required this.dataType,
    this.sourceUrl,
    this.rawContent,
    required this.bounds,
    required this.totalDistance,
    this.totalDuration,
    required this.totalAscent,
    required this.totalDescent,
    required this.maxElevation,
    required this.minElevation,
    this.averageSpeed,
    required this.trackPoints,
    required this.waypoints,
    required this.highestPoint,
    required this.lowestPoint,
    required this.startPoint,
    required this.endPoint,
    required this.pointCount,
    required this.segmentCount,
    this.segments = const <SegmentModel>[],
    required this.recordedAt,
    required this.processingStatus,
  });

  /// 从JSON创建
  factory MapDataModel.fromJson(Map<String, dynamic> json) =>
      _$MapDataModelFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$MapDataModelToJson(this);

  /// 获取距离（公里）
  double get distance => totalDistance / 1000;

  /// 获取累计爬升（米）
  int get elevationGain => totalAscent.round();

  /// 获取累计下降（米）
  double get elevationLoss => totalDescent;

  /// 创建副本并更新指定字段
  MapDataModel copyWith({
    String? id,
    MapDataType? dataType,
    String? sourceUrl,
    String? rawContent,
    MapBoundsVO? bounds,
    double? totalDistance,
    int? totalDuration,
    double? totalAscent,
    double? totalDescent,
    double? maxElevation,
    double? minElevation,
    double? averageSpeed,
    List<TrackPointVO>? trackPoints,
    List<TrackPointVO>? waypoints,
    TrackPointVO? highestPoint,
    TrackPointVO? lowestPoint,
    TrackPointVO? startPoint,
    TrackPointVO? endPoint,
    int? pointCount,
    int? segmentCount,
    List<SegmentModel>? segments,
    DateTime? recordedAt,
    String? processingStatus,
  }) {
    return MapDataModel(
      id: id ?? this.id,
      dataType: dataType ?? this.dataType,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      rawContent: rawContent ?? this.rawContent,
      bounds: bounds ?? this.bounds,
      totalDistance: totalDistance ?? this.totalDistance,
      totalDuration: totalDuration ?? this.totalDuration,
      totalAscent: totalAscent ?? this.totalAscent,
      totalDescent: totalDescent ?? this.totalDescent,
      maxElevation: maxElevation ?? this.maxElevation,
      minElevation: minElevation ?? this.minElevation,
      averageSpeed: averageSpeed ?? this.averageSpeed,
      trackPoints: trackPoints ?? this.trackPoints,
      waypoints: waypoints ?? this.waypoints,
      highestPoint: highestPoint ?? this.highestPoint,
      lowestPoint: lowestPoint ?? this.lowestPoint,
      startPoint: startPoint ?? this.startPoint,
      endPoint: endPoint ?? this.endPoint,
      pointCount: pointCount ?? this.pointCount,
      segmentCount: segmentCount ?? this.segmentCount,
      segments: segments ?? this.segments,
      recordedAt: recordedAt ?? this.recordedAt,
      processingStatus: processingStatus ?? this.processingStatus,
    );
  }
}
