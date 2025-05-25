import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:walk/model/model/route/route_model.dart';
import 'package:walk/model/route/daily_itinerary_model.dart';
import 'package:walk/service/trip_plan_service.dart';
import 'package:walk/ui/page/trip_plan/components/section_title_widget.dart';
import 'package:walk/ui/page/trip_plan/components/daily_itinerary_card.dart';
import 'package:walk/ui/page/trip_plan/components/timeline_card.dart';
import 'package:walk/ui/widgets/common/cupertino_card.dart';
import 'package:walk/theme/theme/app_colors.dart';

/// 行程部分
class ItinerarySection extends StatefulWidget {
  /// 路线
  final RouteModel route;

  /// 出发日期
  final DateTime? startDate;

  /// 行程规划服务
  final TripPlanService tripPlanService;

  /// 构造函数
  const ItinerarySection({
    Key? key,
    required this.route,
    required this.startDate,
    required this.tripPlanService,
  }) : super(key: key);

  @override
  State<ItinerarySection> createState() => _ItinerarySectionState();
}

class _ItinerarySectionState extends State<ItinerarySection> {
  /// 当前视图模式
  int _viewMode = 0; // 0: 时间线, 1: 每日行程, 2: 地图视图

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 视图切换控制器
        _buildCardSegmentControl(),

        const SizedBox(height: 16),

        // 当前视图内容
        Expanded(
          child: _buildCurrentView(),
        ),
      ],
    );
  }

  /// 构建卡片式分段控制器
  Widget _buildCardSegmentControl() {
    final segments = [
      {'icon': CupertinoIcons.time_solid, 'label': '时间线'},
      {'icon': CupertinoIcons.calendar_today, 'label': '每日行程'},
      {'icon': CupertinoIcons.map, 'label': '地图视图'},
    ];

    return Container(
      height: 80,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(segments.length, (index) {
          final isSelected = _viewMode == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _viewMode = index;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      segments[index]['icon'] as IconData,
                      color: isSelected
                          ? CupertinoColors.white
                          : CupertinoColors.systemGrey,
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      segments[index]['label'] as String,
                      style: TextStyle(
                        color: isSelected
                            ? CupertinoColors.white
                            : CupertinoColors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  /// 构建当前视图
  Widget _buildCurrentView() {
    switch (_viewMode) {
      case 0:
        return _buildTimelineView();
      case 1:
        return _buildDailyItineraryView();
      case 2:
        return _buildMapView();
      default:
        return const SizedBox.shrink();
    }
  }

  /// 构建时间线视图
  Widget _buildTimelineView() {
    return FutureBuilder(
      future: widget.tripPlanService.getTimelineData(widget.route.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CupertinoActivityIndicator(),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const Center(
            child: Text('无法加载行程时间线'),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: CupertinoColors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: CupertinoColors.systemGrey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 标题栏
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                CupertinoIcons.time_solid,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                '行程时间线',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
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
                            onPressed: () {
                              // TODO: 打开时间线编辑器
                            },
                          ),
                        ],
                      ),
                    ),

                    // 内容
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: TimelineCard(
                        timelineData: snapshot.data!,
                        startDate: widget.startDate,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 构建每日行程视图
  Widget _buildDailyItineraryView() {
    return FutureBuilder<List<DailyItinerary>>(
      future: widget.tripPlanService.getDailyItineraries(
        widget.route.id,
        widget.startDate,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CupertinoActivityIndicator(),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const Center(
            child: Text('无法加载每日行程'),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: CupertinoColors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: CupertinoColors.systemGrey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 标题栏
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                CupertinoIcons.calendar,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                '每日行程',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              CupertinoButton(
                                padding: EdgeInsets.zero,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: CupertinoColors.activeBlue,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    '添加',
                                    style: TextStyle(
                                      color: CupertinoColors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  // TODO: 添加行程日
                                },
                              ),
                              const SizedBox(width: 8),
                              CupertinoButton(
                                padding: EdgeInsets.zero,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
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
                                onPressed: () {
                                  // TODO: 打开行程编辑器
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // 内容
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: DailyItineraryCard(
                        dailyItineraries: snapshot.data!,
                        onEdit: () {
                          // TODO: 打开每日行程编辑器
                        },
                        onAddDay: () {
                          // TODO: 添加行程日
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 构建地图视图
  Widget _buildMapView() {
    return const Center(
      child: Text('地图视图 - 开发中'),
    );
  }
}
