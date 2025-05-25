import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:walk/model/model/route/route_model.dart';
import 'package:walk/model/transportation/transportation_plan_model.dart';
import 'package:walk/model/transportation/transportation_segment_model.dart';
import 'package:walk/service/trip_plan_service.dart';
import 'package:walk/ui/page/trip_plan/components/section_title_widget.dart';
import 'package:walk/ui/page/trip_plan/components/transportation_card.dart';
import 'package:walk/ui/widgets/common/cupertino_card.dart';
import 'package:walk/theme/theme/app_colors.dart';

/// 交通部分
class TransportationSection extends StatefulWidget {
  /// 路线
  final RouteModel route;

  /// 出发日期
  final DateTime? startDate;

  /// 出发城市
  final String departureCity;

  /// 行程规划服务
  final TripPlanService tripPlanService;

  /// 构造函数
  const TransportationSection({
    Key? key,
    required this.route,
    required this.startDate,
    required this.departureCity,
    required this.tripPlanService,
  }) : super(key: key);

  @override
  State<TransportationSection> createState() => _TransportationSectionState();
}

class _TransportationSectionState extends State<TransportationSection> {
  /// 当前交通方向
  TransportationDirection _currentDirection = TransportationDirection.outbound;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 交通方向切换控制器
        _buildCardSegmentControl(),

        const SizedBox(height: 16),

        // 交通方案内容
        Expanded(
          child: _buildTransportationContent(),
        ),
      ],
    );
  }

  /// 构建卡片式分段控制器
  Widget _buildCardSegmentControl() {
    final segments = [
      {
        'value': TransportationDirection.outbound,
        'label': '去程',
        'icon': CupertinoIcons.arrow_right_circle_fill
      },
      {
        'value': TransportationDirection.inbound,
        'label': '返程',
        'icon': CupertinoIcons.arrow_left_circle_fill
      },
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
          final direction = segments[index]['value'] as TransportationDirection;
          final isSelected = _currentDirection == direction;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _currentDirection = direction;
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
                        fontSize: 16,
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

  /// 构建交通方案内容
  Widget _buildTransportationContent() {
    return FutureBuilder<List<TransportationPlanModel>>(
      future: widget.tripPlanService.getTransportationPlans(
        widget.route.id,
        widget.departureCity,
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
            child: Text('无法加载交通方案'),
          );
        }

        // 筛选当前方向的交通方案
        final directionPlans = snapshot.data!
            .where((plan) => plan.direction == _currentDirection)
            .toList();

        if (directionPlans.isEmpty) {
          return _buildEmptyTransportation();
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
                                _currentDirection ==
                                        TransportationDirection.outbound
                                    ? CupertinoIcons.arrow_right_circle_fill
                                    : CupertinoIcons.arrow_left_circle_fill,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _currentDirection ==
                                        TransportationDirection.outbound
                                    ? '去程交通'
                                    : '返程交通',
                                style: const TextStyle(
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
                              // TODO: 打开交通方案编辑器
                            },
                          ),
                        ],
                      ),
                    ),

                    // 内容
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: TransportationCard(
                        transportationPlans: directionPlans,
                        onEdit: () {
                          // TODO: 打开交通方案编辑器
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 交通预订状态卡片
              _buildBookingStatusCard(directionPlans.first),
            ],
          ),
        );
      },
    );
  }

  /// 构建空交通方案视图
  Widget _buildEmptyTransportation() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CupertinoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SectionTitleWidget(
                      title:
                          _currentDirection == TransportationDirection.outbound
                              ? '去程交通'
                              : '返程交通',
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: const Text('添加'),
                      onPressed: () {
                        // TODO: 添加交通方案
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    '暂无交通方案',
                    style: TextStyle(
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: CupertinoButton.filled(
                    child: const Text('添加交通方案'),
                    onPressed: () {
                      // TODO: 添加交通方案
                    },
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建交通预订状态卡片
  Widget _buildBookingStatusCard(TransportationPlanModel plan) {
    final isBooked = plan.segments.every((segment) => segment.isBooked);

    return Container(
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
              color: isBooked
                  ? CupertinoColors.activeGreen.withOpacity(0.1)
                  : CupertinoColors.systemYellow.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isBooked
                      ? CupertinoIcons.checkmark_circle_fill
                      : CupertinoIcons.exclamationmark_circle_fill,
                  color: isBooked
                      ? CupertinoColors.activeGreen
                      : CupertinoColors.systemYellow,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '预订状态',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: isBooked
                        ? CupertinoColors.activeGreen
                        : CupertinoColors.systemYellow,
                  ),
                ),
              ],
            ),
          ),

          // 内容
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isBooked ? '所有交通已预订完成' : '还有未预订的交通项目',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isBooked ? '您的行程交通已全部预订，请按时出行。' : '建议尽快完成交通预订，以免影响您的行程。',
                  style: const TextStyle(
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                if (!isBooked) ...[
                  const SizedBox(height: 16),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        '前往预订',
                        style: TextStyle(
                          color: CupertinoColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    onPressed: () {
                      // TODO: 跳转到预订页面
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 获取交通类型名称
  String _getTransportationTypeName(TransportationType type) {
    switch (type) {
      case TransportationType.flight:
        return '飞机';
      case TransportationType.train:
        return '火车';
      case TransportationType.highSpeedRail:
        return '高铁';
      case TransportationType.bus:
        return '大巴';
      case TransportationType.ferry:
        return '轮渡';
      case TransportationType.car:
        return '私家车';
      case TransportationType.taxi:
        return '出租车';
      case TransportationType.rideshare:
        return '拼车';
      case TransportationType.shuttle:
        return '班车';
      case TransportationType.publicTransport:
        return '公共交通';
      case TransportationType.subway:
        return '地铁';
      case TransportationType.other:
        return '其他';
    }
  }
}
