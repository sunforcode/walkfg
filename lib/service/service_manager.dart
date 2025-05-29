import 'package:walk/service/mock/mock_guide_service.dart';
import 'package:walk/service/mock/mock_route_service.dart';
import 'package:walk/service/mock/mock_search_history_service.dart';
import 'package:walk/service/mock/mock_track_format_service.dart';
import 'package:walk/service/mock/mock_trip_plan_service.dart';
import 'package:walk/service/mock/mock_user_service.dart';
import 'package:walk/service/mock/mock_weather_service.dart';
import 'package:walk/service/mock/mock_recommendation_service.dart';
import 'package:walk/service/mock/mock_trip_service.dart';
import 'package:walk/service/trip_plan_service.dart';
import 'search_history_service.dart';
import 'track_format_service.dart';
import 'route_service.dart';
import 'user_service.dart';
import 'guide_service.dart';
import 'weather_service.dart';
import 'recommendation_service.dart';
import 'trip_service.dart';
import 'map_service.dart';
import 'equipment_service.dart';
import 'route_data_service.dart';
import 'mock/mock_equipment_service.dart';

/// 服务定位器，用于管理和访问各种服务
class ServiceLocator {
  /// 单例实例
  static final ServiceLocator instance = ServiceLocator._internal();

  /// 行程服务 - 提供行程相关功能
  late final TripService _tripService;

  /// 搜索历史服务 - 提供搜索历史管理
  late final SearchHistoryService _searchHistoryService;

  /// 轨迹格式服务 - 提供轨迹格式转换
  late final TrackFormatService _trackFormatService;

  /// 路线服务 - 提供路线相关功能
  late RouteService _routeService;

  /// 路线数据服务 - 提供路线相关数据
  late final RouteDataService _routeDataService;

  /// 用户服务 - 提供用户相关功能
  late final UserService _userService;

  /// 攻略服务 - 提供攻略相关功能
  late final GuideService _guideService;

  /// 天气服务 - 提供天气相关功能
  late final WeatherService _weatherService;

  /// 行程计划服务 - 提供行程计划相关功能
  late final TripPlanService _tripPlanService;

  /// 推荐服务 - 提供推荐相关功能
  late final RecommendationService _recommendationService;

  /// 装备服务
  late EquipmentService _equipmentService;

  /// 私有构造函数
  ServiceLocator._internal() {
    // 初始化服务
    _routeService = MockRouteService();
    _equipmentService = MockEquipmentService();
    _routeDataService = RouteDataService();
  }

  late final MapService _mapService;

  /// 初始化服务
  void initialize({bool useMock = true}) {
    if (useMock) {
      _registerMockServices();
    } else {
      _registerRealServices();
    }

    // 初始化通用服务
    _searchHistoryService = MockSearchHistoryService();
    _trackFormatService = MockTrackFormatService();
  }

  /// 注册模拟服务
  void _registerMockServices() {
    // 首先初始化底层API服务

    // 然后初始化其他依赖API服务的服务
    _tripService = MockTripService();
    _routeService = MockRouteService();
    _userService = MockUserService();
    _guideService = MockGuideService();
    _weatherService = MockWeatherService();
    _tripPlanService = MockTripPlanService();
    _recommendationService = MockRecommendationService();
    _mapService = MapService.instance;
  }

  /// 注册真实服务
  void _registerRealServices() {
    // 在生产环境中注册真实的服务实现
    // TODO: 实现真实服务
    _tripService = MockTripService(); // 临时使用Mock
    _routeService = MockRouteService(); // 临时使用Mock
    _userService = MockUserService(); // 临时使用Mock
    _guideService = MockGuideService(); // 临时使用Mock
    _weatherService = MockWeatherService(); // 临时使用Mock
    _tripPlanService = MockTripPlanService(); // 临时使用Mock
    _recommendationService = MockRecommendationService(); // 临时使用Mock
    _mapService = MapService.instance;
  }

  /// 获取行程服务
  TripService getTripService() {
    return _tripService;
  }

  /// 获取搜索历史服务
  SearchHistoryService getSearchHistoryService() {
    return _searchHistoryService;
  }

  /// 获取轨迹格式服务
  TrackFormatService getTrackFormatService() {
    return _trackFormatService;
  }

  /// 获取路线服务
  RouteService getRouteService() {
    return _routeService;
  }

  /// 获取路线数据服务
  RouteDataService getRouteDataService() {
    return _routeDataService;
  }

  /// 获取用户服务
  UserService getUserService() {
    return _userService;
  }

  /// 获取攻略服务
  GuideService getGuideService() {
    return _guideService;
  }

  /// 获取天气服务
  WeatherService getWeatherService() {
    return _weatherService;
  }

  /// 获取行程计划服务
  TripPlanService getTripPlanService() {
    return _tripPlanService;
  }

  /// 获取推荐服务
  RecommendationService getRecommendationService() {
    return _recommendationService;
  }

  MapService getMapService() {
    return _mapService;
  }

  /// 获取装备服务
  EquipmentService getEquipmentService() {
    return _equipmentService;
  }

  /// 注册路线服务
  void registerRouteService(RouteService service) {
    _routeService = service;
  }

  /// 注册行程服务
  void registerTripService(TripService service) {
    _tripService = service;
  }

  /// 注册装备服务
  void registerEquipmentService(EquipmentService service) {
    _equipmentService = service;
  }
}
