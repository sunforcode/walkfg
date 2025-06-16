import 'package:json_annotation/json_annotation.dart';
import '../base/base_model.dart';

part 'route_comment_model.g.dart';

/// 路线评论模型
@JsonSerializable()
class RouteCommentModel extends BaseModel {
  /// 路线ID
  final String routeId;

  /// 用户ID
  final String userId;

  /// 用户名
  final String userName;

  /// 用户头像
  final String? userAvatar;

  /// 评论内容
  final String content;

  /// 评分
  final double rating;

  /// 构造函数
  RouteCommentModel({
    required super.id,
    required this.routeId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.content,
    required this.rating,
  });

  /// 从JSON创建
  factory RouteCommentModel.fromJson(Map<String, dynamic> json) =>
      _$RouteCommentModelFromJson(json);

  /// 转换为JSON
  @override
  Map<String, dynamic> toJson() => _$RouteCommentModelToJson(this);
}
