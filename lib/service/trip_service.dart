import '../model/route/route_model.dart';
import '../model/trip/hot_search_model.dart';
import '../model/trip/recommended_route_model.dart';
import '../model/trip/trip_filter_model.dart';

/// 行程服务接口
///
/// 专注于提供行程相关的功能
abstract class TripService {
  /// 根据筛选条件获取路线
  Future<List<RouteModel>> getRoutesByFilter(TripFilterModel filter, {int limit = 20});

  /// 获取热门搜索
  Future<HotSearchListModel> getHotSearches({int limit = 10});

  /// 获取推荐路线列表
  Future<RecommendedRouteListModel> getRecommendedRoutes();

  /// 获取指定类型的推荐路线
  Future<RecommendedRouteModel?> getRecommendedRoutesByType(RecommendedRouteType type);
}
