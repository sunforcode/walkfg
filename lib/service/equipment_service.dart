import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:walk/model/equipment/equipment_category.dart';
import 'package:walk/model/equipment/equipment_list_type.dart';
import 'package:walk/model/equipment/equipment_list_status.dart';
import 'package:walk/model/equipment/equipment_template_model.dart';
import 'package:walk/model/equipment/user_equipment_inventory_model.dart';
import '../model/equipment/equipment_list_model.dart';
import '../model/equipment/equipment_item_model.dart';

/// 装备服务
///
/// 使用静态方法，无需实例化
/// 当前使用本地 JSON 数据，后续可改为 API 请求
class EquipmentService {
  // 禁止实例化
  EquipmentService._();

  /// 装备清单缓存
  static List<EquipmentListModel>? _equipmentListsCache;

  /// 装备模板缓存
  static List<EquipmentTemplateModel>? _equipmentTemplatesCache;

  /// 用户装备库缓存
  static final Map<String, UserEquipmentInventoryModel> _userEquipmentInventoryCache = {};

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

  /// 获取装备清单列表
  static Future<List<EquipmentListModel>> getEquipmentLists() async {
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

  /// 根据ID获取装备清单
  static Future<EquipmentListModel> getEquipmentListById(String id) async {
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

  /// 获取推荐装备清单
  static Future<List<EquipmentListModel>> getRecommendedEquipmentLists(
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

  /// 获取官方装备清单
  static Future<List<EquipmentListModel>> getOfficialEquipmentLists(
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

  /// 获取用户创建的装备清单
  static Future<List<EquipmentListModel>> getUserEquipmentLists(
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

  /// 根据季节获取装备清单
  static Future<List<EquipmentListModel>> getEquipmentListsBySeason(
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

  /// 根据行程天数获取装备清单
  static Future<List<EquipmentListModel>> getEquipmentListsByTripDays(
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

  /// 搜索装备清单
  static Future<List<EquipmentListModel>> searchEquipmentLists(String keyword,
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

  /// 创建装备清单
  static Future<EquipmentListModel> createEquipmentList(
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

  /// 更新装备清单
  static Future<EquipmentListModel> updateEquipmentList(
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

  /// 删除装备清单
  static Future<bool> deleteEquipmentList(String id) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 更新缓存
    if (_equipmentListsCache != null) {
      _equipmentListsCache =
          _equipmentListsCache!.where((list) => list.id != id).toList();
    }

    return true;
  }

  /// 添加装备项目到装备清单
  static Future<EquipmentListModel> addEquipmentItem(
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

  /// 更新装备清单中的装备项目
  static Future<EquipmentListModel> updateEquipmentItem(
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

  /// 从装备清单中删除装备项目
  static Future<EquipmentListModel> removeEquipmentItem(
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

  /// 获取装备项目列表
  static Future<List<EquipmentItemModel>> getEquipmentItems(
      String equipmentListId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 获取装备清单
    final equipmentList = await getEquipmentListById(equipmentListId);

    return equipmentList.equipments;
  }

  /// 获取装备项目详情
  static Future<EquipmentItemModel> getEquipmentItemById(
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

  /// 获取装备分类列表
  static Future<List<EquipmentCategory>> getEquipmentCategories() async {
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

  /// 复制装备清单
  static Future<EquipmentListModel> cloneEquipmentList(String equipmentListId,
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

  /// 根据类型获取装备清单
  static Future<List<EquipmentListModel>> getEquipmentListsByType(
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

  /// 根据状态获取装备清单
  static Future<List<EquipmentListModel>> getEquipmentListsByStatus(
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

  /// 获取装备模板列表
  static Future<List<EquipmentTemplateModel>> getEquipmentTemplates(
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

  /// 根据ID获取装备模板
  static Future<EquipmentTemplateModel> getEquipmentTemplateById(String id) async {
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

  /// 根据类型获取装备模板
  static Future<List<EquipmentTemplateModel>> getEquipmentTemplatesByType(
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

  /// 创建装备模板
  static Future<EquipmentTemplateModel> createEquipmentTemplate(
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

  /// 更新装备模板
  static Future<EquipmentTemplateModel> updateEquipmentTemplate(
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

  /// 删除装备模板
  static Future<bool> deleteEquipmentTemplate(String id) async {
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

  /// 从模板创建装备清单
  static Future<EquipmentListModel> createEquipmentListFromTemplate(
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

  /// 获取用户装备库
  static Future<UserEquipmentInventoryModel> getUserEquipmentInventory(
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

  /// 添加装备到用户装备库
  static Future<UserEquipmentInventoryModel> addEquipmentToInventory(
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

  /// 更新用户装备库中的装备
  static Future<UserEquipmentInventoryModel> updateEquipmentInInventory(
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

  /// 从用户装备库中删除装备
  static Future<UserEquipmentInventoryModel> removeEquipmentFromInventory(
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

  /// 获取用户装备库中的装备
  static Future<List<EquipmentItemModel>> getUserEquipmentItems(String userId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 获取用户装备库
    final inventory = await getUserEquipmentInventory(userId);

    return inventory.equipments;
  }

  /// 获取用户装备库中的装备详情
  static Future<EquipmentItemModel> getUserEquipmentItemById(
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

  /// 搜索用户装备库
  static Future<List<EquipmentItemModel>> searchUserEquipment(
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

  /// 根据分类获取用户装备
  static Future<List<EquipmentItemModel>> getUserEquipmentByCategory(
      String userId, EquipmentCategory category) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 获取用户装备库
    final inventory = await getUserEquipmentInventory(userId);

    // 筛选符合分类的装备
    return inventory.getItemsByCategory(category);
  }

  /// 获取用户装备分类统计
  static Future<List<CategoryDistribution>> getUserEquipmentCategoryDistribution(
      String userId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 获取用户装备库
    final inventory = await getUserEquipmentInventory(userId);

    // 获取分类分布
    return inventory.getCategoryDistribution();
  }

  /// 获取用户装备状态统计
  static Future<List<ConditionDistribution>> getUserEquipmentConditionDistribution(
      String userId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 获取用户装备库
    final inventory = await getUserEquipmentInventory(userId);

    // 获取状态分布
    return inventory.getConditionDistribution();
  }

  /// 获取需要维护的装备
  static Future<List<EquipmentItemModel>> getEquipmentNeedingMaintenance(
      String userId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 获取用户装备库
    final inventory = await getUserEquipmentInventory(userId);

    // 获取需要维护的装备
    return inventory.getItemsNeedingMaintenance();
  }

  /// 更新装备清单状态
  static Future<EquipmentListModel> updateEquipmentListStatus(
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

  /// 更新装备准备状态
  static Future<EquipmentListModel> updateEquipmentPreparedStatus(
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

  /// 批量更新装备准备状态
  static Future<EquipmentListModel> batchUpdateEquipmentPreparedStatus(
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

  /// 获取装备清单统计信息
  static Future<EquipmentListStats> getEquipmentListStats(
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

  /// 获取装备清单准备进度
  static Future<double> getEquipmentListPreparationProgress(
      String equipmentListId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 获取装备清单
    final equipmentList = await getEquipmentListById(equipmentListId);

    // 计算准备进度
    return equipmentList.preparationPercentage;
  }
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
