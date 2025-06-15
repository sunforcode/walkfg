import 'package:walk/core/network/api_client.dart';
import 'package:walk/core/network/api_endpoints.dart';
import 'package:walk/core/network/api_exception.dart';
import 'package:walk/model/route/route_model.dart';
import 'package:walk/model/route/route_comment_model.dart';
import 'package:walk/model/trip/trip_filter_model.dart';
import 'package:walk/model/route/route_enums.dart';
import '../route_service.dart';

/// 真实的路线服务实现
///
/// 连接到实际的后台API服务
class RealRouteService implements RouteService {
  final ApiClient _apiClient;

  RealRouteService(this._apiClient);

  @override
  Future<List<RouteModel>> getRoutes({String? season, int? limit}) async {
    try {
      final response = await _apiClient.get(
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
      throw ApiExceptionFactory.fromException(e as Exception);
    }
  }

  @override
  Future<RouteModel> getRouteById(String routeId) async {
    try {
      final response = await _apiClient.get(
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
      throw ApiExceptionFactory.fromException(e as Exception);
    }
  }

  @override
  Future<RouteModel> getRouteDetail(String routeId) async {
    return getRouteById(routeId);
  }

  @override
  Future<List<RouteModel>> searchRoutes(String keyword,
      {int limit = 20}) async {
    try {
      final response = await _apiClient.get(
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
      throw ApiExceptionFactory.fromException(e as Exception);
    }
  }

  @override
  Future<List<RouteModel>> getPopularRoutes({int limit = 10}) async {
    print("开始请求");
    try {
      final response = await _apiClient.get(
        ApiEndpoints.routes,
        queryParameters: {'limit': limit},
      );
      return _parseRoutesResponse(response.data);
    } catch (e) {
      print("请求失败#{e}");
      print(e);
      if (e is ApiException) {
        rethrow;
      }
      throw ApiExceptionFactory.fromException(e as Exception);
    }
  }

  @override
  Future<List<RouteModel>> getSeasonalRoutes({int limit = 10}) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.seasonalRoutes,
        queryParameters: {'limit': limit},
      );

      return _parseRoutesResponse(response.data);
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiExceptionFactory.fromException(e as Exception);
    }
  }

