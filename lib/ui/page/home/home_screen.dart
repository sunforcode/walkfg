import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../model/user_model.dart';
import '../../../model/guide_model.dart';
import '../../../model/route/route_model.dart';
import '../../../model/weather/weather_model.dart';
import '../../../service/service_manager.dart';
import '../../../common/utils/date_time_utils.dart';
import '../../../common/utils/weather_utils.dart';
import 'widgets/welcome_weather_card.dart';
import 'widgets/stats_card.dart';
import 'widgets/planned_routes_section.dart';
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

  /// 规划路线列表Future
  late Future<List<PlannedRouteModel>> _plannedRoutesFuture;

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
    _plannedRoutesFuture = _loadPlannedRoutesData();
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

  /// 加载规划路线数据
  Future<List<PlannedRouteModel>> _loadPlannedRoutesData() async {
    final apiService = ServiceLocator.instance.getRouteService();
    return apiService.getPlannedRoutes();
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
    _unfinishedPlansCount = tripPlanService.getUnfinishedTripPlansCount();
  }

  /// 导航到已完成路线页面
  void _navigateToCompletedRoutes() {
    // TODO: 实现导航到已完成路线页面
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('导航到已完成路线页面'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  /// 导航到装备列表页面
  void _navigateToEquipmentList() {
    // TODO: 实现导航到装备列表页面
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('导航到装备列表页面'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  /// 导航到收藏路线页面
  void _navigateToFavoriteRoutes() {
    // TODO: 实现导航到收藏路线页面
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('导航到收藏路线页面'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  /// 刷新用户统计数据
  void _refreshUserStats() {
    setState(() {
      _userStatsFuture = _loadUserStatsData();
    });

    // 显示刷新提示
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('统计数据已更新'),
        duration: Duration(seconds: 1),
      ),
    );
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
                child: FutureBuilder<Map<String, dynamic>>(
                  future: _userWeatherFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return WelcomeWeatherCard.loading();
                    } else if (snapshot.hasError) {
                      return WelcomeWeatherCard.error(
                        errorMessage: snapshot.error.toString(),
                      );
                    } else if (snapshot.hasData) {
                      final user = snapshot.data!['user'] as UserModel;
                      final weather = snapshot.data!['weather'] as WeatherModel;

                      // 获取问候语和天气相关文本
                      final greeting = DateTimeUtils.getGreeting();
                      final weatherDescription =
                          WeatherUtils.getWeatherDescription(weather.condition);
                      final weatherConditionText =
                          WeatherUtils.getWeatherConditionText(
                              weather.condition);
                      final backgroundColor =
                          WeatherUtils.getWeatherColor(weather.condition);

                      return WelcomeWeatherCard(
                        user: user,
                        weather: weather,
                        greeting: greeting,
                        weatherDescription: weatherDescription,
                        weatherConditionText: weatherConditionText,
                        backgroundColor: backgroundColor,
                      );
                    } else {
                      return WelcomeWeatherCard.error(
                        errorMessage: '数据加载失败',
                      );
                    }
                  },
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

              // 规划路线部分
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: PlannedRoutesSection(
                  plannedRoutesFuture: _plannedRoutesFuture,
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
