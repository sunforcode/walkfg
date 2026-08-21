import 'package:json_annotation/json_annotation.dart';

part 'user_stats_model.g.dart';

/// 用户统计数据模型
///
/// 对应后端 GET /api/v1/user/stats 接口返回的数据
@JsonSerializable()
class UserStatsModel {
  /// 用户ID
  @JsonKey(name: 'user_id')
  final String userId;

  /// 用户名
  final String username;

  /// 创建的路线数量
  @JsonKey(name: 'route_count', defaultValue: 0)
  final int routeCount;

  /// 参与的行程数量
  @JsonKey(name: 'trip_count', defaultValue: 0)
  final int tripCount;

  /// 已完成路线数量
  @JsonKey(name: 'completed_routes', defaultValue: 0)
  final int completedRoutes;

  /// 收藏路线数量
  @JsonKey(name: 'favorite_routes', defaultValue: 0)
  final int favoriteRoutes;

  /// 装备清单数量
  @JsonKey(name: 'equipment_lists', defaultValue: 0)
  final int equipmentLists;

  /// 构造函数
  const UserStatsModel({
    required this.userId,
    required this.username,
    this.routeCount = 0,
    this.tripCount = 0,
    this.completedRoutes = 0,
    this.favoriteRoutes = 0,
    this.equipmentLists = 0,
  });

  /// 从JSON创建模型
  factory UserStatsModel.fromJson(Map<String, dynamic> json) =>
      _$UserStatsModelFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$UserStatsModelToJson(this);
}
