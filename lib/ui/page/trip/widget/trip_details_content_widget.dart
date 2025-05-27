import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:walk/model/equipment/equipment_list_model.dart';
import 'package:walk/model/trip/trip_model.dart';
import 'package:walk/model/trip/trip_day_plan_model.dart';
import 'package:walk/model/user/user_model.dart';
import 'package:walk/theme/theme/app_colors.dart';
import 'package:walk/ui/page/trip/widget/trip_basic_info_card_widget.dart';
import 'package:walk/ui/page/trip/widget/trip_card_template.dart';
import 'package:walk/ui/page/trip/widget/trip_cover_widget.dart';
import 'package:walk/ui/page/trip/widget/trip_equipment_card_widget.dart';
import 'package:walk/ui/page/trip/widget/trip_food_widget.dart';
import 'package:walk/ui/page/trip/widget/trip_itinerary_card_widget.dart';
import 'package:walk/ui/page/trip/widget/trip_participants_widget.dart';
import 'package:walk/ui/page/trip/widget/trip_transportation_card_widget.dart';
import 'package:walk/ui/page/trip/widget/trip_transportation_widget.dart';
import 'package:walk/ui/page/trip/widget/trip_water_widget.dart';
import 'package:walk/ui/page/trip/widget/trip_weather_card_widget.dart';

/// 行程详情内容组件
///
/// 封装行程详情页的所有内容卡片，包括基本信息、行程描述、参与者等
class TripDetailsContentWidget extends StatelessWidget {
  /// 行程数据
  final TripModel trip;

  /// 是否处于编辑模式
  final bool isEditMode;

  /// 当前正在编辑的部分ID
  final String? editingSectionId;

  /// 编辑中的行程数据
  final TripModel? editingTrip;

  /// 滚动控制器
  final ScrollController scrollController;

  /// 编辑按钮点击回调
  final Function(String) onEdit;

  /// 保存按钮点击回调
  final Function(String) onSave;

  /// 切换编辑模式回调
  final VoidCallback onToggleEditMode;

  /// 日期选择器显示回调
  final Function(DateTime, Function(DateTime)) onShowDatePicker;

  /// 行程数据更新回调
  final Function(TripModel) onTripUpdated;

