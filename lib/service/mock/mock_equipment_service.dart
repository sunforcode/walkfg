import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:walk/model/equipment/equipment_category.dart';
import 'package:walk/model/equipment/equipment_list_type.dart';
import 'package:walk/model/equipment/equipment_list_status.dart';
import 'package:walk/model/equipment/equipment_template_model.dart';
import 'package:walk/model/equipment/user_equipment_inventory_model.dart';
import '../equipment_service.dart';
import '../../model/equipment/equipment_list_model.dart';
import '../../model/equipment/equipment_item_model.dart';

/// Mock装备服务实现
class MockEquipmentService implements EquipmentService {
  /// 单例实例
  static final MockEquipmentService _instance =
      MockEquipmentService._internal();

  /// 工厂构造函数
  factory MockEquipmentService() {
    return _instance;
  }

  /// 私有构造函数
  MockEquipmentService._internal();

  /// 装备清单缓存
  List<EquipmentListModel>? _equipmentListsCache;

  /// 装备模板缓存
  List<EquipmentTemplateModel>? _equipmentTemplatesCache;

  /// 用户装备库缓存
  Map<String, UserEquipmentInventoryModel> _userEquipmentInventoryCache = {};

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
  Future<List<EquipmentListModel>> getEquipmentLists() async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 如果有缓存，直接返回
    if (_equipmentListsCache != null) {
      return _equipmentListsCache!;
    }
    // 如果新路径加载失败，尝试旧路径
    final equipmentListsJson =
        await _loadJsonData('assets/mock_data/equipment_lists.json');
    _equipmentListsCache = equipmentListsJson
        .map<EquipmentListModel>((json) => EquipmentListModel.fromJson(json))
        .toList();
    return _equipmentListsCache!;
  }

  @override
  Future<EquipmentListModel> getEquipmentListById(String id) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 确保缓存已加载
    final lists = await getEquipmentLists();

    // 查找指定ID的装备清单
    final equipmentList = lists.firstWhere(
      (list) => list.id == id,
      orElse: () => throw Exception('装备清单不存在: $id'),
    );

    return equipmentList;
  }

  @override
  Future<List<EquipmentListModel>> getRecommendedEquipmentLists(
      {int limit = 10}) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 确保缓存已加载
    final lists = await getEquipmentLists();

    // 随机排序，模拟推荐算法
    final recommendedLists = List<EquipmentListModel>.from(lists)..shuffle();

    // 限制数量
    if (recommendedLists.length > limit) {
      return recommendedLists.sublist(0, limit);
    }

    return recommendedLists;
  }

  @override
  Future<List<EquipmentListModel>> getOfficialEquipmentLists(
      {int limit = 10}) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 确保缓存已加载
    final lists = await getEquipmentLists();

    // 筛选官方装备清单
    final officialLists = lists.where((list) => list.isOfficial).toList();

    // 限制数量
    if (officialLists.length > limit) {
      return officialLists.sublist(0, limit);
    }

    return officialLists;
  }

  @override
  Future<List<EquipmentListModel>> getUserEquipmentLists(
      {int limit = 10}) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 确保缓存已加载
    final lists = await getEquipmentLists();

    // 筛选用户创建的装备清单（非官方的）
    final userLists = lists.where((list) => !list.isOfficial).toList();

    // 限制数量
    if (userLists.length > limit) {
      return userLists.sublist(0, limit);
    }

    return userLists;
  }

  @override
  Future<List<EquipmentListModel>> getEquipmentListsBySeason(
      List<SeasonSuitability> seasons,
      {int limit = 10}) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 确保缓存已加载
    final lists = await getEquipmentLists();

    // 筛选符合季节的装备清单
    final seasonalLists = lists.where((list) {
      return list.seasons.any((season) => seasons.contains(season));
    }).toList();

    // 限制数量
    if (seasonalLists.length > limit) {
      return seasonalLists.sublist(0, limit);
    }

    return seasonalLists;
  }

  @override
  Future<List<EquipmentListModel>> getEquipmentListsByTripDays(
      int minDays, int maxDays,
      {int limit = 10}) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 确保缓存已加载
    final lists = await getEquipmentLists();

    // 筛选符合行程天数的装备清单
    final filteredLists = lists.where((list) {
      return list.tripDays >= minDays && list.tripDays <= maxDays;
    }).toList();

    // 限制数量
    if (filteredLists.length > limit) {
      return filteredLists.sublist(0, limit);
    }

    return filteredLists;
  }

  @override
  Future<List<EquipmentListModel>> searchEquipmentLists(String keyword,
      {int limit = 10}) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 确保缓存已加载
    final lists = await getEquipmentLists();

    // 如果关键词为空，返回所有装备清单
    if (keyword.isEmpty) {
      return lists.length > limit ? lists.sublist(0, limit) : lists;
    }

    // 搜索匹配的装备清单
    final searchResults = lists.where((list) {
      return list.name.toLowerCase().contains(keyword.toLowerCase()) ||
          list.description.toLowerCase().contains(keyword.toLowerCase()) ||
          list.tags
              .any((tag) => tag.toLowerCase().contains(keyword.toLowerCase()));
    }).toList();

    // 限制数量
    if (searchResults.length > limit) {
      return searchResults.sublist(0, limit);
    }

    return searchResults;
  }

  @override
  Future<EquipmentListModel> createEquipmentList(
      EquipmentListModel equipmentList) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 生成新ID
    final now = DateTime.now();
    final newId = 'equipment_${now.millisecondsSinceEpoch}';

    // 创建新装备清单
    final newEquipmentList = equipmentList.copyWith(
      id: newId,
      createdAt: now,
      updatedAt: now,
    );

    // 更新缓存
    if (_equipmentListsCache != null) {
      _equipmentListsCache = [..._equipmentListsCache!, newEquipmentList];
    }

    return newEquipmentList;
  }

  @override
  Future<EquipmentListModel> updateEquipmentList(
      EquipmentListModel equipmentList) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 更新时间戳
    final updatedEquipmentList = equipmentList.copyWith(
      updatedAt: DateTime.now(),
    );

    // 更新缓存
    if (_equipmentListsCache != null) {
      _equipmentListsCache = _equipmentListsCache!
          .map((list) =>
              list.id == updatedEquipmentList.id ? updatedEquipmentList : list)
          .toList();
    }

    return updatedEquipmentList;
  }

  @override
  Future<bool> deleteEquipmentList(String id) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 更新缓存
    if (_equipmentListsCache != null) {
      _equipmentListsCache =
          _equipmentListsCache!.where((list) => list.id != id).toList();
    }

    return true;
  }

  @override
  Future<EquipmentListModel> addEquipmentItem(
      String equipmentListId, EquipmentItemModel item) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 获取装备清单
    final equipmentList = await getEquipmentListById(equipmentListId);

    // 添加装备项目
    final updatedEquipments = [...equipmentList.equipments, item];

    // 更新装备清单
    final updatedEquipmentList = equipmentList.copyWith(
      equipments: updatedEquipments,
      updatedAt: DateTime.now(),
    );

    // 更新缓存
    if (_equipmentListsCache != null) {
      _equipmentListsCache = _equipmentListsCache!
          .map((list) =>
              list.id == equipmentListId ? updatedEquipmentList : list)
          .toList();
    }

    return updatedEquipmentList;
  }

  @override
  Future<EquipmentListModel> updateEquipmentItem(
      String equipmentListId, EquipmentItemModel item) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 获取装备清单
    final equipmentList = await getEquipmentListById(equipmentListId);

    // 更新装备项目
    final updatedEquipments = equipmentList.equipments
        .map((existingItem) => existingItem.id == item.id ? item : existingItem)
        .toList();

    // 更新装备清单
    final updatedEquipmentList = equipmentList.copyWith(
      equipments: updatedEquipments,
      updatedAt: DateTime.now(),
    );

    // 更新缓存
    if (_equipmentListsCache != null) {
      _equipmentListsCache = _equipmentListsCache!
          .map((list) =>
              list.id == equipmentListId ? updatedEquipmentList : list)
          .toList();
    }

    return updatedEquipmentList;
  }

  @override
  Future<EquipmentListModel> removeEquipmentItem(
      String equipmentListId, String itemId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 获取装备清单
    final equipmentList = await getEquipmentListById(equipmentListId);

    // 移除装备项目
    final updatedEquipments =
        equipmentList.equipments.where((item) => item.id != itemId).toList();

    // 更新装备清单
    final updatedEquipmentList = equipmentList.copyWith(
      equipments: updatedEquipments,
      updatedAt: DateTime.now(),
    );

    // 更新缓存
    if (_equipmentListsCache != null) {
      _equipmentListsCache = _equipmentListsCache!
          .map((list) =>
              list.id == equipmentListId ? updatedEquipmentList : list)
          .toList();
    }

    return updatedEquipmentList;
  }

  @override
  Future<List<EquipmentItemModel>> getEquipmentItems(
      String equipmentListId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 获取装备清单
    final equipmentList = await getEquipmentListById(equipmentListId);

    return equipmentList.equipments;
  }

  @override
  Future<EquipmentItemModel> getEquipmentItemById(
      String equipmentListId, String itemId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 获取装备清单
    final equipmentList = await getEquipmentListById(equipmentListId);

    // 查找指定ID的装备项目
    final item = equipmentList.equipments.firstWhere(
      (item) => item.id == itemId,
      orElse: () => throw Exception('装备项目不存在: $itemId'),
    );

    return item;
  }

  @override
  Future<List<EquipmentCategory>> getEquipmentCategories() async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 获取所有装备清单
    final lists = await getEquipmentLists();

    // 提取所有装备项目的分类
    final categories = <EquipmentCategory>{};
    for (final list in lists) {
      for (final item in list.equipments) {
        categories.add(item.category);
      }
    }

    return categories.toList();
  }

  @override
  Future<EquipmentListModel> cloneEquipmentList(String equipmentListId,
      {String? newName}) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 获取装备清单
    final equipmentList = await getEquipmentListById(equipmentListId);

    // 生成新ID
    final now = DateTime.now();
    final newId = 'equipment_${now.millisecondsSinceEpoch}';

    // 创建副本
    final clonedEquipmentList = equipmentList.copyWith(
      id: newId,
      name: newName ?? '${equipmentList.name} (副本)',
      createdAt: now,
      updatedAt: now,
      isOfficial: false, // 副本不是官方的
    );

    // 更新缓存
    if (_equipmentListsCache != null) {
      _equipmentListsCache = [..._equipmentListsCache!, clonedEquipmentList];
    }

    return clonedEquipmentList;
  }

  @override
  Future<List<EquipmentListModel>> getEquipmentListsByType(
      EquipmentListType type,
      {int limit = 10}) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 确保缓存已加载
    final lists = await getEquipmentLists();

    // 筛选符合类型的装备清单
    final filteredLists = lists.where((list) => list.type == type).toList();

    // 限制数量
    if (filteredLists.length > limit) {
      return filteredLists.sublist(0, limit);
    }

    return filteredLists;
  }

  @override
  Future<List<EquipmentListModel>> getEquipmentListsByStatus(
      EquipmentListStatus status,
      {int limit = 10}) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 确保缓存已加载
    final lists = await getEquipmentLists();

    // 筛选符合状态的装备清单
    final filteredLists = lists.where((list) => list.status == status).toList();

    // 限制数量
    if (filteredLists.length > limit) {
      return filteredLists.sublist(0, limit);
    }

    return filteredLists;
  }

  @override
  Future<List<EquipmentTemplateModel>> getEquipmentTemplates(
      {int limit = 10}) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 如果有缓存，直接返回
    if (_equipmentTemplatesCache != null) {
      final templates = _equipmentTemplatesCache!;
      return templates.length > limit ? templates.sublist(0, limit) : templates;
    }

    try {
      final templatesJson =
          await _loadJsonData('assets/mock_data/equipment_templates.json');
      _equipmentTemplatesCache = templatesJson
          .map<EquipmentTemplateModel>(
              (json) => EquipmentTemplateModel.fromJson(json))
          .toList();

      final templates = _equipmentTemplatesCache!;
      return templates.length > limit ? templates.sublist(0, limit) : templates;
    } catch (e) {
      print('加载装备模板失败: $e');
      return [];
    }
  }

  @override
  Future<EquipmentTemplateModel> getEquipmentTemplateById(String id) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 确保缓存已加载
    final templates = await getEquipmentTemplates(limit: 1000);

    // 查找指定ID的装备模板
    final template = templates.firstWhere(
      (template) => template.id == id,
      orElse: () => throw Exception('装备模板不存在: $id'),
    );

    return template;
  }

  @override
  Future<List<EquipmentTemplateModel>> getEquipmentTemplatesByType(
      EquipmentListType type,
      {int limit = 10}) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 确保缓存已加载
    final templates = await getEquipmentTemplates(limit: 1000);

    // 筛选符合类型的装备模板
    final filteredTemplates =
        templates.where((template) => template.type == type).toList();

    // 限制数量
    if (filteredTemplates.length > limit) {
      return filteredTemplates.sublist(0, limit);
    }

    return filteredTemplates;
  }

  @override
  Future<EquipmentTemplateModel> createEquipmentTemplate(
      EquipmentTemplateModel template) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 生成新ID
    final now = DateTime.now();
    final newId = 'template_${now.millisecondsSinceEpoch}';

    // 创建新装备模板
    final newTemplate = template.copyWith(
      id: newId,
      createdAt: now,
      updatedAt: now,
    );

    // 更新缓存
    if (_equipmentTemplatesCache != null) {
      _equipmentTemplatesCache = [..._equipmentTemplatesCache!, newTemplate];
    }

    return newTemplate;
  }

  @override
  Future<EquipmentTemplateModel> updateEquipmentTemplate(
      EquipmentTemplateModel template) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 更新时间戳
    final updatedTemplate = template.copyWith(
      updatedAt: DateTime.now(),
    );

    // 更新缓存
    if (_equipmentTemplatesCache != null) {
      _equipmentTemplatesCache = _equipmentTemplatesCache!
          .map((t) => t.id == updatedTemplate.id ? updatedTemplate : t)
          .toList();
    }

    return updatedTemplate;
  }

  @override
  Future<bool> deleteEquipmentTemplate(String id) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 更新缓存
    if (_equipmentTemplatesCache != null) {
      _equipmentTemplatesCache = _equipmentTemplatesCache!
          .where((template) => template.id != id)
          .toList();
    }

    return true;
  }

  @override
  Future<EquipmentListModel> createEquipmentListFromTemplate(
    String templateId, {
    required String name,
    String? description,
    String? routeId,
    String? routeName,
    String? tripId,
    required int tripDays,
    int personCount = 1,
  }) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 获取模板
    final template = await getEquipmentTemplateById(templateId);

    // 生成新ID
    final now = DateTime.now();
    final newId = 'equipment_${now.millisecondsSinceEpoch}';

    // 从模板创建装备清单
    final equipmentList = template.createEquipmentList(
      id: newId,
      creatorId: 'current_user',
      creatorName: '当前用户',
      routeId: routeId,
      routeName: routeName,
      tripId: tripId,
      tripDays: tripDays,
      personCount: personCount,
    );

    // 更新名称和描述
    final customizedList = equipmentList.copyWith(
      name: name,
      description: description ?? equipmentList.description,
    );

    // 更新缓存
    if (_equipmentListsCache != null) {
      _equipmentListsCache = [..._equipmentListsCache!, customizedList];
    }

    return customizedList;
  }

  @override
  Future<UserEquipmentInventoryModel> getUserEquipmentInventory(
      String userId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 如果有缓存，直接返回
    if (_userEquipmentInventoryCache.containsKey(userId)) {
      return _userEquipmentInventoryCache[userId]!;
    }

    try {
      final inventoriesJson =
          await _loadJsonData('assets/mock_data/user_equipment_inventory.json');
      final inventories = inventoriesJson
          .map<UserEquipmentInventoryModel>(
              (json) => UserEquipmentInventoryModel.fromJson(json))
          .toList();

      // 查找指定用户的装备库
      final inventory = inventories.firstWhere(
        (inventory) => inventory.userId == userId,
        orElse: () {
          // 如果找不到，创建一个空的装备库
          final now = DateTime.now();
          return UserEquipmentInventoryModel(
            id: 'inventory_${now.millisecondsSinceEpoch}',
            userId: userId,
            equipments: [],
            lastUpdatedAt: now,
            createdAt: now,
            updatedAt: now,
          );
        },
      );

      // 更新缓存
      _userEquipmentInventoryCache[userId] = inventory;

      return inventory;
    } catch (e) {
      print('加载用户装备库失败: $e');

      // 如果加载失败，创建一个空的装备库
      final now = DateTime.now();
      final inventory = UserEquipmentInventoryModel(
        id: 'inventory_${now.millisecondsSinceEpoch}',
        userId: userId,
        equipments: [],
        lastUpdatedAt: now,
        createdAt: now,
        updatedAt: now,
      );

      // 更新缓存
      _userEquipmentInventoryCache[userId] = inventory;

      return inventory;
    }
  }

  @override
  Future<UserEquipmentInventoryModel> addEquipmentToInventory(
      String userId, EquipmentItemModel item) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 获取用户装备库
    final inventory = await getUserEquipmentInventory(userId);

    // 生成新ID
    final now = DateTime.now();
    final newItemId = '${inventory.id}_${now.millisecondsSinceEpoch}';

    // 创建新装备项目
    final newItem = item.copyWith(
      id: newItemId,
      createdAt: now,
      updatedAt: now,
    );

    // 添加装备项目
    final updatedEquipments = [...inventory.equipments, newItem];

    // 更新装备库
    final updatedInventory = inventory.copyWith(
      equipments: updatedEquipments,
      lastUpdatedAt: now,
      updatedAt: now,
    );

    // 更新缓存
    _userEquipmentInventoryCache[userId] = updatedInventory;

    return updatedInventory;
  }

  @override
  Future<UserEquipmentInventoryModel> updateEquipmentInInventory(
      String userId, EquipmentItemModel item) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 获取用户装备库
    final inventory = await getUserEquipmentInventory(userId);

    // 更新装备项目
    final now = DateTime.now();
    final updatedEquipments = inventory.equipments
        .map((existingItem) => existingItem.id == item.id
            ? item.copyWith(updatedAt: now)
            : existingItem)
        .toList();

    // 更新装备库
    final updatedInventory = inventory.copyWith(
      equipments: updatedEquipments,
      lastUpdatedAt: now,
      updatedAt: now,
    );

    // 更新缓存
    _userEquipmentInventoryCache[userId] = updatedInventory;

    return updatedInventory;
  }

  @override
  Future<UserEquipmentInventoryModel> removeEquipmentFromInventory(
      String userId, String itemId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 获取用户装备库
    final inventory = await getUserEquipmentInventory(userId);

    // 移除装备项目
    final now = DateTime.now();
    final updatedEquipments =
        inventory.equipments.where((item) => item.id != itemId).toList();

    // 更新装备库
    final updatedInventory = inventory.copyWith(
      equipments: updatedEquipments,
      lastUpdatedAt: now,
      updatedAt: now,
    );

    // 更新缓存
    _userEquipmentInventoryCache[userId] = updatedInventory;

    return updatedInventory;
  }

  @override
  Future<List<EquipmentItemModel>> getUserEquipmentItems(String userId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 获取用户装备库
    final inventory = await getUserEquipmentInventory(userId);

    return inventory.equipments;
  }

  @override
  Future<EquipmentItemModel> getUserEquipmentItemById(
      String userId, String itemId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 获取用户装备库
    final inventory = await getUserEquipmentInventory(userId);

    // 查找指定ID的装备项目
    final item = inventory.equipments.firstWhere(
      (item) => item.id == itemId,
      orElse: () => throw Exception('装备项目不存在: $itemId'),
    );

    return item;
  }

  @override
  Future<List<EquipmentItemModel>> searchUserEquipment(
      String userId, String keyword) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 获取用户装备库
    final inventory = await getUserEquipmentInventory(userId);

    // 如果关键词为空，返回所有装备
    if (keyword.isEmpty) {
      return inventory.equipments;
    }

    // 搜索匹配的装备
    return inventory.searchItems(keyword);
  }

  @override
  Future<List<EquipmentItemModel>> getUserEquipmentByCategory(
      String userId, EquipmentCategory category) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 获取用户装备库
    final inventory = await getUserEquipmentInventory(userId);

    // 筛选符合分类的装备
    return inventory.getItemsByCategory(category);
  }

  @override
  Future<List<CategoryDistribution>> getUserEquipmentCategoryDistribution(
      String userId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 获取用户装备库
    final inventory = await getUserEquipmentInventory(userId);

    // 获取分类分布
    return inventory.getCategoryDistribution();
  }

  @override
  Future<List<ConditionDistribution>> getUserEquipmentConditionDistribution(
      String userId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 获取用户装备库
    final inventory = await getUserEquipmentInventory(userId);

    // 获取状态分布
    return inventory.getConditionDistribution();
  }

  @override
  Future<List<EquipmentItemModel>> getEquipmentNeedingMaintenance(
      String userId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 获取用户装备库
    final inventory = await getUserEquipmentInventory(userId);

    // 获取需要维护的装备
    return inventory.getItemsNeedingMaintenance();
  }

  @override
  Future<EquipmentListModel> updateEquipmentListStatus(
      String equipmentListId, EquipmentListStatus status) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 获取装备清单
    final equipmentList = await getEquipmentListById(equipmentListId);

    // 更新状态
    final updatedEquipmentList = equipmentList.copyWith(
      status: status,
      updatedAt: DateTime.now(),
    );

    // 更新缓存
    if (_equipmentListsCache != null) {
      _equipmentListsCache = _equipmentListsCache!
          .map((list) =>
              list.id == equipmentListId ? updatedEquipmentList : list)
          .toList();
    }

    return updatedEquipmentList;
  }

  @override
  Future<EquipmentListModel> updateEquipmentPreparedStatus(
      String equipmentListId, String itemId, bool prepared) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 获取装备清单
    final equipmentList = await getEquipmentListById(equipmentListId);

    // 更新装备准备状态
    final updatedEquipments = equipmentList.equipments.map((item) {
      if (item.id == itemId) {
        return item.copyWith(prepared: prepared);
      }
      return item;
    }).toList();

    // 更新装备清单
    final updatedEquipmentList = equipmentList.copyWith(
      equipments: updatedEquipments,
      updatedAt: DateTime.now(),
    );

    // 更新缓存
    if (_equipmentListsCache != null) {
      _equipmentListsCache = _equipmentListsCache!
          .map((list) =>
              list.id == equipmentListId ? updatedEquipmentList : list)
          .toList();
    }

    return updatedEquipmentList;
  }

  @override
  Future<EquipmentListModel> batchUpdateEquipmentPreparedStatus(
      String equipmentListId, List<String> itemIds, bool prepared) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 获取装备清单
    final equipmentList = await getEquipmentListById(equipmentListId);

    // 批量更新装备准备状态
    final updatedEquipments = equipmentList.equipments.map((item) {
      if (itemIds.contains(item.id)) {
        return item.copyWith(prepared: prepared);
      }
      return item;
    }).toList();

    // 更新装备清单
    final updatedEquipmentList = equipmentList.copyWith(
      equipments: updatedEquipments,
      updatedAt: DateTime.now(),
    );

    // 更新缓存
    if (_equipmentListsCache != null) {
      _equipmentListsCache = _equipmentListsCache!
          .map((list) =>
              list.id == equipmentListId ? updatedEquipmentList : list)
          .toList();
    }

    return updatedEquipmentList;
  }

  @override
  Future<EquipmentListStats> getEquipmentListStats(
      String equipmentListId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 获取装备清单
    final equipmentList = await getEquipmentListById(equipmentListId);

    // 计算统计信息
    return EquipmentListStats(
      totalItems: equipmentList.totalItems,
      essentialItems: equipmentList.essentialItems,
      recommendedItems: equipmentList.recommendedItems,
      optionalItems: equipmentList.optionalItems,
      preparedItems: equipmentList.preparedItems,
      totalWeight: equipmentList.totalWeight,
      baseWeight: equipmentList.baseWeight,
      consumableWeight: equipmentList.consumableWeight,
      wornWeight: equipmentList.wornWeight,
      weightPerPersonPerDay: equipmentList.weightPerPersonPerDay,
      totalValue: equipmentList.totalValue,
      ownedItems: equipmentList.ownedItems,
      itemsToBuy: equipmentList.itemsToBuy,
      valueToBuy: equipmentList.valueToBuy,
    );
  }

  @override
  Future<double> getEquipmentListPreparationProgress(
      String equipmentListId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 获取装备清单
    final equipmentList = await getEquipmentListById(equipmentListId);

    // 计算准备进度
    return equipmentList.preparationPercentage;
  }
}
