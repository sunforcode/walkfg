import '../model/route/route_model.dart';
import '../model/trip_plan_model.dart';

/// 路线服务接口
///
/// 专注于提供路线相关的功能
abstract class RouteService {
  /// 获取路线详情
  Future<RouteModel> getRouteDetail(String routeId);

  /// 根据ID获取路线
  Future<RouteModel> getRouteById(String routeId);

  /// 获取热门路线
  Future<List<RouteModel>> getPopularRoutes({int limit = 10});

  /// 获取季节推荐路线
  Future<List<RouteModel>> getSeasonalRoutes({int limit = 10});

  /// 获取新晋路线
  Future<List<RouteModel>> getNewRoutes({int limit = 10});

  /// 获取周末短途路线
  Future<List<RouteModel>> getWeekendRoutes({int limit = 10});

  /// 根据地区获取路线
  Future<List<RouteModel>> getRoutesByRegion(String region, {int limit = 20});

  /// 根据难度获取路线
  Future<List<RouteModel>> getRoutesByDifficulty(RouteDifficulty difficulty,
      {int limit = 20});

  /// 根据时长获取路线
  Future<List<RouteModel>> getRoutesByDuration(int minDays, int maxDays,
      {int limit = 20});

  /// 搜索路线
  Future<List<RouteModel>> searchRoutes(String keyword, {int limit = 20});

  /// 获取收藏路线
  Future<List<RouteModel>> getFavoriteRoutes();

  /// 收藏路线
  Future<bool> favoriteRoute(String routeId);

  /// 取消收藏路线
  Future<bool> unfavoriteRoute(String routeId);

  /// 获取规划路线列表
  Future<List<PlannedRouteModel>> getPlannedRoutes();

  /// 获取已完成路线列表
  Future<List<RouteModel>> getCompletedRoutes();

  /// 获取推荐路线列表
  Future<List<RouteModel>> getRecommendedRoutes({String? season, int? limit});
}
