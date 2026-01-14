import 'dart:convert';
import 'package:flutter/services.dart';
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
/// 当前使用本地 JSON 数据，后续可改为 API 请求
class GuideService {
  // 禁止实例化
  GuideService._();

  /// 从JSON文件加载数据
  static Future<dynamic> _loadJsonData(String path) async {
    try {
      final String jsonString = await rootBundle.loadString(path);
      return json.decode(jsonString);
    } catch (e) {
      print('加载JSON文件失败: $e');
      return null;
    }
  }

  /// 获取攻略列表
  static Future<List<GuideModel>> getGuides({String? tag, int? limit}) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    final guidesJson = await _loadJsonData('assets/mock_data/guides.json');
    if (guidesJson == null || !(guidesJson is List)) {
      return [];
    }

    List<GuideModel> guides = guidesJson
        .map<GuideModel>((json) => GuideModel.fromJson(json))
        .toList();

    // 根据标签筛选
    if (tag != null && tag.isNotEmpty) {
      guides = guides.where((guide) => guide.tags.contains(tag)).toList();
    }

    // 限制数量
    if (limit != null && guides.length > limit) {
      guides = guides.sublist(0, limit);
    }

    return guides;
  }

  /// 获取攻略详情
  static Future<GuideModel> getGuideById(String guideId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    final guidesJson = await _loadJsonData('assets/mock_data/guides.json');
    if (guidesJson == null || !(guidesJson is List)) {
      throw Exception('Failed to load guides data');
    }

    final guideJson = guidesJson.firstWhere(
      (guide) => guide['id'] == guideId,
      orElse: () => throw Exception('Guide not found: $guideId'),
    );

    return GuideModel.fromJson(guideJson);
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
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    final guidesJson = await _loadJsonData('assets/mock_data/guides.json');
    if (guidesJson == null || !(guidesJson is List)) {
      return [];
    }

    List<GuideModel> guides = guidesJson
        .map<GuideModel>((json) => GuideModel.fromJson(json))
        .toList();

    // 按点赞数排序
    guides.sort((a, b) => b.likes.compareTo(a.likes));

    // 限制数量
    if (limit != null && guides.length > limit) {
      guides = guides.sublist(0, limit);
    }

    return guides;
  }

  /// 获取最新攻略
  static Future<List<GuideModel>> getLatestGuides({int? limit}) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    final guidesJson = await _loadJsonData('assets/mock_data/guides.json');
    if (guidesJson == null || !(guidesJson is List)) {
      return [];
    }

    List<GuideModel> guides = guidesJson
        .map<GuideModel>((json) => GuideModel.fromJson(json))
        .toList();

    // 按发布日期排序
    guides.sort((a, b) => b.publishDate.compareTo(a.publishDate));

    // 限制数量
    if (limit != null && guides.length > limit) {
      guides = guides.sublist(0, limit);
    }

    return guides;
  }

  /// 获取用户收藏的攻略
  static Future<List<GuideModel>> getFavoriteGuides() async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    final guidesJson = await _loadJsonData('assets/mock_data/guides.json');
    if (guidesJson == null || !(guidesJson is List)) {
      return [];
    }

    List<GuideModel> guides = guidesJson
        .map<GuideModel>((json) => GuideModel.fromJson(json))
        .toList();

    // 筛选已点赞的攻略
    guides = guides.where((guide) => guide.isLiked).toList();

    return guides;
  }

  /// 点赞攻略
  static Future<GuideModel> likeGuide(String guideId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 获取攻略详情
    final guide = await getGuideById(guideId);

    // 更新点赞状态
    return guide.copyWith(isLiked: true);
  }

  /// 取消点赞攻略
  static Future<GuideModel> unlikeGuide(String guideId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 获取攻略详情
    final guide = await getGuideById(guideId);

    // 更新点赞状态
    return guide.copyWith(isLiked: false);
  }

  /// 收藏攻略
  static Future<bool> favoriteGuide(String guideId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 模拟收藏成功
    return true;
  }

  /// 取消收藏攻略
  static Future<bool> unfavoriteGuide(String guideId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 模拟取消收藏成功
    return true;
  }

  /// 创建攻略
  static Future<GuideModel> createGuide(GuideModel guide) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 模拟创建成功，返回带有ID的对象
    final now = DateTime.now();
    return GuideModel(
      id: 'guide_${now.millisecondsSinceEpoch}',
      title: guide.title,
      location: "1",
      content: guide.content,
      author: guide.author,
      authorId: guide.authorId,
      authorAvatarUrl: guide.authorAvatarUrl,
      likes: 0,
      views: 0,
      publishDate: now,
      updateDate: now,
      iconCode: guide.iconCode,
      coverUrl: guide.coverUrl,
      tags: guide.tags,
      isLiked: false,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// 更新攻略
  static Future<GuideModel> updateGuide(GuideModel guide) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 模拟更新成功，返回更新后的对象
    final now = DateTime.now();
    return GuideModel(
      id: guide.id,
      title: guide.title,
      content: guide.content,
      location: "1",
      author: guide.author,
      authorId: guide.authorId,
      authorAvatarUrl: guide.authorAvatarUrl,
      likes: guide.likes,
      views: guide.views,
      publishDate: guide.publishDate,
      updateDate: now,
      iconCode: guide.iconCode,
      coverUrl: guide.coverUrl,
      tags: guide.tags,
      isLiked: guide.isLiked,
      createdAt: guide.createdAt,
      updatedAt: now,
    );
  }

  /// 删除攻略
  static Future<bool> deleteGuide(String guideId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 模拟删除成功
    return true;
  }

  /// 获取攻略分类
  static Future<List<String>> getGuideCategories() async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    final categoriesJson =
        await _loadJsonData('assets/mock_data/guide_categories.json');
    if (categoriesJson == null || !(categoriesJson is List)) {
      return [];
    }

    return List<String>.from(categoriesJson);
  }
}
