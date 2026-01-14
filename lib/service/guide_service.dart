import 'package:flutter/foundation.dart';
import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../core/network/api_exception.dart';
import '../model/guide/guide_model.dart';
import '../model/route/route_model.dart';
import '../model/trip/trip_model.dart';
import '../model/equipment/equipment_list_model.dart';
import '../model/user/user_model.dart';
import 'route_service.dart';
import 'trip_service.dart';
import 'equipment_service.dart';
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
      final responseData = response.data as Map<String, dynamic>;

      if (responseData['code'] != 200) {
        throw BusinessException(
          responseData['message'] ?? '获取攻略详情失败',
          code: responseData['code']?.toString(),
        );
      }

      final guideData = responseData['data'] as Map<String, dynamic>;
      return GuideModel.fromJson(guideData);
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiExceptionFactory.fromException(e as Exception);
    }
  }

  /// 获取包含完整关联数据的攻略详情
  static Future<GuideModel> getGuideWithDetails(String guideId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 600));

    // 1. 获取基础攻略数据
    final guide = await getGuideById(guideId);

    // 2. 并行加载关联数据
    final futures = await Future.wait([
      _loadBaseRoute(guide.baseRouteId),
      _loadBaseTrip(guide.baseTripId),
      _loadEquipmentList(guide.equipmentListId),
      _loadAuthorProfile(guide.authorId),
      _loadRelatedGuides(guide.relatedGuideIds),
    ]);

    // 3. 组装完整数据
    return guide.copyWith(
      baseRoute: futures[0] as RouteModel?,
      baseTrip: futures[1] as TripModel?,
      equipmentList: futures[2] as EquipmentListModel?,
      authorProfile: futures[3] as UserModel?,
      relatedGuides: futures[4] as List<GuideModel>?,
    );
  }

  /// 加载基础路线数据
  static Future<RouteModel?> _loadBaseRoute(String? routeId) async {
    if (routeId == null || routeId.isEmpty) return null;

    try {
      return await RouteService.getRouteById(routeId);
    } catch (e) {
      print('加载路线数据失败: $e');
      return null;
    }
  }

  /// 加载基础行程数据
  static Future<TripModel?> _loadBaseTrip(String? tripId) async {
    if (tripId == null || tripId.isEmpty) return null;

    try {
      return await TripService.getTripById(tripId);
    } catch (e) {
      print('加载行程数据失败: $e');
      return null;
    }
  }

  /// 加载装备清单数据
  static Future<EquipmentListModel?> _loadEquipmentList(
      String? equipmentListId) async {
    if (equipmentListId == null || equipmentListId.isEmpty) return null;

    try {
      return await EquipmentService.getEquipmentListById(equipmentListId);
    } catch (e) {
      print('加载装备清单数据失败: $e');
      return null;
    }
  }

  /// 加载作者详细信息
  static Future<UserModel?> _loadAuthorProfile(String authorId) async {
    try {
      return await UserService.getCurrentUser();
    } catch (e) {
      print('加载作者信息失败: $e');
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
      print('加载相关攻略失败: $e');
      return null;
    }
  }

  /// 获取热门攻略
  static Future<List<GuideModel>> getPopularGuides({int? limit}) async {
    try {
      final response = await ApiClient.instance.get(
        ApiEndpoints.popularGuides,
        queryParameters: {
          if (limit != null) 'limit': limit,
        },
      );
      return _parseGuidesResponse(response.data);
    } catch (e) {
      debugPrint('GuideService: 获取热门攻略失败: $e');
      return [];
    }
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

  /// 获取用户收藏的攻略
  static Future<List<GuideModel>> getFavoriteGuides() async {
    try {
      final response = await ApiClient.instance.get(
        ApiEndpoints.guides,
        queryParameters: {'filter': 'favorites'},
      );
      return _parseGuidesResponse(response.data);
    } catch (e) {
      debugPrint('GuideService: 获取收藏攻略失败: $e');
      return [];
    }
  }

  /// 点赞攻略
  static Future<GuideModel> likeGuide(String guideId) async {
    try {
      await ApiClient.instance.post(
        ApiEndpoints.guideDetail(guideId),
        data: {'action': 'like'},
      );
      return await getGuideById(guideId);
    } catch (e) {
      debugPrint('GuideService: 点赞攻略失败: $e');
      rethrow;
    }
  }

  /// 取消点赞攻略
  static Future<GuideModel> unlikeGuide(String guideId) async {
    try {
      await ApiClient.instance.post(
        ApiEndpoints.guideDetail(guideId),
        data: {'action': 'unlike'},
      );
      return await getGuideById(guideId);
    } catch (e) {
      debugPrint('GuideService: 取消点赞攻略失败: $e');
      rethrow;
    }
  }

  /// 收藏攻略
  static Future<bool> favoriteGuide(String guideId) async {
    try {
      await ApiClient.instance.post(
        ApiEndpoints.guideDetail(guideId),
        data: {'action': 'favorite'},
      );
      return true;
    } catch (e) {
      debugPrint('GuideService: 收藏攻略失败: $e');
      return false;
    }
  }

  /// 取消收藏攻略
  static Future<bool> unfavoriteGuide(String guideId) async {
    try {
      await ApiClient.instance.delete(
        ApiEndpoints.guideDetail(guideId),
        data: {'action': 'unfavorite'},
      );
      return true;
    } catch (e) {
      debugPrint('GuideService: 取消收藏攻略失败: $e');
      return false;
    }
  }

  /// 创建攻略
  static Future<GuideModel> createGuide(GuideModel guide) async {
    try {
      final response = await ApiClient.instance.post(
        ApiEndpoints.guides,
        data: guide.toJson(),
      );
      final responseData = response.data as Map<String, dynamic>;

      if (responseData['code'] != 200) {
        throw BusinessException(
          responseData['message'] ?? '创建攻略失败',
          code: responseData['code']?.toString(),
        );
      }

      final guideData = responseData['data'] as Map<String, dynamic>;
      return GuideModel.fromJson(guideData);
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiExceptionFactory.fromException(e as Exception);
    }
  }

  /// 更新攻略
  static Future<GuideModel> updateGuide(GuideModel guide) async {
    try {
      final response = await ApiClient.instance.put(
        ApiEndpoints.guideDetail(guide.id),
        data: guide.toJson(),
      );
      final responseData = response.data as Map<String, dynamic>;

      if (responseData['code'] != 200) {
        throw BusinessException(
          responseData['message'] ?? '更新攻略失败',
          code: responseData['code']?.toString(),
        );
      }

      final guideData = responseData['data'] as Map<String, dynamic>;
      return GuideModel.fromJson(guideData);
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiExceptionFactory.fromException(e as Exception);
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
    try {
      final response = await ApiClient.instance.get(
        ApiEndpoints.guideCategories,
      );
      final responseData = response.data as Map<String, dynamic>;

      if (responseData['code'] != 200) {
        return [];
      }

      final categories = responseData['data'] as List<dynamic>;
      return List<String>.from(categories);
    } catch (e) {
      debugPrint('GuideService: 获取攻略分类失败: $e');
      return [];
    }
  }

  /// 解析攻略响应数据的通用方法
  static List<GuideModel> _parseGuidesResponse(dynamic responseData) {
    final data = responseData as Map<String, dynamic>;

    if (data['code'] != 200) {
      throw BusinessException(
        data['message'] ?? '获取攻略数据失败',
        code: data['code']?.toString(),
      );
    }

    final guidesData = data['data'] as Map<String, dynamic>;
    final content = guidesData['content'] as List<dynamic>;
    debugPrint('GuideService: 成功解析攻略数据，共 ${content.length} 条');

    return content.map((json) => GuideModel.fromJson(json)).toList();
  }
}
