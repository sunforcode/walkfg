import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../recommendation_service.dart';
import '../../model/route/route_model.dart';
import '../../model/search/hot_search_model.dart';
import '../../model/routes/recommended_route_model.dart';

/// Mock推荐服务实现
class MockRecommendationService implements RecommendationService {
  /// 单例实例
  static final MockRecommendationService _instance =
      MockRecommendationService._internal();

  /// 工厂构造函数
  factory MockRecommendationService() {
    return _instance;
  }

  /// 私有构造函数
  MockRecommendationService._internal();

  /// 从JSON文件加载数据
  Future<dynamic> _loadJsonData(String path) async {
    try {
      final String jsonString = await rootBundle.loadString(path);
      return json.decode(jsonString);
    } catch (e) {
      print('加载JSON文件失败: $e');
      return null;
    }
  }

  @override
  Future<HotSearchListModel> getHotSearches({int limit = 10}) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    final hotSearchesJson =
        await _loadJsonData('assets/mock_data/hot_searches.json');
    if (hotSearchesJson == null) {
      return HotSearchListModel(items: []);
    }

    final List<dynamic> itemsJson = hotSearchesJson['items'] as List<dynamic>;
    List<HotSearchModel> items = itemsJson
        .map<HotSearchModel>((json) => HotSearchModel.fromJson(json))
        .toList();

    // 限制数量
    if (items.length > limit) {
      items = items.sublist(0, limit);
    }

    return HotSearchListModel(items: items);
  }

  @override
  Future<RecommendedRouteListModel> getRecommendedRoutes() async {
    // 模拟网络延迟
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    final recommendedRoutesJson =
        await _loadJsonData('assets/mock_data/recommended_routes.json');

    RecommendedRouteListModel items =
        RecommendedRouteListModel.fromJson(recommendedRoutesJson);
    return items;
  }

  @override
  Future<RecommendedRouteModel?> getRecommendedRoutesByType(
      RecommendedRouteType type) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    final recommendedRoutesJson =
        await _loadJsonData('assets/mock_data/recommended_routes.json');
    if (recommendedRoutesJson == null) {
      debugPrint('推荐路线数据为空');
      return null;
    }

    RecommendedRouteModel items =
        RecommendedRouteModel.fromJson(recommendedRoutesJson);
    return items;
  }

  @override
  Future<List<RouteModel>> getSeasonalRecommendations(
      {String? season, int limit = 10}) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    final routesJson = await _loadJsonData('assets/mock_data/routes.json');
    if (routesJson == null || !(routesJson is List)) {
      return [];
    }

    List<RouteModel> routes = routesJson
        .map<RouteModel>((json) => RouteModel.fromJson(json))
        .toList();

    return routes;
  }

  @override
  Future<List<RouteModel>> getPersonalizedRecommendations(
      {int limit = 10}) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    final routesJson = await _loadJsonData('assets/mock_data/routes.json');
    if (routesJson == null || !(routesJson is List)) {
      return [];
    }

    List<RouteModel> routes = routesJson
        .map<RouteModel>((json) => RouteModel.fromJson(json))
        .toList();

    return routes;
  }

  @override
  Future<List<RouteModel>> getSimilarRoutes(String routeId,
      {int limit = 5}) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    final routesJson = await _loadJsonData('assets/mock_data/routes.json');
    if (routesJson == null || !(routesJson is List)) {
      return [];
    }

    // 获取参考路线
    RouteModel? referenceRoute;
    try {
      final referenceJson =
          routesJson.firstWhere((route) => route['id'] == routeId);
      referenceRoute = RouteModel.fromJson(referenceJson);
    } catch (e) {
      return [];
    }

    List<RouteModel> routes = routesJson
        .where((json) => json['id'] != routeId) // 排除参考路线自身
        .map<RouteModel>((json) => RouteModel.fromJson(json))
        .toList();
    return routes;
  }

  /// 获取当前季节
  String _getCurrentSeason() {
    final now = DateTime.now();
    if (now.month >= 3 && now.month <= 5) {
      return '春';
    } else if (now.month >= 6 && now.month <= 8) {
      return '夏';
    } else if (now.month >= 9 && now.month <= 11) {
      return '秋';
    } else {
      return '冬';
    }
  }
}
