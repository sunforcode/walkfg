import 'package:json_annotation/json_annotation.dart';

part 'route_ratings_model.g.dart';

/// 路线评分值对象模型
///
/// 作为路径模型的嵌套对象，不需要独立的ID和时间戳
@JsonSerializable()
class RouteRatingsVO {
  /// 总体评分
  final double overall;

  /// 景色评分
  final double scenery;

  /// 难度评分
  final double difficulty;

  /// 设施评分
  final double facilities;

  /// 完成率
  final double completionRate;

  /// 评论数量
  final int reviewCount;

  /// 构造函数
  RouteRatingsVO({
    required this.overall,
    required this.scenery,
    required this.difficulty,
    required this.facilities,
    required this.completionRate,
    required this.reviewCount,
  });

  /// 从JSON创建
  factory RouteRatingsVO.fromJson(Map<String, dynamic> json) =>
      _$RouteRatingsVOFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$RouteRatingsVOToJson(this);
}
