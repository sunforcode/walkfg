import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:walk/service/route_service.dart';

import '../../model/route/route_model.dart';
import '../../model/trip_plan_model.dart';
import '../api_service.dart';
import 'mock_api_service.dart';

/// 模拟路线服务实现
class MockRouteService implements RouteService {
  /// API服务
  final ApiService _apiService = MockApiService();

  /// 路线缓存
  List<RouteModel>? _routesCache;

  @override
  Future<RouteModel> getRouteDetail(String routeId) async {
    return _apiService.getRouteDetail(routeId);
  }

  @override
  Future<RouteModel> getRouteById(String routeId) async {
    return _apiService.getRouteDetail(routeId);
  }

  @override
  Future<List<RouteModel>> getPopularRoutes({int limit = 10}) async {
    final routes = await _getRoutes();
    // 按评分排序
    routes.sort((a, b) => b.rating.compareTo(a.rating));
    return routes.take(limit).toList();
  }

  @override
  Future<List<RouteModel>> getSeasonalRoutes({int limit = 10}) async {
    final routes = await _getRoutes();
    final currentSeason = _getCurrentSeason();
    return routes
        .where((route) => route.bestSeasons.contains(currentSeason))
        .take(limit)
        .toList();
  }

  @override
  Future<List<RouteModel>> getNewRoutes({int limit = 10}) async {
    final routes = await _getRoutes();
    // 模拟新晋路线，取后半部分
    final startIndex =
        routes.length > limit * 2 ? routes.length - limit * 2 : 0;
    return routes.sublist(startIndex).take(limit).toList();
  }

  @override
  Future<List<RouteModel>> getWeekendRoutes({int limit = 10}) async {
    final routes = await _getRoutes();
    return routes
        .where((route) => route.durationDays <= 2)
        .take(limit)
        .toList();
  }

  @override
  Future<List<RouteModel>> getRoutesByRegion(String region,
      {int limit = 20}) async {
    final routes = await _getRoutes();
    return routes.where((route) => route.region == region).take(limit).toList();
  }

  @override
  Future<List<RouteModel>> getRoutesByDifficulty(RouteDifficulty difficulty,
      {int limit = 20}) async {
    final routes = await _getRoutes();
    return routes
        .where((route) => route.difficulty == difficulty)
        .take(limit)
        .toList();
  }

  @override
  Future<List<RouteModel>> getRoutesByDuration(int minDays, int maxDays,
      {int limit = 20}) async {
    final routes = await _getRoutes();
    return routes
        .where((route) =>
            route.durationDays >= minDays && route.durationDays <= maxDays)
        .take(limit)
        .toList();
  }

  @override
  Future<List<RouteModel>> searchRoutes(String keyword,
      {int limit = 20}) async {
    if (keyword.isEmpty) {
      return [];
    }

    final routes = await _getRoutes();
    final lowercaseKeyword = keyword.toLowerCase();

    return routes
        .where((route) {
          return route.name.toLowerCase().contains(lowercaseKeyword) ||
              route.region.toLowerCase().contains(lowercaseKeyword) ||
              route.description.toLowerCase().contains(lowercaseKeyword);
        })
        .take(limit)
        .toList();
  }

  @override
  Future<List<RouteModel>> getFavoriteRoutes() async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 500));

    // 从所有路线中随机选择3个作为收藏路线
    final routes = await _getRoutes();
    return routes.take(3).toList();
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
  Future<List<PlannedRouteModel>> getPlannedRoutes() async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    try {
      // 从JSON文件加载计划路线数据
      final jsonString =
          await rootBundle.loadString('assets/mock_data/planned_routes.json');
      final List<dynamic> jsonList = json.decode(jsonString);

      // 解析为模型
      return jsonList.map((json) => PlannedRouteModel.fromJson(json)).toList();
    } catch (e) {
      // 如果加载失败，返回默认数据
      final routes = await _getRoutes();
      if (routes.isEmpty) return [];

      // 创建一些默认的计划路线
      return [
        PlannedRouteModel(
          id: 'plan1',
          routeId: routes[0].id,
          name: '${routes[0].name} 行程',
          date: DateTime.now().add(const Duration(days: 7)),
          days: routes[0].durationDays,
          status: RouteStatus.planning,
          notes: '准备中的行程',
        ),
        PlannedRouteModel(
          id: 'plan2',
          routeId: routes.length > 1 ? routes[1].id : routes[0].id,
          name: '${routes.length > 1 ? routes[1].name : routes[0].name} 行程',
          date: DateTime.now().add(const Duration(days: 14)),
          days: routes.length > 1
              ? routes[1].durationDays
              : routes[0].durationDays,
          status: RouteStatus.planning,
          notes: '即将出发',
        ),
      ];
    }
  }

  @override
  Future<List<RouteModel>> getCompletedRoutes() async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 500));

    // 从所有路线中随机选择2个作为已完成路线
    final routes = await _getRoutes();
    if (routes.length < 2) return routes;

    return routes.sublist(0, 2);
  }

  @override
  Future<List<RouteModel>> getRecommendedRoutes(
      {String? season, int? limit}) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 600));

    final routes = await _getRoutes();

    // 根据季节筛选
    var filteredRoutes = routes;
    if (season != null) {
      filteredRoutes =
          routes.where((route) => route.bestSeasons.contains(season)).toList();
    }

    // 限制返回数量
    if (limit != null && limit > 0 && limit < filteredRoutes.length) {
      filteredRoutes = filteredRoutes.sublist(0, limit);
    }

    return filteredRoutes;
  }

  /// 获取路线数据
  Future<List<RouteModel>> _getRoutes() async {
    // 如果有缓存，直接返回
    if (_routesCache != null) {
      return _routesCache!;
    }

    // 从API服务获取所有路线
    _routesCache = await _apiService.getRoutes();
    return _routesCache!;
  }

  /// 获取当前季节
  String _getCurrentSeason() {
    final now = DateTime.now();
    final month = now.month;

    if (month >= 3 && month <= 5) {
      return '春季';
    } else if (month >= 6 && month <= 8) {
      return '夏季';
    } else if (month >= 9 && month <= 11) {
      return '秋季';
    } else {
      return '冬季';
    }
  }
}
