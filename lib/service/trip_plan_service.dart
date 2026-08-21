import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:walk/model/trip/trip_model.dart';
import 'package:walk/model/route/daily_itinerary_model.dart';
import 'package:walk/model/transportation/transportation_plan_model.dart';

/// 行程计划服务（本地数据，后端暂未实现）
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
      debugPrint('加载JSON文件失败: $e');
      return null;
    }
  }

  /// 加载JSON资源文件
  static Future<String?> _loadJsonAsset(String path) async {
    try {
      return await rootBundle.loadString(path);
    } catch (e) {
      debugPrint('加载JSON文件失败: $path, 错误: $e');
      return null;
    }
  }

  /// 获取用户行程计划列表
  static Future<List<TripModel>> getUserTripPlans() async {
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
    // 模拟更新成功，返回更新后的对象
    return tripPlan.copyWith(
      updatedAt: DateTime.now(),
    );
  }

  /// 删除行程计划
  static Future<bool> deleteTripPlan(String id) async {
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

  /// 获取交通方案
  static Future<List<TransportationPlanModel>> getTransportationPlans(
    String routeId,
    String departureCity,
    DateTime? startDate,
  ) async {
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
    try {
      // 尝试从JSON文件加载数据
      final jsonString =
          await _loadJsonAsset('assets/mock_data/daily_itineraries.json');

      final List<dynamic> jsonList = json.decode(jsonString!);
      return jsonList.map((json) => DailyItinerary.fromJson(json)).toList();
    } catch (e) {
      debugPrint('获取每日行程失败: $e');
      return [];
    }
  }

}
