import 'package:json_annotation/json_annotation.dart';
import '../base/base_model.dart';

part 'route_rating_model.g.dart';

/// 路线评分模型
@JsonSerializable()
class RouteRatingModel extends BaseModel {
  /// 路线ID
  final String routeId;

  /// 用户ID
  final String userId;

  /// 评分
  final double rating;

  /// 构造函数
  RouteRatingModel({
    required super.id,
    super.createdAt,
    super.updatedAt,
    required this.routeId,
    required this.userId,
    required this.rating,
  });

  /// 从JSON创建
  factory RouteRatingModel.fromJson(Map<String, dynamic> json) =>
      _$RouteRatingModelFromJson(json);

  /// 转换为JSON
  @override
  Map<String, dynamic> toJson() => _$RouteRatingModelToJson(this);
}