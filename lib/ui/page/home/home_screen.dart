import 'package:flutter/cupertino.dart';
import '../../../model/user/user_model.dart';
import '../../../model/guide/guide_model.dart';
import '../../../model/model/route/route_model.dart';
import '../../../model/model/trip/trip_model.dart';
import '../../../model/weather/weather_model.dart';
import '../../../service/service_manager.dart';
import 'widgets/welcome_weather_card.dart';
import 'widgets/stats_card.dart';
import 'widgets/planned_trips_section.dart';
import 'widgets/recommended_routes_section.dart';
import 'widgets/hiking_guides_section.dart';
import 'widgets/trip_planning_entries.dart';

/// 首页
class HomeScreen extends StatefulWidget {
  /// 构造函数
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  /// 用户和天气数据Future
  late Future<Map<String, dynamic>> _userWeatherFuture;

  /// 用户统计数据Future
  late Future<UserModel> _userStatsFuture;

  /// 规划行程列表Future
  late Future<List<TripModel>> _plannedTripsFuture;

  /// 推荐路线列表Future
  late Future<List<RouteModel>> _recommendedRoutesFuture;

  /// 徒步攻略列表Future
  late Future<List<GuideModel>> _hikingGuidesFuture;

  /// 未完成行程计划数量
  late int _unfinishedPlansCount;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _userWeatherFuture = _loadUserWeatherData();
    _userStatsFuture = _loadUserStatsData();
    _plannedTripsFuture = _loadPlannedTripsData();
    _recommendedRoutesFuture = _loadRecommendedRoutesData();
    _hikingGuidesFuture = _loadHikingGuidesData();
    _loadUnfinishedPlansCount();
  }

  /// 加载用户和天气数据
  Future<Map<String, dynamic>> _loadUserWeatherData() async {
    final userService = ServiceLocator.instance.getUserService();
    final weatherService = ServiceLocator.instance.getWeatherService();

    // 并行加载用户和天气数据
    final results = await Future.wait([
      userService.getCurrentUser(),
      weatherService.getWeather(30.2741, 120.1551), // 杭州的经纬度
    ]);

    return {
      'user': results[0] as UserModel,
      'weather': results[1] as WeatherModel,
    };
  }

  /// 加载用户统计数据
  Future<UserModel> _loadUserStatsData() async {
    final userService = ServiceLocator.instance.getUserService();
    return userService.getUserStats();
  }

  /// 加载规划行程数据
  Future<List<TripModel>> _loadPlannedTripsData() async {
    final tripService = ServiceLocator.instance.getTripService();
    return tripService.getPlannedTrips();
  }

  /// 加载推荐路线数据
  Future<List<RouteModel>> _loadRecommendedRoutesData() async {
    final routeService = ServiceLocator.instance.getRouteService();
    return routeService.getPopularRoutes();
  }

  /// 加载徒步攻略数据
  Future<List<GuideModel>> _loadHikingGuidesData() async {
    final guideService = ServiceLocator.instance.getGuideService();
    // 获取徒步攻略，限制4条
    return guideService.getGuides(limit: 4);
  }

  /// 加载未完成行程计划数量
  void _loadUnfinishedPlansCount() {
    final tripPlanService = ServiceLocator.instance.getTripPlanService();
    _unfinishedPlansCount = 5;
    //tripPlanService.getUnfinishedTripPlansCount();
  }

  /// 显示提示信息
  void _showToast(String message) {
    showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.of(context, rootNavigator: true).pop();
        });
        return CupertinoAlertDialog(
          content: Text(message),
        );
      },
    );
  }

  /// 导航到已完成路线页面
  void _navigateToCompletedRoutes() {
    // TODO: 实现导航到已完成路线页面
    _showToast('导航到已完成路线页面');
  }

  /// 导航到装备列表页面
  void _navigateToEquipmentList() {
    // TODO: 实现导航到装备列表页面
    _showToast('导航到装备列表页面');
  }

  /// 导航到收藏路线页面
  void _navigateToFavoriteRoutes() {
    // TODO: 实现导航到收藏路线页面
    _showToast('导航到收藏路线页面');
  }

  /// 刷新用户统计数据
  void _refreshUserStats() {
    setState(() {
      _userStatsFuture = _loadUserStatsData();
    });

    // 显示刷新提示
    _showToast('统计数据已更新');
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // 必须调用super.build

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('首页'),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 天气卡片
              Padding(
                padding: const EdgeInsets.all(16),
                child: WelcomeWeatherCard.fromFuture(
                  future: _userWeatherFuture,
                ),
              ),

              // 行程规划入口
              TripPlanningEntries(
                unfinishedPlansCount: _unfinishedPlansCount,
              ),

              // 用户统计卡片
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: StatsCard(
                  userStatsFuture: _userStatsFuture,
                  onCompletedRoutesPressed: _navigateToCompletedRoutes,
                  onEquipmentListPressed: _navigateToEquipmentList,
                  onFavoriteRoutesPressed: _navigateToFavoriteRoutes,
                  onRefreshPressed: _refreshUserStats,
                ),
              ),

              const SizedBox(height: 24),

              // 规划行程部分
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: PlannedTripsSection(
                  plannedTripsFuture: _plannedTripsFuture,
                ),
              ),

              const SizedBox(height: 24),

              // 当季推荐路线部分
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: RecommendedRoutesSection(
                  recommendedRoutesFuture: _recommendedRoutesFuture,
                ),
              ),

              const SizedBox(height: 24),

              // 徒步攻略部分
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: HikingGuidesSection(
                  hikingGuidesFuture: _hikingGuidesFuture,
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
