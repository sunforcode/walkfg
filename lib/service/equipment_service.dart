import 'package:walk/model/equipment/equipment_category.dart';
import 'package:walk/model/equipment/equipment_list_type.dart';
import 'package:walk/model/equipment/equipment_list_status.dart';
import 'package:walk/model/equipment/equipment_template_model.dart';
import 'package:walk/model/equipment/user_equipment_inventory_model.dart';

import '../model/equipment/equipment_list_model.dart';
import '../model/equipment/equipment_item_model.dart';

/// 装备服务接口
abstract class EquipmentService {
  /// 获取装备清单列表
  Future<List<EquipmentListModel>> getEquipmentLists();

  /// 根据ID获取装备清单
  Future<EquipmentListModel> getEquipmentListById(String id);

  /// 获取推荐装备清单
  Future<List<EquipmentListModel>> getRecommendedEquipmentLists(
      {int limit = 10});

  /// 获取官方装备清单
  Future<List<EquipmentListModel>> getOfficialEquipmentLists({int limit = 10});

  /// 获取用户创建的装备清单
  Future<List<EquipmentListModel>> getUserEquipmentLists({int limit = 10});

  /// 根据季节获取装备清单
  Future<List<EquipmentListModel>> getEquipmentListsBySeason(
      List<SeasonSuitability> seasons,
      {int limit = 10});

  /// 根据行程天数获取装备清单
  Future<List<EquipmentListModel>> getEquipmentListsByTripDays(
      int minDays, int maxDays,
      {int limit = 10});

  /// 搜索装备清单
  Future<List<EquipmentListModel>> searchEquipmentLists(String keyword,
      {int limit = 10});

  /// 创建装备清单
  Future<EquipmentListModel> createEquipmentList(
      EquipmentListModel equipmentList);

  /// 更新装备清单
  Future<EquipmentListModel> updateEquipmentList(
      EquipmentListModel equipmentList);

  /// 删除装备清单
  Future<bool> deleteEquipmentList(String id);

  /// 添加装备项目到装备清单
  Future<EquipmentListModel> addEquipmentItem(
      String equipmentListId, EquipmentItemModel item);

  /// 更新装备清单中的装备项目
  Future<EquipmentListModel> updateEquipmentItem(
      String equipmentListId, EquipmentItemModel item);

  /// 从装备清单中删除装备项目
  Future<EquipmentListModel> removeEquipmentItem(
      String equipmentListId, String itemId);

  /// 获取装备项目列表
  Future<List<EquipmentItemModel>> getEquipmentItems(String equipmentListId);

  /// 获取装备项目详情
  Future<EquipmentItemModel> getEquipmentItemById(
      String equipmentListId, String itemId);

  /// 获取装备分类列表
  Future<List<EquipmentCategory>> getEquipmentCategories();

  /// 复制装备清单
  Future<EquipmentListModel> cloneEquipmentList(String equipmentListId,
      {String? newName});

  /// 根据类型获取装备清单
  Future<List<EquipmentListModel>> getEquipmentListsByType(
      EquipmentListType type,
      {int limit = 10});

  /// 根据状态获取装备清单
  Future<List<EquipmentListModel>> getEquipmentListsByStatus(
      EquipmentListStatus status,
      {int limit = 10});

  /// 获取装备模板列表
  Future<List<EquipmentTemplateModel>> getEquipmentTemplates({int limit = 10});

  /// 根据ID获取装备模板
  Future<EquipmentTemplateModel> getEquipmentTemplateById(String id);

  /// 根据类型获取装备模板
  Future<List<EquipmentTemplateModel>> getEquipmentTemplatesByType(
      EquipmentListType type,
      {int limit = 10});

  /// 创建装备模板
  Future<EquipmentTemplateModel> createEquipmentTemplate(
      EquipmentTemplateModel template);

  /// 更新装备模板
  Future<EquipmentTemplateModel> updateEquipmentTemplate(
      EquipmentTemplateModel template);

