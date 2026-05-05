import 'package:flutter/foundation.dart';
import 'package:walk/core/network/api_client.dart';
import 'package:walk/core/network/api_endpoints.dart';
import 'package:walk/core/network/api_exception.dart';
import 'package:walk/model/route/route_model.dart';
import 'package:walk/model/route/route_comment_model.dart';
import 'package:walk/model/trip/trip_filter_model.dart';
import 'package:walk/model/route/route_enums.dart';

/// 路线查询参数映射工具
/// 提供统一的参数抽象，将前端的抽象参数映射到后端的具体查询条件
class RouteQueryParamMapper {
  /// 路线类别到英文 category 的映射
  static const Map<String, String?> _categoryMap = {
    '全部': null,
    '徒步': 'hiking',
    '骑行': 'cycling',
    '露营': 'camping',
    '攀岩': 'climbing',
    '城市': 'urban',
    '山地': 'mountain',
    '海滨': 'coastal',
  };

  /// 难度到字符串的映射
  static const Map<String, String> _difficultyMap = {
    '简单': 'easy',
    '中等': 'medium',
    '困难': 'hard',
  };

  /// 路线类型到字符串的映射
  static const Map<String, String> _routeTypeMap = {
    '往返': 'roundtrip',
    '环线': 'loop',
    '单程': 'oneway',
    '多日': 'multiday',
  };

  /// 排序方式映射
  static const Map<String, String> _sortMap = {
    '热门': 'popular',
    '最新': 'new',
    '距离': 'distance',
  };

  /// 将中文类别转换为英文 category
  static String? mapCategory(String? category) {
    if (category == null) return null;
    return _categoryMap[category] ?? category;
  }

  /// 将难度转换为统一格式
  static String? mapDifficulty(dynamic difficulty) {
    if (difficulty == null) return null;
    if (difficulty is int) return difficulty.toString();
    if (difficulty is String) {
      return _difficultyMap[difficulty] ?? difficulty;
    }
    return difficulty.toString();
  }

  /// 将路线类型转换为统一格式
  static String? mapRouteType(dynamic routeType) {
    if (routeType == null) return null;
    if (routeType is int) return routeType.toString();
    if (routeType is String) {
      return _routeTypeMap[routeType] ?? routeType;
    }
    return routeType.toString();
  }

  /// 将排序方式转换为统一格式
  static String mapSort(String? sort) {
    if (sort == null) return 'popular';
    return _sortMap[sort] ?? sort;
  }

  /// 将标签列表转换为逗号分隔的字符串
  static String? mapTags(List<String>? tags) {
    if (tags == null || tags.isEmpty) return null;
    return tags.join(',');
  }

  /// 获取所有支持的中文类别
  static List<String> getChineseCategories() {
    return _categoryMap.keys.where((k) => k != '全部').toList();
  }
}

/// 路线服务
///
/// 使用静态方法，无需实例化
class RouteService {
  // 禁止实例化
  RouteService._();

  /// 默认缓存时间
  static const Duration _defaultCacheTTL = Duration(hours: 1);

  /// 获取路线列表（支持统一参数）
  ///
  /// 支持抽象参数：
  /// - [category]: 路线类别（中文：徒步/骑行/露营/攀岩/城市/山地/海滨 或英文）
  /// - [tags]: 标签列表
  /// - [difficulty]: 难度（数字 1-5 或字符串 easy/medium/hard）
  /// - [routeType]: 路线类型（数字 0-3 或字符串 roundtrip/loop/oneway/multiday）
  /// - [sort]: 排序方式（popular/new/distance 或 热门/最新/距离）
  static Future<List<RouteModel>> getRoutes({
    String? keyword,
    String? category,
    List<String>? tags,
    String? regionId,
    dynamic difficulty,
    dynamic routeType,
    double? minDistance,
    double? maxDistance,
    String? userId,
    String? sort,
    int page = 0,
    int size = 20,
    int? limit,
  }) async {
    try {
      final response = await ApiClient.instance.get(
        ApiEndpoints.routes,
        queryParameters: {
          if (keyword != null) 'keyword': keyword,
          if (category != null)
            'category': RouteQueryParamMapper.mapCategory(category),
          if (tags != null && tags.isNotEmpty)
            'tags': RouteQueryParamMapper.mapTags(tags),
          if (regionId != null) 'regionId': regionId,
          if (difficulty != null)
            'difficulty': RouteQueryParamMapper.mapDifficulty(difficulty),
          if (routeType != null)
            'routeType': RouteQueryParamMapper.mapRouteType(routeType),
          if (minDistance != null) 'minDistance': minDistance,
          if (maxDistance != null) 'maxDistance': maxDistance,
          if (userId != null) 'userId': userId,
          'sort': RouteQueryParamMapper.mapSort(sort),
          'page': page,
          'size': limit ?? size,
        },
      );

      // 验证响应数据类型
      if (response.data is! Map<String, dynamic>) {
        throw BusinessException(
          'API返回了非JSON格式的数据，可能是HTML错误页面。请检查API端点是否正确。',
          code: 'INVALID_RESPONSE_FORMAT',
        );
      }

      // 解析API响应
      final responseData = response.data as Map<String, dynamic>;

      // 检查响应状态
      if (responseData['code'] != 200) {
        throw BusinessException(
          responseData['message'] ?? '获取路线列表失败',
          code: responseData['code']?.toString(),
        );
      }

      // 解析分页数据
      final data = responseData['data'] as Map<String, dynamic>;
      final content = data['content'] as List<dynamic>;

      // 转换为RouteModel列表
      return content.map((json) => RouteModel.fromJson(json)).toList();
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiExceptionFactory.fromException(e);
    }
  }

