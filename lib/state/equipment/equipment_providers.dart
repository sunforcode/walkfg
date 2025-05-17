/// 装备相关的状态管理提供者
///
/// 包含装备清单列表、当前选中的装备清单等状态

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../model/equipment/equipment_model.dart';

/// 装备清单列表提供者
final equipmentListsProvider = StateNotifierProvider<EquipmentListsNotifier, List<EquipmentListModel>>((ref) {
  return EquipmentListsNotifier();
});

/// 选中的装备清单提供者
final selectedEquipmentListProvider = StateProvider<EquipmentListModel?>((ref) => null);

/// 装备筛选提供者
final equipmentFilterProvider = StateProvider<EquipmentFilter>((ref) => const EquipmentFilter());

/// 装备清单列表状态管理
class EquipmentListsNotifier extends StateNotifier<List<EquipmentListModel>> {
  /// 构造函数
  EquipmentListsNotifier() : super([]);

  /// 加载装备清单列表
  Future<void> loadEquipmentLists() async {
    // 模拟加载数据
    await Future.delayed(const Duration(milliseconds: 800));
    state = _getMockEquipmentLists();
  }

  /// 添加装备清单
  void addEquipmentList(EquipmentListModel equipmentList) {
    state = [...state, equipmentList];
  }

  /// 更新装备清单
  void updateEquipmentList(EquipmentListModel equipmentList) {
    state = state.map((e) => e.id == equipmentList.id ? equipmentList : e).toList();
  }

  /// 删除装备清单
  void deleteEquipmentList(String id) {
    state = state.where((e) => e.id != id).toList();
  }

  /// 获取装备清单
  EquipmentListModel? getEquipmentList(String id) {
    return state.firstWhere((e) => e.id == id, orElse: () => throw Exception('装备清单不存在'));
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
        categories: [
          EquipmentCategory(
            name: '背包系统',
            icon: 'backpack',
            items: [
              EquipmentItem(
                name: '徒步背包',
                description: '40-50L容量的轻量化徒步背包',
                weight: 1200,
                quantity: 1,
                necessity: EquipmentNecessity.essential,
                brand: 'Osprey',
                model: 'Exos 48',
                price: 1200,
              ),
              EquipmentItem(
                name: '防雨罩',
                weight: 80,
                quantity: 1,
                necessity: EquipmentNecessity.essential,
              ),
            ],
          ),
          EquipmentCategory(
            name: '睡眠系统',
            icon: 'hotel',
            items: [
              EquipmentItem(
                name: '睡袋',
                description: '适合5-15℃的轻量化睡袋',
                weight: 800,
                quantity: 1,
                necessity: EquipmentNecessity.essential,
                brand: 'Naturehike',
                model: 'UL400',
                price: 500,
              ),
              EquipmentItem(
                name: '睡垫',
                weight: 350,
                quantity: 1,
                necessity: EquipmentNecessity.essential,
              ),
            ],
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
      ),
      EquipmentListModel(
        id: '2',
        name: '七日长线徒步装备清单',
        description: '适合七日长线徒步旅行的全面装备清单，包含应对各种天气情况的装备。',
        tripDays: 7,
        seasons: [SeasonSuitability.summer],
        categories: [
          EquipmentCategory(
            name: '背包系统',
            icon: 'backpack',
            items: [
              EquipmentItem(
                name: '徒步背包',
                description: '60-70L容量的徒步背包',
                weight: 1800,
                quantity: 1,
                necessity: EquipmentNecessity.essential,
                brand: 'Deuter',
                model: 'Aircontact 65+10',
                price: 1500,
              ),
              EquipmentItem(
                name: '防雨罩',
                weight: 100,
                quantity: 1,
                necessity: EquipmentNecessity.essential,
              ),
            ],
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
      ),
    ];
  }
}

/// 装备筛选器
class EquipmentFilter {
  /// 搜索关键词
  final String? searchQuery;

  /// 季节
  final List<SeasonSuitability>? seasons;

  /// 最小行程天数
  final int? minTripDays;

  /// 最大行程天数
  final int? maxTripDays;

  /// 只显示官方推荐
  final bool? onlyOfficial;

  /// 只显示公开的
  final bool? onlyPublic;

  /// 构造函数
  const EquipmentFilter({
    this.searchQuery,
    this.seasons,
    this.minTripDays,
    this.maxTripDays,
    this.onlyOfficial,
    this.onlyPublic,
  });

  /// 创建副本并更新指定字段
  EquipmentFilter copyWith({
    String? searchQuery,
    List<SeasonSuitability>? seasons,
    int? minTripDays,
    int? maxTripDays,
    bool? onlyOfficial,
    bool? onlyPublic,
  }) {
    return EquipmentFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      seasons: seasons ?? this.seasons,
      minTripDays: minTripDays ?? this.minTripDays,
      maxTripDays: maxTripDays ?? this.maxTripDays,
      onlyOfficial: onlyOfficial ?? this.onlyOfficial,
      onlyPublic: onlyPublic ?? this.onlyPublic,
    );
  }

  /// 应用筛选
  List<EquipmentListModel> apply(List<EquipmentListModel> lists) {
    var filteredLists = List<EquipmentListModel>.from(lists);

    // 搜索关键词筛选
    if (searchQuery != null && searchQuery!.isNotEmpty) {
      filteredLists = filteredLists.where((list) {
        return list.name.toLowerCase().contains(searchQuery!.toLowerCase()) ||
            list.description.toLowerCase().contains(searchQuery!.toLowerCase()) ||
            list.tags.any((tag) => tag.toLowerCase().contains(searchQuery!.toLowerCase()));
      }).toList();
    }

    // 季节筛选
    if (seasons != null && seasons!.isNotEmpty) {
      filteredLists = filteredLists.where((list) {
        return list.seasons.any((season) => seasons!.contains(season));
      }).toList();
    }

    // 行程天数筛选
    if (minTripDays != null) {
      filteredLists = filteredLists.where((list) => list.tripDays >= minTripDays!).toList();
    }
    if (maxTripDays != null) {
      filteredLists = filteredLists.where((list) => list.tripDays <= maxTripDays!).toList();
    }

    // 官方推荐筛选
    if (onlyOfficial == true) {
      filteredLists = filteredLists.where((list) => list.isOfficial).toList();
    }

    return filteredLists;
  }
}