import 'dart:convert';
import 'package:flutter/services.dart';
import '../trip_plan_service.dart';
// import '../../model/trip/trip_plan_model.dart';
import '../../model/equipment/equipment_item_model.dart';
import '../../model/route/daily_itinerary_model.dart';
import '../../model/transportation/transportation_plan_model.dart';

/// Mock行程计划服务实现
class MockTripPlanService implements TripPlanService {
  // /// 单例实例
  // static final MockTripPlanService _instance = MockTripPlanService._internal();

  // /// 工厂构造函数
  // factory MockTripPlanService() {
  //   return _instance;
  // }

  // /// 私有构造函数
  // MockTripPlanService._internal();

  // /// 从JSON文件加载数据
  // Future<dynamic> _loadJsonData(String path) async {
  //   try {
  //     final String jsonString = await rootBundle.loadString(path);
  //     return json.decode(jsonString);
  //   } catch (e) {
  //     print('加载JSON文件失败: $e');
  //     return null;
  //   }
  // }

  // @override
  // Future<List<TripPlanModel>> getUserTripPlans() async {
  //   // 模拟网络延迟
  //   await Future.delayed(const Duration(milliseconds: 400));

  //   final plansJson = await _loadJsonData('assets/mock_data/trip_plans.json');
  //   if (plansJson == null || !(plansJson is List)) {
  //     return [];
  //   }

  //   List<TripPlanModel> plans = plansJson
  //       .map<TripPlanModel>((json) => TripPlanModel.fromJson(json))
  //       .toList();

  //   // 按创建时间排序
  //   if (plans.isNotEmpty && plans.first.createdAt != null) {
  //     plans.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
  //   }

  //   return plans;
  // }

  // @override
  // Future<TripPlanModel> getTripPlanById(String id) async {
  //   // 模拟网络延迟
  //   await Future.delayed(const Duration(milliseconds: 400));

  //   final plansJson = await _loadJsonData('assets/mock_data/trip_plans.json');
  //   if (plansJson == null || !(plansJson is List)) {
  //     throw Exception('Failed to load trip plans');
  //   }

  //   final planJson = plansJson.firstWhere(
  //     (plan) => plan['id'] == id,
  //     orElse: () => throw Exception('Trip plan not found: $id'),
  //   );

  //   return TripPlanModel.fromJson(planJson);
  // }

  // @override
  // Future<TripPlanModel> createTripPlan(TripPlanModel tripPlan) async {
  //   // 模拟网络延迟
  //   await Future.delayed(const Duration(milliseconds: 400));

  //   // 模拟创建成功，返回带有ID的对象
  //   final now = DateTime.now();
  //   return tripPlan.copyWith(
  //     id: 'plan_${now.millisecondsSinceEpoch}',
  //     createdAt: now,
  //     updatedAt: now,
  //   );
  // }

  // @override
  // Future<TripPlanModel> updateTripPlan(TripPlanModel tripPlan) async {
  //   // 模拟网络延迟
  //   await Future.delayed(const Duration(milliseconds: 400));

  //   // 模拟更新成功，返回更新后的对象
  //   return tripPlan.copyWith(
  //     updatedAt: DateTime.now(),
  //   );
  // }

  // @override
  // Future<bool> deleteTripPlan(String id) async {
  //   // 模拟网络延迟
  //   await Future.delayed(const Duration(milliseconds: 400));

  //   // 模拟删除成功
  //   return true;
  // }

  // @override
  // int getUnfinishedTripPlansCount() {
  //   // 返回一个固定值，实际应用中应该从缓存中获取
  //   return 3;
  // }

  // @override
  // Future<List<DailyItinerary>> getRouteItineraries(String routeId) async {
  //   // 模拟网络延迟
  //   await Future.delayed(const Duration(milliseconds: 400));

  //   final itinerariesJson =
  //       await _loadJsonData('assets/mock_data/daily_itineraries.json');
  //   if (itinerariesJson == null || !(itinerariesJson is List)) {
  //     return [];
  //   }

  //   // 查找指定路线的行程
  //   final routeData = itinerariesJson.firstWhere(
  //     (item) => item['routeId'] == routeId,
  //     orElse: () => {'itineraries': []},
  //   );

  //   if (routeData['itineraries'] == null ||
  //       !(routeData['itineraries'] is List)) {
  //     return [];
  //   }

  //   return (routeData['itineraries'] as List)
  //       .map<DailyItinerary>((json) => DailyItinerary.fromJson(json))
  //       .toList();
  // }

  // @override
  // Future<List<EquipmentItemModel>> getRecommendedEquipment(
  //     String routeId, int days) async {
  //   // 模拟网络延迟
  //   await Future.delayed(const Duration(milliseconds: 400));

  //   final equipmentJson =
  //       await _loadJsonData('assets/mock_data/recommended_equipment.json');
  //   if (equipmentJson == null || !(equipmentJson is List)) {
  //     return [];
  //   }

  //   // 查找指定路线的装备
  //   final routeData = equipmentJson.firstWhere(
  //     (item) => item['routeId'] == routeId,
  //     orElse: () => {'items': []},
  //   );

  //   if (routeData['items'] == null || !(routeData['items'] is List)) {
  //     return [];
  //   }

  //   // 根据天数调整装备数量（例如，增加更多的衣物）
  //   List<EquipmentItemModel> equipment = (routeData['items'] as List)
  //       .map<EquipmentItemModel>((json) => EquipmentItemModel.fromJson(json))
  //       .toList();

  //   // 如果天数超过3天，增加一些额外装备
  //   if (days > 3) {
  //     // 这里可以添加一些逻辑来增加装备数量或种类
  //   }

  //   return equipment;
  // }

  // @override
  // Future<List<TransportationPlanModel>> getTransportationPlans(
  //     String from, String to) async {
  //   // 模拟网络延迟
  //   await Future.delayed(const Duration(milliseconds: 400));

  //   final transportationJson =
  //       await _loadJsonData('assets/mock_data/transportation_plans.json');
  //   if (transportationJson == null || !(transportationJson is List)) {
  //     return [];
  //   }

  //   // 筛选符合条件的交通方案
  //   List<TransportationPlanModel> plans = transportationJson
  //       .where((plan) =>
  //           plan['departureCity'] == from && plan['destinationCity'] == to)
  //       .map<TransportationPlanModel>(
  //           (json) => TransportationPlanModel.fromJson(json))
  //       .toList();

  //   return plans;
  // }
}
