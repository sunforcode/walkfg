import 'dart:async';
import 'package:flutter/material.dart';
import '../model/user_model.dart';
import '../model/weather_model.dart';
import '../model/route/route_model.dart';
import '../model/guide_model.dart';
import '../model/trip_plan_model.dart';
import 'api_service.dart';

/// Mock API服务实现
class MockApiService implements ApiService {
  /// 单例实例
  static final MockApiService _instance = MockApiService._internal();

  /// 工厂构造函数
  factory MockApiService() {
    return _instance;
  }

  /// 私有构造函数
  MockApiService._internal();

  @override
  Future<UserModel> getCurrentUser() async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 300));

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
    await Future.delayed(const Duration(milliseconds: 500));

    return WeatherModel(
      temperature: '23°C',
      condition: '晴',
      isSuitableForHiking: true,
      iconCode: 'clear_day',
      humidity: 45,
      windSpeed: 3.5,
      advice: '今天是个徒步的好日子！',
    );
  }

  @override
  Future<UserModel> getUserStats() async {
    // 直接调用获取当前用户的方法
    return getCurrentUser();
  }

  @override
  Future<List<PlannedRouteModel>> getPlannedRoutes() async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    return [
      PlannedRouteModel(
        id: 'plan1',
        routeId: 'route1',
        name: '五一假期黄山之旅',
        date: DateTime(2023, 5, 1),
        days: 3,
        status: RouteStatus.planning,
        notes: '需要提前预订住宿',
      ),
      PlannedRouteModel(
        id: 'plan2',
        routeId: 'route2',
        name: '周末莫干山一日游',
        date: DateTime(2023, 4, 15),
        days: 1,
        status: RouteStatus.completed,
        notes: null,
      ),
    ];
  }

  @override
  Future<List<RouteModel>> getRecommendedRoutes(
      {String? season, int? limit}) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 600));

    final allRoutes = [
      RouteModel(
        id: 'route1',
        name: '黄山主峰徒步路线',
        description: '黄山主峰徒步路线是一条经典的徒步路线，沿途可以欣赏到黄山的壮丽景色。',
        distance: 15.5,
        duration: '6小时',
        difficulty: RouteDifficulty.medium,
        bestSeason: '春季最佳',
        elevationGain: 1200,
        elevationLoss: 800,
        highestPoint: 1864,
        lowestPoint: 680,
        imageUrls: [
          'https://example.com/huangshan1.jpg',
          'https://example.com/huangshan2.jpg'
        ],
        gpxUrl: 'https://example.com/huangshan.gpx',
        region: '安徽',
        rating: 4.8,
        bestSeasons: ['春', '秋'],
      ),
      RouteModel(
        id: 'route2',
        name: '莫干山竹海徒步',
        description: '莫干山竹海徒步路线穿越茂密的竹林，空气清新，视野开阔。',
        distance: 8.2,
        duration: '3小时',
        difficulty: RouteDifficulty.easy,
        bestSeason: '四季皆宜',
        elevationGain: 450,
        elevationLoss: 450,
        highestPoint: 758,
        lowestPoint: 350,
        imageUrls: ['https://example.com/moganshan1.jpg'],
        gpxUrl: null,
        region: '浙江',
        rating: 4.5,
        bestSeasons: ['春', '夏', '秋', '冬'],
      ),
      RouteModel(
        id: 'route3',
        name: '庐山三日穿越',
        description: '庐山三日穿越路线是一条挑战性较高的路线，需要较好的体力和装备。',
        distance: 32.0,
        duration: '3天',
        difficulty: RouteDifficulty.hard,
        bestSeason: '秋季最佳',
        elevationGain: 2200,
        elevationLoss: 2200,
        highestPoint: 1474,
        lowestPoint: 120,
        imageUrls: [
          'https://example.com/lushan1.jpg',
          'https://example.com/lushan2.jpg'
        ],
        gpxUrl: 'https://example.com/lushan.gpx',
        region: '江西',
        rating: 4.9,
        bestSeasons: ['秋'],
      ),
    ];

    // 根据季节筛选
    var filteredRoutes = allRoutes;
    if (season != null) {
      filteredRoutes = allRoutes
          .where((route) => route.bestSeason.contains(season))
          .toList();
    }

    // 限制返回数量
    if (limit != null && limit > 0 && limit < filteredRoutes.length) {
      filteredRoutes = filteredRoutes.sublist(0, limit);
    }

    return filteredRoutes;
  }

  @override
  Future<RouteModel> getRouteDetail(String routeId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 300));

    // 获取所有路线
    final routes = await getRecommendedRoutes();

    // 查找指定ID的路线
    final route = routes.firstWhere(
      (route) => route.id == routeId,
      orElse: () => throw Exception('Route not found'),
    );

    return route;
  }

  @override
  Future<List<GuideModel>> getHikingGuides(
      {int? limit, int? offset, String? tag}) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 500));

    final allGuides = [
      GuideModel(
        id: 'guide1',
        title: '初级徒步装备选购指南：从零开始准备你的第一套装备',
        content: '本指南将帮助初学者选择合适的徒步装备，包括背包、鞋子、衣物、帐篷等必备物品的详细介绍和推荐...',
        author: '山野君',
        authorId: 'author1',
        authorAvatarUrl: 'https://randomuser.me/api/portraits/men/32.jpg',
        likes: 256,
        views: 1024,
        publishDate: DateTime(2023, 3, 15),
        updateDate: DateTime(2023, 3, 15),
        iconCode: 'shopping_bag',
        coverUrl:
            'https://images.unsplash.com/photo-1501554728187-ce583db33af7?ixlib=rb-1.2.1&auto=format&fit=crop&w=1000&q=80',
        tags: ['装备', '入门', '选购指南'],
        isLiked: false,
      ),
      GuideModel(
        id: 'guide2',
        title: '高海拔徒步注意事项：如何应对高原反应',
        content: '在高海拔地区徒步需要特别注意以下几点：提前适应高原环境、控制上升速度、保持充分水分...',
        author: '登山者',
        authorId: 'author2',
        authorAvatarUrl: 'https://randomuser.me/api/portraits/women/44.jpg',
        likes: 189,
        views: 876,
        publishDate: DateTime(2023, 2, 20),
        updateDate: DateTime(2023, 2, 25),
        iconCode: 'terrain',
        coverUrl:
            'https://images.unsplash.com/photo-1454496522488-7a8e488e8606?ixlib=rb-1.2.1&auto=format&fit=crop&w=1000&q=80',
        tags: ['高海拔', '安全', '健康'],
        isLiked: true,
      ),
      GuideModel(
        id: 'guide3',
        title: '徒步摄影技巧分享：如何在旅途中拍出震撼风景',
        content: '如何在徒步过程中拍摄出精彩的照片？本文将分享构图技巧、光线运用、设备选择等专业摄影知识...',
        author: '风景摄影师',
        authorId: 'author3',
        authorAvatarUrl: 'https://randomuser.me/api/portraits/men/67.jpg',
        likes: 324,
        views: 1532,
        publishDate: DateTime(2023, 4, 5),
        updateDate: DateTime(2023, 4, 5),
        iconCode: 'camera_alt',
        coverUrl:
            'https://images.unsplash.com/photo-1506744038136-46273834b3fb?ixlib=rb-1.2.1&auto=format&fit=crop&w=1000&q=80',
        tags: ['摄影', '技巧', '风景'],
        isLiked: false,
      ),
      GuideModel(
        id: 'guide4',
        title: '雨天徒步装备防水指南：保持干燥的秘诀',
        content: '雨天徒步如何保持装备干燥？从防水背包套、快干衣物到防水收纳袋，全方位解决雨天徒步难题...',
        author: '装备达人',
        authorId: 'author4',
        authorAvatarUrl: 'https://randomuser.me/api/portraits/women/22.jpg',
        likes: 145,
        views: 689,
        publishDate: DateTime(2023, 3, 28),
        updateDate: DateTime(2023, 3, 30),
        iconCode: 'water_drop',
        coverUrl:
            'https://images.unsplash.com/photo-1516298773066-c48f8e9bd92b?ixlib=rb-1.2.1&auto=format&fit=crop&w=1000&q=80',
        tags: ['装备', '防水', '雨天'],
        isLiked: false,
      ),
      GuideModel(
        id: 'guide5',
        title: '徒步营养补给全攻略：能量补充与轻量化平衡',
        content: '长途徒步如何保证足够的能量摄入？本文详细介绍各类徒步食品的选择、准备和携带方式...',
        author: '户外营养师',
        authorId: 'author5',
        authorAvatarUrl: 'https://randomuser.me/api/portraits/men/18.jpg',
        likes: 278,
        views: 1245,
        publishDate: DateTime(2023, 5, 10),
        updateDate: DateTime(2023, 5, 12),
        iconCode: 'restaurant',
        coverUrl:
            'https://images.unsplash.com/photo-1499715217757-2aa48ed7e593?ixlib=rb-1.2.1&auto=format&fit=crop&w=1000&q=80',
        tags: ['营养', '食品', '能量补给'],
        isLiked: true,
      ),
      GuideModel(
        id: 'guide6',
        title: '徒步安全指南：野外急救与自救技能',
        content: '户外徒步中可能遇到的安全问题及应对方法，包括基础急救知识、常见伤病处理和紧急求救信号...',
        author: '安全专家',
        authorId: 'author6',
        authorAvatarUrl: 'https://randomuser.me/api/portraits/women/56.jpg',
        likes: 412,
        views: 2034,
        publishDate: DateTime(2023, 1, 15),
        updateDate: DateTime(2023, 1, 20),
        iconCode: 'health_and_safety',
        coverUrl:
            'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?ixlib=rb-1.2.1&auto=format&fit=crop&w=1000&q=80',
        tags: ['安全', '急救', '自救'],
        isLiked: false,
      ),
    ];

    // 根据标签筛选
    var filteredGuides = allGuides;
    if (tag != null) {
      filteredGuides =
          allGuides.where((guide) => guide.tags.contains(tag)).toList();
    }

    // 应用分页
    final startIndex = offset ?? 0;
    var endIndex = filteredGuides.length;
    if (limit != null) {
      endIndex = startIndex + limit < filteredGuides.length
          ? startIndex + limit
          : filteredGuides.length;
    }

    if (startIndex >= filteredGuides.length) {
      return [];
    }

    return filteredGuides.sublist(startIndex, endIndex);
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

  @override
  Future<PlannedRouteModel> createPlannedRoute(
      PlannedRouteModel plannedRoute) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 模拟创建成功，返回带有ID的对象
    return PlannedRouteModel(
      id: 'new_${DateTime.now().millisecondsSinceEpoch}',
      routeId: plannedRoute.routeId,
      name: plannedRoute.name,
      date: plannedRoute.date,
      days: plannedRoute.days,
      status: plannedRoute.status,
      notes: plannedRoute.notes,
    );
  }

  @override
  Future<PlannedRouteModel> updatePlannedRoute(
      PlannedRouteModel plannedRoute) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 300));

    // 模拟更新成功，直接返回传入的对象
    return plannedRoute;
  }

  @override
  Future<bool> deletePlannedRoute(String plannedRouteId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 300));

    // 模拟删除成功
    return true;
  }

  @override
  Future<bool> favoriteRoute(String routeId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 200));

    // 模拟收藏成功
    return true;
  }

  @override
  Future<bool> unfavoriteRoute(String routeId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 200));

    // 模拟取消收藏成功
    return true;
  }

  @override
  Future<List<RouteModel>> getFavoriteRoutes() async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 获取所有路线
    final routes = await getRecommendedRoutes();

    // 模拟收藏的路线（这里简单返回前两条）
    return routes.take(2).toList();
  }

  @override
  Future<GuideModel> likeGuide(String guideId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 200));

    // 获取所有攻略
    final guides = await getHikingGuides();

    // 查找指定ID的攻略
    final guideIndex = guides.indexWhere((guide) => guide.id == guideId);
    if (guideIndex == -1) {
      throw Exception('Guide not found');
    }

    // 更新点赞状态和数量
    final guide = guides[guideIndex];
    final updatedGuide = guide.copyWith(isLiked: true);

    return updatedGuide;
  }

  @override
  Future<GuideModel> unlikeGuide(String guideId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 200));

    // 获取所有攻略
    final guides = await getHikingGuides();

    // 查找指定ID的攻略
    final guideIndex = guides.indexWhere((guide) => guide.id == guideId);
    if (guideIndex == -1) {
      throw Exception('Guide not found');
    }

    // 更新点赞状态和数量
    final guide = guides[guideIndex];
    final updatedGuide = guide.copyWith(isLiked: false);

    return updatedGuide;
  }

  /// 将Material图标代码转换为IconData
  IconData getIconData(String iconCode) {
    // 这里只是简单示例，实际应用中可能需要更复杂的映射
    switch (iconCode) {
      case 'shopping_bag':
        return Icons.shopping_bag;
      case 'terrain':
        return Icons.terrain;
      case 'camera_alt':
        return Icons.camera_alt;
      case 'water_drop':
        return Icons.water_drop;
      default:
        return Icons.article;
    }
  }

  /// 获取未完成行程规划数量
  @override
  int getUnfinishedTripPlansCount() {
    // 模拟数据
    return 2;
  }

  /// 获取热门路线列表
  @override
  Future<List<RouteModel>> getPopularRoutes({int? limit}) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 500));

    // 获取所有路线
    final routes = await getRecommendedRoutes();

    // 按评分排序
    routes.sort((a, b) => b.rating.compareTo(a.rating));

    // 限制返回数量
    if (limit != null && limit > 0 && limit < routes.length) {
      return routes.sublist(0, limit);
    }

    return routes;
  }

  /// 获取用户行程规划列表
  @override
  Future<List<TripPlanModel>> getUserTripPlans() async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 600));

    // 模拟数据
    return [
      TripPlanModel(
        id: 'trip1',
        userId: 'user1',
        routeId: 'route1',
        routeName: '黄山主峰徒步行程',
        startDate: DateTime(2023, 10, 1),
        participantCount: 3,
        departureCity: '上海',
        status: TripPlanStatus.draft,
      ),
      TripPlanModel(
        id: 'trip2',
        userId: 'user1',
        routeId: 'route2',
        routeName: '莫干山周末徒步',
        startDate: DateTime(2023, 9, 15),
        participantCount: 2,
        departureCity: '杭州',
        status: TripPlanStatus.completed,
      ),
      TripPlanModel(
        id: 'trip3',
        userId: 'user1',
        routeId: 'route3',
        routeName: '庐山三日穿越计划',
        startDate: DateTime(2023, 11, 20),
        participantCount: 4,
        departureCity: '南昌',
        status: TripPlanStatus.draft,
      ),
    ];
  }

  /// 根据ID获取路线
  @override
  Future<RouteModel> getRouteById(String routeId) async {
    // 直接调用路线详情方法
    return getRouteDetail(routeId);
  }

  /// 搜索路线
  @override
  Future<List<RouteModel>> searchRoutes(String query,
      {Map<String, dynamic>? filters}) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 500));

    // 获取所有路线
    final routes = await getRecommendedRoutes();

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
      // 生成每日行程数据
      itineraries.add(DailyItinerary(
        startPoint: i == 0 ? '起点' : '营地${i}',
        endPoint: i == days - 1 ? '终点' : '营地${i + 1}',
        distance: route.distance / days,
        elevationGain: route.elevationGain ~/ days,
        elevationLoss: route.elevationLoss ~/ days,
        estimatedTime: i == 0 ? 6.0 : 5.0,
        waypoints: _generateWaypoints(i, days),
        recommendedCampsite: i < days - 1 ? _generateCampsite(i + 1) : null,
        alternateCampsites: i < days - 1
            ? [_generateCampsite(i + 10), _generateCampsite(i + 20)]
            : [],
      ));
    }

    return itineraries;
  }

  /// 生成途经点数据
  List<WaypointModel> _generateWaypoints(int day, int totalDays) {
    final List<WaypointModel> waypoints = [];

    // 起点
    if (day == 0) {
      waypoints.add(WaypointModel(
        id: 'wp_${day}_start',
        name: '起点',
        latitude: 30.0 + day * 0.01,
        longitude: 120.0 + day * 0.01,
        elevation: 500 + day * 50,
        type: WaypointType.start,
        estimatedArrivalTime: '08:00',
      ));
    }

    // 中间点
    waypoints.add(WaypointModel(
      id: 'wp_${day}_1',
      name: '观景台${day + 1}',
      description: '可以俯瞰整个山谷的绝佳观景点',
      latitude: 30.0 + day * 0.01 + 0.005,
      longitude: 120.0 + day * 0.01 + 0.005,
      elevation: 600 + day * 50,
      type: WaypointType.viewpoint,
      estimatedArrivalTime: '10:30',
    ));

    waypoints.add(WaypointModel(
      id: 'wp_${day}_2',
      name: '休息点${day + 1}',
      description: '适合午餐和短暂休息的地点',
      latitude: 30.0 + day * 0.01 + 0.008,
      longitude: 120.0 + day * 0.01 + 0.008,
      elevation: 650 + day * 50,
      type: WaypointType.rest,
      estimatedArrivalTime: '12:00',
    ));

    waypoints.add(WaypointModel(
      id: 'wp_${day}_3',
      name: '水源点${day + 1}',
      description: '清澈的山泉，可以补充饮用水',
      latitude: 30.0 + day * 0.01 + 0.012,
      longitude: 120.0 + day * 0.01 + 0.012,
      elevation: 600 + day * 50,
      type: WaypointType.waterSource,
      estimatedArrivalTime: '14:30',
    ));

    // 终点或营地
    if (day == totalDays - 1) {
      waypoints.add(WaypointModel(
        id: 'wp_${day}_end',
        name: '终点',
        latitude: 30.0 + (day + 1) * 0.01,
        longitude: 120.0 + (day + 1) * 0.01,
        elevation: 500 + day * 30,
        type: WaypointType.end,
        estimatedArrivalTime: '17:00',
      ));
    } else {
      waypoints.add(WaypointModel(
        id: 'wp_${day}_camp',
        name: '营地${day + 1}',
        description: '平坦开阔的营地，靠近水源',
        latitude: 30.0 + (day + 1) * 0.01,
        longitude: 120.0 + (day + 1) * 0.01,
        elevation: 550 + day * 40,
        type: WaypointType.campsite,
        estimatedArrivalTime: '16:30',
      ));
    }

    return waypoints;
  }

  /// 生成营地数据
  CampSiteModel _generateCampsite(int id) {
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

    // 获取路线详情
    final route = await getRouteDetail(routeId);

    // 基础装备
    final List<EquipmentItemModel> baseEquipment = [
      EquipmentItemModel(
        id: 'equip_1',
        name: '徒步背包',
        category: '背包',
        isEssential: true,
        description: '30-40L容量，带防雨罩',
      ),
      EquipmentItemModel(
        id: 'equip_2',
        name: '登山鞋',
        category: '鞋类',
        isEssential: true,
        description: '防滑耐磨，支撑性好',
      ),
      EquipmentItemModel(
        id: 'equip_3',
        name: '速干衣裤',
        category: '服装',
        isEssential: true,
        description: '轻便透气，快速排汗',
      ),
      EquipmentItemModel(
        id: 'equip_4',
        name: '保温水壶',
        category: '饮食',
        isEssential: true,
        description: '至少1L容量',
      ),
      EquipmentItemModel(
        id: 'equip_5',
        name: '头灯',
        category: '工具',
        isEssential: true,
        description: '带备用电池',
      ),
      EquipmentItemModel(
        id: 'equip_6',
        name: '急救包',
        category: '医疗',
        isEssential: true,
        description: '基础医疗用品',
      ),
    ];

    // 根据难度添加额外装备
    List<EquipmentItemModel> additionalEquipment = [];

    if (route.difficulty == RouteDifficulty.medium ||
        route.difficulty == RouteDifficulty.hard) {
      additionalEquipment.addAll([
        EquipmentItemModel(
          id: 'equip_7',
          name: '登山杖',
          category: '工具',
          isEssential: route.difficulty == RouteDifficulty.hard,
          description: '减轻膝盖负担，提高稳定性',
        ),
        EquipmentItemModel(
          id: 'equip_8',
          name: '防晒霜',
          category: '护理',
          isEssential: false,
          description: 'SPF50+，防水型',
        ),
      ]);
    }

    // 根据天数添加露营装备
    if (route.durationDays > 1) {
      additionalEquipment.addAll([
        EquipmentItemModel(
          id: 'equip_9',
          name: '帐篷',
          category: '露营',
          isEssential: true,
          description: '轻量化，防风防雨',
        ),
        EquipmentItemModel(
          id: 'equip_10',
          name: '睡袋',
          category: '露营',
          isEssential: true,
          description: '适合季节温度范围',
        ),
        EquipmentItemModel(
          id: 'equip_11',
          name: '防潮垫',
          category: '露营',
          isEssential: true,
          description: '隔绝地面湿气和寒气',
        ),
        EquipmentItemModel(
          id: 'equip_12',
          name: '便携炉具',
          category: '饮食',
          isEssential: false,
          description: '轻便高效，带备用燃料',
        ),
      ]);
    }

    // 根据海拔添加保暖装备
    if (route.highestPoint > 1000) {
      additionalEquipment.addAll([
        EquipmentItemModel(
          id: 'equip_13',
          name: '抓绒衣',
          category: '服装',
          isEssential: true,
          description: '保暖层，轻便保暖',
        ),
        EquipmentItemModel(
          id: 'equip_14',
          name: '冲锋衣',
          category: '服装',
          isEssential: route.highestPoint > 1500,
          description: '防风防水，透气',
        ),
      ]);
    }

    return [...baseEquipment, ...additionalEquipment];
  }
}
