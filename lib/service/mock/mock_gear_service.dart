import 'dart:convert';
import 'package:flutter/services.dart';
import '../gear_service.dart';
import '../../model/equipment/gear_recommendation_model.dart';
import '../../model/equipment/gear_detail_model.dart';
import '../../model/equipment/gear_purchase_model.dart';
import '../../model/equipment/gear_rental_model.dart';

/// Mock装备服务实现
class MockGearService implements GearService {
  /// 单例实例
  static final MockGearService _instance = MockGearService._internal();

  /// 工厂构造函数
  factory MockGearService() {
    return _instance;
  }

  /// 私有构造函数
  MockGearService._internal();

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
  Future<GearRecommendationModel> getRouteGearRecommendations(
      String routeId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    final recommendationsJson =
        await _loadJsonData('assets/mock_data/gear_recommendations.json');
    if (recommendationsJson == null) {
      throw Exception('Failed to load gear recommendations');
    }

    // 查找指定路线的推荐装备
    final routeRecommendation = recommendationsJson.firstWhere(
      (rec) => rec['routeId'] == routeId,
      orElse: () =>
          throw Exception('Gear recommendations not found for route: $routeId'),
    );

    return GearRecommendationModel.fromJson(routeRecommendation);
  }

  @override
  Future<GearDetailModel> getGearDetail(String gearId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    final gearDetailsJson =
        await _loadJsonData('assets/mock_data/gear_details.json');
    if (gearDetailsJson == null) {
      throw Exception('Failed to load gear details');
    }

    // 查找指定装备的详情
    final gearDetail = gearDetailsJson.firstWhere(
      (gear) => gear['id'] == gearId,
      orElse: () => throw Exception('Gear detail not found: $gearId'),
    );

    return GearDetailModel.fromJson(gearDetail);
  }

  @override
  Future<List<String>> getGearCategories() async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    final categoriesJson =
        await _loadJsonData('assets/mock_data/gear_categories.json');
    if (categoriesJson == null || !(categoriesJson is List)) {
      return [];
    }

    return List<String>.from(categoriesJson);
  }

  @override
  Future<List<GearItemModel>> getGearsByCategory(String category) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    final gearsByCategoryJson =
        await _loadJsonData('assets/mock_data/gear_by_category.json');
    if (gearsByCategoryJson == null) {
      return [];
    }

    // 查找指定类别的装备
    final categoryGears = gearsByCategoryJson[category];
    if (categoryGears == null || !(categoryGears is List)) {
      return [];
    }

    return categoryGears
        .map<GearItemModel>((gear) => GearItemModel.fromJson(gear))
        .toList();
  }

  @override
  Future<List<GearItemModel>> searchGears(String keyword) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    if (keyword.isEmpty) {
      return [];
    }

    // 获取所有类别的装备
    final gearsByCategoryJson =
        await _loadJsonData('assets/mock_data/gear_by_category.json');
    if (gearsByCategoryJson == null) {
      return [];
    }

    List<GearItemModel> allGears = [];

    // 遍历所有类别，收集装备
    gearsByCategoryJson.forEach((category, gears) {
      if (gears is List) {
        allGears.addAll(
            gears.map<GearItemModel>((gear) => GearItemModel.fromJson(gear)));
      }
    });

    // 根据关键词筛选
    final lowercaseKeyword = keyword.toLowerCase();
    return allGears
        .where((gear) =>
            gear.name.toLowerCase().contains(lowercaseKeyword) ||
            (gear.description?.toLowerCase().contains(lowercaseKeyword) ??
                false) ||
            (gear.brand?.toLowerCase().contains(lowercaseKeyword) ?? false))
        .toList();
  }

  @override
  Future<GearPurchaseOptionsModel> getGearPurchaseOptions(String gearId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    final purchaseOptionsJson =
        await _loadJsonData('assets/mock_data/gear_purchase_options.json');
    if (purchaseOptionsJson == null) {
      throw Exception('Failed to load gear purchase options');
    }

    // 查找指定装备的购买选项
    final gearOptions = purchaseOptionsJson.firstWhere(
      (option) => option['gearId'] == gearId,
      orElse: () =>
          throw Exception('Purchase options not found for gear: $gearId'),
    );

    return GearPurchaseOptionsModel.fromJson(gearOptions);
  }

  @override
  Future<List<GearRentalOptionModel>> getGearRentalOptions(String gearId,
      {String? location}) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    final rentalOptionsJson =
        await _loadJsonData('assets/mock_data/gear_rental_options.json');
    if (rentalOptionsJson == null || !(rentalOptionsJson is List)) {
      return [];
    }

    // 筛选指定装备的租赁选项
    List<GearRentalOptionModel> options = [];
    for (var option in rentalOptionsJson) {
      if (option['gearId'] == gearId) {
        options.add(GearRentalOptionModel.fromJson(option));
      }
    }

    // 如果指定了位置，进一步筛选
    if (location != null && location.isNotEmpty) {
      options = options
          .where((option) =>
              option.location.toLowerCase().contains(location.toLowerCase()))
          .toList();
    }

    return options;
  }
}
