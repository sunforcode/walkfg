import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:walk/ui/page/trip_plan/components/timeline_card.dart';
import '../trip_plan_service.dart';
import '../../model/model/trip/trip_model.dart';
import '../../model/equipment/equipment_item_model.dart';
import '../../model/route/daily_itinerary_model.dart';
import '../../model/transportation/transportation_plan_model.dart';

/// Mock行程计划服务实现
class MockTripPlanService implements TripPlanService {
  /// 单例实例
  static final MockTripPlanService _instance = MockTripPlanService._internal();

  /// 工厂构造函数
  factory MockTripPlanService() {
    return _instance;
  }

  /// 私有构造函数
  MockTripPlanService._internal();

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
  Future<List<TripModel>> getUserTripPlans() async {
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

  @override
  Future<TripModel> getTripPlanById(String id) async {
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

  @override
  Future<TripModel> createTripPlan(TripModel tripPlan) async {
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

  @override
  Future<TripModel> updateTripPlan(TripModel tripPlan) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 模拟更新成功，返回更新后的对象
    return tripPlan.copyWith(
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<bool> deleteTripPlan(String id) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 模拟删除成功
    return true;
  }

  @override
  int getUnfinishedTripPlansCount() {
    // 返回一个固定值，实际应用中应该从缓存中获取
    return 3;
  }

  @override
  Future<List<DailyItinerary>> getRouteItineraries(String routeId) async {
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

  @override
  Future<List<EquipmentItemModel>> getRecommendedEquipment(
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

  @override
  Future<TimelineData> getTimelineData(String routeId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      // 创建模拟数据
      return TimelineData(
        items: [
          TimelineItem(
            title: '北京 → 五台山',
            subtitle: '高铁+大巴 (约4小时)',
            icon: CupertinoIcons.airplane,
          ),
          TimelineItem(
            title: '五台山东线徒步',
            subtitle: '显通寺→塔院寺 (12公里)',
            icon: CupertinoIcons.map,
          ),
          TimelineItem(
            title: '五台山西线徒步',
            subtitle: '菩萨顶→南山寺 (15公里)',
            icon: CupertinoIcons.map,
          ),
          TimelineItem(
            title: '五台山 → 北京',
            subtitle: '大巴+高铁 (约4.5小时)',
            icon: CupertinoIcons.airplane,
          ),
        ],
      );
    } catch (e) {
      print('获取时间线数据失败: $e');
      return TimelineData(items: []);
    }
  }

  @override
  Future<List<TransportationPlanModel>> getTransportationPlans(
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

  @override
  Future<List<DailyItinerary>> getDailyItineraries(
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

  @override
  Future<List<EquipmentItemModel>> getEquipmentList(
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

  @override
  Future<bool> saveTripPlan(
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

  /// 加载JSON资源文件
  Future<String?> _loadJsonAsset(String path) async {
    try {
      return await rootBundle.loadString(path);
    } catch (e) {
      print('加载JSON文件失败: $path, 错误: $e');
      return null;
    }
  }
}
