import 'package:flutter/foundation.dart';
import 'package:walk/core/network/api_client.dart';
import 'package:walk/core/network/api_endpoints.dart';
import 'package:walk/core/network/api_exception.dart';
import 'package:walk/core/network/response_unwrap.dart';
import 'package:walk/model/route/route_model.dart';
import 'package:walk/model/trip/trip_filter_model.dart';

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

      // 解析分页数据
      final data = unwrapResponse(response.data as Map<String, dynamic>);
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

      final routeData = unwrapResponse(response.data as Map<String, dynamic>);
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

      final data = unwrapResponse(response.data as Map<String, dynamic>);
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
    try {
      final response = await ApiClient.instance.get(
        ApiEndpoints.popularRoutes,
        queryParameters: {'limit': limit},
      );

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
    final routesData = unwrapResponse(responseData as Map<String, dynamic>);
    final content = routesData['content'] as List<dynamic>;

    return content.map((json) => RouteModel.fromJson(json)).toList();
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
  ///
  /// 注意：`userId` 目前由客户端自报，后端未做身份校验，与代码库中既有的
  /// `_currentUserId = 'current_user'` 占位约定保持一致。
  static Future<List<RouteModel>> getFavoriteRoutes({
    String userId = 'current_user',
    int page = 0,
    int size = 10,
  }) async {
    try {
      final response = await ApiClient.instance.get(
        ApiEndpoints.favoriteRoutes,
        queryParameters: {
          'userId': userId,
          'page': page,
          'size': size,
        },
      );

      if (response.data is! Map<String, dynamic>) {
        throw BusinessException(
          'API返回了非JSON格式的数据，可能是HTML错误页面。请检查API端点是否正确。',
          code: 'INVALID_RESPONSE_FORMAT',
        );
      }

      final data = unwrapResponse(response.data as Map<String, dynamic>);
      final content = data['content'] as List<dynamic>;

      return content
          .map((json) => RouteModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiExceptionFactory.fromException(e);
    }
  }

  /// 收藏路线
  static Future<bool> favoriteRoute(
    String routeId, {
    String userId = 'current_user',
  }) async {
    try {
      final response = await ApiClient.instance.post(
        ApiEndpoints.favoriteRoute(routeId),
        queryParameters: {'userId': userId},
      );

      unwrapResponse(response.data as Map<String, dynamic>);

      return true;
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiExceptionFactory.fromException(e);
    }
  }

  /// 取消收藏路线
  static Future<bool> unfavoriteRoute(
    String routeId, {
    String userId = 'current_user',
  }) async {
    try {
      final response = await ApiClient.instance.delete(
        ApiEndpoints.favoriteRoute(routeId),
        queryParameters: {'userId': userId},
      );

      unwrapResponse(response.data as Map<String, dynamic>);

      return true;
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiExceptionFactory.fromException(e);
    }
  }

  /// 检查路线是否已收藏
  ///
  /// 注意：后端没有独立的"检查收藏状态"端点，收藏状态是随
  /// `GET /api/v1/routes/{id}?userId=` 一并返回的 `is_favorite` 字段，
  /// 因此这里通过拉取路线详情来获取该状态。
  static Future<bool> checkIfFavorite(
    String routeId, {
    String userId = 'current_user',
  }) async {
    try {
      final response = await ApiClient.instance.get(
        ApiEndpoints.routeDetail(routeId),
        queryParameters: {'userId': userId},
      );

      final routeData = unwrapResponse(response.data as Map<String, dynamic>);
      return RouteModel.fromJson(routeData).isFavorite;
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiExceptionFactory.fromException(e);
    }
  }

  /// 添加收藏
  static Future<bool> addFavorite(String routeId) async {
    return favoriteRoute(routeId);
  }

  /// 移除收藏
  static Future<bool> removeFavorite(String routeId) async {
    return unfavoriteRoute(routeId);
  }

  /// 创建路线
  static Future<RouteModel> createRoute(RouteModel route) async {
    try {
      final response = await ApiClient.instance.post(
        ApiEndpoints.routes,
        data: route.toJson(),
      );
      final data = unwrapResponse(response.data as Map<String, dynamic>);
      return RouteModel.fromJson(data);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiExceptionFactory.fromException(e);
    }
  }

  /// 更新路线
  static Future<RouteModel> updateRoute(RouteModel route) async {
    try {
      final response = await ApiClient.instance.put(
        ApiEndpoints.routeDetail(route.id),
        data: route.toJson(),
      );
      final data = unwrapResponse(response.data as Map<String, dynamic>);
      return RouteModel.fromJson(data);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiExceptionFactory.fromException(e);
    }
  }

  /// 删除路线
  static Future<bool> deleteRoute(String routeId) async {
    try {
      final response = await ApiClient.instance.delete(
        ApiEndpoints.routeDetail(routeId),
      );
      unwrapResponse(response.data as Map<String, dynamic>);
      return true;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiExceptionFactory.fromException(e);
    }
  }

}
