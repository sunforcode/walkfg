import 'package:walk/model/equipment/equipment_item_model.dart';
import 'package:walk/model/route/daily_itinerary_model.dart';
import 'package:walk/model/transportation/transportation_plan_model.dart';

/// 行程计划服务接口
abstract class TripPlanService {
  /// 获取用户行程计划列表
  // Future<List<TripPlanModel>> getUserTripPlans();

  // /// 获取行程计划详情
  // Future<TripPlanModel> getTripPlanById(String id);

  // /// 创建行程计划
  // Future<TripPlanModel> createTripPlan(TripPlanModel tripPlan);

  // /// 更新行程计划
  // Future<TripPlanModel> updateTripPlan(TripPlanModel tripPlan);

  // /// 删除行程计划
  // Future<bool> deleteTripPlan(String id);

  // /// 获取未完成行程计划数量
  // int getUnfinishedTripPlansCount();

  // /// 获取路线行程安排
  // Future<List<DailyItinerary>> getRouteItineraries(String routeId);

  // /// 获取推荐装备清单
  // Future<List<EquipmentItemModel>> getRecommendedEquipment(
  //     String routeId, int days);

  // /// 获取交通方案
  // Future<List<TransportationPlanModel>> getTransportationPlans(
  //     String from, String to);
}

