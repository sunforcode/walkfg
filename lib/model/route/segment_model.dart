import 'package:json_annotation/json_annotation.dart';

part 'segment_model.g.dart';

/// 路线分段模型
@JsonSerializable()
class SegmentModel {
  /// ID
  final String id;

  /// 名称
  final String name;

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

  /// 路径点列表
  @JsonKey(name: 'path_points')
  final List<List<double>> pathPoints;

  /// 构造函数
  SegmentModel({
    required this.id,
    required this.name,
    required this.description,
    required this.distance,
    required this.duration,
    required this.elevationGain,
    this.elevationLoss,
    required this.startWaypointId,
    required this.endWaypointId,
    required this.pathPoints,
  });

  /// 从JSON创建
  factory SegmentModel.fromJson(Map<String, dynamic> json) =>
      _$SegmentModelFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$SegmentModelToJson(this);
}
