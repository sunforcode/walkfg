import 'package:flutter/cupertino.dart';
import 'package:walk/model/trip/trip_model.dart';
import 'package:walk/model/route/daily_plan_model.dart';
import 'package:walk/theme/tokens/colors.dart';

/// 每日行程展示组件
class TripItineraryDisplayWidget extends StatefulWidget {
  final TripModel trip;

  const TripItineraryDisplayWidget({
    super.key,
    required this.trip,
  });

  @override
  State<TripItineraryDisplayWidget> createState() =>
      _TripItineraryDisplayWidgetState();
}

class _TripItineraryDisplayWidgetState
    extends State<TripItineraryDisplayWidget> {
  bool _showAll = false;
  static const int _maxDisplayCount = 3;

  @override
  Widget build(BuildContext context) {
    final itinerary = widget.trip.itinerary;
    final displayItinerary =
        _showAll ? itinerary : itinerary.take(_maxDisplayCount).toList();
    final hasMore = itinerary.length > _maxDisplayCount;

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题行
          _buildSectionHeader(itinerary),
          const SizedBox(height: 16),
          // 行程内容
          if (itinerary.isNotEmpty) ...[
            ...displayItinerary.map((plan) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildDayPlan(plan),
              );
            }).toList(),
            // 更多按钮
            if (hasMore && !_showAll) _buildShowMoreButton(itinerary),
          ] else
            _buildEmptyState(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(List<dynamic> itinerary) {
    return Row(
      children: [
        const Icon(
          CupertinoIcons.calendar,
          size: 20,
          color: AppColors.statusCompletedText,
        ),
        const SizedBox(width: 8),
        const Text(
          '每日行程',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.statusCompletedBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${itinerary.length}天',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.statusCompletedText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShowMoreButton(List<dynamic> itinerary) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        setState(() {
          _showAll = true;
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.border,
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '查看更多行程',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.statusCompletedText,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '(${itinerary.length - _maxDisplayCount}天)',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textWeak,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              CupertinoIcons.chevron_down,
              size: 16,
              color: AppColors.statusCompletedText,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayPlan(DailyPlanModel plan) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 日期标题
          _buildDayPlanHeader(plan),
          const SizedBox(height: 16),

          // 描述信息
          if (plan.description.isNotEmpty) ...[
            Text(
              plan.description,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
          ],

          // 统计信息
          _buildDayPlanStats(plan),
        ],
      ),
    );
  }

  Widget _buildDayPlanHeader(DailyPlanModel plan) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.interactiveAccent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              'D${plan.dayNumber}',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                plan.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              _buildDayPlanSubInfo(plan),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDayPlanSubInfo(DailyPlanModel plan) {
    return Row(
      children: [
        Text(
          '',
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textWeak,
          ),
        ),
        const SizedBox(width: 16),
        Icon(
          CupertinoIcons.location,
          size: 12,
          color: AppColors.textWeak,
        ),
        const SizedBox(width: 4),
        Text(
          '${plan.distance.toStringAsFixed(1)}km',
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textWeak,
          ),
        ),
        const SizedBox(width: 12),
        Icon(
          CupertinoIcons.arrow_up_arrow_down,
          size: 12,
          color: AppColors.textWeak,
        ),
        const SizedBox(width: 4),
        Text(
          '+${plan.elevationGain}m',
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textWeak,
          ),
        ),
      ],
    );
  }

  Widget _buildDayPlanStats(DailyPlanModel plan) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.interactiveAccentBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              icon: CupertinoIcons.time,
              value: plan.estimatedTime.toString(),
              label: '预计时长',
              color: AppColors.interactiveAccent,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              icon: CupertinoIcons.location,
              value: '${plan.distance.toStringAsFixed(1)}km',
              label: '徒步距离',
              color: AppColors.statusCompletedText,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              icon: CupertinoIcons.arrow_up,
              value: '+${plan.elevationGain}m',
              label: '爬升高度',
              color: AppColors.statusPlanningText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.textWeak,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
          width: 0.5,
        ),
      ),
      child: const Column(
        children: [
          Icon(
            CupertinoIcons.calendar,
            size: 48,
            color: AppColors.textWeak,
          ),
          SizedBox(height: 16),
          Text(
            '暂无详细行程安排',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textWeak,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '行程规划完成后将显示详细的每日安排',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textWeak,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
