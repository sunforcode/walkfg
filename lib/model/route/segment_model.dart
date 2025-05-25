import 'package:json_annotation/json_annotation.dart';
import '../base/base_model.dart';
import '../map/track_point_model.dart';
import 'seasonal_closure_model.dart';

part 'segment_model.g.dart';

/// 路径段模型
@JsonSerializable()
class SegmentModel extends BaseModel {
  /// 起始点ID
  final String startPoint;

  /// 终点ID
  final String endPoint;

  /// 距离(km)
  final double distance;

  /// 爬升(m)
  final int elevationGain;

  /// 下降(m)
  final int elevationLoss;

  /// 预计时间(小时)
  final double estimatedTime;

  /// 难度(1-5)
  final int difficulty;

  /// 地形类型
  final String terrain;

  /// 路径坐标点集
  final List<TrackPointVO> path;

  /// 路面类型
  final String surfaceType;

  /// 危险因素
  final List<String> hazards;

  /// 季节性关闭信息
  final List<SeasonalClosureVO> seasonalClosures;

  /// 人流量等级(1-5)
  final int trafficLevel;

  /// 构造函数
  SegmentModel({
    required super.id,
    super.createdAt,
    super.updatedAt,
    required this.startPoint,
    required this.endPoint,
    required this.distance,
    required this.elevationGain,
    required this.elevationLoss,
    required this.estimatedTime,
    required this.difficulty,
    required this.terrain,
    required this.path,
    required this.surfaceType,
    List<String>? hazards,
    List<SeasonalClosureVO>? seasonalClosures,
    this.trafficLevel = 1,
  })  : this.hazards = hazards ?? const [],
        this.seasonalClosures = seasonalClosures ?? const [];

  /// 从JSON创建
  factory SegmentModel.fromJson(Map<String, dynamic> json) =>
      _$SegmentModelFromJson(json);

  /// 转换为JSON
  @override
  Map<String, dynamic> toJson() => _$SegmentModelToJson(this);
}
