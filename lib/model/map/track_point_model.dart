import 'package:json_annotation/json_annotation.dart';
part 'track_point_model.g.dart';

/// 轨迹点值对象模型
@JsonSerializable()
class TrackPointVO {
  /// 纬度
  final double latitude;

  final String? name = null;

  /// 经度
  final double longitude;

  /// 海拔高度（米）
  final double elevation;

  /// 时间戳
  @JsonKey(ignore: true)
  final DateTime? timestamp;

  /// 距离起点的累计距离（米）
  @JsonKey(ignore: true)
  final double? distanceFromStart;

  /// 构造函数
  TrackPointVO({
    required this.latitude,
    required this.longitude,
    required this.elevation,
    this.timestamp,
    this.distanceFromStart,
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
  }) {
    return TrackPointVO(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      elevation: elevation ?? this.elevation,
      timestamp: timestamp ?? this.timestamp,
      distanceFromStart: distanceFromStart ?? this.distanceFromStart,
    );
  }
}
