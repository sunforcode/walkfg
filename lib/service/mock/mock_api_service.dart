import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:walk/model/weather/weather_model.dart';
import 'package:walk/service/mock/mock_track_format_service.dart';
import '../../model/route/route_model.dart';
import '../../model/trip_plan_model.dart';
import '../../model/route/track_point_model.dart';
import '../../model/user_model.dart';
import '../../model/guide_model.dart';
import '../api_service.dart';
import '../track_format_service.dart';

/// 模拟API服务实现
class MockApiService implements ApiService {
  /// 单例实例
  static final MockApiService _instance = MockApiService._internal();

  /// 工厂构造函数
  factory MockApiService() {
    return _instance;
  }

  /// 私有构造函数
  MockApiService._internal();

  /// 轨迹格式服务
  final TrackFormatService _trackFormatService = MockTrackFormatService();

  /// 加载JSON文件
  Future<dynamic> _loadJsonFile(String path) async {
    try {
      final String jsonString = await rootBundle.loadString(path);
      return json.decode(jsonString);
    } catch (e) {
      print('MockApiService._loadJsonFile - 加载JSON文件失败: $e');
      print('MockApiService._loadJsonFile - 错误堆栈: ${StackTrace.current}');
      return null;
    }
  }

  /// 从JSON文件加载轨迹点
  Future<List<TrackPointModel>> _loadTrackPoints() async {
    try {
      final trackPointsJson =
          await _loadJsonFile('assets/mock_data/track_points.json');
      if (trackPointsJson != null) {
        return (trackPointsJson as List)
            .map((item) => TrackPointModel.fromJson(item))
            .toList();
      }
    } catch (e) {
      print('MockApiService._loadTrackPoints - 加载轨迹点失败: $e');
    }

    // 如果加载失败，生成默认轨迹点
    return [];
  }