  /// 构造函数
  const TripDetailsContentWidget({
    Key? key,
    required this.trip,
    required this.isEditMode,
    required this.editingSectionId,
    required this.editingTrip,
    required this.scrollController,
    required this.onEdit,
    required this.onSave,
    required this.onToggleEditMode,
    required this.onShowDatePicker,
    required this.onTripUpdated,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
              endPoint: day.startWaypointId,
              distance: 5.0, // 模拟数据
              elevationGain: 200, // 模拟数据
              elevationLoss: 150, // 模拟数据
              estimatedTime: 3.5, // 模拟数据
              notes: "",
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
                equipments: [],
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

    // 创建交通信息列表
    final transportations = _createTransportationList(trip);

    // 创建天气信息列表
    final weatherList = _createWeatherList(trip);

    return CustomScrollView(
      controller: scrollController,
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
                // 行程基本信息卡片
                TripBasicInfoCardWidget(
                  trip: trip,
                  isEditMode: isEditMode,
                  editingSectionId: editingSectionId,
                  onEdit: onEdit,
                  onSave: onSave,
                  onToggleEditMode: onToggleEditMode,
                  onNameChanged: (value) {
                    if (editingTrip != null) {
                      final updatedTrip = editingTrip!;
                      updatedTrip.name = value;
                      onTripUpdated(updatedTrip);
                    }
                  },
                  onStartDateSelected: (date) {
                    if (editingTrip != null) {
                      final updatedTrip = editingTrip!;
                      updatedTrip.startDate = date;
                      onTripUpdated(updatedTrip);
                    }
                  },
                  onEndDateSelected: (date) {
                    if (editingTrip != null) {
                      final updatedTrip = editingTrip!;
                      updatedTrip.endDate = date;
                      onTripUpdated(updatedTrip);
                    }
                  },
                  onShowDatePicker: onShowDatePicker,
                ),

                const SizedBox(height: 24),

                // 行程描述卡片
                TripCardTemplate(
                  title: '行程描述',
                  icon: CupertinoIcons.doc_text,
                  usePrimaryHeader: false,
                  actionButton: _buildActionButton('description'),
                  content: isEditMode && editingSectionId == 'description'
                      ? CupertinoTextField(
                          padding: const EdgeInsets.all(12),
                          maxLines: 5,
                          placeholder: '请输入行程描述',
                          decoration: BoxDecoration(
                            border:
                                Border.all(color: CupertinoColors.systemGrey4),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          controller:
                              TextEditingController(text: trip.description),
                          onChanged: (value) {
                            if (editingTrip != null) {
                              final updatedTrip = editingTrip!;
                              updatedTrip.description = value;
                              onTripUpdated(updatedTrip);
                            }
                          },
                        )
                      : Text(
                          trip.description,
                          style: const TextStyle(
                            fontSize: 16,
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                ),

                const SizedBox(height: 24),

                // 参与者卡片
                TripCardTemplate(
                  title: '参与者',
                  icon: CupertinoIcons.person_2,
                  usePrimaryHeader: true,
                  actionButton: _buildActionButton('participants'),
                  content: Column(
                    children: [
                      TripParticipantsWidget(
                        participants: participants,
                      ),
                      if (isEditMode && editingSectionId == 'participants') ...[
                        const SizedBox(height: 16),
                        CupertinoButton(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 8),
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                CupertinoIcons.person_add,
                                color: AppColors.primary,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '添加参与者',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          onPressed: () {
                            // TODO: 显示添加参与者对话框
                          },
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 行程安排卡片
                TripItineraryCardWidget(
                  trip: trip,
                  itinerary: itinerary,
                  isEditMode: isEditMode,
                  editingSectionId: editingSectionId,
                  onEdit: onEdit,
                  onSave: onSave,
                ),

                const SizedBox(height: 24),

                // 交通安排卡片
                TripTransportationCardWidget(
                  transportations: transportations,
                  isEditMode: isEditMode,
                  editingSectionId: editingSectionId,
                  onEdit: onEdit,
                  onSave: onSave,
                ),

                const SizedBox(height: 24),

                // 天气预报卡片
                TripWeatherCardWidget(
                  weatherList: weatherList,
                  isEditMode: isEditMode,
                  editingSectionId: editingSectionId,
                  onEdit: onEdit,
                  onSave: onSave,
                ),

                if (equipmentList != null) ...[
                  const SizedBox(height: 24),

                  // 装备清单卡片
                  TripEquipmentCardWidget(
                    listModel: equipmentList,
                    isEditMode: isEditMode,
                    editingSectionId: editingSectionId,
                    onEdit: onEdit,
                    onSave: onSave,
                  ),
                ],

                // 膳食计划卡片
                if (trip.mealPlan != null) ...[
                  const SizedBox(height: 24),
                  TripCardTemplate(
                    title: '膳食计划',
                    icon: CupertinoIcons.cart,
                    usePrimaryHeader: true,
                    actionButton: _buildActionButton('meal'),
                    content: Column(
                      children: [
                        TripFoodWidget(
                          mealPlan: trip.mealPlan,
                        ),
                        if (isEditMode && editingSectionId == 'meal') ...[
                          const SizedBox(height: 16),
                          CupertinoButton(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 8),
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  CupertinoIcons.pencil,
                                  color: AppColors.primary,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '编辑膳食计划',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            onPressed: () {
                              // TODO: 显示编辑膳食计划对话框
                            },
                          ),
                        ],
                      ],
                    ),
                    infoText: '根据行程强度，每人每天需要约2500-3000卡路里的热量摄入',
                  ),
                ],

                // 饮水计划卡片
                if (trip.waterPlan != null) ...[
                  const SizedBox(height: 24),
                  TripCardTemplate(
                    title: '饮水计划',
                    icon: CupertinoIcons.drop,
                    usePrimaryHeader: false,
                    actionButton: _buildActionButton('water'),
                    content: Column(
                      children: [
                        TripWaterWidget(
                          waterPlan: trip.waterPlan,
                        ),
                        if (isEditMode && editingSectionId == 'water') ...[
                          const SizedBox(height: 16),
                          CupertinoButton(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 8),
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  CupertinoIcons.pencil,
                                  color: AppColors.primary,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '编辑饮水计划',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            onPressed: () {
                              // TODO: 显示编辑饮水计划对话框
                            },
                          ),
                        ],
                      ],
                    ),
                    warningText: '自然水源需要过滤或煮沸后饮用，建议携带便携式水过滤器',
                  ),
                ],

                // 备注卡片
                if (trip.notes != null && trip.notes!.isNotEmpty ||
                    isEditMode) ...[
                  const SizedBox(height: 24),
                  TripCardTemplate(
                    title: '备注',
                    icon: CupertinoIcons.doc_text,
                    usePrimaryHeader: true,
                    actionButton: _buildActionButton('notes'),
                    content: isEditMode && editingSectionId == 'notes'
                        ? CupertinoTextField(
                            padding: const EdgeInsets.all(12),
                            maxLines: 3,
                            placeholder: '请输入备注信息',
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: CupertinoColors.systemGrey4),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            controller: TextEditingController(text: trip.notes),
                            onChanged: (value) {
                              if (editingTrip != null) {
                                final updatedTrip = editingTrip!;
                                updatedTrip.notes = value;
                                onTripUpdated(updatedTrip);
                              }
                            },
                          )
                        : Text(
                            trip.notes ?? '暂无备注',
                            style: const TextStyle(
                              fontSize: 16,
                              color: CupertinoColors.systemGrey,
                            ),
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

  /// 构建操作按钮（编辑/保存）
  Widget? _buildActionButton(String sectionId) {
    if (!isEditMode) return null;

    if (editingSectionId == sectionId) {
      // 保存按钮
      return CupertinoButton(
        padding: EdgeInsets.zero,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            '保存',
            style: TextStyle(
              color: CupertinoColors.white,
              fontSize: 14,
            ),
          ),
        ),
        onPressed: () => onSave(sectionId),
      );
    } else {
      // 编辑按钮
      return CupertinoButton(
        padding: EdgeInsets.zero,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            '编辑',
            style: TextStyle(
              color: CupertinoColors.white,
              fontSize: 14,
            ),
          ),
        ),
        onPressed: () => onEdit(sectionId),
      );
    }
  }

  /// 从行程数据创建交通信息列表
  List<TransportationInfo> _createTransportationList(TripModel trip) {
    final List<TransportationInfo> transportations = [];

    // 从行程数据中提取交通信息
    // 这里使用行程的日程信息来构建交通信息
    if (trip.itinerary.isNotEmpty) {
      // 添加去程交通
      final firstDay = trip.itinerary.first;
      if (firstDay.transportation != null) {
        transportations.add(
          TransportationInfo(
            type: '去程',
            from: '出发地',
            to: firstDay.accommodation ?? firstDay.title,
            method: firstDay.transportation!,
            time: '${firstDay.date.month}月${firstDay.date.day}日',
            isBooked: true,
          ),
        );
      }

      // 添加行程中的交通
      for (int i = 1; i < trip.itinerary.length; i++) {
        final prevDay = trip.itinerary[i - 1];
        final currentDay = trip.itinerary[i];

        if (currentDay.transportation != null) {
          transportations.add(
            TransportationInfo(
              type: '中转',
              from: prevDay.accommodation ?? prevDay.title,
              to: currentDay.accommodation ?? currentDay.title,
              method: currentDay.transportation!,
              time: '${currentDay.date.month}月${currentDay.date.day}日',
              isBooked: i < trip.itinerary.length - 1, // 假设除了最后一天，其他都已预订
            ),
          );
        }
      }

      // 添加返程交通
      final lastDay = trip.itinerary.last;
      if (lastDay.transportation != null) {
        transportations.add(
          TransportationInfo(
            type: '返程',
            from: lastDay.accommodation ?? lastDay.title,
            to: '目的地',
            method: lastDay.transportation!,
            time: '${lastDay.date.month}月${lastDay.date.day}日',
            isBooked: false,
          ),
        );
      }
    }

    // 如果没有从行程数据中提取到交通信息，添加一些示例数据
    if (transportations.isEmpty) {
      transportations.addAll([
        TransportationInfo(
          type: '去程',
          from: '北京',
          to: trip.name,
          method: '高铁 + 大巴',
          time: '${trip.startDate.month}月${trip.startDate.day}日 08:30',
          isBooked: true,
        ),
        TransportationInfo(
          type: '返程',
          from: trip.name,
          to: '北京',
          method: '大巴 + 高铁',
          time: '${trip.endDate.month}月${trip.endDate.day}日 16:00',
          isBooked: false,
        ),
      ]);
    }

    return transportations;
  }

  /// 创建天气信息列表
  List<WeatherInfo> _createWeatherList(TripModel trip) {
    // 创建示例天气数据
    final List<WeatherInfo> weatherList = [];

    // 计算行程天数
    final tripDays = trip.endDate.difference(trip.startDate).inDays + 1;

    // 为每一天创建天气信息
    for (int i = 0; i < tripDays; i++) {
      weatherList.add(
        WeatherInfo(
          day: '星期一',
          weather: "天晴",
          temperature: '${18 + i}°/${8 + i}°',
          icon: Icons.sunny,
        ),
      );
    }

    return weatherList;
  }
}
