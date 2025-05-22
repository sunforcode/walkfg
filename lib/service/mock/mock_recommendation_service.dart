import 'dart:convert';
import 'package:flutter/services.dart';
import '../recommendation_service.dart';
import '../../model/model/route/route_model.dart';
import '../../model/trip/hot_search_model.dart';
import '../../model/trip/recommended_route_model.dart';

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
    await Future.delayed(const Duration(milliseconds: 400));

    final recommendedRoutesJson =
        await _loadJsonData('assets/mock_data/recommended_routes.json');
    if (recommendedRoutesJson == null) {
      return RecommendedRouteListModel(items: []);
    }

    final List<dynamic> itemsJson =
        recommendedRoutesJson['items'] as List<dynamic>;
    List<RecommendedRouteModel> items = itemsJson
        .map<RecommendedRouteModel>(
            (json) => RecommendedRouteModel.fromJson(json))
        .toList();

    return RecommendedRouteListModel(items: items);
  }

  @override
  Future<RecommendedRouteModel?> getRecommendedRoutesByType(
      RecommendedRouteType type) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    final recommendedRoutesJson =
        await _loadJsonData('assets/mock_data/recommended_routes.json');
    if (recommendedRoutesJson == null) {
      return null;
    }

    final List<dynamic> itemsJson =
        recommendedRoutesJson['items'] as List<dynamic>;
    List<RecommendedRouteModel> items = itemsJson
        .map<RecommendedRouteModel>(
            (json) => RecommendedRouteModel.fromJson(json))
        .toList();

    // 查找指定类型的推荐路线
    try {
      return items.firstWhere((item) => item.type == type);
    } catch (e) {
      return null;
    }
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

    // 获取当前季节
    final currentSeason = season ?? _getCurrentSeason();

    // 筛选当前季节适合的路线
    routes = routes
        .where((route) => route.basicInfo.bestSeason.contains(currentSeason))
        .toList();

    // 按评分排序
    routes.sort((a, b) => b.ratings.overall.compareTo(a.ratings.overall));

    // 限制数量
    if (routes.length > limit) {
      routes = routes.sublist(0, limit);
    }

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

    // 模拟个性化推荐（随机排序）
    routes.shuffle();

    // 限制数量
    if (routes.length > limit) {
      routes = routes.sublist(0, limit);
    }

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

    // 计算相似度并排序（这里简化为相同难度和相近距离）
    routes.sort((a, b) {
      // 难度相同加分
      final aDifficultyMatch =
          a.basicInfo.difficulty == referenceRoute!.basicInfo.difficulty ? 1 : 0;
      final bDifficultyMatch =
          b.basicInfo.difficulty == referenceRoute.basicInfo.difficulty ? 1 : 0;

      // 距离相近加分（距离差的绝对值越小越好）
      final aDistanceDiff = (a.basicInfo.distance - referenceRoute.basicInfo.distance).abs();
      final bDistanceDiff = (b.basicInfo.distance - referenceRoute.basicInfo.distance).abs();

      // 综合评分（难度匹配度 - 距离差）
      final aScore = aDifficultyMatch - aDistanceDiff / 100;
      final bScore = bDifficultyMatch - bDistanceDiff / 100;

      return bScore.compareTo(aScore);
    });

    // 限制数量
    if (routes.length > limit) {
      routes = routes.sublist(0, limit);
    }

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
