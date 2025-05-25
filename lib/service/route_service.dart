import '../model/route/route_model.dart';
import '../model/route/route_rating_model.dart';
import '../model/route/route_comment_model.dart';
import '../model/trip/trip_filter_model.dart';

/// 路线服务接口
///
/// 专注于路线数据的查询、筛选和管理
abstract class RouteService {
  /// 根据ID获取路线
  Future<RouteModel> getRouteById(String routeId);

  /// 获取路线详情
  Future<RouteModel> getRouteDetail(String routeId);

  /// 获取路线评分
  Future<Map<String, dynamic>> getRouteRatings(String routeId);

  /// 获取路线标签
  Future<List<String>> getRouteTags(String routeId);

  /// 获取路线关键点
  Future<Map<String, dynamic>> getRouteWaypoints(String routeId);

  /// 获取热门路线
  Future<List<RouteModel>> getPopularRoutes({int limit = 10});

  /// 获取季节性路线
  Future<List<RouteModel>> getSeasonalRoutes({int limit = 10});

  /// 获取新晋路线
  Future<List<RouteModel>> getNewRoutes({int limit = 10});

  /// 获取周末路线
  Future<List<RouteModel>> getWeekendRoutes({int limit = 10});

  /// 获取推荐路线
  Future<List<RouteModel>> getRecommendedRoutes({int limit = 10});

  /// 获取路线列表
  Future<List<RouteModel>> getRoutes({String? season, int? limit});

  /// 根据地区获取路线
  Future<List<RouteModel>> getRoutesByRegion(String region, {int limit = 20});

  /// 根据难度获取路线
  Future<List<RouteModel>> getRoutesByDifficulty(RouteDifficulty difficulty,
      {int limit = 20});

  /// 根据持续时间获取路线
  Future<List<RouteModel>> getRoutesByDuration(int minDays, int maxDays,
      {int limit = 20});

  /// 搜索路线
  Future<List<RouteModel>> searchRoutes(String keyword, {int limit = 20});

  /// 根据筛选条件获取路线
  Future<List<RouteModel>> getRoutesByFilter(TripFilterModel filter,
      {int limit = 20});

  /// 获取收藏路线
  Future<List<RouteModel>> getFavoriteRoutes();

  /// 收藏路线
  Future<bool> favoriteRoute(String routeId);

  /// 取消收藏路线
  Future<bool> unfavoriteRoute(String routeId);

  /// 检查路线是否已收藏
  Future<bool> checkIfFavorite(String routeId);

  /// 添加收藏
  Future<bool> addFavorite(String routeId);

  /// 移除收藏
  Future<bool> removeFavorite(String routeId);

  /// 获取计划路线
  Future<List<RouteModel>> getPlannedRoutes();

  /// 获取已完成路线
  Future<List<RouteModel>> getCompletedRoutes();

  /// 获取路线评论
  Future<List<RouteCommentModel>> getRouteComments(String routeId);

  /// 添加路线评论
  Future<RouteCommentModel> addRouteComment(
      String routeId, String content, double rating);

  /// 评分路线
  Future<RouteRatingModel> rateRoute(String routeId, double rating);

  /// 创建路线
  Future<RouteModel> createRoute(RouteModel route);

  /// 更新路线
  Future<RouteModel> updateRoute(RouteModel route);

  /// 删除路线
  Future<bool> deleteRoute(String routeId);
}
