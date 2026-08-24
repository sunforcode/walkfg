import 'package:flutter/cupertino.dart';
import 'package:walk/model/trip/trip_model.dart';
import 'package:walk/theme/tokens/colors.dart';

/// 预算展示组件
class TripBudgetDisplayWidget extends StatelessWidget {
  final TripModel trip;

  const TripBudgetDisplayWidget({
    super.key,
    required this.trip,
  });

  @override
  Widget build(BuildContext context) {
    final hasBudget = trip.budget != null && trip.budget! > 0;
    final hasActualCost = trip.actualCost != null && trip.actualCost! > 0;

    if (!hasBudget && !hasActualCost) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题行
          _buildSectionHeader(hasBudget, hasActualCost),
          const SizedBox(height: 16),

          // 预算信息卡片
          _buildBudgetCard(hasBudget, hasActualCost),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(bool hasBudget, bool hasActualCost) {
    return Row(
      children: [
        const Icon(
          CupertinoIcons.money_yen_circle,
          size: 20,
          color: AppColors.statusPlanningText,
        ),
        const SizedBox(width: 8),
        const Text(
          '费用预算',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        if (hasBudget || hasActualCost)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.statusPlanningBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              hasBudget ? '已设置' : '实际花费',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.statusPlanningText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBudgetCard(bool hasBudget, bool hasActualCost) {
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
          if (hasBudget) ...[
            Row(
              children: [
                const Icon(
                  CupertinoIcons.chart_pie,
                  size: 16,
                  color: AppColors.interactiveAccent,
                ),
                const SizedBox(width: 8),
                const Text(
                  '预算金额',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Text(
                  '¥${trip.budget!.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.interactiveAccent,
                  ),
                ),
              ],
            ),
          ],

          if (hasBudget && hasActualCost) const SizedBox(height: 12),

          if (hasActualCost) ...[
            Row(
              children: [
                const Icon(
                  CupertinoIcons.money_dollar_circle,
                  size: 16,
                  color: AppColors.statusCompletedText,
                ),
                const SizedBox(width: 8),
                const Text(
                  '实际花费',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Text(
                  '¥${trip.actualCost!.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.statusCompletedText,
                  ),
                ),
              ],
            ),
          ],

          // 预算对比
          if (hasBudget && hasActualCost) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getBudgetComparisonColor().withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Icon(
                    _getBudgetComparisonIcon(),
                    size: 14,
                    color: _getBudgetComparisonColor(),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _getBudgetComparisonText(),
                      style: TextStyle(
                        fontSize: 12,
                        color: _getBudgetComparisonColor(),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getBudgetComparisonColor() {
    if (trip.budget == null || trip.actualCost == null) {
      return AppColors.textWeak;
    }
    final difference = trip.actualCost! - trip.budget!;
    if (difference > 0) {
      return AppColors.statusCancelledText;
    } else if (difference < 0) {
      return AppColors.statusCompletedText;
    } else {
      return AppColors.interactiveAccent;
    }
  }

  IconData _getBudgetComparisonIcon() {
    if (trip.budget == null || trip.actualCost == null) {
      return CupertinoIcons.info_circle;
    }
    final difference = trip.actualCost! - trip.budget!;
    if (difference > 0) {
      return CupertinoIcons.arrow_up_circle;
    } else if (difference < 0) {
      return CupertinoIcons.arrow_down_circle;
    } else {
      return CupertinoIcons.checkmark_circle;
    }
  }

  String _getBudgetComparisonText() {
    if (trip.budget == null || trip.actualCost == null) {
      return '预算信息不完整';
    }
    final difference = trip.actualCost! - trip.budget!;
    if (difference > 0) {
      return '超出预算 ¥${difference.toStringAsFixed(0)}';
    } else if (difference < 0) {
      return '节省 ¥${(-difference).toStringAsFixed(0)}';
    } else {
      return '与预算一致';
    }
  }
}
