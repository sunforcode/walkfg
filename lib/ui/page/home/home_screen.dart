import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../../model/guide/guide_model.dart';
import '../../../model/route/route_model.dart';
import '../../../model/trip/trip_model.dart';
import '../../../model/user/user_model.dart';
import '../../../model/weather/weather_model.dart';
import '../../../service/weather/weather_manager.dart';
import '../../../service/location/location_service.dart';
import '../../../service/user_service.dart';
import '../../../service/weather_service.dart';
import '../../../service/trip_service.dart';
import '../../../service/route_service.dart';
import '../../../service/guide_service.dart';
import '../../../core/network/interceptors/auth_interceptor.dart';
import '../../../core/state/auth_notifier.dart';
import '../../../theme/tokens/tokens.dart';
import '../debug/map_test_screen.dart';
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
  /// 公开数据（不需要登录）
  late Future<_HomePublicData> _publicDataFuture;

  /// 用户数据（需要登录）
  Future<_HomeUserData>? _userDataFuture;

  /// 天气管理器
  final WeatherManager _weatherManager = WeatherManager();

  /// 是否正在请求位置权限
  bool _isRequestingPermission = false;

  /// 海拔信息
  AltitudeInfo? _altitudeInfo;

  /// 是否正在获取海拔
  bool _isLoadingAltitude = false;

  /// 是否已登录
  bool _isLoggedIn = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadData();
    
    // 监听登录状态变化
    AuthNotifier().addListener(_onAuthStateChanged);
    debugPrint('HomeScreen: Listening to AuthNotifier');
  }

  @override
  void dispose() {
    // 移除登录状态监听
    AuthNotifier().removeListener(_onAuthStateChanged);
    debugPrint('HomeScreen: Stopped listening to AuthNotifier');
    
    _weatherManager.dispose();
    super.dispose();
  }

  /// 登录状态变化回调
  void _onAuthStateChanged() {
    debugPrint('HomeScreen: Auth state changed, isLoggedIn: ${AuthNotifier().isLoggedIn}');
    
    if (mounted) {
      setState(() {
        _isLoggedIn = AuthNotifier().isLoggedIn;
      });
      
      // 重新加载数据
      _loadData();
    }
  }

  /// 加载所有数据
  void _loadData() {
    debugPrint('HomeScreen: _loadData called');
    debugPrint('HomeScreen: isLoggedIn: ${AuthNotifier().isLoggedIn}');

    // 使用 AuthNotifier 的状态（在应用启动时已从本地存储初始化）
    final isLoggedIn = AuthNotifier().isLoggedIn;
    
    if (mounted) {
      setState(() {
        _isLoggedIn = isLoggedIn;
      });
    }

    // 始终加载公开数据
    _publicDataFuture = _loadPublicData();

    // 如果已登录，加载用户数据
    if (isLoggedIn) {
      _userDataFuture = _loadUserData();
    }
  }

  /// 刷新天气数据
  Future<void> _refreshWeatherData() async {
    setState(() {
      _loadData();
    });
  }

  /// 加载公开数据（不需要登录）
  Future<_HomePublicData> _loadPublicData() async {
    debugPrint('HomeScreen: Loading public data');
    
    try {
      // 并行加载公开数据
      final results = await Future.wait([
        _loadWeatherData(),
        _loadRecommendedRoutesData(),
        _loadHikingGuidesData(),
      ], eagerError: false);

      return _HomePublicData(
        weather: results[0] as WeatherModel?,
        recommendedRoutes: results[1] as List<RouteModel>,
        hikingGuides: results[2] as List<GuideModel>,
      );
    } catch (e) {
      debugPrint('HomeScreen: Error loading public data: $e');
      return _HomePublicData(
        weather: null,
        recommendedRoutes: [],
        hikingGuides: [],
      );
    }
  }

  /// 加载用户数据（需要登录）
  Future<_HomeUserData> _loadUserData() async {
    debugPrint('HomeScreen: Loading user data');
    
    try {
      final results = await Future.wait([
        _loadUserProfile(),
        _loadPlannedTripsData(),
      ], eagerError: false);

      return _HomeUserData(
        user: results[0] as UserModel?,
        plannedTrips: results[1] as List<TripModel>,
      );
    } catch (e) {
      debugPrint('HomeScreen: Error loading user data: $e');
      await AuthInterceptor.clearAuthTokens();
      if (mounted) {
        setState(() {
          _isLoggedIn = false;
          _userDataFuture = null;
        });
      }
      return _HomeUserData(
        user: null,
        plannedTrips: [],
      );
    }
  }

  /// 加载用户信息
  Future<UserModel?> _loadUserProfile() async {
    try {
      final user = await UserService.getCurrentUser();
      debugPrint('HomeScreen: User profile loaded: ${user.nickname}');
      return user;
    } catch (e) {
      debugPrint('HomeScreen: Error loading user profile: $e');
      return null;
    }
  }

  /// 加载天气数据
  Future<WeatherModel?> _loadWeatherData() async {
    WeatherModel? weather;
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied && !_isRequestingPermission) {
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

      if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
        weather = await _weatherManager.getCurrentLocationWeather();
      }
    } catch (e) {
      debugPrint('HomeScreen: 获取位置或天气失败: $e');
    }

    if (weather == null) {
      try {
        debugPrint('HomeScreen: 使用默认位置获取天气');
        weather = await WeatherService.getWeather(30.2741, 120.1551);
      } catch (e) {
        debugPrint('HomeScreen: 获取默认位置天气失败: $e');
      }
    }

    return weather;
  }

  /// 加载规划行程数据
  Future<List<TripModel>> _loadPlannedTripsData() async {
    try {
      return await TripService.getPlannedTrips();
    } catch (e) {
      debugPrint('HomeScreen: 加载规划行程数据失败: $e');
      return [];
    }
  }

  /// 加载推荐路线数据
  Future<List<RouteModel>> _loadRecommendedRoutesData() async {
    try {
      return await RouteService.getPopularRoutes();
    } catch (e) {
      debugPrint('HomeScreen: 加载推荐路线数据失败: $e');
      return [];
    }
  }

  /// 加载徒步攻略数据
  Future<List<GuideModel>> _loadHikingGuidesData() async {
    try {
      return await GuideService.getGuides(limit: 4);
    } catch (e) {
      debugPrint('HomeScreen: 加载徒步攻略数据失败: $e');
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
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('首页'),
      ),
      child: FutureBuilder<_HomePublicData>(
        future: _publicDataFuture,
        builder: (context, publicSnapshot) {
          if (publicSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CupertinoActivityIndicator(),
            );
          }

          final publicData = publicSnapshot.data ?? _HomePublicData(
            weather: null,
            recommendedRoutes: [],
            hikingGuides: [],
          );

          if (_isLoggedIn && _userDataFuture != null) {
            return FutureBuilder<_HomeUserData>(
              future: _userDataFuture,
              builder: (context, userSnapshot) {
                final userData = userSnapshot.data ?? _HomeUserData(
                  user: null,
                  plannedTrips: [],
                );

                return _buildContent(
                  publicData: publicData,
                  userData: _isLoggedIn ? userData : null,
                );
              },
            );
          }

          return _buildContent(
            publicData: publicData,
            userData: null,
          );
        },
      ),
    );
  }

  /// 构建页面内容
  Widget _buildContent({
    required _HomePublicData publicData,
    _HomeUserData? userData,
  }) {
    return Stack(
      children: [
        SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildWeatherCard(
                    publicData: publicData,
                    userData: userData,
                  ),
                ),

                const SizedBox(height: 24),

                if (userData != null && userData.user != null) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: PlannedTripsSection(
                      plannedTripsFuture: Future.value(userData.plannedTrips),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: RecommendedRoutesSection(
                    recommendedRoutesFuture: Future.value(publicData.recommendedRoutes),
                  ),
                ),

                const SizedBox(height: 24),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: HikingGuidesSection(
                    hikingGuidesFuture: Future.value(publicData.hikingGuides),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),

        // 悬浮按钮 - 地图测试入口
        Positioned(
          right: 16,
          bottom: 16,
          child: _buildMapTestFAB(),
        ),
      ],
    );
  }

  /// 构建地图测试悬浮按钮
  Widget _buildMapTestFAB() {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (context) => const MapTestScreen(),
          ),
        );
      },
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: CupertinoColors.systemBlue,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Center(
          child: Icon(
            CupertinoIcons.map_fill,
            color: CupertinoColors.white,
            size: 28,
          ),
        ),
      ),
    );
  }

  /// 构建天气卡片
  Widget _buildWeatherCard({
    required _HomePublicData publicData,
    _HomeUserData? userData,
  }) {
    if (userData != null && userData.user != null) {
      return WelcomeWeatherCard(
        user: userData.user!,
        weather: publicData.weather,
        onRefresh: _refreshWeatherData,
        altitudeInfo: _altitudeInfo,
        isLoadingAltitude: _isLoadingAltitude,
        onGetAltitude: _getAltitude,
      );
    }

    return _buildGuestWelcomeCard(publicData.weather);
  }

  /// 构建访客欢迎卡片（未登录状态）
  Widget _buildGuestWelcomeCard(WeatherModel? weather) {
    return Container(
      decoration: BoxDecoration(
        gradient: weather != null
            ? AppColors.getWeatherGradient(weather.conditionString)
            : AppColors.weatherDefaultGradient,
        borderRadius: AppRadius.borderXl,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: AppRadius.borderXl,
        child: Stack(
          children: [
            Positioned(
              right: -20,
              top: -20,
              child: Icon(
                weather != null ? weather.weatherIcon : Icons.cloud,
                size: 120,
                color: Colors.white.withValues(alpha: 0.2),
              ),
            ),

            Padding(
              padding: AppSpacing.allMd,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGuestHeader(),

                  const SizedBox(height: 20),

                  if (weather != null) ...[
                    _buildWeatherMainInfo(weather),
                    const SizedBox(height: 16),
                    _buildWeatherDetailsRow(weather),
                  ] else ...[
                    const Center(
                      child: Text(
                        '无法获取天气信息',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建访客头部
  Widget _buildGuestHeader() {
    return Row(
      children: [
        const CircleAvatar(
          radius: 20,
          backgroundColor: Colors.white24,
          child: Icon(Icons.person, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '欢迎来到 Walk',
              style: TextStyle(
                color: AppColors.textOnDark,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              _getGreetingByTime(),
              style: TextStyle(
                color: AppColors.textOnDark.withValues(alpha: 0.9),
                fontSize: 14,
              ),
            ),
          ],
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.refresh, color: AppColors.textOnDark),
          onPressed: _refreshWeatherData,
          tooltip: '刷新天气',
        ),
      ],
    );
  }

  /// 构建天气主要信息
  Widget _buildWeatherMainInfo(WeatherModel weather) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${weather.temperature.toStringAsFixed(1)}°C',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.bold,
                height: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              weather.conditionString,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const Spacer(),
        Icon(
          weather.weatherIcon,
          size: 64,
          color: Colors.white,
        ),
      ],
    );
  }

  /// 构建天气详情行
  Widget _buildWeatherDetailsRow(WeatherModel weather) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildWeatherDetailItem(
          icon: CupertinoIcons.drop,
          label: '湿度',
          value: '${weather.humidity.toInt()}%',
        ),
        _buildWeatherDetailItem(
          icon: CupertinoIcons.wind,
          label: '风速',
          value: '${weather.windSpeed.toStringAsFixed(1)} km/h',
        ),
        _buildWeatherDetailItem(
          icon: CupertinoIcons.eye,
          label: '能见度',
          value: '${weather.visibility?.toStringAsFixed(0) ?? '--'} km',
        ),
        GestureDetector(
          onTap: _isLoadingAltitude ? null : _getAltitude,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                _isLoadingAltitude
                    ? const CupertinoActivityIndicator(radius: 8, color: Colors.white)
                    : const Icon(CupertinoIcons.location_north_line_fill, color: Colors.white, size: 16),
                const SizedBox(height: 2),
                Text(
                  _altitudeInfo != null
                      ? '${_altitudeInfo!.altitude.toStringAsFixed(0)}m'
                      : '测海拔',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 构建天气详情项
  Widget _buildWeatherDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  /// 根据时间获取问候语
  String _getGreetingByTime() {
    final hour = DateTime.now().hour;
    if (hour < 6) {
      return '夜深了，注意休息';
    } else if (hour < 9) {
      return '早上好，新的一天';
    } else if (hour < 12) {
      return '上午好，今天天气不错';
    } else if (hour < 14) {
      return '中午好，享用午餐吧';
    } else if (hour < 18) {
      return '下午好，来杯咖啡？';
    } else if (hour < 22) {
      return '晚上好，度过愉快的夜晚';
    } else {
      return '夜深了，注意休息';
    }
  }
}

/// 首页公开数据模型（不需要登录）
class _HomePublicData {
  final WeatherModel? weather;
  final List<RouteModel> recommendedRoutes;
  final List<GuideModel> hikingGuides;

  _HomePublicData({
    required this.weather,
    required this.recommendedRoutes,
    required this.hikingGuides,
  });
}

/// 首页用户数据模型（需要登录）
class _HomeUserData {
  final UserModel? user;
  final List<TripModel> plannedTrips;

  _HomeUserData({
    required this.user,
    required this.plannedTrips,
  });
}