  @override
  Future<UserModel> getCurrentUser() async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 300));

    // 从JSON文件加载用户数据
    final usersJson = await _loadJsonFile('assets/mock_data/users.json');
    if (usersJson != null && usersJson is List && usersJson.isNotEmpty) {
      return UserModel.fromJson(usersJson[0]);
    }

    // 如果加载失败，返回默认用户
    return UserModel(
      id: 'user1',
      username: 'hikingfan',
      nickname: '徒步爱好者',
      avatarUrl: null,
      completedRoutes: 3,
      equipmentLists: 2,
      favoriteRoutes: 5,
    );
  }

  @override
  Future<WeatherModel> getWeather(double latitude, double longitude) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 100));

    // 从JSON文件加载天气数据
    final weatherJson = await _loadJsonFile('assets/mock_data/weather.json');
    final model = WeatherModel.fromJson(weatherJson);
    return model;
  }

  @override
  Future<UserModel> getUserStats() async {
    // 直接调用获取当前用户的方法
    return getCurrentUser();
  }

  @override
  Future<RouteModel> getRouteDetail(String routeId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 300));

    print('MockApiService.getRouteDetail - 开始加载路线详情，路线ID: $routeId');

    // 从JSON文件加载路线数据
    final routesJson = await _loadJsonFile('assets/mock_data/routes.json');
    // 查找指定ID的路线
    final routeJson = routesJson.firstWhere(
      (route) => route['id'] == routeId,
      orElse: () => null,
    );

    // 获取轨迹点
    List<TrackPointModel> trackPoints = await _loadTrackPoints();

    // 创建路线模型
    return RouteModel(
      id: routeJson['id'],
      name: routeJson['name'],
      description: routeJson['description'],
      distance: (routeJson['distance'] as num).toDouble(),
      duration: routeJson['duration'],
      difficulty: _parseDifficulty(routeJson['difficulty']),
      bestSeason: routeJson['best_season'],
      elevationGain: routeJson['elevation_gain'],
      elevationLoss: routeJson['elevation_loss'],
      highestPoint: routeJson['highest_point'],
      lowestPoint: routeJson['lowest_point'],
      imageUrls: List<String>.from(routeJson['image_urls']),
      gpxUrl: routeJson['gpx_url'],
      region: routeJson['region'],
      rating: (routeJson['rating'] as num).toDouble(),
      bestSeasons: List<String>.from(routeJson['best_seasons']),
      reviewCount: routeJson['review_count'] ?? 0,
      trackPoints: trackPoints,
    );
  }

  @override
  Future<List<GuideModel>> getHikingGuides(
      {int? limit, int? offset, String? tag}) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 500));

    // 从JSON文件加载攻略数据
    final guidesJson = await _loadJsonFile('assets/mock_data/guides.json');
    if (guidesJson == null || !(guidesJson is List)) {
      return [];
    }

    // 将JSON数据转换为攻略模型列表
    final now = DateTime.now();
    List<GuideModel> guides = guidesJson.map((item) {
      // 确保JSON中包含必要的基础字段
      if (!item.containsKey('created_at')) {
        item['created_at'] =
            now.subtract(const Duration(days: 90)).toIso8601String();
      }
      if (!item.containsKey('updated_at')) {
        item['updated_at'] =
            now.subtract(const Duration(days: 10)).toIso8601String();
      }
      return GuideModel.fromJson(item);
    }).toList();

    // 根据标签筛选
    if (tag != null) {
      guides = guides.where((guide) => guide.tags.contains(tag)).toList();
    }

    // 应用分页
    final startIndex = offset ?? 0;
    var endIndex = guides.length;
    if (limit != null) {
      endIndex = startIndex + limit < guides.length
          ? startIndex + limit
          : guides.length;
    }

    if (startIndex >= guides.length) {
      return [];
    }

    return guides.sublist(startIndex, endIndex);
  }

  @override
  Future<GuideModel> getGuideDetail(String guideId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 300));

    // 获取所有攻略
    final guides = await getHikingGuides();

    // 查找指定ID的攻略
    final guide = guides.firstWhere(
      (guide) => guide.id == guideId,
      orElse: () => throw Exception('Guide not found'),
    );
    return guide;
  }

  /// 搜索路线
  @override
  Future<List<RouteModel>> searchRoutes(String query,
      {Map<String, dynamic>? filters}) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 500));

    // 获取所有路线
    final routes = await getRoutes();

    // 根据查询关键词筛选
    if (query.isNotEmpty) {
      return routes
          .where((route) =>
              route.name.toLowerCase().contains(query.toLowerCase()) ||
              route.description.toLowerCase().contains(query.toLowerCase()) ||
              route.region.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }

    // 应用其他筛选条件
    if (filters != null && filters.isNotEmpty) {
      var filteredRoutes = routes;

      // 按难度筛选
      if (filters.containsKey('difficulty')) {
        final difficulty = filters['difficulty'] as RouteDifficulty?;
        if (difficulty != null) {
          filteredRoutes = filteredRoutes
              .where((route) => route.difficulty == difficulty)
              .toList();
        }
      }

      // 按地区筛选
      if (filters.containsKey('region')) {
        final region = filters['region'] as String?;
        if (region != null && region.isNotEmpty) {
          filteredRoutes =
              filteredRoutes.where((route) => route.region == region).toList();
        }
      }

      // 按季节筛选
      if (filters.containsKey('season')) {
        final season = filters['season'] as String?;
        if (season != null && season.isNotEmpty) {
          filteredRoutes = filteredRoutes
              .where((route) => route.bestSeasons.contains(season))
              .toList();
        }
      }

      return filteredRoutes;
    }
    return routes;
  }

  /// 获取路线行程安排
  @override
  Future<List<DailyItinerary>> getRouteItineraries(String routeId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 获取路线详情
    final route = await getRouteDetail(routeId);

    // 根据路线天数生成行程安排
    final days = route.durationDays;
    final List<DailyItinerary> itineraries = [];

    for (int i = 0; i < days; i++) {
      // 获取途经点数据
      final waypoints = await _loadWaypoints(i);

      // 获取营地数据
      CampSiteModel? recommendedCampsite = null;
      List<CampSiteModel> alternateCampsites = [];

      if (i < days - 1) {
        recommendedCampsite = await _generateCampsite(i + 1);
        alternateCampsites = await Future.wait(
            [_generateCampsite(i + 10), _generateCampsite(i + 20)]);
      }

      // 生成每日行程数据
      itineraries.add(DailyItinerary(
        startPoint: i == 0 ? '起点' : '营地${i}',
        endPoint: i == days - 1 ? '终点' : '营地${i + 1}',
        distance: route.distance / days,
        elevationGain: route.elevationGain ~/ days,
        elevationLoss: route.elevationLoss ~/ days,
        estimatedTime: i == 0 ? 6.0 : 5.0,
        waypoints: waypoints,
        recommendedCampsite: recommendedCampsite,
        alternateCampsites: alternateCampsites,
      ));
    }

    return itineraries;
  }

  /// 获取途经点数据
  Future<List<WaypointModel>> _loadWaypoints(int day) async {
    try {
      // 从JSON文件加载途经点数据
      final waypointsJson =
          await _loadJsonFile('assets/mock_data/waypoints.json');
      if (waypointsJson != null && waypointsJson is List) {
        // 查找指定天数的途经点
        final dayData = waypointsJson.firstWhere(
          (item) => item['day'] == day,
          orElse: () => null,
        );

        if (dayData != null && dayData['waypoints'] is List) {
          return (dayData['waypoints'] as List)
              .map((item) => WaypointModel(
                    id: item['id'],
                    name: item['name'],
                    description: item['description'] ?? '',
                    latitude: (item['latitude'] as num).toDouble(),
                    longitude: (item['longitude'] as num).toDouble(),
                    elevation: (item['elevation'] as num).toInt(),
                    type: WaypointType.values[item['type'] as int],
                    estimatedArrivalTime: item['estimated_arrival_time'],
                  ))
              .toList();
        }
      }
    } catch (e) {
      print('MockApiService._loadWaypoints - 加载途经点失败: $e');
    }

    // 如果加载失败，使用原来的生成方法
    return [];
  }

  /// 生成营地数据
  Future<CampSiteModel> _generateCampsite(int id) async {
    try {
      // 从JSON文件加载营地数据
      final campsitesJson =
          await _loadJsonFile('assets/mock_data/campsites.json');
      if (campsitesJson != null && campsitesJson is List) {
        // 查找指定ID的营地
        final campId = 'camp_$id';
        final campData = campsitesJson.firstWhere(
          (item) => item['id'] == campId,
          orElse: () => null,
        );

        if (campData != null) {
          return CampSiteModel(
            id: campData['id'],
            name: campData['name'],
            description: campData['description'],
            latitude: (campData['latitude'] as num).toDouble(),
            longitude: (campData['longitude'] as num).toDouble(),
            elevation: (campData['elevation'] as num).toInt(),
            capacity: campData['capacity'],
            waterSourceDistance: campData['water_source_distance'],
            facilities: List<String>.from(campData['facilities']),
            features: List<String>.from(campData['features']),
          );
        }
      }
    } catch (e) {
      print('MockApiService._generateCampsite - 加载营地数据失败: $e');
    }

    // 如果加载失败，使用原来的生成方法
    return CampSiteModel(
      id: 'camp_$id',
      name: '营地$id',
      description: '平坦开阔的营地，视野良好，靠近水源',
      latitude: 30.0 + id * 0.005,
      longitude: 120.0 + id * 0.005,
      elevation: 550 + id * 20,
      capacity: 5 + (id % 5),
      waterSourceDistance: 50 + (id % 3) * 30,
      facilities: ['平整营地', '遮风处', '篝火区'],
      features: ['靠近水源', '视野开阔', '日出观景点'],
    );
  }

  /// 获取推荐装备列表
  @override
  Future<List<EquipmentItemModel>> getRecommendedEquipment(
      String routeId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      // 从JSON文件加载推荐装备数据
      final equipmentJson =
          await _loadJsonFile('assets/mock_data/recommended_equipment.json');
      if (equipmentJson != null && equipmentJson is List) {
        // 查找指定路线ID的装备
        final routeEquipment = equipmentJson.firstWhere(
          (item) => item['route_id'] == routeId,
          orElse: () => null,
        );

        if (routeEquipment != null && routeEquipment['equipment'] is List) {
          return (routeEquipment['equipment'] as List)
              .map((item) => EquipmentItemModel(
                    id: item['id'],
                    name: item['name'],
                    category: item['category'],
                    isEssential: item['is_essential'],
                    description: item['description'],
                  ))
              .toList();
        }
      }
    } catch (e) {
      print('MockApiService.getRecommendedEquipment - 加载推荐装备失败: $e');
    }

    // 如果加载失败，使用原来的生成方法
    return [];
  }

  @override
  Future<TripPlanModel> getTripPlanDetail(String tripPlanId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 800));

    // 从JSON文件加载行程计划数据
    final plansJson = await _loadJsonFile('assets/mock_data/trip_plans.json');
    if (plansJson != null && plansJson is List) {
      final planJson = plansJson.firstWhere(
        (plan) => plan['id'] == tripPlanId,
        orElse: () => null,
      );

      if (planJson != null) {
        return TripPlanModel.fromJson(planJson);
      }
    }

    throw Exception('Trip plan not found');
  }

  @override
  Future<TripPlanModel> createTripPlan(TripPlanModel tripPlan) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 800));
    return tripPlan.copyWith(
        id: 'new_${DateTime.now().millisecondsSinceEpoch}');
  }

  @override
  Future<TripPlanModel> updateTripPlan(TripPlanModel tripPlan) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 800));
    return tripPlan;
  }

  @override
  Future<bool> deleteTripPlan(String tripPlanId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 800));
    return true;
  }

  @override
  Future<List<TripPlanModel>> getTripPlans() async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 500));

    // 从JSON文件加载行程计划数据
    final plansJson = await _loadJsonFile('assets/mock_data/trip_plans.json');
    if (plansJson != null && plansJson is List) {
      return plansJson.map((json) => TripPlanModel.fromJson(json)).toList();
    }

    return [];
  }

  @override
  Future<List<RouteModel>> getRoutes({String? season, int? limit}) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 600));

    print('获取路线数据，季节: $season, 限制: $limit');

    // 从JSON文件加载路线数据
    final routesJson = await _loadJsonFile('assets/mock_data/routes.json');
    if (routesJson == null || !(routesJson is List)) {
      return [];
    }

    // 将JSON数据转换为路线模型列表
    List<RouteModel> allRoutes = [];
    for (var routeJson in routesJson) {
      // 获取轨迹点
      List<TrackPointModel> trackPoints = await _loadTrackPoints();

      // 创建路线模型
      try {
        final route = RouteModel(
          id: routeJson['id'],
          name: routeJson['name'],
          description: routeJson['description'],
          distance: (routeJson['distance'] as num).toDouble(),
          duration: routeJson['duration'],
          difficulty: _parseDifficulty(routeJson['difficulty']),
          bestSeason: routeJson['best_season'],
          elevationGain: routeJson['elevation_gain'],
          elevationLoss: routeJson['elevation_loss'],
          highestPoint: routeJson['highest_point'],
          lowestPoint: routeJson['lowest_point'],
          imageUrls: List<String>.from(routeJson['image_urls']),
          gpxUrl: routeJson['gpx_url'],
          region: routeJson['region'],
          rating: (routeJson['rating'] as num).toDouble(),
          bestSeasons: List<String>.from(routeJson['best_seasons']),
          reviewCount: routeJson['review_count'] ?? 0,
          trackPoints: trackPoints,
        );
        allRoutes.add(route);
      } catch (e) {
        print('解析路线数据失败: $e');
      }
    }

    print('所有路线数量: ${allRoutes.length}');

    // 根据季节筛选
    var filteredRoutes = allRoutes;
    if (season != null) {
      filteredRoutes = allRoutes
          .where((route) => route.bestSeasons.contains(season))
          .toList();
    }

    print('筛选后路线数量: ${filteredRoutes.length}');

    // 限制返回数量
    if (limit != null && limit > 0 && limit < filteredRoutes.length) {
      filteredRoutes = filteredRoutes.sublist(0, limit);
    }

    print('最终返回路线数量: ${filteredRoutes.length}');
    return filteredRoutes;
  }

  /// 解析难度字符串为枚举值
  RouteDifficulty _parseDifficulty(String? difficultyStr) {
    switch (difficultyStr?.toLowerCase()) {
      case 'easy':
        return RouteDifficulty.easy;
      case 'medium':
        return RouteDifficulty.medium;
      case 'hard':
        return RouteDifficulty.hard;
      case 'extreme':
        return RouteDifficulty.extreme;
      default:
        return RouteDifficulty.medium;
    }
  }
}
