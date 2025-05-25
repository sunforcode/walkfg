import 'package:json_annotation/json_annotation.dart';

part 'track_point_model.g.dart';

/// 轨迹点来源类型
enum TrackPointSourceType {
  /// KML格式
  kml,

  /// GPX格式
  gpx,

  /// GeoJSON格式
  geoJson,

  /// 自定义格式
  custom,

  /// 未知格式
  unknown
}

/// 轨迹点值对象模型
@JsonSerializable()
class TrackPointVO {
  /// 纬度
  final double latitude;

  /// 经度
  final double longitude;

  /// 海拔高度（米）
  final double elevation;

  /// 时间戳
  final DateTime? timestamp;

  /// 距离起点的累计距离（米）
  @JsonKey(name: 'distance_from_start')
  final double? distanceFromStart;

  /// 点类型（起点、终点、兴趣点等）
  @JsonKey(name: 'point_type')
  final String? pointType;

  /// 名称（对于兴趣点等）
  final String? name;

  /// 描述
  final String? description;

  /// 点类型（可选，如"途经点"、"起点"、"终点"等）
  final String? type;

  /// 点来源类型
  final TrackPointSourceType? sourceType;

  /// 原始数据（保存原始格式的数据，便于调试和特殊处理）
  final Map<String, dynamic>? rawData;

  /// 构造函数
  TrackPointVO({
    required this.latitude,
    required this.longitude,
    required this.elevation,
    this.timestamp,
    this.distanceFromStart,
    this.pointType,
    this.name,
    this.description,
    this.type,
    this.sourceType,
    this.rawData,
  });

  /// 从KML格式创建轨迹点
  factory TrackPointVO.fromKml({
    required double latitude,
    required double longitude,
    double elevation = 0.0,
    DateTime? timestamp,
    String? name,
    String? description,
    String? type,
    Map<String, dynamic>? rawData,
  }) {
    return TrackPointVO(
      latitude: latitude,
      longitude: longitude,
      elevation: elevation,
      timestamp: timestamp,
      name: name,
      description: description,
      type: type,
      sourceType: TrackPointSourceType.kml,
      rawData: rawData,
    );
  }

  /// 从JSON创建
  factory TrackPointVO.fromJson(Map<String, dynamic> json) =>
      _$TrackPointVOFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$TrackPointVOToJson(this);

  /// 创建副本并更新属性
  TrackPointVO copyWith({
    double? latitude,
    double? longitude,
    double? elevation,
    DateTime? timestamp,
    double? distanceFromStart,
    String? pointType,
    String? name,
    String? description,
    String? type,
    TrackPointSourceType? sourceType,
    Map<String, dynamic>? rawData,
  }) {
    return TrackPointVO(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      elevation: elevation ?? this.elevation,
      timestamp: timestamp ?? this.timestamp,
      distanceFromStart: distanceFromStart ?? this.distanceFromStart,
      pointType: pointType ?? this.pointType,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      sourceType: sourceType ?? this.sourceType,
      rawData: rawData ?? this.rawData,
    );
  }

  @override
  String toString() {
    return 'TrackPointVO(lat: $latitude, lng: $longitude, ele: $elevation, name: $name)';
  }
}
