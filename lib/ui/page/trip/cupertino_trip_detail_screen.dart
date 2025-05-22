import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:walk/model/model/trip/trip_model.dart';
import 'package:walk/model/equipment/equipment_model.dart';
import 'package:walk/model/equipment/equipment_item_model.dart';
import 'package:walk/model/model/food/meal_plan_model.dart';
import 'package:walk/model/user/user_model.dart';
import 'package:walk/model/trip/trip_day_plan_model.dart';
import 'package:walk/service/service_manager.dart';
import 'package:walk/service/trip_service.dart';
import 'package:walk/ui/page/trip/widget/trip_cover_widget.dart';
import 'package:walk/ui/page/trip/widget/trip_participants_widget.dart';
import 'package:walk/ui/page/trip/widget/trip_itinerary_widget.dart';
import 'package:walk/ui/page/trip/widget/trip_equipment_widget.dart';
import 'package:walk/ui/page/trip/widget/trip_food_widget.dart';
import 'package:walk/ui/page/trip/widget/trip_water_widget.dart';
import 'package:walk/ui/page/trip/widget/section_title_widget.dart';
import 'package:walk/ui/widgets/common/error_widget.dart';
import 'package:walk/ui/widgets/common/loading_indicator.dart';

/// 行程详情页面
class TripDetailScreen extends StatefulWidget {
  /// 行程ID
  final String tripId;

  /// 构造函数
  const TripDetailScreen({
    super.key,
    required this.tripId,
  });

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  late Future<TripModel> _tripFuture;
  final TripService _tripService = ServiceLocator.instance.getTripService();

  @override
  void initState() {
    super.initState();
    _loadTripDetails();
  }

  /// 加载行程详情
  void _loadTripDetails() {
    setState(() {
      _tripFuture = _tripService.getTripById(widget.tripId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('行程详情'),
      ),
      child: SafeArea(
        child: FutureBuilder<TripModel>(
          future: _tripFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingIndicator();
            }

            if (snapshot.hasError) {
              return ErrorMessageWidget(
                errorMessage: snapshot.error.toString(),
                onRetry: _loadTripDetails,
              );
            }

            final trip = snapshot.data;
            if (trip == null) {
              return const Center(
                child: Text('未找到行程信息'),
              );
            }

            return _buildTripDetails(trip);
          },
        ),
      ),
    );
  }

  /// 构建行程详情
  Widget _buildTripDetails(TripModel trip) {
    // 计算行程天数
    final tripDays = trip.endDate.difference(trip.startDate).inDays + 1;

    // 将 ParticipantModel 转换为 UserModel
    final participants = trip.participants
        .map((p) => UserModel(
              id: p.userId,
              username: p.userId,
              nickname: p.name,
              avatarUrl: null,
              completedRoutes: 0,
              equipmentLists: 0,
              favoriteRoutes: 0,
            ))
        .toList();

    // 将 ItineraryDayModel 转换为 TripDayPlanModel
    final itinerary = trip.itinerary
        .map((day) => TripDayPlanModel(
              id: day.id,
              day: day.dayNumber,
              title: day.title,
              description: day.description,
              startPoint: day.accommodation ?? '起点',
              endPoint: day.transportation ?? '终点',
              distance: 5.0, // 模拟数据
              elevationGain: 200, // 模拟数据
              elevationLoss: 150, // 模拟数据
              estimatedTime: 3.5, // 模拟数据
              notes: day.notes,
            ))
        .toList();

    // 创建装备清单模型
    final equipmentList =
        trip.equipmentList != null && trip.equipmentList!.totalItems > 0
            ? EquipmentListModel(
                id: 'equipment-list-${trip.id}',
                name: '${trip.name}装备清单',
                description: '行程装备清单',
                tripDays: tripDays,
                seasons: [SeasonSuitability.allSeasons],
                categories: [
                  EquipmentCategory(
                    name: '装备',
                    items: trip.equipmentList?.allItems ?? [],
                  ),
                ],
                totalWeight: 19,
                baseWeight: 0.0,
                consumableWeight: 0.0,
                wornWeight: 0.0,
                creatorId: trip.organizerId,
                creatorName: trip.participants
                    .firstWhere((p) => p.userId == trip.organizerId,
                        orElse: () => trip.participants.first)
                    .name,
                tags: [],
              )
            : null;

    return CustomScrollView(
      slivers: [
        // 封面图片
        if (trip.coverUrl != null)
          TripCoverWidget(
            trip: trip,
            tripDays: tripDays,
          ),

        // 行程内容
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 行程描述
                const SectionTitleWidget(title: '行程描述'),
                Text(
                  trip.description,
                  style: const TextStyle(
                    fontSize: 16,
                    color: CupertinoColors.systemGrey,
                  ),
                ),

                const SizedBox(height: 24),

                // 参与者
                const SectionTitleWidget(title: '参与者'),
                TripParticipantsWidget(
                  participants: participants,
                ),

                const SizedBox(height: 24),

                // 行程安排
                const SectionTitleWidget(title: '行程安排'),
                TripItineraryWidget(
                  itinerary: itinerary,
                ),

                if (equipmentList != null) ...[
                  const SizedBox(height: 24),

                  // 装备清单
                  const SectionTitleWidget(title: '装备清单'),
                  TripEquipmentWidget(
                    listModel: equipmentList,
                  ),
                ],

                // 膳食计划
                if (trip.mealPlan != null) ...[
                  const SizedBox(height: 24),
                  const SectionTitleWidget(title: '膳食计划'),
                  TripFoodWidget(
                    mealPlan: trip.mealPlan,
                  ),
                ],

                // 饮水计划
                if (trip.waterPlan != null) ...[
                  const SizedBox(height: 24),
                  const SectionTitleWidget(title: '饮水计划'),
                  TripWaterWidget(
                    waterPlan: trip.waterPlan,
                  ),
                ],

                if (trip.notes != null && trip.notes!.isNotEmpty) ...[
                  const SizedBox(height: 24),

                  // 备注
                  const SectionTitleWidget(title: '备注'),
                  Text(
                    trip.notes!,
                    style: const TextStyle(
                      fontSize: 16,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                ],

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
