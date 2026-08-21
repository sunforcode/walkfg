import 'package:flutter/foundation.dart';
import 'package:walk/core/network/response_unwrap.dart';
import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../core/network/api_exception.dart';
import '../model/guide/guide_model.dart';
import '../model/route/route_model.dart';
import '../model/trip/trip_model.dart';
import '../model/user/user_model.dart';
import 'route_service.dart';
import 'trip_service.dart';
import 'user_service.dart';

/// 攻略服务
///
/// 使用静态方法，无需实例化
class GuideService {
  // 禁止实例化
  GuideService._();


  /// 获取攻略列表
  static Future<List<GuideModel>> getGuides({String? tag, int? limit}) async {
    try {
      final response = await ApiClient.instance.get(
        ApiEndpoints.guides,
        queryParameters: {
          if (tag != null) 'tag': tag,
          if (limit != null) 'limit': limit,
        },
      );
      return _parseGuidesResponse(response.data);
    } catch (e) {
      debugPrint('GuideService: 获取攻略列表失败: $e');
      return [];
    }
  }

  /// 获取攻略详情
  static Future<GuideModel> getGuideById(String guideId) async {
    try {
      final response = await ApiClient.instance.get(
        ApiEndpoints.guideDetail(guideId),
      );
      final guideData = unwrapResponse(response.data as Map<String, dynamic>);
      return GuideModel.fromJson(guideData);
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiExceptionFactory.fromException(e);
    }
  }

  /// 获取包含完整关联数据的攻略详情
  static Future<GuideModel> getGuideWithDetails(String guideId) async {
    // 1. 获取基础攻略数据
    final guide = await getGuideById(guideId);

    // 2. 并行加载关联数据
    final futures = await Future.wait([
      _loadBaseRoute(guide.baseRouteId),
      _loadBaseTrip(guide.baseTripId),
      _loadAuthorProfile(guide.authorId),
      _loadRelatedGuides(guide.relatedGuideIds),
    ]);

    // 3. 组装完整数据
    return guide.copyWith(
      baseRoute: futures[0] as RouteModel?,
      baseTrip: futures[1] as TripModel?,
      authorProfile: futures[2] as UserModel?,
      relatedGuides: futures[3] as List<GuideModel>?,
    );
  }

  /// 加载基础路线数据
  static Future<RouteModel?> _loadBaseRoute(String? routeId) async {
    if (routeId == null || routeId.isEmpty) return null;

    try {
      return await RouteService.getRouteById(routeId);
    } catch (e) {
      debugPrint('加载路线数据失败: $e');
      return null;
    }
  }

  /// 加载基础行程数据
  static Future<TripModel?> _loadBaseTrip(String? tripId) async {
    if (tripId == null || tripId.isEmpty) return null;

    try {
      return await TripService.getTripById(tripId);
    } catch (e) {
      debugPrint('加载行程数据失败: $e');
      return null;
    }
  }

  /// 加载作者详细信息
  static Future<UserModel?> _loadAuthorProfile(String authorId) async {
    try {
      return await UserService.getCurrentUser();
    } catch (e) {
      debugPrint('加载作者信息失败: $e');
      return null;
    }
  }

  /// 加载相关攻略列表
  static Future<List<GuideModel>?> _loadRelatedGuides(
      List<String> relatedGuideIds) async {
    if (relatedGuideIds.isEmpty) return null;

    try {
      final futures = relatedGuideIds.map((id) => getGuideById(id));
      final guides = await Future.wait(futures);
      return guides;
    } catch (e) {
      debugPrint('加载相关攻略失败: $e');
      return null;
    }
  }

  /// 获取热门攻略
  static Future<List<GuideModel>> getPopularGuides({int? limit}) async {
    // 后端无独立 /popular 端点，使用 getGuides 替代
    return getGuides(limit: limit);
  }

  /// 获取最新攻略
  static Future<List<GuideModel>> getLatestGuides({int? limit}) async {
    try {
      final response = await ApiClient.instance.get(
        ApiEndpoints.guides,
        queryParameters: {
          'sort': 'latest',
          if (limit != null) 'limit': limit,
        },
      );
      return _parseGuidesResponse(response.data);
    } catch (e) {
      debugPrint('GuideService: 获取最新攻略失败: $e');
      return [];
    }
  }

  /// 点赞攻略
  ///
  /// 对应后端 `POST /api/v1/guides/{id}/like`
  static Future<GuideModel> likeGuide(String guideId) async {
    try {
      final response = await ApiClient.instance.post(
        ApiEndpoints.guideLike(guideId),
      );
      final guideData = unwrapResponse(response.data as Map<String, dynamic>);
      return GuideModel.fromJson(guideData);
    } catch (e) {
      debugPrint('GuideService: 点赞攻略失败: $e');
      rethrow;
    }
  }

  /// 取消点赞攻略
  ///
  /// 对应后端 `POST /api/v1/guides/{id}/unlike`
  static Future<GuideModel> unlikeGuide(String guideId) async {
    try {
      final response = await ApiClient.instance.post(
        ApiEndpoints.guideUnlike(guideId),
      );
      final guideData = unwrapResponse(response.data as Map<String, dynamic>);
      return GuideModel.fromJson(guideData);
    } catch (e) {
      debugPrint('GuideService: 取消点赞攻略失败: $e');
      rethrow;
    }
  }

  /// 创建攻略
  static Future<GuideModel> createGuide(GuideModel guide) async {
    try {
      final response = await ApiClient.instance.post(
        ApiEndpoints.guides,
        data: guide.toJson(),
      );
      final guideData = unwrapResponse(response.data as Map<String, dynamic>);
      return GuideModel.fromJson(guideData);
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiExceptionFactory.fromException(e);
    }
  }

  /// 更新攻略
  static Future<GuideModel> updateGuide(GuideModel guide) async {
    try {
      final response = await ApiClient.instance.put(
        ApiEndpoints.guideDetail(guide.id),
        data: guide.toJson(),
      );
      final guideData = unwrapResponse(response.data as Map<String, dynamic>);
      return GuideModel.fromJson(guideData);
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiExceptionFactory.fromException(e);
    }
  }

  /// 删除攻略
  static Future<bool> deleteGuide(String guideId) async {
    try {
      await ApiClient.instance.delete(
        ApiEndpoints.guideDetail(guideId),
      );
      return true;
    } catch (e) {
      debugPrint('GuideService: 删除攻略失败: $e');
      return false;
    }
  }

  /// 获取攻略分类
  static Future<List<String>> getGuideCategories() async {
    // 后端无独立分类端点，攻略使用 tag 进行分类
    return ['徒步', '露营', '登山', '穿越', '骑行', '攀岩'];
  }

  /// 解析攻略响应数据的通用方法
  static List<GuideModel> _parseGuidesResponse(dynamic responseData) {
    final guidesData = unwrapResponse(responseData as Map<String, dynamic>);
    final content = guidesData['content'] as List<dynamic>? ?? [];

    return content.map((json) => GuideModel.fromJson(json)).toList();
  }
}
