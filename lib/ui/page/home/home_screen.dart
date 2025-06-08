import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import '../../../model/user/user_model.dart';
import '../../../model/guide/guide_model.dart';
import '../../../model/route/route_model.dart';
import '../../../model/trip/trip_model.dart';
import '../../../model/weather/weather_model.dart';
import '../../../service/service_manager.dart';
import '../../../services/weather/weather_manager.dart';
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

  /// 天气管理器
  final WeatherManager _weatherManager = WeatherManager();

  /// 是否正在请求位置权限
  bool _isRequestingPermission = false;

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

  @override
  void dispose() {
    _weatherManager.dispose();
    super.dispose();
  }

  /// 加载用户和天气数据
  Future<Map<String, dynamic>> _loadUserWeatherData() async {
    final userService = ServiceLocator.instance.getUserService();

    // 先获取用户数据
    final user = await userService.getCurrentUser();

    // 尝试获取当前位置的天气
    WeatherModel? weather;
    try {
      // 检查位置权限
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied && !_isRequestingPermission) {
        // 直接请求位置权限
        setState(() {
          _isRequestingPermission = true;
        });

        permission = await Geolocator.requestPermission();

        setState(() {
          _isRequestingPermission = false;
        });
      }

      // 如果有位置权限，获取当前位置的天气
      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        weather = await _weatherManager.getCurrentLocationWeather();
      }
    } catch (e) {
      debugPrint('获取位置或天气失败: $e');
    }

    // 如果无法获取当前位置的天气，使用默认位置（杭州）
    if (weather == null) {
      final weatherService = ServiceLocator.instance.getWeatherService();
      weather = await weatherService.getWeather(30.2741, 120.1551); // 杭州的经纬度
    }

    return {
      'user': user,
      'weather': weather,
    };
  }

  /// 刷新天气数据
  Future<void> _refreshWeatherData() async {
    setState(() {
      _userWeatherFuture = _loadUserWeatherData();
    });
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
      child: Stack(
        children: [
          // 主要内容
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 天气卡片
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: WelcomeWeatherCard.fromFuture(
                      future: _userWeatherFuture,
                      onRefresh: _refreshWeatherData,
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

          // 地图功能悬浮按钮
          Positioned(
            right: 16,
            bottom: 100, // 避免与底部导航栏重叠
            child: _buildMapFloatingButton(),
          ),
        ],
      ),
    );
  }

  /// 构建地图功能悬浮按钮
  Widget _buildMapFloatingButton() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // 提示标签
        Container(
          margin: const EdgeInsets.only(bottom: 8, right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: CupertinoColors.black.withOpacity(0.8),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: CupertinoColors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                CupertinoIcons.sparkles,
                color: Colors.white,
                size: 14,
              ),
              SizedBox(width: 4),
              Text(
                '地图演示',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        // 悬浮按钮
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF4A90E2),
                Color(0xFF357ABD),
              ],
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4A90E2).withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 8),
                spreadRadius: 2,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(28),
              onTap: () {
                // 添加触觉反馈
                HapticFeedback.lightImpact();
              },
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // 主图标
                    const Icon(
                      CupertinoIcons.map_fill,
                      color: Colors.white,
                      size: 28,
                    ),

                    // 闪烁效果
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.6),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