  /// 根据ID获取路线
  static Future<RouteModel> getRouteById(String routeId) async {
    try {
      final response = await ApiClient.instance.get(
        ApiEndpoints.routeDetail(routeId),
      );

      final responseData = response.data as Map<String, dynamic>;

      if (responseData['code'] != 200) {
        throw BusinessException(
          responseData['message'] ?? '获取路线详情失败',
          code: responseData['code']?.toString(),
        );
      }

      final routeData = responseData['data'] as Map<String, dynamic>;
      return RouteModel.fromJson(routeData);
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiExceptionFactory.fromException(e);
    }
  }

  /// 获取路线详情
  static Future<RouteModel> getRouteDetail(String routeId) async {
    return getRouteById(routeId);
  }

  /// 搜索路线
  static Future<List<RouteModel>> searchRoutes(String keyword,
      {int limit = 20}) async {
    try {
      final response = await ApiClient.instance.get(
        ApiEndpoints.searchRoutes,
        queryParameters: {
          'keyword': keyword,
          'limit': limit,
        },
      );

      final responseData = response.data as Map<String, dynamic>;

      if (responseData['code'] != 200) {
        throw BusinessException(
          responseData['message'] ?? '搜索路线失败',
          code: responseData['code']?.toString(),
        );
      }

      final data = responseData['data'] as Map<String, dynamic>;
      final content = data['content'] as List<dynamic>;

      return content.map((json) => RouteModel.fromJson(json)).toList();
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiExceptionFactory.fromException(e);
    }
  }

  /// 获取热门路线
  static Future<List<RouteModel>> getPopularRoutes({int limit = 10}) async {
    debugPrint('RouteService: 开始请求热门路线');
    try {
      final response = await ApiClient.instance.get(
        ApiEndpoints.popularRoutes,
        queryParameters: {'limit': limit},
      );
      debugPrint('RouteService: 请求热门路线成功');

      return _parseRoutesResponse(response.data);
    } catch (e) {
      debugPrint('RouteService: 请求热门路线失败: $e');
      if (e is ApiException) {
        rethrow;
      }
      throw ApiExceptionFactory.fromException(e);
    }
  }

  /// 获取季节性路线
  static Future<List<RouteModel>> getSeasonalRoutes({int limit = 10}) async {
    try {
      final response = await ApiClient.instance.get(
        ApiEndpoints.seasonalRoutes,
        queryParameters: {'limit': limit},
      );

      return _parseRoutesResponse(response.data);
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiExceptionFactory.fromException(e);
    }
  }

  /// 获取新晋路线
  static Future<List<RouteModel>> getNewRoutes({int limit = 10}) async {
    try {
      final response = await ApiClient.instance.get(
        ApiEndpoints.newRoutes,
        queryParameters: {'limit': limit},
      );

      return _parseRoutesResponse(response.data);
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiExceptionFactory.fromException(e);
    }
  }

  /// 获取周末路线
  static Future<List<RouteModel>> getWeekendRoutes({int limit = 10}) async {
    try {
      final response = await ApiClient.instance.get(
        ApiEndpoints.weekendRoutes,
        queryParameters: {'limit': limit},
      );

      return _parseRoutesResponse(response.data);
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiExceptionFactory.fromException(e);
    }
  }

  /// 获取推荐路线
  static Future<List<RouteModel>> getRecommendedRoutes({int limit = 10}) async {
    try {
      final response = await ApiClient.instance.get(
        ApiEndpoints.recommendedRoutes,
        queryParameters: {'limit': limit},
      );

      return _parseRoutesResponse(response.data);
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiExceptionFactory.fromException(e);
    }
  }

  /// 解析路线响应数据的通用方法
  static List<RouteModel> _parseRoutesResponse(dynamic responseData) {
    final data = responseData as Map<String, dynamic>;

    if (data['code'] != 200) {
      throw BusinessException(
        data['message'] ?? '获取路线数据失败',
        code: data['code']?.toString(),
      );
    }

    final routesData = data['data'] as Map<String, dynamic>;
    final content = routesData['content'] as List<dynamic>;
    debugPrint('RouteService: 成功解析路线数据，共 ${content.length} 条');

    return content.map((json) => RouteModel.fromJson(json)).toList();
  }

  // 以下是其他接口的基础实现，可以根据实际API进行调整

  /// 获取路线评分
  static Future<Map<String, dynamic>> getRouteRatings(String routeId) async {
    // TODO: 实现获取路线评分的API调用
    throw UnimplementedError('getRouteRatings not implemented yet');
  }

