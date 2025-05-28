import 'package:json_annotation/json_annotation.dart';
import '../route/route_model.dart';

part 'recommended_route_model.g.dart';

/// 推荐路线类型
enum RecommendedRouteType {
  /// 热门路线
  popular,

  /// 新路线
  new_routes,

  /// 附近路线
  nearby,

  /// 季节性路线
  seasonal,

  /// 难度适中路线
  moderate,

  /// 初学者路线
  beginner,

  /// 高级路线
  advanced,
}

/// 推荐路线模型
@JsonSerializable()
class RecommendedRouteModel {
  /// 类型
  @JsonKey(fromJson: _typeFromJson, toJson: _typeToJson)
  final RecommendedRouteType type;

  /// 标题
  final String title;

  /// 描述
  final String description;

  /// 路线列表
  final List<RouteModel> routes;

  /// 构造函数
  RecommendedRouteModel({
    required this.type,
    required this.title,
    required this.description,
    required this.routes,
  });

  /// 从JSON创建
  factory RecommendedRouteModel.fromJson(Map<String, dynamic> json) =>
      _$RecommendedRouteModelFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$RecommendedRouteModelToJson(this);

  /// 解析类型
  static RecommendedRouteType _typeFromJson(dynamic type) {
    if (type is int && type >= 0 && type < RecommendedRouteType.values.length) {
      return RecommendedRouteType.values[type];
    }
    return RecommendedRouteType.popular;
  }

  /// 类型转JSON
  static int _typeToJson(RecommendedRouteType type) {
    return type.index;
  }
}

/// 推荐路线列表模型
@JsonSerializable()
class RecommendedRouteListModel {
  /// 推荐路线列表
  final List<RecommendedRouteModel> items;

  /// 构造函数
  RecommendedRouteListModel({
    required this.items,
  });

  /// 从JSON创建
  factory RecommendedRouteListModel.fromJson(Map<String, dynamic> json) =>
      _$RecommendedRouteListModelFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$RecommendedRouteListModelToJson(this);
}
