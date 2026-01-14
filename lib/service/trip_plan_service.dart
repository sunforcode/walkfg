import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:walk/model/equipment/equipment_item_model.dart';
import 'package:walk/model/trip/trip_model.dart';
import 'package:walk/model/route/daily_itinerary_model.dart';
import 'package:walk/model/transportation/transportation_plan_model.dart';

/// 行程计划服务
///
/// 使用静态方法，无需实例化
/// 当前使用本地 JSON 数据，后续可改为 API 请求
class TripPlanService {
  // 禁止实例化
  TripPlanService._();

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

  /// 加载JSON资源文件
  static Future<String?> _loadJsonAsset(String path) async {
    try {
      return await rootBundle.loadString(path);
    } catch (e) {
      print('加载JSON文件失败: $path, 错误: $e');
      return null;
    }
  }

  /// 获取用户行程计划列表
  static Future<List<TripModel>> getUserTripPlans() async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    final plansJson = await _loadJsonData('assets/mock_data/trip_plans.json');
    if (plansJson == null || !(plansJson is List)) {
      return [];
    }

    List<TripModel> plans =
        plansJson.map<TripModel>((json) => TripModel.fromJson(json)).toList();

    // 按创建时间排序
    if (plans.isNotEmpty && plans.first.createdAt != null) {
      plans.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
    }

    return plans;
  }

  /// 获取行程计划详情
  static Future<TripModel> getTripPlanById(String id) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    final plansJson = await _loadJsonData('assets/mock_data/trip_plans.json');
    if (plansJson == null || !(plansJson is List)) {
      throw Exception('Failed to load trip plans');
    }

    final planJson = plansJson.firstWhere(
      (plan) => plan['id'] == id,
      orElse: () => throw Exception('Trip plan not found: $id'),
    );

    return TripModel.fromJson(planJson);
  }

  /// 创建行程计划
  static Future<TripModel> createTripPlan(TripModel tripPlan) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 模拟创建成功，返回带有ID的对象
    final now = DateTime.now();
    return tripPlan.copyWith(
      id: 'plan_${now.millisecondsSinceEpoch}',
      createdAt: now,
      updatedAt: now,
    );
  }

  /// 更新行程计划
  static Future<TripModel> updateTripPlan(TripModel tripPlan) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 模拟更新成功，返回更新后的对象
    return tripPlan.copyWith(
      updatedAt: DateTime.now(),
    );
  }

  /// 删除行程计划
  static Future<bool> deleteTripPlan(String id) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 模拟删除成功
    return true;
  }

  /// 获取未完成行程计划数量
  static int getUnfinishedTripPlansCount() {
    // 返回一个固定值，实际应用中应该从缓存中获取
    return 3;
  }

  /// 获取路线行程安排
  static Future<List<DailyItinerary>> getRouteItineraries(String routeId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    final itinerariesJson =
        await _loadJsonData('assets/mock_data/daily_itineraries.json');
    if (itinerariesJson == null || !(itinerariesJson is List)) {
      return [];
    }

    // 查找指定路线的行程
    final routeData = itinerariesJson.firstWhere(
      (item) => item['routeId'] == routeId,
      orElse: () => {'itineraries': []},
    );

    if (routeData['itineraries'] == null ||
        !(routeData['itineraries'] is List)) {
      return [];
    }

    return (routeData['itineraries'] as List)
        .map<DailyItinerary>((json) => DailyItinerary.fromJson(json))
        .toList();
  }

  /// 获取推荐装备清单
  static Future<List<EquipmentItemModel>> getRecommendedEquipment(
      String routeId, int days) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    final equipmentJson =
        await _loadJsonData('assets/mock_data/recommended_equipment.json');
    if (equipmentJson == null || !(equipmentJson is List)) {
      return [];
    }

    // 查找指定路线的装备
    final routeData = equipmentJson.firstWhere(
      (item) => item['routeId'] == routeId,
      orElse: () => {'items': []},
    );

    if (routeData['items'] == null || !(routeData['items'] is List)) {
      return [];
    }

    // 根据天数调整装备数量（例如，增加更多的衣物）
    List<EquipmentItemModel> equipment = (routeData['items'] as List)
        .map<EquipmentItemModel>((json) => EquipmentItemModel.fromJson(json))
        .toList();

    // 如果天数超过3天，增加一些额外装备
    if (days > 3) {
      // 这里可以添加一些逻辑来增加装备数量或种类
    }

    return equipment;
  }

  /// 获取交通方案
  static Future<List<TransportationPlanModel>> getTransportationPlans(
    String routeId,
    String departureCity,
    DateTime? startDate,
  ) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 500));
    // 尝试从JSON文件加载数据
    final jsonString =
        await _loadJsonAsset('assets/mock_data/transportation_plans.json');
    final List<dynamic> jsonList = json.decode(jsonString!);
    return jsonList
        .map((json) => TransportationPlanModel.fromJson(json))
        .toList();
  }

  /// 获取每日行程
  static Future<List<DailyItinerary>> getDailyItineraries(
    String routeId,
    DateTime? startDate,
  ) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      // 尝试从JSON文件加载数据
      final jsonString =
          await _loadJsonAsset('assets/mock_data/daily_itineraries.json');

      final List<dynamic> jsonList = json.decode(jsonString!);
      return jsonList.map((json) => DailyItinerary.fromJson(json)).toList();
    } catch (e) {
      print('获取每日行程失败: $e');
      return [];
    }
  }

  /// 获取装备清单
  static Future<List<EquipmentItemModel>> getEquipmentList(
    String routeId,
    int participantCount,
  ) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      // 尝试从JSON文件加载数据
      final jsonString =
          await _loadJsonAsset('assets/mock_data/equipment_list.json');
      final List<dynamic> jsonList = json.decode(jsonString!);
      return jsonList.map((json) => EquipmentItemModel.fromJson(json)).toList();
    } catch (e) {
      print('获取装备清单失败: $e');
      return [];
    }
  }

  /// 保存行程计划
  static Future<bool> saveTripPlan(
    String routeId,
    String departureCity,
    DateTime? startDate,
    int participantCount,
    List<TransportationPlanModel> transportationPlans,
    List<DailyItinerary> dailyItineraries,
    List<EquipmentItemModel> equipmentList,
  ) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      // 模拟保存成功
      print('保存行程计划成功');
      print('路线ID: $routeId');
      print('出发城市: $departureCity');
      print('出发日期: $startDate');
      print('参与人数: $participantCount');
      print('交通方案数量: ${transportationPlans.length}');
      print('每日行程数量: ${dailyItineraries.length}');
      print('装备清单数量: ${equipmentList.length}');

      return true;
    } catch (e) {
      print('保存行程计划失败: $e');
      return false;
    }
  }
}
