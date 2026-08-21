import 'package:json_annotation/json_annotation.dart';

part 'route_ratings.g.dart';

/// 路线评分值对象
@JsonSerializable()
class RouteRatingsVO {
  /// 总体评分
  final double? overall;

  /// 风景评分
  final double? scenery;

  /// 难度评分
  final double? difficulty;

  /// 体验评分
  final double? experience;

  /// 设施评分
  final double? facilities;

  /// 评分人数
  @JsonKey(name: 'rating_count', defaultValue: 0)
  final int ratingCount;

  /// 构造函数
  RouteRatingsVO({
    this.overall,
    this.scenery,
    this.difficulty,
    this.experience,
    this.facilities,
    this.ratingCount = 0,
  });

  /// 从JSON创建
  factory RouteRatingsVO.fromJson(Map<String, dynamic> json) =>
      _$RouteRatingsVOFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$RouteRatingsVOToJson(this);
}