  @override
  Future<List<RouteModel>> getNewRoutes({int limit = 10}) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.newRoutes,
        queryParameters: {'limit': limit},
      );

      return _parseRoutesResponse(response.data);
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiExceptionFactory.fromException(e as Exception);
    }
  }

  @override
  Future<List<RouteModel>> getWeekendRoutes({int limit = 10}) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.weekendRoutes,
        queryParameters: {'limit': limit},
      );

      return _parseRoutesResponse(response.data);
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiExceptionFactory.fromException(e as Exception);
    }
  }

  @override
  Future<List<RouteModel>> getRecommendedRoutes({int limit = 10}) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.recommendedRoutes,
        queryParameters: {'limit': limit},
      );

      return _parseRoutesResponse(response.data);
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiExceptionFactory.fromException(e as Exception);
    }
  }

  /// 解析路线响应数据的通用方法
  List<RouteModel> _parseRoutesResponse(dynamic responseData) {
    final data = responseData as Map<String, dynamic>;

    if (data['code'] != 200) {
      throw BusinessException(
        data['message'] ?? '获取路线数据失败',
        code: data['code']?.toString(),
      );
    }

    final routesData = data['data'] as Map<String, dynamic>;
    final content = routesData['content'] as List<dynamic>;
    print("获取路线数据失败");
    print(content);
    content[0]['created_at'] = '2024-01-15T08:00:00.000Z';
    content[0]['region_id'] = '2024-01-15T08:00:00.000Z';

    return content.map((json) => RouteModel.fromJson(json)).toList();
  }

  // 以下是其他接口的基础实现，可以根据实际API进行调整

  @override
  Future<Map<String, dynamic>> getRouteRatings(String routeId) async {
    // TODO: 实现获取路线评分的API调用
    throw UnimplementedError('getRouteRatings not implemented yet');
  }

  @override
  Future<List<String>> getRouteTags(String routeId) async {
    // TODO: 实现获取路线标签的API调用
    throw UnimplementedError('getRouteTags not implemented yet');
  }

  @override
  Future<Map<String, dynamic>> getRouteWaypoints(String routeId) async {
    // TODO: 实现获取路线关键点的API调用
    throw UnimplementedError('getRouteWaypoints not implemented yet');
  }

  @override
  Future<List<RouteModel>> getRoutesByRegion(String region,
      {int limit = 20}) async {
    // TODO: 实现按地区获取路线的API调用
    throw UnimplementedError('getRoutesByRegion not implemented yet');
  }

  @override
  Future<List<RouteModel>> getRoutesByDifficulty(RouteDifficulty difficulty,
      {int limit = 20}) async {
    // TODO: 实现按难度获取路线的API调用
    throw UnimplementedError('getRoutesByDifficulty not implemented yet');
  }

  @override
  Future<List<RouteModel>> getRoutesByDuration(int minDays, int maxDays,
      {int limit = 20}) async {
    // TODO: 实现按持续时间获取路线的API调用
    throw UnimplementedError('getRoutesByDuration not implemented yet');
  }

  @override
  Future<List<RouteModel>> getRoutesByFilter(TripFilterModel filter,
      {int limit = 20}) async {
    // TODO: 实现按筛选条件获取路线的API调用
    throw UnimplementedError('getRoutesByFilter not implemented yet');
  }

  @override
  Future<List<RouteModel>> getFavoriteRoutes() async {
    // TODO: 实现获取收藏路线的API调用
    throw UnimplementedError('getFavoriteRoutes not implemented yet');
  }

  @override
  Future<bool> favoriteRoute(String routeId) async {
    // TODO: 实现收藏路线的API调用
    throw UnimplementedError('favoriteRoute not implemented yet');
  }

  @override
  Future<bool> unfavoriteRoute(String routeId) async {
    // TODO: 实现取消收藏路线的API调用
    throw UnimplementedError('unfavoriteRoute not implemented yet');
  }

  @override
  Future<bool> checkIfFavorite(String routeId) async {
    // TODO: 实现检查路线是否已收藏的API调用
    throw UnimplementedError('checkIfFavorite not implemented yet');
  }

  @override
  Future<bool> addFavorite(String routeId) async {
    return favoriteRoute(routeId);
  }

  @override
  Future<bool> removeFavorite(String routeId) async {
    return unfavoriteRoute(routeId);
  }

  @override
  Future<List<RouteModel>> getPlannedRoutes() async {
    // TODO: 实现获取计划路线的API调用
    throw UnimplementedError('getPlannedRoutes not implemented yet');
  }

  @override
  Future<List<RouteModel>> getCompletedRoutes() async {
    // TODO: 实现获取已完成路线的API调用
    throw UnimplementedError('getCompletedRoutes not implemented yet');
  }

  @override
  Future<List<RouteCommentModel>> getRouteComments(String routeId) async {
    // TODO: 实现获取路线评论的API调用
    throw UnimplementedError('getRouteComments not implemented yet');
  }

  @override
  Future<RouteCommentModel> addRouteComment(
      String routeId, String content, double rating) async {
    // TODO: 实现添加路线评论的API调用
    throw UnimplementedError('addRouteComment not implemented yet');
  }

  @override
  Future<RouteModel> createRoute(RouteModel route) async {
    // TODO: 实现创建路线的API调用
    throw UnimplementedError('createRoute not implemented yet');
  }

  @override
  Future<RouteModel> updateRoute(RouteModel route) async {
    // TODO: 实现更新路线的API调用
    throw UnimplementedError('updateRoute not implemented yet');
  }

  @override
  Future<bool> deleteRoute(String routeId) async {
    // TODO: 实现删除路线的API调用
    throw UnimplementedError('deleteRoute not implemented yet');
  }

  @override
  Future<List<RouteModel>> getRelatedRoutes(String routeId,
      {int limit = 5}) async {
    // TODO: 实现获取相关路线的API调用
    throw UnimplementedError('getRelatedRoutes not implemented yet');
  }
}
