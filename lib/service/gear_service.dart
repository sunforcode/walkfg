import '../model/equipment/gear_recommendation_model.dart';
import '../model/equipment/gear_detail_model.dart';
import '../model/equipment/gear_purchase_model.dart';
import '../model/equipment/gear_rental_model.dart';

/// 装备服务接口
abstract class GearService {
  /// 获取路线装备推荐
  Future<GearRecommendationModel> getRouteGearRecommendations(String routeId);

  /// 获取装备详情
  Future<GearDetailModel> getGearDetail(String gearId);

  /// 获取装备类别列表
  Future<List<String>> getGearCategories();

  /// 根据类别获取装备列表
  Future<List<GearItemModel>> getGearsByCategory(String category);

  /// 搜索装备
  Future<List<GearItemModel>> searchGears(String keyword);

  /// 获取装备购买选项
  Future<GearPurchaseOptionsModel> getGearPurchaseOptions(String gearId);

  /// 获取装备租赁选项
  Future<List<GearRentalOptionModel>> getGearRentalOptions(String gearId, {String? location});
}