  /// 删除装备模板
  Future<bool> deleteEquipmentTemplate(String id);

  /// 从模板创建装备清单
  Future<EquipmentListModel> createEquipmentListFromTemplate(
    String templateId, {
    required String name,
    String? description,
    String? routeId,
    String? routeName,
    String? tripId,
    required int tripDays,
    int personCount = 1,
  });

  /// 获取用户装备库
  Future<UserEquipmentInventoryModel> getUserEquipmentInventory(String userId);

  /// 添加装备到用户装备库
  Future<UserEquipmentInventoryModel> addEquipmentToInventory(
      String userId, EquipmentItemModel item);

  /// 更新用户装备库中的装备
  Future<UserEquipmentInventoryModel> updateEquipmentInInventory(
      String userId, EquipmentItemModel item);

  /// 从用户装备库中删除装备
  Future<UserEquipmentInventoryModel> removeEquipmentFromInventory(
      String userId, String itemId);

  /// 获取用户装备库中的装备
  Future<List<EquipmentItemModel>> getUserEquipmentItems(String userId);

  /// 获取用户装备库中的装备详情
  Future<EquipmentItemModel> getUserEquipmentItemById(
      String userId, String itemId);

  /// 搜索用户装备库
  Future<List<EquipmentItemModel>> searchUserEquipment(
      String userId, String keyword);

  /// 根据分类获取用户装备
  Future<List<EquipmentItemModel>> getUserEquipmentByCategory(
      String userId, EquipmentCategory category);

  /// 获取用户装备分类统计
  Future<List<CategoryDistribution>> getUserEquipmentCategoryDistribution(
      String userId);

  /// 获取用户装备状态统计
  Future<List<ConditionDistribution>> getUserEquipmentConditionDistribution(
      String userId);

  /// 获取需要维护的装备
  Future<List<EquipmentItemModel>> getEquipmentNeedingMaintenance(
      String userId);

  /// 更新装备清单状态
  Future<EquipmentListModel> updateEquipmentListStatus(
      String equipmentListId, EquipmentListStatus status);

  /// 更新装备准备状态
  Future<EquipmentListModel> updateEquipmentPreparedStatus(
      String equipmentListId, String itemId, bool prepared);

  /// 批量更新装备准备状态
  Future<EquipmentListModel> batchUpdateEquipmentPreparedStatus(
      String equipmentListId, List<String> itemIds, bool prepared);

  /// 获取装备清单统计信息
  Future<EquipmentListStats> getEquipmentListStats(String equipmentListId);

  /// 获取装备清单准备进度
  Future<double> getEquipmentListPreparationProgress(String equipmentListId);
}

/// 装备清单统计信息
class EquipmentListStats {
  /// 总装备数
  final int totalItems;

  /// 必需装备数
  final int essentialItems;

  /// 推荐装备数
  final int recommendedItems;

  /// 可选装备数
  final int optionalItems;

  /// 已准备装备数
  final int preparedItems;

  /// 总重量(g)
  final double totalWeight;

  /// 基础重量(g)
  final double baseWeight;

  /// 消耗品重量(g)
  final double consumableWeight;

  /// 穿着重量(g)
  final double wornWeight;

  /// 每人每日平均重量(g)
  final double weightPerPersonPerDay;

  /// 装备总价值(元)
  final double totalValue;

  /// 已拥有装备数量
  final int ownedItems;

  /// 需要购买的装备数量
  final int itemsToBuy;

  /// 需要购买的装备总价值(元)
  final double valueToBuy;

  /// 构造函数
  EquipmentListStats({
    required this.totalItems,
    required this.essentialItems,
    required this.recommendedItems,
    required this.optionalItems,
    required this.preparedItems,
    required this.totalWeight,
    required this.baseWeight,
    required this.consumableWeight,
    required this.wornWeight,
    required this.weightPerPersonPerDay,
    required this.totalValue,
    required this.ownedItems,
    required this.itemsToBuy,
    required this.valueToBuy,
  });
}
