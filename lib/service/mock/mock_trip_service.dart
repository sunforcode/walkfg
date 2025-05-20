import 'dart:convert';
import 'package:flutter/services.dart';
import '../../model/route/route_model.dart';
import '../../model/trip/hot_search_model.dart';
import '../../model/trip/recommended_route_model.dart';
import '../../model/trip/trip_filter_model.dart';
import '../trip_service.dart';

/// 模拟行程服务实现
class MockTripService implements TripService {
  /// API服务

  /// 路线缓存
  List<RouteModel>? _routesCache;

  /// 热门搜索缓存
  HotSearchListModel? _hotSearchesCache;

  /// 推荐路线缓存
  RecommendedRouteListModel? _recommendedRoutesCache;


  Future<List<RouteModel>> getPopularRoutes({int limit = 10}) async {
    final routes = await getRoutes();
    return routes.take(limit).toList();
  }


  Future<List<RouteModel>> getSeasonalRoutes({int limit = 10}) async {
    final routes = await getRoutes();
    return routes
        .where((route) => route.bestSeasons.contains('秋季'))
        .take(limit)
        .toList();
  }


  Future<List<RouteModel>> getNewRoutes({int limit = 10}) async {
    final routes = await getRoutes();
    // 模拟新晋路线，取后半部分
    final startIndex =
        routes.length > limit * 2 ? routes.length - limit * 2 : 0;
    return routes.sublist(startIndex).take(limit).toList();
  }


  Future<List<RouteModel>> getWeekendRoutes({int limit = 10}) async {
    final routes = await getRoutes();
    return routes
        .where((route) => route.durationDays <= 2)
        .take(limit)
        .toList();
  }


  Future<List<RouteModel>> getRoutesByRegion(String region,
      {int limit = 20}) async {
    final routes = await getRoutes();
    return routes.where((route) => route.region == region).take(limit).toList();
  }


  Future<List<RouteModel>> getRoutesByDifficulty(RouteDifficulty difficulty,
      {int limit = 20}) async {
    final routes = await getRoutes();
    return routes
        .where((route) => route.difficulty == difficulty)
        .take(limit)
        .toList();
  }


  Future<List<RouteModel>> getRoutesByDuration(int minDays, int maxDays,
      {int limit = 20}) async {
    final routes = await getRoutes();
    return routes
        .where((route) =>
            route.durationDays >= minDays && route.durationDays <= maxDays)
        .take(limit)
        .toList();
  }

  @override
  Future<List<RouteModel>> getRoutesByFilter(TripFilterModel filter,
      {int limit = 20}) async {
    final routes = await _getRoutes();

    return routes
        .where((route) {
          // 应用筛选条件
          if (filter.region != null && route.region != filter.region) {
            return false;
          }

          if (filter.difficulty != null &&
              route.difficulty != filter.difficulty) {
            return false;
          }

          if (filter.minDays != null && route.durationDays < filter.minDays!) {
            return false;
          }

          if (filter.maxDays != null && route.durationDays > filter.maxDays!) {
            return false;
          }

          if (filter.season != null &&
              !route.bestSeasons.contains(filter.season)) {
            return false;
          }

          return true;
        })
        .take(limit)
        .toList();
  }

