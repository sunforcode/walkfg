import 'package:json_annotation/json_annotation.dart';
import 'map_bounds.dart';
import 'map_statistics.dart';
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

  /// 统计信息
  final MapStatisticsVO statistics;

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
    required this.statistics,
    required this.trackPoints,
    required this.waypoints,
    required this.highestPoint,
    required this.lowestPoint,
    required this.startPoint,
    required this.endPoint,
    required this.pointCount,
    required this.segmentCount,
    required this.recordedAt,
    required this.processingStatus,
  });

  /// 从JSON创建
  factory MapDataModel.fromJson(Map<String, dynamic> json) =>
      _$MapDataModelFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$MapDataModelToJson(this);
}
