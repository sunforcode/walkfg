import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../model/user/user_model.dart';
import '../../../model/guide/guide_model.dart';
import '../../../model/route/route_model.dart';
import '../../../model/trip/trip_model.dart';
import '../../../model/weather/weather_model.dart';
import '../../../service/service_manager.dart';
import 'widgets/welcome_weather_card.dart';
import 'widgets/planned_trips_section.dart';
import 'widgets/recommended_routes_section.dart';
import 'widgets/hiking_guides_section.dart';

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

  /// 规划行程列表Future
  late Future<List<TripModel>> _plannedTripsFuture;

  /// 推荐路线列表Future
  late Future<List<RouteModel>> _recommendedRoutesFuture;

  /// 徒步攻略列表Future
  late Future<List<GuideModel>> _hikingGuidesFuture;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _userWeatherFuture = _loadUserWeatherData();
    _plannedTripsFuture = _loadPlannedTripsData();
    _recommendedRoutesFuture = _loadRecommendedRoutesData();
    _hikingGuidesFuture = _loadHikingGuidesData();
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
