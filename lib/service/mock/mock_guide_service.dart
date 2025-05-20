import 'package:walk/service/guide_service.dart';
import '../../model/guide_model.dart';
import 'json_data_provider.dart';

/// 从JSON文件读取数据的攻略服务实现
class MockGuideService implements GuideService {
  final JsonDataProvider _dataProvider = JsonDataProvider();

  @override
  Future<List<GuideModel>> getGuides({String? tag, int? limit}) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 500));

    var guides = await _dataProvider.getGuides();

    // 按标签筛选
    if (tag != null) {
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
    await Future.delayed(const Duration(milliseconds: 300));

    return _dataProvider.getGuideById(guideId);
  }

  @override
  Future<List<GuideModel>> getPopularGuides({int? limit}) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 500));

    // 按点赞数排序
    var guides = await _dataProvider.getGuides();
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
    await Future.delayed(const Duration(milliseconds: 500));

    // 按发布日期排序
    var guides = await _dataProvider.getGuides();
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
    await Future.delayed(const Duration(milliseconds: 500));

    // 获取所有攻略
    var guides = await _dataProvider.getGuides();

    // 模拟收藏的攻略（随机选择几个）
    guides.shuffle();
    return guides.take(3).toList();
  }

  @override
  Future<GuideModel> likeGuide(String guideId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 300));

    // 获取攻略
    final guide = await getGuideById(guideId);

    // 更新点赞状态
    return guide.copyWith(isLiked: true);
  }

  @override
  Future<GuideModel> unlikeGuide(String guideId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 300));

    // 获取攻略
    final guide = await getGuideById(guideId);

    // 更新点赞状态
    return guide.copyWith(isLiked: false);
  }

  @override
  Future<bool> favoriteGuide(String guideId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 300));

    // 模拟收藏成功
    return true;
  }

  @override
  Future<bool> unfavoriteGuide(String guideId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 300));

    // 模拟取消收藏成功
    return true;
  }

  @override
  Future<GuideModel> createGuide(GuideModel guide) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 800));

    // 模拟创建成功，返回带有ID的对象
    final now = DateTime.now();
    return GuideModel(
      id: 'new_${now.millisecondsSinceEpoch}',
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
    await Future.delayed(const Duration(milliseconds: 500));

    // 模拟更新成功
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
      updateDate: DateTime.now(),
      iconCode: guide.iconCode,
      coverUrl: guide.coverUrl,
      tags: guide.tags,
      isLiked: guide.isLiked,
      createdAt: guide.createdAt,
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<bool> deleteGuide(String guideId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 模拟删除成功
    return true;
  }
}
