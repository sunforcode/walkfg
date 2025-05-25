import 'dart:convert';
import 'package:flutter/services.dart';
import '../equipment_service.dart';
import '../../model/equipment/equipment_model.dart';
import '../../model/equipment/equipment_item_model.dart';
import '../../model/equipment/equipment_necessity.dart';

/// Mock装备服务实现
class MockEquipmentService implements EquipmentService {
  /// 单例实例
  static final MockEquipmentService _instance = MockEquipmentService._internal();

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

    try {
      final equipmentListsJson = await _loadJsonData('assets/mock_data/equipment_lists.json');
      if (equipmentListsJson == null || !(equipmentListsJson is List)) {
        _equipmentListsCache = _getMockEquipmentLists();
        return _equipmentListsCache!;
      }

      _equipmentListsCache = equipmentListsJson
          .map<EquipmentListModel>((json) => EquipmentListModel.fromJson(json))
          .toList();
      return _equipmentListsCache!;
    } catch (e) {
      print('获取装备清单列表失败: $e');
      _equipmentListsCache = _getMockEquipmentLists();
      return _equipmentListsCache!;
    }
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
  Future<List<EquipmentListModel>> getRecommendedEquipmentLists({int limit = 10}) async {
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
  Future<List<EquipmentListModel>> getOfficialEquipmentLists({int limit = 10}) async {
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
  Future<List<EquipmentListModel>> getUserEquipmentLists({int limit = 10}) async {
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
  Future<List<EquipmentListModel>> getEquipmentListsBySeason(List<SeasonSuitability> seasons, {int limit = 10}) async {
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
  Future<List<EquipmentListModel>> getEquipmentListsByTripDays(int minDays, int maxDays, {int limit = 10}) async {
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
  Future<List<EquipmentListModel>> searchEquipmentLists(String keyword, {int limit = 10}) async {
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
          list.tags.any((tag) => tag.toLowerCase().contains(keyword.toLowerCase()));
    }).toList();

    // 限制数量
    if (searchResults.length > limit) {
      return searchResults.sublist(0, limit);
    }

    return searchResults;
  }

  @override
  Future<EquipmentListModel> createEquipmentList(EquipmentListModel equipmentList) async {
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
  Future<EquipmentListModel> updateEquipmentList(EquipmentListModel equipmentList) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 更新时间戳
    final updatedEquipmentList = equipmentList.copyWith(
      updatedAt: DateTime.now(),
    );

    // 更新缓存
    if (_equipmentListsCache != null) {
      _equipmentListsCache = _equipmentListsCache!
          .map((list) => list.id == updatedEquipmentList.id ? updatedEquipmentList : list)
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
      _equipmentListsCache = _equipmentListsCache!.where((list) => list.id != id).toList();
    }

    return true;
  }

  @override
  Future<EquipmentListModel> addEquipmentItem(String equipmentListId, EquipmentItemModel item) async {
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
          .map((list) => list.id == equipmentListId ? updatedEquipmentList : list)
          .toList();
    }

    return updatedEquipmentList;
  }

  @override
  Future<EquipmentListModel> updateEquipmentItem(String equipmentListId, EquipmentItemModel item) async {
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
          .map((list) => list.id == equipmentListId ? updatedEquipmentList : list)
          .toList();
    }

    return updatedEquipmentList;
  }

  @override
  Future<EquipmentListModel> removeEquipmentItem(String equipmentListId, String itemId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 获取装备清单
    final equipmentList = await getEquipmentListById(equipmentListId);

    // 移除装备项目
    final updatedEquipments = equipmentList.equipments.where((item) => item.id != itemId).toList();

    // 更新装备清单
    final updatedEquipmentList = equipmentList.copyWith(
      equipments: updatedEquipments,
      updatedAt: DateTime.now(),
    );

    // 更新缓存
    if (_equipmentListsCache != null) {
      _equipmentListsCache = _equipmentListsCache!
          .map((list) => list.id == equipmentListId ? updatedEquipmentList : list)
          .toList();
    }

    return updatedEquipmentList;
  }

  @override
  Future<List<EquipmentItemModel>> getEquipmentItems(String equipmentListId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 获取装备清单
    final equipmentList = await getEquipmentListById(equipmentListId);

    return equipmentList.equipments;
  }

  @override
  Future<EquipmentItemModel> getEquipmentItemById(String equipmentListId, String itemId) async {
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
  Future<List<String>> getEquipmentCategories() async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 获取所有装备清单
    final lists = await getEquipmentLists();

    // 提取所有装备项目的分类
    final categories = <String>{};
    for (final list in lists) {
      for (final item in list.equipments) {
        categories.add(item.category);
      }
    }

    return categories.toList();
  }

  @override
  Future<EquipmentListModel> cloneEquipmentList(String equipmentListId, {String? newName}) async {
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
  Future<Map<String, dynamic>> getEquipmentListStats(String equipmentListId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 获取装备清单
    final equipmentList = await getEquipmentListById(equipmentListId);

    // 计算统计信息
    final totalItems = equipmentList.totalItems;
    final essentialItems = equipmentList.essentialItems;
    final recommendedItems = equipmentList.recommendedItems;
    final optionalItems = equipmentList.optionalItems;
    final totalWeight = equipmentList.totalWeight;
    final weightPerDay = equipmentList.weightPerPersonPerDay;

    // 按分类统计
    final categoryStats = <String, Map<String, dynamic>>{};
    for (final item in equipmentList.equipments) {
      if (!categoryStats.containsKey(item.category)) {
        categoryStats[item.category] = {
          'count': 0,
          'weight': 0.0,
        };
      }
      categoryStats[item.category]!['count'] = categoryStats[item.category]!['count'] + 1;
      categoryStats[item.category]!['weight'] = categoryStats[item.category]!['weight'] + item.totalWeight;
    }

    return {
      'total_items': totalItems,
      'essential_items': essentialItems,
      'recommended_items': recommendedItems,
      'optional_items': optionalItems,
      'total_weight': totalWeight,
      'weight_per_day': weightPerDay,
      'category_stats': categoryStats,
    };
  }

  /// 获取模拟装备清单列表
  List<EquipmentListModel> _getMockEquipmentLists() {
    return [
      EquipmentListModel(
        id: '1',
        name: '三日徒步装备清单',
        description: '适合三日徒步旅行的轻量化装备清单，总重量控制在10kg以内。',
        tripDays: 3,
        seasons: [SeasonSuitability.spring, SeasonSuitability.autumn],
        equipments: [
          EquipmentItemModel(
            id: '1',
            name: '徒步背包',
            category: '背包系统',
            description: '40-50L容量的轻量化徒步背包',
            weight: 1200,
            quantity: 1,
            necessity: EquipmentNecessity.essential,
            brand: 'Osprey',
            model: 'Exos 48',
            price: 1200,
          ),
          EquipmentItemModel(
            id: '2',
            name: '防雨罩',
            category: '背包系统',
            weight: 80,
            quantity: 1,
            necessity: EquipmentNecessity.essential,
          ),
          EquipmentItemModel(
            id: '3',
            name: '睡袋',
            category: '睡眠系统',
            description: '适合5-15℃的轻量化睡袋',
            weight: 800,
            quantity: 1,
            necessity: EquipmentNecessity.essential,
            brand: 'Naturehike',
            model: 'UL400',
            price: 500,
          ),
          EquipmentItemModel(
            id: '4',
            name: '睡垫',
            category: '睡眠系统',
            weight: 350,
            quantity: 1,
            necessity: EquipmentNecessity.essential,
          ),
          EquipmentItemModel(
            id: '5',
            name: '帐篷',
            category: '庇护系统',
            description: '2人轻量化帐篷',
            weight: 1500,
            quantity: 1,
            necessity: EquipmentNecessity.essential,
            brand: 'Naturehike',
            model: 'Cloud Up 2',
            price: 800,
          ),
          EquipmentItemModel(
            id: '6',
            name: '速干T恤',
            category: '服装系统',
            weight: 150,
            quantity: 2,
            necessity: EquipmentNecessity.essential,
          ),
          EquipmentItemModel(
            id: '7',
            name: '徒步裤',
            category: '服装系统',
            weight: 300,
            quantity: 1,
            necessity: EquipmentNecessity.essential,
          ),
          EquipmentItemModel(
            id: '8',
            name: '抓绒衣',
            category: '服装系统',
            weight: 400,
            quantity: 1,
            necessity: EquipmentNecessity.recommended,
          ),
          EquipmentItemModel(
            id: '9',
            name: '防水冲锋衣',
            category: '服装系统',
            weight: 500,
            quantity: 1,
            necessity: EquipmentNecessity.essential,
          ),
          EquipmentItemModel(
            id: '10',
            name: '徒步鞋',
            category: '鞋袜系统',
            weight: 800,
            quantity: 1,
            necessity: EquipmentNecessity.essential,
          ),
        ],
        totalWeight: 10000,
        baseWeight: 8000,
        consumableWeight: 1500,
        wornWeight: 500,
        creatorId: 'user1',
        creatorName: '徒步爱好者',
        tags: ['轻量化', '三季', '入门级'],
        isOfficial: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      EquipmentListModel(
        id: '2',
        name: '七日长线徒步装备清单',
        description: '适合七日长线徒步旅行的全面装备清单，包含应对各种天气情况的装备。',
        tripDays: 7,
        seasons: [SeasonSuitability.summer],
        equipments: [
          EquipmentItemModel(
            id: '11',
            name: '徒步背包',
            category: '背包系统',
            description: '60-70L容量的徒步背包',
            weight: 1800,
            quantity: 1,
            necessity: EquipmentNecessity.essential,
            brand: 'Deuter',
            model: 'Aircontact 65+10',
            price: 1500,
          ),
          EquipmentItemModel(
            id: '12',
            name: '防雨罩',
            category: '背包系统',
            weight: 100,
            quantity: 1,
            necessity: EquipmentNecessity.essential,
          ),
          EquipmentItemModel(
            id: '13',
            name: '睡袋',
            category: '睡眠系统',
            description: '适合0-10℃的睡袋',
            weight: 1200,
            quantity: 1,
            necessity: EquipmentNecessity.essential,
            brand: 'Mountain Hardwear',
            model: 'Lamina 0',
            price: 1200,
          ),
          EquipmentItemModel(
            id: '14',
            name: '充气睡垫',
            category: '睡眠系统',
            weight: 450,
            quantity: 1,
            necessity: EquipmentNecessity.essential,
            brand: 'Therm-a-Rest',
            model: 'NeoAir XLite',
            price: 1000,
          ),
        ],
        totalWeight: 15000,
        baseWeight: 12000,
        consumableWeight: 2500,
        wornWeight: 500,
        creatorId: 'user2',
        creatorName: '资深驴友',
        tags: ['长线', '夏季', '进阶级'],
        isOfficial: false,
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        updatedAt: DateTime.now().subtract(const Duration(days: 45)),
      ),
      EquipmentListModel(
        id: '3',
        name: '冬季徒步装备清单',
        description: '适合冬季低海拔徒步的装备清单，注重保暖和安全。',
        tripDays: 2,
        seasons: [SeasonSuitability.winter],
        equipments: [
          EquipmentItemModel(
            id: '15',
            name: '徒步背包',
            category: '背包系统',
            description: '45L容量的徒步背包',
            weight: 1500,
            quantity: 1,
            necessity: EquipmentNecessity.essential,
          ),
          EquipmentItemModel(
            id: '16',
            name: '防水内袋',
            category: '背包系统',
            weight: 100,
            quantity: 2,
            necessity: EquipmentNecessity.recommended,
          ),
          EquipmentItemModel(
            id: '17',
            name: '羽绒服',
            category: '服装系统',
            description: '800蓬松度以上的羽绒服',
            weight: 600,
            quantity: 1,
            necessity: EquipmentNecessity.essential,
          ),
          EquipmentItemModel(
            id: '18',
            name: '保暖内衣裤',
            category: '服装系统',
            weight: 300,
            quantity: 1,
            necessity: EquipmentNecessity.essential,
          ),
        ],
        totalWeight: 8000,
        baseWeight: 6000,
        consumableWeight: 1500,
        wornWeight: 500,
        creatorId: 'user3',
        creatorName: '冬季徒步爱好者',
        tags: ['冬季', '保暖', '短途'],
        isOfficial: true,
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
        updatedAt: DateTime.now().subtract(const Duration(days: 85)),
      ),
    ];
  }
}