  Future<List<RouteModel>> searchRoutes(String keyword,
      {int limit = 20}) async {
    if (keyword.isEmpty) {
      return [];
    }

    final routes = await getRoutes();
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
  Future<HotSearchListModel> getHotSearches({int limit = 10}) async {
    // 如果有缓存，直接返回
    if (_hotSearchesCache != null) {
      return _hotSearchesCache!;
    }

    try {
      // 从JSON文件加载数据
      final jsonString =
          await rootBundle.loadString('assets/mock_data/hot_searches.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      // 解析为模型
      _hotSearchesCache = HotSearchListModel.fromJson(jsonData);

      // 限制数量
      final items = _hotSearchesCache!.items.take(limit).toList();
      return HotSearchListModel(
        items: items,
        updatedAt: _hotSearchesCache!.updatedAt,
      );
    } catch (e) {
      // 如果加载失败，返回默认数据
      final defaultItems = [
        HotSearchModel(keyword: '贡嘎大环线', count: 1245, isHot: true),
        HotSearchModel(keyword: '雨崩徒步', count: 987, isHot: true),
        HotSearchModel(keyword: '丙察察线', count: 876, isHot: true),
        HotSearchModel(keyword: '南迦巴瓦', count: 765),
        HotSearchModel(keyword: '毕棚沟', count: 654),
        HotSearchModel(keyword: '鳌太穿越', count: 543),
      ];

      return HotSearchListModel(
        items: defaultItems.take(limit).toList(),
        updatedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<RecommendedRouteListModel> getRecommendedRoutes() async {
    // 如果有缓存，直接返回
    if (_recommendedRoutesCache != null) {
      return _recommendedRoutesCache!;
    }

    try {
      // 从JSON文件加载数据
      final jsonString = await rootBundle
          .loadString('assets/mock_data/recommended_routes.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      // 解析为模型
      _recommendedRoutesCache = RecommendedRouteListModel.fromJson(jsonData);
      return _recommendedRoutesCache!;
    } catch (e) {
      // 如果加载失败，创建默认数据
      final routes = await _getRoutes();

      final items = [
        RecommendedRouteModel(
          type: RecommendedRouteType.featured,
          title: '精选路线',
          description: '精心挑选的热门徒步路线',
          routes: routes.take(5).toList(),
        ),
        RecommendedRouteModel(
          type: RecommendedRouteType.popular,
          title: '热门路线',
          description: '最受徒步爱好者欢迎的路线',
          routes: routes.sublist(2, 7).toList(),
        ),
        RecommendedRouteModel(
          type: RecommendedRouteType.seasonal,
          title: '秋季推荐',
          description: '最适合秋季徒步的路线',
          routes: routes
              .where((route) => route.bestSeasons.contains('秋季'))
              .take(5)
              .toList(),
        ),
        RecommendedRouteModel(
          type: RecommendedRouteType.weekend,
          title: '周末短途',
          description: '适合周末出行的短途徒步路线',
          routes:
              routes.where((route) => route.durationDays <= 2).take(5).toList(),
        ),
      ];

      return RecommendedRouteListModel(
        items: items,
        updatedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<RecommendedRouteModel?> getRecommendedRoutesByType(
      RecommendedRouteType type) async {
    final recommendedRoutes = await getRecommendedRoutes();
    return recommendedRoutes.getByType(type);
  }

  /// 获取路线数据

  Future<List<RouteModel>> getRoutes() async {
    // 如果有缓存，直接返回
    if (_routesCache != null) {
      return _routesCache!;
    }

    try {
      // 从JSON文件加载数据
      final jsonString =
          await rootBundle.loadString('assets/mock_data/routes.json');
      final List<dynamic> jsonList = json.decode(jsonString);

      // 解析为模型
      _routesCache = jsonList.map((json) => RouteModel.fromJson(json)).toList();
      return _routesCache!;
    } catch (e) {
      // 如果加载失败，返回空列表
      return [];
    }
  }

  /// 获取路线数据
  Future<List<RouteModel>> _getRoutes() async {
    // 如果有缓存，直接返回
    if (_routesCache != null) {
      return _routesCache!;
    }

    try {
      // 从JSON文件加载数据
      final jsonString =
          await rootBundle.loadString('assets/mock_data/routes.json');
      final List<dynamic> jsonList = json.decode(jsonString);

      // 解析为模型
      _routesCache = jsonList.map((json) => RouteModel.fromJson(json)).toList();
      return _routesCache!;
    } catch (e) {
      // 如果加载失败，返回空列表
      return [];
    }
  }
}
