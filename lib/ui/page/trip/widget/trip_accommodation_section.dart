import 'package:flutter/cupertino.dart';
import 'package:walk/model/trip/trip_model.dart';
import 'package:walk/ui/page/trip/widget/trip_section_placeholder.dart';

/// 住宿安排section组件
class TripAccommodationSection extends StatelessWidget {
  /// 行程数据
  final TripModel? trip;
  
  /// 是否处于编辑模式
  final bool isEditMode;
  
  /// 编辑回调
  final VoidCallback? onEdit;

  const TripAccommodationSection({
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
            '🏨 住宿安排',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.label,
            ),
          ),
          const SizedBox(height: 16),
          
          // 住宿安排内容
          if ((trip?.itinerary ?? []).any((plan) =>
              plan.accommodation != null && plan.accommodation!.isNotEmpty))
            ...(trip?.itinerary ?? [])
                .where((plan) =>
                    plan.accommodation != null && plan.accommodation!.isNotEmpty)
                .map((plan) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              'Day${plan.dayNumber} 住宿',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 2,
                            child: Text(
                              plan.accommodation ?? '',
                              style: const TextStyle(
                                fontSize: 14,
                                color: CupertinoColors.secondaryLabel,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ))
          else
            TripSectionPlaceholder(
              icon: CupertinoIcons.bed_double_fill,
              title: '制定住宿安排',
              subtitle: '为每一天选择合适的住宿',
              buttonText: '开始住宿规划',
              onPressed: onEdit ?? () {},
            ),
        ],
      ),
    );
  }
}