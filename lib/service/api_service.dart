import '../model/guide_model.dart';
import '../model/route/route_model.dart';
import '../model/trip_plan_model.dart';
import '../model/user_model.dart';
import '../model/weather/weather_model.dart';

/// API服务接口
///
/// 提供基础的API调用功能，是所有其他服务的底层支持
abstract class ApiService {
  /// 获取路线详情
  Future<RouteModel> getRouteDetail(String routeId);

  /// 获取所有路线数据
  Future<List<RouteModel>> getRoutes({String? season, int? limit});

  /// 搜索路线
  Future<List<RouteModel>> searchRoutes(String query,
      {Map<String, dynamic>? filters});

  /// 获取用户信息
  Future<UserModel> getCurrentUser();

  /// 获取用户统计数据
  Future<UserModel> getUserStats();

  /// 获取天气信息
  Future<WeatherModel> getWeather(double latitude, double longitude);

  /// 获取攻略详情
  Future<GuideModel> getGuideDetail(String guideId);

  /// 获取攻略列表
  Future<List<GuideModel>> getHikingGuides(
      {int? limit, int? offset, String? tag});

  /// 获取行程计划详情
  Future<TripPlanModel> getTripPlanDetail(String tripPlanId);

  /// 创建行程计划
  Future<TripPlanModel> createTripPlan(TripPlanModel tripPlan);

  /// 更新行程计划
  Future<TripPlanModel> updateTripPlan(TripPlanModel tripPlan);

  /// 删除行程计划
  Future<bool> deleteTripPlan(String tripPlanId);

  /// 获取行程计划列表
  Future<List<TripPlanModel>> getTripPlans();

  /// 获取路线行程安排
  Future<List<DailyItinerary>> getRouteItineraries(String routeId);

  /// 获取推荐装备列表
  Future<List<EquipmentItemModel>> getRecommendedEquipment(String routeId);
}
