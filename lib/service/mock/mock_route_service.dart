import 'dart:convert';
import 'package:flutter/services.dart';
import '../route_service.dart';
import '../../model/model/route/route_model.dart';
import '../../model/route/route_rating_model.dart';
import '../../model/route/route_comment_model.dart';
import '../../model/enums/route_status.dart';
import '../../model/trip/trip_filter_model.dart';

/// Mock路线服务实现
class MockRouteService implements RouteService {
  /// 单例实例
  static final MockRouteService _instance = MockRouteService._internal();

  /// 工厂构造函数
  factory MockRouteService() {
    return _instance;
  }

  /// 私有构造函数
  MockRouteService._internal();

  /// 路线评分缓存
  List<RouteRatingModel>? _routeRatingsCache;

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
  Future<RouteModel> getRouteById(String routeId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    final routesJson = await _loadJsonData('assets/mock_data/routes.json');
    if (routesJson == null || !(routesJson is List)) {
      throw Exception('Failed to load routes data');
    }

    final routeJson = routesJson.firstWhere(
      (route) => route['id'] == routeId,
      orElse: () => throw Exception('Route not found: $routeId'),
    );

    return RouteModel.fromJson(routeJson);
  }

  @override
  Future<RouteModel> getRouteDetail(String routeId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    final routesJson =
        await _loadJsonData('assets/mock_data/route_details.json');
    if (routesJson == null || !(routesJson is List)) {
      throw Exception('Failed to load route details');
    }

    final routeJson = routesJson.firstWhere(
      (route) => route['id'] == routeId,
      orElse: () => throw Exception('Route not found: $routeId'),
    );

    return RouteModel.fromJson(routeJson);
  }

  @override
  Future<Map<String, dynamic>> getRouteRatings(String routeId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 如果有缓存，直接返回
    if (_routeRatingsCache != null) {
      final ratings = _routeRatingsCache!
          .where((rating) => rating.routeId == routeId)
          .toList();

      // 计算平均评分
      double averageRating = 0;
      if (ratings.isNotEmpty) {
        averageRating = ratings.map((r) => r.rating).reduce((a, b) => a + b) /
            ratings.length;
      }

      return {
        'average': averageRating,
        'count': ratings.length,
        'ratings': ratings.map((r) => r.toJson()).toList(),
      };
    }

    final ratingsJson =
        await _loadJsonData('assets/mock_data/route_ratings.json');
    if (ratingsJson == null || !(ratingsJson is List)) {
      _routeRatingsCache = [];
      return {
        'average': 0.0,
        'count': 0,
        'ratings': [],
      };
    }

    _routeRatingsCache = ratingsJson
        .map<RouteRatingModel>((json) => RouteRatingModel.fromJson(json))
        .toList();

    final ratings = _routeRatingsCache!
        .where((rating) => rating.routeId == routeId)
        .toList();

    // 计算平均评分
    double averageRating = 0;
    if (ratings.isNotEmpty) {
      averageRating =
          ratings.map((r) => r.rating).reduce((a, b) => a + b) / ratings.length;
    }

    return {
      'average': averageRating,
      'count': ratings.length,
      'ratings': ratings.map((r) => r.toJson()).toList(),
    };
  }

  @override
  Future<List<String>> getRouteTags(String routeId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 模拟路线标签
    return ['徒步', '山地', '风景', '自然', '摄影'];
  }

  @override
  Future<Map<String, dynamic>> getRouteWaypoints(String routeId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 获取路线详情
    final routeDetail = await getRouteDetail(routeId);

    // 返回途经点
    return {
      'route_id': routeId,
      'waypoints': routeDetail.waypoints.map((w) => w.toJson()).toList(),
    };
  }

  @override
  Future<List<RouteModel>> getPopularRoutes({int limit = 10}) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    final routesJson = await _loadJsonData('assets/mock_data/routes.json');
    if (routesJson == null || !(routesJson is List)) {
      return [];
    }

    List<RouteModel> routes = routesJson
        .map<RouteModel>((json) => RouteModel.fromJson(json))
        .toList();

    // 按人气排序
    routes.sort((a, b) => b.popularity.compareTo(a.popularity));

    // 限制数量
    if (routes.length > limit) {
      routes = routes.sublist(0, limit);
    }

