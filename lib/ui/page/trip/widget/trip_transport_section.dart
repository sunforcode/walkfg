import 'package:flutter/cupertino.dart';
import 'package:walk/model/trip/trip_model.dart';
import 'package:walk/ui/page/trip/widget/trip_section_placeholder.dart';

/// 每日交通行程section组件
class TripTransportSection extends StatelessWidget {
  /// 行程数据
  final TripModel? trip;

  /// 是否处于编辑模式
  final bool isEditMode;

  /// 编辑回调
  final VoidCallback? onEdit;

  const TripTransportSection({
    super.key,
    required this.trip,
    required this.isEditMode,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: CupertinoColors.separator,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🚗 每日交通行程',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.label,
            ),
          ),
          const SizedBox(height: 16),

          // 展示交通相关的每日计划
          if ((trip?.itinerary ?? []).isNotEmpty)
            ...(trip?.itinerary ?? [])
                .where((plan) =>
                    plan.title.contains('交通') ||
                    plan.title.contains('transport'))
                .map((plan) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  plan.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  plan.description,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: CupertinoColors.secondaryLabel,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            plan.estimatedTime.toString(),
                            style: const TextStyle(
                              fontSize: 14,
                              color: CupertinoColors.activeBlue,
                            ),
                          ),
                        ],
                      ),
                    )),

          // 占位符
          if ((trip?.itinerary ?? [])
              .where((plan) =>
                  plan.title.contains('交通') || plan.title.contains('transport'))
              .isEmpty)
            TripSectionPlaceholder(
              icon: CupertinoIcons.car,
              title: '制定每日交通计划',
              subtitle: '规划每天的交通方式和时间',
              buttonText: '开始交通规划',
              onPressed: onEdit ?? () {},
            ),
        ],
      ),
    );
  }
}
