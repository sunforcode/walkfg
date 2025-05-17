import '../model/user_model.dart';
import '../model/weather_model.dart';
import '../model/route_model.dart';
import '../model/guide_model.dart';

/// API服务接口
abstract class ApiService {
  /// 获取当前用户信息
  Future<UserModel> getCurrentUser();
  
  /// 获取当前天气信息
  /// [latitude] 纬度
  /// [longitude] 经度
  Future<WeatherModel> getWeather(double latitude, double longitude);
  
  /// 获取用户统计信息
  Future<UserModel> getUserStats();
  
  /// 获取用户计划路线列表
  Future<List<PlannedRouteModel>> getPlannedRoutes();
  
  /// 获取推荐路线列表
  /// [season] 季节筛选（可选）
  /// [limit] 返回数量限制（可选）
  Future<List<RouteModel>> getRecommendedRoutes({String? season, int? limit});
  
  /// 获取路线详情
  /// [routeId] 路线ID
  Future<RouteModel> getRouteDetail(String routeId);
  
  /// 获取徒步攻略列表
  /// [limit] 返回数量限制（可选）
  /// [offset] 分页偏移量（可选）
  /// [tag] 标签筛选（可选）
  Future<List<GuideModel>> getHikingGuides({int? limit, int? offset, String? tag});
  
  /// 获取攻略详情
  /// [guideId] 攻略ID
  Future<GuideModel> getGuideDetail(String guideId);
  
  /// 创建计划路线
  /// [plannedRoute] 计划路线数据
  Future<PlannedRouteModel> createPlannedRoute(PlannedRouteModel plannedRoute);
  
  /// 更新计划路线
  /// [plannedRoute] 计划路线数据
  Future<PlannedRouteModel> updatePlannedRoute(PlannedRouteModel plannedRoute);
  
  /// 删除计划路线
  /// [plannedRouteId] 计划路线ID
  Future<bool> deletePlannedRoute(String plannedRouteId);
  
  /// 收藏路线
  /// [routeId] 路线ID
  Future<bool> favoriteRoute(String routeId);
  
  /// 取消收藏路线
  /// [routeId] 路线ID
  Future<bool> unfavoriteRoute(String routeId);
  
  /// 获取收藏路线列表
  Future<List<RouteModel>> getFavoriteRoutes();
  
  /// 点赞攻略
  /// [guideId] 攻略ID
  Future<GuideModel> likeGuide(String guideId);
  
  /// 取消点赞攻略
  /// [guideId] 攻略ID
  Future<GuideModel> unlikeGuide(String guideId);
}