import 'package:flutter/cupertino.dart';
import 'package:walk/model/route/daily_plan_model.dart';
import 'package:walk/theme/tokens/colors.dart';

/// 每日行程列表组件 (PRD §3.3.3)
///
/// 纵向排列天卡片：天数圆标(D1/D2) + 标题 + 指标行
class DailyItineraryListWidget extends StatelessWidget {
  final List<DailyPlanModel> dailyPlans;
  final Function(int dayIndex)? onDayTap;

  const DailyItineraryListWidget({
    super.key,
    required this.dailyPlans,
    this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    if (dailyPlans.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(count: dailyPlans.length),
        const SizedBox(height: 12),
        ...List.generate(dailyPlans.length, (i) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: i < dailyPlans.length - 1 ? 8 : 0,
            ),
            child: _DayCard(
              dayIndex: i,
              plan: dailyPlans[i],
              onTap: () => onDayTap?.call(i),
            ),
          );
        }),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
//  段标题："📅 每日行程" + 蓝底天数徽标
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  final int count;
  const _SectionHeader({required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          '📅 每日行程',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.sheetTextPrimary,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.badgeBlueBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count天',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.badgeBlueText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
//  天卡片：圆角 12px 浅底，天数圆标 + 标题 + 指标
// ---------------------------------------------------------------------------

class _DayCard extends StatelessWidget {
  final int dayIndex;
  final DailyPlanModel plan;
  final VoidCallback? onTap;

  const _DayCard({
    required this.dayIndex,
    required this.plan,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.sheetCardBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // 天数圆标 (32px 蓝底圆, D1/D2/D3...)
            _DayBadge(dayNumber: dayIndex + 1),
            const SizedBox(width: 12),

            // 标题 + 指标
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.sheetTextPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  _MetricsRow(plan: plan),
                ],
              ),
            ),

            // 耗时
            Text(
              '${plan.estimatedTime.toStringAsFixed(1)}h',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.sheetTextSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  天数圆标 (32px 蓝底圆, 白色 D1/D2 文字)
// ---------------------------------------------------------------------------

class _DayBadge extends StatelessWidget {
  final int dayNumber;
  const _DayBadge({required this.dayNumber});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: const BoxDecoration(
        color: AppColors.badgeBlueText,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          'D$dayNumber',
          style: const TextStyle(
            color: CupertinoColors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  指标行：距离 / 爬升 / 下降
// ---------------------------------------------------------------------------

class _MetricsRow extends StatelessWidget {
  final DailyPlanModel plan;
  const _MetricsRow({required this.plan});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _MetricChip(
          icon: CupertinoIcons.location,
          value: '${plan.distance.toStringAsFixed(1)}km',
        ),
        const SizedBox(width: 12),
        _MetricChip(
          icon: CupertinoIcons.arrow_up,
          value: '${plan.elevationGain}m',
        ),
        const SizedBox(width: 12),
        _MetricChip(
          icon: CupertinoIcons.arrow_down,
          value: '${plan.elevationLoss}m',
        ),
      ],
    );
  }
}

class _MetricChip extends StatelessWidget {
  final IconData icon;
  final String value;
  const _MetricChip({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: AppColors.sheetTextWeak),
        const SizedBox(width: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.sheetTextSecondary,
          ),
        ),
      ],
    );
  }
}