  /// 获取路线标签
  static Future<List<String>> getRouteTags(String routeId) async {
    // TODO: 实现获取路线标签的API调用
    throw UnimplementedError('getRouteTags not implemented yet');
  }

  /// 获取路线关键点
  static Future<Map<String, dynamic>> getRouteWaypoints(String routeId) async {
    // TODO: 实现获取路线关键点的API调用
    throw UnimplementedError('getRouteWaypoints not implemented yet');
  }

  /// 根据地区获取路线
  static Future<List<RouteModel>> getRoutesByRegion(String region,
      {int limit = 20}) async {
    // TODO: 实现按地区获取路线的API调用
    throw UnimplementedError('getRoutesByRegion not implemented yet');
  }

  /// 根据难度获取路线
  static Future<List<RouteModel>> getRoutesByDifficulty(RouteDifficulty difficulty,
      {int limit = 20}) async {
    // TODO: 实现按难度获取路线的API调用
    throw UnimplementedError('getRoutesByDifficulty not implemented yet');
  }

  /// 根据持续时间获取路线
  static Future<List<RouteModel>> getRoutesByDuration(int minDays, int maxDays,
      {int limit = 20}) async {
    // TODO: 实现按持续时间获取路线的API调用
    throw UnimplementedError('getRoutesByDuration not implemented yet');
  }

  /// 根据筛选条件获取路线
  static Future<List<RouteModel>> getRoutesByFilter(
    TripFilterModel filter, {
    int limit = 20,
  }) async {
    return getRoutes(
      keyword: filter.keyword,
      difficulty: filter.difficulty,
      minDistance: filter.minDistance,
      maxDistance: filter.maxDistance,
      sort: filter.sortBy,
      limit: limit,
    );
  }

  /// 按类别获取路线（简化方法）
  static Future<List<RouteModel>> getRoutesByCategory(
    String category, {
    int limit = 20,
    String? sort,
  }) async {
    if (category == '全部' || category == 'all') {
      return getRoutes(
        limit: limit,
        sort: sort,
      );
    }
    return getRoutes(
      category: category,
      limit: limit,
      sort: sort,
    );
  }

  /// 获取收藏路线
  static Future<List<RouteModel>> getFavoriteRoutes() async {
    // TODO: 实现获取收藏路线的API调用
    throw UnimplementedError('getFavoriteRoutes not implemented yet');
  }

  /// 收藏路线
  static Future<bool> favoriteRoute(String routeId) async {
    // TODO: 实现收藏路线的API调用
    throw UnimplementedError('favoriteRoute not implemented yet');
  }

  /// 取消收藏路线
  static Future<bool> unfavoriteRoute(String routeId) async {
    // TODO: 实现取消收藏路线的API调用
    throw UnimplementedError('unfavoriteRoute not implemented yet');
  }

  /// 检查路线是否已收藏
  static Future<bool> checkIfFavorite(String routeId) async {
    // TODO: 实现检查路线是否已收藏的API调用
    throw UnimplementedError('checkIfFavorite not implemented yet');
  }

  /// 添加收藏
  static Future<bool> addFavorite(String routeId) async {
    return favoriteRoute(routeId);
  }

  /// 移除收藏
  static Future<bool> removeFavorite(String routeId) async {
    return unfavoriteRoute(routeId);
  }

  /// 获取计划路线
  static Future<List<RouteModel>> getPlannedRoutes() async {
    // TODO: 实现获取计划路线的API调用
    throw UnimplementedError('getPlannedRoutes not implemented yet');
  }

  /// 获取已完成路线
  static Future<List<RouteModel>> getCompletedRoutes() async {
    // TODO: 实现获取已完成路线的API调用
    throw UnimplementedError('getCompletedRoutes not implemented yet');
  }

  /// 获取路线评论
  static Future<List<RouteCommentModel>> getRouteComments(String routeId) async {
    // TODO: 实现获取路线评论的API调用
    throw UnimplementedError('getRouteComments not implemented yet');
  }

  /// 添加路线评论
  static Future<RouteCommentModel> addRouteComment(
      String routeId, String content, double rating) async {
    // TODO: 实现添加路线评论的API调用
    throw UnimplementedError('addRouteComment not implemented yet');
  }

  /// 创建路线
  static Future<RouteModel> createRoute(RouteModel route) async {
    // TODO: 实现创建路线的API调用
    throw UnimplementedError('createRoute not implemented yet');
  }

  /// 更新路线
  static Future<RouteModel> updateRoute(RouteModel route) async {
    // TODO: 实现更新路线的API调用
    throw UnimplementedError('updateRoute not implemented yet');
  }

  /// 删除路线
  static Future<bool> deleteRoute(String routeId) async {
    // TODO: 实现删除路线的API调用
    throw UnimplementedError('deleteRoute not implemented yet');
  }

  /// 获取相关路线
  static Future<List<RouteModel>> getRelatedRoutes(String routeId,
      {int limit = 5}) async {
    return [];
  }
}
