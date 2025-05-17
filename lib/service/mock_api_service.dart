import 'dart:async';
import 'package:flutter/material.dart';
import '../model/user_model.dart';
import '../model/weather_model.dart';
import '../model/route_model.dart';
import '../model/guide_model.dart';
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
  Future<List<RouteModel>> getRecommendedRoutes({String? season, int? limit}) async {
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
        imageUrls: ['https://example.com/huangshan1.jpg', 'https://example.com/huangshan2.jpg'],
        gpxUrl: 'https://example.com/huangshan.gpx',
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
        imageUrls: ['https://example.com/lushan1.jpg', 'https://example.com/lushan2.jpg'],
        gpxUrl: 'https://example.com/lushan.gpx',
      ),
    ];
    
    // 根据季节筛选
    var filteredRoutes = allRoutes;
    if (season != null) {
      filteredRoutes = allRoutes.where((route) => route.bestSeason.contains(season)).toList();
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
  Future<List<GuideModel>> getHikingGuides({int? limit, int? offset, String? tag}) async {
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
        coverUrl: 'https://images.unsplash.com/photo-1501554728187-ce583db33af7?ixlib=rb-1.2.1&auto=format&fit=crop&w=1000&q=80',
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
        coverUrl: 'https://images.unsplash.com/photo-1454496522488-7a8e488e8606?ixlib=rb-1.2.1&auto=format&fit=crop&w=1000&q=80',
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
        coverUrl: 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?ixlib=rb-1.2.1&auto=format&fit=crop&w=1000&q=80',
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
        coverUrl: 'https://images.unsplash.com/photo-1516298773066-c48f8e9bd92b?ixlib=rb-1.2.1&auto=format&fit=crop&w=1000&q=80',
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
        coverUrl: 'https://images.unsplash.com/photo-1499715217757-2aa48ed7e593?ixlib=rb-1.2.1&auto=format&fit=crop&w=1000&q=80',
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
        coverUrl: 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?ixlib=rb-1.2.1&auto=format&fit=crop&w=1000&q=80',
        tags: ['安全', '急救', '自救'],
        isLiked: false,
      ),
    ];
    
    // 根据标签筛选
    var filteredGuides = allGuides;
    if (tag != null) {
      filteredGuides = allGuides.where((guide) => guide.tags.contains(tag)).toList();
    }
    
    // 应用分页
    final startIndex = offset ?? 0;
    var endIndex = filteredGuides.length;
    if (limit != null) {
      endIndex = startIndex + limit < filteredGuides.length ? startIndex + limit : filteredGuides.length;
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
  Future<PlannedRouteModel> createPlannedRoute(PlannedRouteModel plannedRoute) async {
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
  Future<PlannedRouteModel> updatePlannedRoute(PlannedRouteModel plannedRoute) async {
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
}