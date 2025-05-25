import 'package:walk/model/equipment/equipment_item_model.dart';
import 'package:walk/model/model/trip/trip_model.dart';
import 'package:walk/model/route/daily_itinerary_model.dart';
import 'package:walk/model/transportation/transportation_plan_model.dart';
import 'package:walk/ui/page/trip_plan/components/timeline_card.dart';

/// 行程计划服务接口
abstract class TripPlanService {
  /// 获取用户行程计划列表
  Future<List<TripModel>> getUserTripPlans();

  /// 获取行程计划详情
  Future<TripModel> getTripPlanById(String id);

  /// 创建行程计划
  Future<TripModel> createTripPlan(TripModel tripPlan);

  /// 更新行程计划
  Future<TripModel> updateTripPlan(TripModel tripPlan);

  /// 删除行程计划
  Future<bool> deleteTripPlan(String id);

  /// 获取未完成行程计划数量
  int getUnfinishedTripPlansCount();

  /// 获取路线行程安排
  Future<List<DailyItinerary>> getRouteItineraries(String routeId);

  /// 获取推荐装备清单
  Future<List<EquipmentItemModel>> getRecommendedEquipment(
      String routeId, int days);

  /// 获取时间线数据
  Future<TimelineData> getTimelineData(String routeId);

  /// 获取交通方案
  Future<List<TransportationPlanModel>> getTransportationPlans(
    String routeId,
    String departureCity,
    DateTime? startDate,
  );

  /// 获取每日行程
  Future<List<DailyItinerary>> getDailyItineraries(
    String routeId,
    DateTime? startDate,
  );

  /// 获取装备清单
  Future<List<EquipmentItemModel>> getEquipmentList(
    String routeId,
    int participantCount,
  );

  /// 保存行程计划
  Future<bool> saveTripPlan(
    String routeId,
    String departureCity,
    DateTime? startDate,
    int participantCount,
    List<TransportationPlanModel> transportationPlans,
    List<DailyItinerary> dailyItineraries,
    List<EquipmentItemModel> equipmentList,
  );
}
