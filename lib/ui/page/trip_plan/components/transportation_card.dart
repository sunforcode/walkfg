import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:walk/model/transportation/transportation_plan_model.dart';
import 'package:walk/model/transportation/transportation_segment_model.dart';
import 'package:walk/theme/theme/app_colors.dart';
import 'package:walk/ui/page/trip_plan/components/trip_plan_card.dart';

/// 交通方案卡片
class TransportationCard extends StatelessWidget {
  /// 交通方案列表
  final List<TransportationPlanModel> transportationPlans;

  /// 编辑回调
  final VoidCallback onEdit;

  /// 构造函数
  const TransportationCard({
    Key? key,
    required this.transportationPlans,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TripPlanCard(
      title: '交通方案',
      onEdit: onEdit,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 去程交通
          _buildTransportationSection(
            '去程',
            transportationPlans
                .where((plan) =>
                    plan.direction == TransportationDirection.outbound)
                .toList(),
          ),

          const SizedBox(height: 16),

          // 返程交通
          _buildTransportationSection(
            '返程',
            transportationPlans
                .where(
                    (plan) => plan.direction == TransportationDirection.inbound)
                .toList(),
          ),
        ],
      ),
    );
  }

  /// 构建交通部分
  Widget _buildTransportationSection(
      String title, List<TransportationPlanModel> plans) {
    if (plans.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '暂无交通方案',
            style: TextStyle(
              color: CupertinoColors.systemGrey,
            ),
          ),
        ],
      );
    }

    // 使用第一个方案
    final plan = plans.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),

        // 交通段列表
        ...plan.segments.asMap().entries.map((entry) {
          final index = entry.key;
          final segment = entry.value;

          return Column(
            children: [
              // 交通段
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 交通类型图标
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Icon(
                        _getTransportationIcon(segment.type),
                        color: AppColors.primary,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // 交通详情
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 出发地 -> 目的地
                        Text(
                          '${segment.departureLocation} → ${segment.arrivalLocation}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 4),

                        // 时间和时长
                        Text(
                          '${_formatTime(segment.departureTime)} - ${_formatTime(segment.arrivalTime)} (${_formatDuration(segment.arrivalTime.difference(segment.departureTime))})',
                          style: const TextStyle(
                            fontSize: 14,
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // 如果不是最后一个交通段，添加连接线
              if (index < plan.segments.length - 1)
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Container(
                    width: 1,
                    height: 20,
                    color: CupertinoColors.systemGrey4,
                  ),
                ),
            ],
          );
        }).toList(),
      ],
    );
  }

  /// 获取交通类型图标
  IconData _getTransportationIcon(TransportationType type) {
    switch (type) {
      case TransportationType.flight:
        return CupertinoIcons.airplane;
      case TransportationType.train:
        return CupertinoIcons.tram_fill;
      case TransportationType.highSpeedRail:
        return CupertinoIcons.tram_fill;
      case TransportationType.bus:
        return CupertinoIcons.bus;
      case TransportationType.ferry:
        return CupertinoIcons.bolt_fill;
      case TransportationType.car:
        return CupertinoIcons.car_fill;
      case TransportationType.taxi:
        return CupertinoIcons.car_detailed;
      case TransportationType.rideshare:
        return CupertinoIcons.person_2_fill;
      case TransportationType.shuttle:
        return CupertinoIcons.bus;
      case TransportationType.publicTransport:
        return CupertinoIcons.tram_fill;
      case TransportationType.subway:
        return CupertinoIcons.tram_fill;
      case TransportationType.other:
        return CupertinoIcons.arrow_right;
    }
  }

  /// 格式化时间
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  /// 格式化时长
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0) {
      return '${hours}h${minutes > 0 ? '${minutes}m' : ''}';
    } else {
      return '${minutes}m';
    }
  }
}