    return routes;
  }

  @override
  Future<List<RouteModel>> getSeasonalRoutes({int limit = 10}) async {
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
    final now = DateTime.now();
    String currentSeason;
    if (now.month >= 3 && now.month <= 5) {
      currentSeason = '春';
    } else if (now.month >= 6 && now.month <= 8) {
      currentSeason = '夏';
    } else if (now.month >= 9 && now.month <= 11) {
      currentSeason = '秋';
    } else {
      currentSeason = '冬';
    }

    // 随机排序
    routes.shuffle();

    // 限制数量
    if (routes.length > limit) {
      routes = routes.sublist(0, limit);
    }

    return routes;
  }

  @override
  Future<List<RouteModel>> getNewRoutes({int limit = 10}) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    final routesJson = await _loadJsonData('assets/mock_data/routes.json');
    if (routesJson == null || !(routesJson is List)) {
      return [];
    }

    List<RouteModel> routes = routesJson
        .map<RouteModel>((json) => RouteModel.fromJson(json))
        .toList();

    // 按创建时间排序
    routes.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));

    // 限制数量
    if (routes.length > limit) {
      routes = routes.sublist(0, limit);
    }

    return routes;
  }

  @override
  Future<List<RouteModel>> getWeekendRoutes({int limit = 10}) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    final routesJson = await _loadJsonData('assets/mock_data/routes.json');
    if (routesJson == null || !(routesJson is List)) {
      return [];
    }

    List<RouteModel> routes = routesJson
        .map<RouteModel>((json) => RouteModel.fromJson(json))
        .toList();

    // 筛选适合周末的路线（1-2天的路线）
    routes = routes
        .where((route) =>
            route.basicInfo.duration.contains('1') ||
            route.basicInfo.duration.contains('2'))
        .toList();

    // 随机排序
    routes.shuffle();

    // 限制数量
    if (routes.length > limit) {
      routes = routes.sublist(0, limit);
    }

    return routes;
  }

  @override
  Future<List<RouteModel>> getRoutes({String? season, int? limit}) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    final routesJson = await _loadJsonData('assets/mock_data/routes.json');
    if (routesJson == null || !(routesJson is List)) {
      return [];
    }

    List<RouteModel> routes = routesJson
        .map<RouteModel>((json) => RouteModel.fromJson(json))
        .toList();

    // 季节过滤
    if (season != null && season.isNotEmpty) {
      routes = routes
          .where((route) => route.basicInfo.bestSeason.contains(season))
          .toList();
    }

    // 限制数量
    if (limit != null && routes.length > limit) {
      routes = routes.sublist(0, limit);
    }

    return routes;
  }

  @override
  Future<List<RouteModel>> getRoutesByRegion(String region,
      {int limit = 20}) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    final routesJson = await _loadJsonData('assets/mock_data/routes.json');
    if (routesJson == null || !(routesJson is List)) {
      return [];
    }

    List<RouteModel> routes = routesJson
        .map<RouteModel>((json) => RouteModel.fromJson(json))
        .toList();

    // 模拟按地区筛选（实际上我们没有地区字段，这里随机返回一些路线）
    routes.shuffle();

    // 限制数量
    if (routes.length > limit) {
      routes = routes.sublist(0, limit);
    }

    return routes;
  }

  @override
  Future<List<RouteModel>> getRoutesByDifficulty(RouteDifficulty difficulty,
      {int limit = 20}) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    final routesJson = await _loadJsonData('assets/mock_data/routes.json');
    if (routesJson == null || !(routesJson is List)) {
      return [];
    }

    List<RouteModel> routes = routesJson
        .map<RouteModel>((json) => RouteModel.fromJson(json))
        .toList();

    // 将枚举难度转换为字符串
    String difficultyStr;
    switch (difficulty) {
      case RouteDifficulty.easy:
        difficultyStr = '初级';
        break;
      case RouteDifficulty.medium:
        difficultyStr = '中级';
        break;
      case RouteDifficulty.hard:
        difficultyStr = '高级';
        break;
      case RouteDifficulty.extreme:
        difficultyStr = '专业级';
        break;
    }

    // 按难度筛选
    routes = routes
        .where((route) => route.basicInfo.difficulty == difficultyStr)
        .toList();

    // 限制数量
    if (routes.length > limit) {
      routes = routes.sublist(0, limit);
    }

    return routes;
  }

  @override
  Future<List<RouteModel>> getRoutesByDuration(int minDays, int maxDays,
      {int limit = 20}) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    final routesJson = await _loadJsonData('assets/mock_data/routes.json');
    if (routesJson == null || !(routesJson is List)) {
      return [];
    }

    List<RouteModel> routes = routesJson
        .map<RouteModel>((json) => RouteModel.fromJson(json))
        .toList();

    // 按天数筛选（简单实现，实际应该解析duration字段）
    routes = routes.where((route) {
      // 解析天数，例如 "2-3天" 或 "1天"
      final durationStr = route.basicInfo.duration;
      if (durationStr.contains('-')) {
        final parts = durationStr.split('-');
        final minRouteDays = int.tryParse(parts[0]) ?? 0;
        final maxRouteDays = int.tryParse(parts[1].replaceAll('天', '')) ?? 0;
        return maxRouteDays >= minDays && minRouteDays <= maxDays;
      } else {
        final days = int.tryParse(durationStr.replaceAll('天', '')) ?? 0;
        return days >= minDays && days <= maxDays;
      }
    }).toList();

    // 限制数量
    if (routes.length > limit) {
      routes = routes.sublist(0, limit);
    }

    return routes;
  }

  @override
  Future<List<RouteModel>> searchRoutes(String keyword,
      {int limit = 20}) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    final routesJson = await _loadJsonData('assets/mock_data/routes.json');
    if (routesJson == null || !(routesJson is List)) {
      return [];
    }

    List<RouteModel> routes = routesJson
        .map<RouteModel>((json) => RouteModel.fromJson(json))
        .toList();

    // 关键词过滤
    if (keyword.isNotEmpty) {
      routes = routes
          .where((route) =>
              route.name.toLowerCase().contains(keyword.toLowerCase()) ||
              route.description.toLowerCase().contains(keyword.toLowerCase()))
          .toList();
    }

    // 限制数量
    if (routes.length > limit) {
      routes = routes.sublist(0, limit);
    }

    return routes;
  }

  @override
  Future<List<RouteModel>> getFavoriteRoutes() async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    final routesJson = await _loadJsonData('assets/mock_data/routes.json');
    if (routesJson == null || !(routesJson is List)) {
      return [];
    }

    List<RouteModel> routes = routesJson
        .map<RouteModel>((json) => RouteModel.fromJson(json))
        .toList();

    // 筛选已收藏的路线
    routes = routes.where((route) => route.isFavorite).toList();

    return routes;
  }

  @override
  Future<bool> favoriteRoute(String routeId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 模拟收藏成功
    return true;
  }

  @override
  Future<bool> unfavoriteRoute(String routeId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 模拟取消收藏成功
    return true;
  }

  @override
  Future<bool> checkIfFavorite(String routeId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 模拟检查收藏状态
    // 这里可以随机返回true或false，或者根据路线ID进行一些简单的判断
    return routeId.hashCode % 2 == 0; // 偶数ID为已收藏
  }

  @override
  Future<bool> addFavorite(String routeId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 模拟添加收藏成功
    return true;
  }

  @override
  Future<bool> removeFavorite(String routeId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 模拟移除收藏成功
    return true;
  }

  @override
  Future<List<RouteModel>> getPlannedRoutes() async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    final plannedRoutesJson =
        await _loadJsonData('assets/mock_data/planned_routes.json');
    if (plannedRoutesJson == null || !(plannedRoutesJson is List)) {
      return [];
    }

    List<RouteModel> routes = plannedRoutesJson
        .map<RouteModel>((json) => RouteModel.fromJson(json))
        .toList();

    // 筛选计划中的路线
    routes =
        routes.where((route) => route.status == RouteStatus.planning).toList();

    return routes;
  }

  @override
  Future<List<RouteModel>> getCompletedRoutes() async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    final plannedRoutesJson =
        await _loadJsonData('assets/mock_data/planned_routes.json');
    if (plannedRoutesJson == null || !(plannedRoutesJson is List)) {
      return [];
    }

    List<RouteModel> routes = plannedRoutesJson
        .map<RouteModel>((json) => RouteModel.fromJson(json))
        .toList();

    // 筛选已完成的路线
    routes =
        routes.where((route) => route.status == RouteStatus.completed).toList();

    return routes;
  }

  Future<List<RouteModel>> getRecommendedRoutes(
      {String? season, int? limit}) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    final routesJson = await _loadJsonData('assets/mock_data/routes.json');
    if (routesJson == null || !(routesJson is List)) {
      return [];
    }

    List<RouteModel> routes = routesJson
        .map<RouteModel>((json) => RouteModel.fromJson(json))
        .toList();

    // 季节过滤
    if (season != null && season.isNotEmpty) {
      routes = routes
          .where((route) => route.basicInfo.bestSeason.contains(season))
          .toList();
    }

    // 按评分排序
    routes.sort((a, b) => b.ratings.overall.compareTo(a.ratings.overall));

    // 限制数量
    if (limit != null && routes.length > limit) {
      routes = routes.sublist(0, limit);
    }

    return routes;
  }

  @override
  Future<List<RouteCommentModel>> getRouteComments(String routeId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    final commentsJson =
        await _loadJsonData('assets/mock_data/route_comments.json');
    if (commentsJson == null || !(commentsJson is List)) {
      return [];
    }

    List<RouteCommentModel> comments = commentsJson
        .map<RouteCommentModel>((json) => RouteCommentModel.fromJson(json))
        .where((comment) => comment.routeId == routeId)
        .toList();

    // 按时间排序
    comments.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return comments;
  }

  @override
  Future<RouteCommentModel> addRouteComment(
      String routeId, String content, double rating) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 创建新评论
    final now = DateTime.now();
    final comment = RouteCommentModel(
      id: 'comment_${now.millisecondsSinceEpoch}',
      routeId: routeId,
      userId: 'current_user',
      userName: '当前用户',
      userAvatar: null,
      content: content,
      rating: rating,
      createdAt: now,
    );

    return comment;
  }

  @override
  Future<RouteRatingModel> rateRoute(String routeId, double rating) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 创建新评分
    final now = DateTime.now();
    final ratingModel = RouteRatingModel(
      id: 'rating_${now.millisecondsSinceEpoch}',
      routeId: routeId,
      userId: 'current_user',
      rating: rating,
      createdAt: now,
    );

    // 更新缓存
    if (_routeRatingsCache != null) {
      // 移除旧评分
      _routeRatingsCache!.removeWhere(
          (r) => r.routeId == routeId && r.userId == 'current_user');
      // 添加新评分
      _routeRatingsCache!.add(ratingModel);
    }

    return ratingModel;
  }

  @override
  Future<RouteModel> createRoute(RouteModel route) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 模拟创建成功，返回带有ID的对象
    final now = DateTime.now();
    return route.copyWith(
      id: 'new_${now.millisecondsSinceEpoch}',
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Future<RouteModel> updateRoute(RouteModel route) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 模拟更新成功，返回更新后的对象
    return route.copyWith(
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<bool> deleteRoute(String routeId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 模拟删除成功
    return true;
  }

  @override
  Future<List<RouteModel>> getRoutesByFilter(TripFilterModel filter,
      {int limit = 20}) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    final routesJson = await _loadJsonData('assets/mock_data/routes.json');
    if (routesJson == null || !(routesJson is List)) {
      return [];
    }

    List<RouteModel> routes = routesJson
        .map<RouteModel>((json) => RouteModel.fromJson(json))
        .toList();

    // 关键词过滤
    if (filter.keyword != null && filter.keyword!.isNotEmpty) {
      routes = routes
          .where((route) =>
              route.name
                  .toLowerCase()
                  .contains(filter.keyword!.toLowerCase()) ||
              route.description
                  .toLowerCase()
                  .contains(filter.keyword!.toLowerCase()))
          .toList();
    }

    // 难度过滤
    if (filter.difficulty != null && filter.difficulty!.isNotEmpty) {
      routes = routes
          .where((route) => route.basicInfo.difficulty == filter.difficulty)
          .toList();
    }

    // 季节过滤
    if (filter.season != null && filter.season!.isNotEmpty) {
      routes = routes
          .where((route) => route.basicInfo.bestSeason.contains(filter.season))
          .toList();
    }

    // 时长过滤
    if (filter.duration != null && filter.duration!.isNotEmpty) {
      routes = routes
          .where((route) => route.basicInfo.duration == filter.duration)
          .toList();
    }

    // 距离过滤
    if (filter.minDistance != null) {
      routes = routes
          .where((route) => route.basicInfo.distance >= filter.minDistance!)
          .toList();
    }
    if (filter.maxDistance != null) {
      routes = routes
          .where((route) => route.basicInfo.distance <= filter.maxDistance!)
          .toList();
    }

    // 海拔过滤
    if (filter.minElevation != null) {
      routes = routes
          .where(
              (route) => route.basicInfo.elevationGain >= filter.minElevation!)
          .toList();
    }
    if (filter.maxElevation != null) {
      routes = routes
          .where(
              (route) => route.basicInfo.elevationGain <= filter.maxElevation!)
          .toList();
    }

    // 排序
    if (filter.sortBy != null) {
      final asc = filter.ascending ?? true;
      switch (filter.sortBy) {
        case 'distance':
          routes.sort((a, b) => asc
              ? a.basicInfo.distance.compareTo(b.basicInfo.distance)
              : b.basicInfo.distance.compareTo(a.basicInfo.distance));
          break;
        case 'elevation':
          routes.sort((a, b) => asc
              ? a.basicInfo.elevationGain.compareTo(b.basicInfo.elevationGain)
              : b.basicInfo.elevationGain.compareTo(a.basicInfo.elevationGain));
          break;
        case 'rating':
          routes.sort((a, b) => asc
              ? a.ratings.overall.compareTo(b.ratings.overall)
              : b.ratings.overall.compareTo(a.ratings.overall));
          break;
        case 'popularity':
          routes.sort((a, b) => asc
              ? a.popularity.compareTo(b.popularity)
              : b.popularity.compareTo(a.popularity));
          break;
        case 'date':
          routes.sort((a, b) => asc
              ? a.createdAt!.compareTo(b.createdAt!)
              : b.createdAt!.compareTo(a.createdAt!));
          break;
      }
    }

    // 限制数量
    if (routes.length > limit) {
      routes = routes.sublist(0, limit);
    }

    return routes;
  }
}
