import '../model/guide/guide_model.dart';

/// 攻略服务接口
abstract class GuideService {
  /// 获取攻略列表
  Future<List<GuideModel>> getGuides({String? tag, int? limit});

  /// 获取攻略详情
  Future<GuideModel> getGuideById(String guideId);

  /// 获取包含完整关联数据的攻略详情
  Future<GuideModel> getGuideWithDetails(String guideId);

  /// 获取热门攻略
  Future<List<GuideModel>> getPopularGuides({int? limit});

  /// 获取最新攻略
  Future<List<GuideModel>> getLatestGuides({int? limit});

  /// 获取用户收藏的攻略
  Future<List<GuideModel>> getFavoriteGuides();

  /// 点赞攻略
  Future<GuideModel> likeGuide(String guideId);

  /// 取消点赞攻略
  Future<GuideModel> unlikeGuide(String guideId);

  /// 收藏攻略
  Future<bool> favoriteGuide(String guideId);

  /// 取消收藏攻略
  Future<bool> unfavoriteGuide(String guideId);

  /// 创建攻略
  Future<GuideModel> createGuide(GuideModel guide);

  /// 更新攻略
  Future<GuideModel> updateGuide(GuideModel guide);

  /// 删除攻略
  Future<bool> deleteGuide(String guideId);

  /// 获取攻略分类
  Future<List<String>> getGuideCategories();
}
