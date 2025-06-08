import 'package:json_annotation/json_annotation.dart';

part 'map_statistics.g.dart';

/// 地图统计值对象
@JsonSerializable()
class MapStatisticsVO {
  /// 总距离（公里）
  final double totalDistance;

  /// 总时长（小时）
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

  /// 构造函数
  const MapStatisticsVO({
    required this.totalDistance,
    this.totalDuration,
    required this.totalAscent,
    required this.totalDescent,
    required this.maxElevation,
    required this.minElevation,
    this.averageSpeed,
  });

  /// 从JSON创建
  factory MapStatisticsVO.fromJson(Map<String, dynamic> json) =>
      _$MapStatisticsVOFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$MapStatisticsVOToJson(this);

  @override
  String toString() {
    return 'MapStatisticsVO(distance: ${totalDistance}km, ascent: ${totalAscent}m, descent: ${totalDescent}m)';
  }
}