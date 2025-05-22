import 'package:json_annotation/json_annotation.dart';
part 'map_bounds.g.dart';

/// 地图边界值对象
@JsonSerializable()
class MapBoundsVO {
  /// 北边界
  final double north;

  /// 南边界
  final double south;

  /// 东边界
  final double east;

  /// 西边界
  final double west;

  /// 构造函数
  MapBoundsVO({
    required this.north,
    required this.south,
    required this.east,
    required this.west,
  });

  /// 从JSON创建
  factory MapBoundsVO.fromJson(Map<String, dynamic> json) =>
      _$MapBoundsVOFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$MapBoundsVOToJson(this);
}
