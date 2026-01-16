import 'package:flutter/foundation.dart';
import 'package:walk/core/network/api_client.dart';
import 'package:walk/core/network/api_endpoints.dart';
import 'package:walk/core/network/api_exception.dart';
import 'package:walk/model/route/route_model.dart';
import 'package:walk/model/route/route_comment_model.dart';
import 'package:walk/model/trip/trip_filter_model.dart';
import 'package:walk/model/route/route_enums.dart';

/// 路线服务
///
/// 使用静态方法，无需实例化
class RouteService {
  // 禁止实例化
  RouteService._();

  /// 默认缓存时间
  static const Duration _defaultCacheTTL = Duration(hours: 1);

  /// 获取路线列表
  static Future<List<RouteModel>> getRoutes({String? season, int? limit}) async {
    try {
      final response = await ApiClient.instance.get(
        ApiEndpoints.routes,
        queryParameters: {
          if (season != null) 'season': season,
          if (limit != null) 'limit': limit,
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
  static Future<List<RouteModel>> getRoutesByFilter(TripFilterModel filter,
      {int limit = 20}) async {
    // TODO: 实现按筛选条件获取路线的API调用
    throw UnimplementedError('getRoutesByFilter not implemented yet');
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
