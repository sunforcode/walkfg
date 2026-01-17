import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../../model/guide/guide_model.dart';
import '../../../model/route/route_model.dart';
import '../../../model/trip/trip_model.dart';
import '../../../model/weather/weather_model.dart';
import '../../../service/weather/weather_manager.dart';
import '../../../service/location/location_service.dart';
import '../../../service/user_service.dart';
import '../../../service/weather_service.dart';
import '../../../service/trip_service.dart';
import '../../../service/route_service.dart';
import '../../../service/guide_service.dart';
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

class _HomeScreenState extends State<HomeScreen> with AutomaticKeepAliveClientMixin {
  /// 所有页面数据的Future
  late Future<_HomePageData> _pageDataFuture;

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
    _pageDataFuture = _loadAllPageData();
  }

  @override
  void dispose() {
    _weatherManager.dispose();
    super.dispose();
  }

  /// 并行加载所有页面数据
  Future<_HomePageData> _loadAllPageData() async {
    try {
      // 使用 Future.wait 并行发起所有请求
      final results = await Future.wait([
        _loadUserWeatherData(),
        _loadPlannedTripsData(),
        _loadRecommendedRoutesData(),
        _loadHikingGuidesData(),
      ]);

      return _HomePageData(
        userWeatherData: results[0] as Map<String, dynamic>,
        plannedTrips: results[1] as List<TripModel>,
        recommendedRoutes: results[2] as List<RouteModel>,
        hikingGuides: results[3] as List<GuideModel>,
      );
    } catch (e) {
      debugPrint('加载页面数据失败: $e');
      // 即使发生错误，也返回默认数据结构
      rethrow;
    }
  }

  /// 加载用户和天气数据
  Future<Map<String, dynamic>> _loadUserWeatherData() async {
    try {
      // 先获取用户数据
      final user = await UserService.getCurrentUser();

      // 尝试获取当前位置的天气
      WeatherModel? weather;
      try {
        // 检查位置权限
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied && !_isRequestingPermission) {
          // 直接请求位置权限
          if (mounted) {
            setState(() {
              _isRequestingPermission = true;
            });
          }

          permission = await Geolocator.requestPermission();

          if (mounted) {
            setState(() {
              _isRequestingPermission = false;
            });
          }
        }

        // 如果有位置权限，获取当前位置的天气
        if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
          weather = await _weatherManager.getCurrentLocationWeather();
        }
      } catch (e) {
        debugPrint('获取位置或天气失败: $e');
      }

      // 如果无法获取当前位置的天气，使用默认位置（杭州）
      if (weather == null) {
        debugPrint('使用默认位置获取天气');
        weather = await WeatherService.getWeather(30.2741, 120.1551);
      }

      return {
        'user': user,
        'weather': weather,
      };
    } catch (e) {
      debugPrint('加载用户和天气数据失败: $e');
      // 返回默认数据避免整个页面加载失败
      rethrow;
    }
  }

  /// 刷新所有数据
  Future<void> _refreshAllData() async {
    setState(() {
      _pageDataFuture = _loadAllPageData();
    });
  }

  /// 刷新天气数据
  Future<void> _refreshWeatherData() async {
    setState(() {
      _pageDataFuture = _loadAllPageData();
    });
  }

  /// 加载规划行程数据
  Future<List<TripModel>> _loadPlannedTripsData() async {
    try {
      return await TripService.getPlannedTrips();
    } catch (e) {
      debugPrint('加载规划行程数据失败: $e');
      // 返回空列表，不影响其他数据加载
      return [];
    }
  }

  /// 加载推荐路线数据
  Future<List<RouteModel>> _loadRecommendedRoutesData() async {
    try {
      return await RouteService.getPopularRoutes();
    } catch (e) {
      debugPrint('加载推荐路线数据失败: $e');
      // 返回空列表，不影响其他数据加载
      return [];
    }
  }

  /// 加载徒步攻略数据
  Future<List<GuideModel>> _loadHikingGuidesData() async {
    try {
      // 获取徒步攻略，限制4条
      return await GuideService.getGuides(limit: 4);
    } catch (e) {
      debugPrint('加载徒步攻略数据失败: $e');
      // 返回空列表，不影响其他数据加载
      return [];
    }
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
      debugPrint('获取海拔失败: $e');
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
      child: FutureBuilder<_HomePageData>(
        future: _pageDataFuture,
        builder: (context, snapshot) {
          // 加载中状态
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CupertinoActivityIndicator(),
            );
          }

          // 错误状态
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    CupertinoIcons.exclamationmark_triangle,
                    size: 48,
                    color: CupertinoColors.systemGrey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '加载失败',
                    style: TextStyle(
                      fontSize: 18,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    style: TextStyle(
                      fontSize: 14,
                      color: CupertinoColors.systemGrey2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  CupertinoButton(
                    onPressed: _refreshAllData,
                    child: const Text('重试'),
                  ),
                ],
              ),
            );
          }

          // 成功加载数据
          final pageData = snapshot.data!;

          return Stack(
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
                        child: WelcomeWeatherCard(
                          user: pageData.userWeatherData['user'],
                          weather: pageData.userWeatherData['weather'],
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
                          plannedTripsFuture: Future.value(pageData.plannedTrips),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // 当季推荐路线部分
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: RecommendedRoutesSection(
                          recommendedRoutesFuture: Future.value(pageData.recommendedRoutes),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // 徒步攻略部分
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: HikingGuidesSection(
                          hikingGuidesFuture: Future.value(pageData.hikingGuides),
                        ),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// 首页数据模型
class _HomePageData {
  final Map<String, dynamic> userWeatherData;
  final List<TripModel> plannedTrips;
  final List<RouteModel> recommendedRoutes;
  final List<GuideModel> hikingGuides;

  _HomePageData({
    required this.userWeatherData,
    required this.plannedTrips,
    required this.recommendedRoutes,
    required this.hikingGuides,
  });
}
