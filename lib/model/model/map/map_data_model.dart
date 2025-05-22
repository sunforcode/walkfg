import 'package:json_annotation/json_annotation.dart';
import 'package:walk/model/model/map/map_bounds.dart';
import 'package:walk/model/model/map/map_statistics.dart';
import 'package:walk/model/model/map/track_point_model.dart';
import '../../base/base_model.dart';

part 'map_data_model.g.dart';

/// 地图数据类型枚举
enum MapDataType {
  /// GPX格式
  gpx,
  
  /// KML格式
  kml,
  
  /// GeoJSON格式
  geoJson,
  
  /// 自定义格式
  custom
}

/// 地图数据模型 - 地理数据的基础容器
@JsonSerializable()
class MapDataModel extends BaseModel {
  /// 数据类型
  @JsonKey(name: 'data_type')
  final MapDataType dataType;
  
  /// 数据源URL（GPX、KML或GeoJSON文件的链接）
  @JsonKey(name: 'source_url')
  final String? sourceUrl;
  
  /// 原始数据内容（如果直接存储而非引用）
  @JsonKey(name: 'raw_content', includeIfNull: false)
  final String? rawContent;
  
  /// 数据哈希值（用于验证和缓存）
  @JsonKey(name: 'content_hash', includeIfNull: false)
  final String? contentHash;
  
  /// 边界信息
  final MapBoundsVO bounds;
  
  /// 统计信息
  final MapStatisticsVO statistics;
  
  /// 轨迹点列表
  @JsonKey(name: 'track_points')
  final List<TrackPointVO> trackPoints;
  
  /// 最高点
  @JsonKey(name: 'highest_point')
  final TrackPointVO? highestPoint;
  
  /// 最低点
  @JsonKey(name: 'lowest_point')
  final TrackPointVO? lowestPoint;
  
  /// 起点
  @JsonKey(name: 'start_point')
  final TrackPointVO? startPoint;
  
  /// 终点
  @JsonKey(name: 'end_point')
  final TrackPointVO? endPoint;
  
  /// 轨迹点数量
  @JsonKey(name: 'point_count')
  final int pointCount;
  
  /// 轨迹段数量
  @JsonKey(name: 'segment_count')
  final int segmentCount;
  
  /// 创建时间
  @JsonKey(name: 'recorded_at')
  final DateTime? recordedAt;
  
  /// 处理状态（是否已解析、验证等）
  @JsonKey(name: 'processing_status')
  final String processingStatus;
  
  /// 构造函数
  MapDataModel({
    required super.id,
    super.createdAt,
    super.updatedAt,
    required this.dataType,
    this.sourceUrl,
    this.rawContent,
    this.contentHash,
    required this.bounds,
    required this.statistics,
    required this.trackPoints,
    this.highestPoint,
    this.lowestPoint,
    this.startPoint,
    this.endPoint,
    required this.pointCount,
    required this.segmentCount,
    this.recordedAt,
    required this.processingStatus,
  });
  
  /// 从JSON创建
  factory MapDataModel.fromJson(Map<String, dynamic> json) =>
      _$MapDataModelFromJson(json);
      
  /// 转换为JSON
  @override
  Map<String, dynamic> toJson() => _$MapDataModelToJson(this);
  
  /// 创建副本并更新部分属性
  MapDataModel copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    MapDataType? dataType,
    String? sourceUrl,
    String? rawContent,
    String? contentHash,
    MapBoundsVO? bounds,
    MapStatisticsVO? statistics,
    List<TrackPointVO>? trackPoints,
    TrackPointVO? highestPoint,
    TrackPointVO? lowestPoint,
    TrackPointVO? startPoint,
    TrackPointVO? endPoint,
    int? pointCount,
    int? segmentCount,
    DateTime? recordedAt,
    String? processingStatus,
  }) {
    return MapDataModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dataType: dataType ?? this.dataType,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      rawContent: rawContent ?? this.rawContent,
      contentHash: contentHash ?? this.contentHash,
      bounds: bounds ?? this.bounds,
      statistics: statistics ?? this.statistics,
      trackPoints: trackPoints ?? this.trackPoints,
      highestPoint: highestPoint ?? this.highestPoint,
      lowestPoint: lowestPoint ?? this.lowestPoint,
      startPoint: startPoint ?? this.startPoint,
      endPoint: endPoint ?? this.endPoint,
      pointCount: pointCount ?? this.pointCount,
      segmentCount: segmentCount ?? this.segmentCount,
      recordedAt: recordedAt ?? this.recordedAt,
      processingStatus: processingStatus ?? this.processingStatus,
    );
  }
}