/// 用户数据模型
class UserModel {
  /// 用户ID
  final String id;
  
  /// 用户名
  final String username;
  
  /// 昵称
  final String nickname;
  
  /// 头像URL
  final String? avatarUrl;
  
  /// 已完成路线数量
  final int completedRoutes;
  
  /// 装备清单数量
  final int equipmentLists;
  
  /// 收藏路线数量
  final int favoriteRoutes;

  /// 构造函数
  UserModel({
    required this.id,
    required this.username,
    required this.nickname,
    this.avatarUrl,
    required this.completedRoutes,
    required this.equipmentLists,
    required this.favoriteRoutes,
  });

  /// 从JSON创建模型
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      username: json['username'] as String,
      nickname: json['nickname'] as String,
      avatarUrl: json['avatar_url'] as String?,
      completedRoutes: json['completed_routes'] as int,
      equipmentLists: json['equipment_lists'] as int,
      favoriteRoutes: json['favorite_routes'] as int,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'nickname': nickname,
      'avatar_url': avatarUrl,
      'completed_routes': completedRoutes,
      'equipment_lists': equipmentLists,
      'favorite_routes': favoriteRoutes,
    };
  }
}