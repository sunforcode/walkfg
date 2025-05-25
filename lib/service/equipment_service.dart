import 'package:walk/model/equipment/equipment_category.dart';

import '../model/equipment/equipment_list_model.dart';
import '../model/equipment/equipment_item_model.dart';

/// 装备服务接口
abstract class EquipmentService {
  /// 获取装备清单列表
  Future<List<EquipmentListModel>> getEquipmentLists();

  /// 根据ID获取装备清单
  Future<EquipmentListModel> getEquipmentListById(String id);

  /// 获取推荐装备清单
  Future<List<EquipmentListModel>> getRecommendedEquipmentLists({int limit = 10});

  /// 获取官方装备清单
  Future<List<EquipmentListModel>> getOfficialEquipmentLists({int limit = 10});

  /// 获取用户创建的装备清单
  Future<List<EquipmentListModel>> getUserEquipmentLists({int limit = 10});

  /// 根据季节获取装备清单
  Future<List<EquipmentListModel>> getEquipmentListsBySeason(List<SeasonSuitability> seasons, {int limit = 10});

  /// 根据行程天数获取装备清单
  Future<List<EquipmentListModel>> getEquipmentListsByTripDays(int minDays, int maxDays, {int limit = 10});

  /// 搜索装备清单
  Future<List<EquipmentListModel>> searchEquipmentLists(String keyword, {int limit = 10});

  /// 创建装备清单
  Future<EquipmentListModel> createEquipmentList(EquipmentListModel equipmentList);

  /// 更新装备清单
  Future<EquipmentListModel> updateEquipmentList(EquipmentListModel equipmentList);

  /// 删除装备清单
  Future<bool> deleteEquipmentList(String id);

  /// 添加装备项目到装备清单
  Future<EquipmentListModel> addEquipmentItem(String equipmentListId, EquipmentItemModel item);

  /// 更新装备清单中的装备项目
  Future<EquipmentListModel> updateEquipmentItem(String equipmentListId, EquipmentItemModel item);

  /// 从装备清单中删除装备项目
  Future<EquipmentListModel> removeEquipmentItem(String equipmentListId, String itemId);

  /// 获取装备项目列表
  Future<List<EquipmentItemModel>> getEquipmentItems(String equipmentListId);

  /// 获取装备项目详情
  Future<EquipmentItemModel> getEquipmentItemById(String equipmentListId, String itemId);

  /// 获取装备分类列表
  Future<List<EquipmentCategory>> getEquipmentCategories();

  /// 复制装备清单
  Future<EquipmentListModel> cloneEquipmentList(String equipmentListId, {String? newName});

}