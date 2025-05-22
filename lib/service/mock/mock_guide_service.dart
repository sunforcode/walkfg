import 'dart:convert';
import 'package:flutter/services.dart';
import '../guide_service.dart';
import '../../model/guide/guide_model.dart';

/// Mock攻略服务实现
class MockGuideService implements GuideService {
  /// 单例实例
  static final MockGuideService _instance = MockGuideService._internal();

  /// 工厂构造函数
  factory MockGuideService() {
    return _instance;
  }

  /// 私有构造函数
  MockGuideService._internal();

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
  Future<List<GuideModel>> getGuides({String? tag, int? limit}) async {
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

  @override
  Future<GuideModel> getGuideById(String guideId) async {
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

  @override
  Future<List<GuideModel>> getPopularGuides({int? limit}) async {
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

  @override
  Future<List<GuideModel>> getLatestGuides({int? limit}) async {
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

  @override
  Future<List<GuideModel>> getFavoriteGuides() async {
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

  @override
  Future<GuideModel> likeGuide(String guideId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 获取攻略详情
    final guide = await getGuideById(guideId);

    // 更新点赞状态
    return guide.copyWith(isLiked: true);
  }

  @override
  Future<GuideModel> unlikeGuide(String guideId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 获取攻略详情
    final guide = await getGuideById(guideId);

    // 更新点赞状态
    return guide.copyWith(isLiked: false);
  }

  @override
  Future<bool> favoriteGuide(String guideId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 模拟收藏成功
    return true;
  }

  @override
  Future<bool> unfavoriteGuide(String guideId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 模拟取消收藏成功
    return true;
  }

  @override
  Future<GuideModel> createGuide(GuideModel guide) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 模拟创建成功，返回带有ID的对象
    final now = DateTime.now();
    return GuideModel(
      id: 'guide_${now.millisecondsSinceEpoch}',
      title: guide.title,
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

  @override
  Future<GuideModel> updateGuide(GuideModel guide) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 模拟更新成功，返回更新后的对象
    final now = DateTime.now();
    return GuideModel(
      id: guide.id,
      title: guide.title,
      content: guide.content,
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

  @override
  Future<bool> deleteGuide(String guideId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 模拟删除成功
    return true;
  }

  @override
  Future<List<String>> getGuideCategories() async {
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
