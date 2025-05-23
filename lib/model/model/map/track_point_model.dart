import 'package:json_annotation/json_annotation.dart';

part 'track_point_model.g.dart';

/// 轨迹点值对象模型
///
@JsonSerializable()
class TrackPointVO {
  /// 纬度
  final double latitude;

  /// 经度
  final double longitude;

  /// 海拔（米）
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

  /// 构造函数
  TrackPointVO({
    required this.latitude,
    required this.longitude,
    this.timestamp,
    this.distanceFromStart,
    this.pointType,
    this.name,
    required this.elevation,
    this.description,
  });

  /// 从JSON创建
  factory TrackPointVO.fromJson(Map<String, dynamic> json) =>
      _$TrackPointVOFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$TrackPointVOToJson(this);
}
