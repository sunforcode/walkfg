import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:walk/model/equipment/equipment_category.dart';
import '../equipment_service.dart';
import '../../model/equipment/equipment_list_model.dart';
import '../../model/equipment/equipment_item_model.dart';
import '../../model/equipment/equipment_necessity.dart';

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
}
