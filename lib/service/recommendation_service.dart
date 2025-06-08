import '../model/route/route_model.dart';
import '../model/search/hot_search_model.dart';
import '../model/route/recommended_route_model.dart';

/// 推荐服务接口
///
/// 专注于提供推荐功能，包括热门搜索、推荐路线等
abstract class RecommendationService {
  /// 获取热门搜索
  /// 
  /// [limit] 限制返回的结果数量
  Future<HotSearchListModel> getHotSearches({int limit = 10});

  /// 获取推荐路线列表
  Future<RecommendedRouteListModel> getRecommendedRoutes();

  /// 获取指定类型的推荐路线
  /// 
  /// [type] 推荐路线类型
  Future<RecommendedRouteModel?> getRecommendedRoutesByType(RecommendedRouteType type);
  
  /// 获取季节性推荐路线
  /// 
  /// [season] 季节，如"春"、"夏"、"秋"、"冬"
  /// [limit] 限制返回的结果数量
  Future<List<RouteModel>> getSeasonalRecommendations({String? season, int limit = 10});
  
  /// 获取个性化推荐路线
  /// 
  /// 基于用户历史行为和偏好推荐路线
  /// [limit] 限制返回的结果数量
  Future<List<RouteModel>> getPersonalizedRecommendations({int limit = 10});
  
  /// 获取相似路线推荐
  /// 
  /// [routeId] 参考路线ID
  /// [limit] 限制返回的结果数量
  Future<List<RouteModel>> getSimilarRoutes(String routeId, {int limit = 5});
}