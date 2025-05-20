import '../route/route_model.dart';

/// 推荐路线类型
enum RecommendedRouteType {
  /// 精选路线
  featured,

  /// 热门路线
  popular,

  /// 季节推荐
  seasonal,

  /// 新晋路线
  new_routes,

  /// 周末短途
  weekend,
}

/// 推荐路线模型
class RecommendedRouteModel {
  /// 推荐类型
  final RecommendedRouteType type;

  /// 推荐标题
  final String title;

  /// 推荐描述
  final String? description;

  /// 路线列表
  final List<RouteModel> routes;

  /// 构造函数
  const RecommendedRouteModel({
    required this.type,
    required this.title,
    this.description,
    required this.routes,
  });

  /// 从JSON创建
  factory RecommendedRouteModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> routesJson = json['routes'] as List<dynamic>;
    final routes = routesJson
        .map((route) => RouteModel.fromJson(route as Map<String, dynamic>))
        .toList();

    return RecommendedRouteModel(
      type: _typeFromString(json['type'] as String),
      title: json['title'] as String,
      description: json['description'] as String?,
      routes: routes,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'type': _typeToString(type),
      'title': title,
      'description': description,
      'routes': routes.map((route) => route.toJson()).toList(),
    };
  }

  /// 从字符串转换为推荐类型
  static RecommendedRouteType _typeFromString(String typeStr) {
    switch (typeStr) {
      case 'featured':
        return RecommendedRouteType.featured;
      case 'popular':
        return RecommendedRouteType.popular;
      case 'seasonal':
        return RecommendedRouteType.seasonal;
      case 'new_routes':
        return RecommendedRouteType.new_routes;
      case 'weekend':
        return RecommendedRouteType.weekend;
      default:
        return RecommendedRouteType.featured;
    }
  }

  /// 将推荐类型转换为字符串
  static String _typeToString(RecommendedRouteType type) {
    switch (type) {
      case RecommendedRouteType.featured:
        return 'featured';
      case RecommendedRouteType.popular:
        return 'popular';
      case RecommendedRouteType.seasonal:
        return 'seasonal';
      case RecommendedRouteType.new_routes:
        return 'new_routes';
      case RecommendedRouteType.weekend:
        return 'weekend';
    }
  }
}

/// 推荐路线列表模型
class RecommendedRouteListModel {
  /// 推荐路线列表
  final List<RecommendedRouteModel> items;

  /// 更新时间
  final DateTime updatedAt;

  /// 构造函数
  const RecommendedRouteListModel({
    required this.items,
    required this.updatedAt,
  });

  /// 从JSON创建
  factory RecommendedRouteListModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> itemsJson = json['items'] as List<dynamic>;
    final items = itemsJson
        .map((item) => RecommendedRouteModel.fromJson(item as Map<String, dynamic>))
        .toList();

    return RecommendedRouteListModel(
      items: items,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// 获取指定类型的推荐路线
  RecommendedRouteModel? getByType(RecommendedRouteType type) {
    try {
      return items.firstWhere((item) => item.type == type);
    } catch (e) {
      return null;
    }
  }
}