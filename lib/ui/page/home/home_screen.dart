import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../../model/guide/guide_model.dart';
import '../../../model/route/route_model.dart';
import '../../../model/trip/trip_model.dart';
import '../../../model/weather/weather_model.dart';
import '../../../service/service_manager.dart';
import '../../../services/weather/weather_manager.dart';
import '../../../services/location/location_service.dart';
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

  /// 海拔信息
  AltitudeInfo? _altitudeInfo;

  /// 是否正在获取海拔
  bool _isLoadingAltitude = false;

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
      print("获取到的天气为null");
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

  /// 获取海拔信息
  Future<void> _getAltitude() async {
    if (_isLoadingAltitude) return;

    setState(() {
      _isLoadingAltitude = true;
    });

    try {
      final altitudeInfo = await LocationService.instance.getCurrentAltitude(
        forceRefresh: true,
      );

      if (mounted) {
        setState(() {
          _altitudeInfo = altitudeInfo;
          _isLoadingAltitude = false;
        });
      }
    } catch (e) {
      print('获取海拔失败: $e');
      if (mounted) {
        setState(() {
          _isLoadingAltitude = false;
        });

        // 显示错误提示
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('获取海拔失败: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
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
                      altitudeInfo: _altitudeInfo,
                      isLoadingAltitude: _isLoadingAltitude,
                      onGetAltitude: _getAltitude,
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
        ],
      ),
    );
  }
}
