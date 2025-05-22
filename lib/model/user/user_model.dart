import 'package:json_annotation/json_annotation.dart';
import '../base/base_model.dart';

part 'user_model.g.dart';

/// 用户数据模型
@JsonSerializable()
class UserModel extends BaseModel {
  /// 用户名
  final String username;

  /// 昵称
  final String nickname;

  /// 头像URL
  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;

  /// 已完成路线数量
  @JsonKey(name: 'completed_routes')
  final int completedRoutes;

  /// 装备清单数量
  @JsonKey(name: 'equipment_lists')
  final int equipmentLists;

  /// 收藏路线数量
  @JsonKey(name: 'favorite_routes')
  final int favoriteRoutes;

  /// 构造函数
  UserModel({
    required super.id,
    super.createdAt,
    super.updatedAt,
    required this.username,
    required this.nickname,
    this.avatarUrl,
    required this.completedRoutes,
    required this.equipmentLists,
    required this.favoriteRoutes,
  });

  /// 从JSON创建模型
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  /// 转换为JSON
  @override
  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
