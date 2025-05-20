import 'package:walk/service/trip_plan_service.dart';
import '../../model/trip_plan_model.dart';
import 'json_data_provider.dart';

/// 模拟行程计划服务实现
class MockTripPlanService implements TripPlanService {
  final JsonDataProvider _dataProvider = JsonDataProvider();

  @override
  Future<List<TripPlanModel>> getUserTripPlans() async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 600));

    // 从JSON数据提供者获取数据
    return _dataProvider.getTripPlans();
  }

  @override
  Future<TripPlanModel> getTripPlanById(String id) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 300));

    // 从JSON数据提供者获取数据
    return _dataProvider.getTripPlanById(id);
  }

  @override
  Future<TripPlanModel> createTripPlan(TripPlanModel tripPlan) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 500));

    // 模拟创建成功，返回带有ID的对象
    final now = DateTime.now();
    return TripPlanModel(
      id: 'new_${now.millisecondsSinceEpoch}',
      userId: tripPlan.userId,
      routeId: tripPlan.routeId,
      routeName: tripPlan.routeName,
      startDate: tripPlan.startDate,
      participantCount: tripPlan.participantCount,
      departureCity: tripPlan.departureCity,
      customizedItinerary: tripPlan.customizedItinerary,
      transportationPlans: tripPlan.transportationPlans,
      equipmentList: tripPlan.equipmentList,
      status: tripPlan.status,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Future<TripPlanModel> updateTripPlan(TripPlanModel tripPlan) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 模拟更新成功，返回更新后的对象
    return TripPlanModel(
      id: tripPlan.id,
      userId: tripPlan.userId,
      routeId: tripPlan.routeId,
      routeName: tripPlan.routeName,
      startDate: tripPlan.startDate,
      participantCount: tripPlan.participantCount,
      departureCity: tripPlan.departureCity,
      customizedItinerary: tripPlan.customizedItinerary,
      transportationPlans: tripPlan.transportationPlans,
      equipmentList: tripPlan.equipmentList,
      status: tripPlan.status,
      createdAt: tripPlan.createdAt,
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<bool> deleteTripPlan(String id) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 300));

    // 模拟删除成功
    return true;
  }

  @override
  int getUnfinishedTripPlansCount() {
    // 模拟数据
    return 2;
  }

  @override
  Future<List<DailyItinerary>> getRouteItineraries(String routeId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 获取路线详情
    final route = await _dataProvider.getRouteById(routeId);

    // 根据路线天数获取行程安排
    final days = route.durationDays;
    return _dataProvider.getItinerary(days);
  }

  @override
  Future<List<EquipmentItemModel>> getRecommendedEquipment(
      String routeId, int days) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 500));

    // 从JSON数据提供者获取装备数据
    return _dataProvider.getEquipment();
  }

  @override
  Future<List<TransportationPlanModel>> getTransportationPlans(
      String from, String to) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 从JSON数据提供者获取交通方案数据
    return _dataProvider.getTransportation(from, to);
  }
}
