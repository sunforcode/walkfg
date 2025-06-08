import 'package:flutter/cupertino.dart';

/// 预算概览组件
class TripBudgetSummaryWidget extends StatelessWidget {
  final double? budget;
  final double? actualCost;
  final int participantCount;
  final Function() onManage;

  const TripBudgetSummaryWidget({
    super.key,
    required this.budget,
    required this.actualCost,
    required this.participantCount,
    required this.onManage,
  });

  @override
  Widget build(BuildContext context) {
    if (budget == null || budget == 0) {
      return _buildEmptyState();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 预算概览
          Row(
            children: [
              Expanded(
                child: _buildBudgetCard(
                  title: '总预算',
                  value: '¥${budget!.toStringAsFixed(0)}',
                  subtitle:
                      '人均 ¥${(budget! / participantCount).toStringAsFixed(0)}',
                  color: CupertinoColors.systemBlue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildBudgetCard(
                  title: '已花费',
                  value: '¥${(actualCost ?? 0).toStringAsFixed(0)}',
                  subtitle:
                      '人均 ¥${((actualCost ?? 0) / participantCount).toStringAsFixed(0)}',
                  color: CupertinoColors.systemOrange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 预算进度
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '预算使用情况',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.label,
                    ),
                  ),
                  Text(
                    '${_getBudgetUsagePercentage()}%',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _getBudgetStatusColor(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey5,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _getBudgetUsageRatio(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _getBudgetStatusColor(),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _getBudgetStatusText(),
                style: TextStyle(
                  fontSize: 13,
                  color: _getBudgetStatusColor(),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 费用分类
          const Text(
            '费用分类',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.label,
            ),
          ),
          const SizedBox(height: 12),
          ..._buildExpenseCategories(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(
            CupertinoIcons.money_dollar_circle,
            size: 48,
            color: CupertinoColors.systemGrey,
          ),
          const SizedBox(height: 16),
          const Text(
            '暂未设置预算',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: CupertinoColors.secondaryLabel,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '设置预算有助于更好地控制行程费用',
            style: TextStyle(
              fontSize: 14,
              color: CupertinoColors.tertiaryLabel,
            ),
          ),
          const SizedBox(height: 16),
          CupertinoButton.filled(
            child: const Text('设置预算'),
            onPressed: onManage,
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: CupertinoColors.secondaryLabel,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildExpenseCategories() {
    // 模拟费用分类数据
    final categories = [
      {
        'name': '交通费用',
        'budgeted': 800.0,
        'actual': 720.0,
        'icon': CupertinoIcons.car_fill,
        'color': CupertinoColors.systemBlue,
      },
      {
        'name': '住宿费用',
        'budgeted': 600.0,
        'actual': 560.0,
        'icon': CupertinoIcons.bed_double_fill,
        'color': CupertinoColors.systemPurple,
      },
      {
        'name': '餐饮费用',
        'budgeted': 400.0,
        'actual': 380.0,
        'icon': CupertinoIcons.flame_fill,
        'color': CupertinoColors.systemOrange,
      },
      {
        'name': '装备费用',
        'budgeted': 300.0,
        'actual': 250.0,
        'icon': CupertinoIcons.bag_fill,
        'color': CupertinoColors.systemGreen,
      },
      {
        'name': '其他费用',
        'budgeted': 200.0,
        'actual': 150.0,
        'icon': CupertinoIcons.ellipsis_circle_fill,
        'color': CupertinoColors.systemGrey,
      },
    ];

    return categories.map((category) {
      final budgeted = category['budgeted'] as double;
      final actual = category['actual'] as double;
      final progress = budgeted > 0 ? actual / budgeted : 0.0;
      final isOverBudget = actual > budgeted;

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: CupertinoColors.systemGrey6.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              category['icon'] as IconData,
              size: 20,
              color: category['color'] as Color,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        category['name'] as String,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: CupertinoColors.label,
                        ),
                      ),
                      Text(
                        '¥${actual.toStringAsFixed(0)}/¥${budgeted.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 13,
                          color: isOverBudget
                              ? CupertinoColors.systemRed
                              : CupertinoColors.secondaryLabel,
                          fontWeight: isOverBudget
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey5,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progress.clamp(0.0, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isOverBudget
                              ? CupertinoColors.systemRed
                              : progress >= 0.8
                                  ? CupertinoColors.systemOrange
                                  : CupertinoColors.systemGreen,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  int _getBudgetUsagePercentage() {
    if (budget == null || budget == 0) return 0;
    return (((actualCost ?? 0) / budget!) * 100).round();
  }

  double _getBudgetUsageRatio() {
    if (budget == null || budget == 0) return 0.0;
    return ((actualCost ?? 0) / budget!).clamp(0.0, 1.0);
  }

  Color _getBudgetStatusColor() {
    final percentage = _getBudgetUsagePercentage();
    if (percentage > 100) return CupertinoColors.systemRed;
    if (percentage >= 80) return CupertinoColors.systemOrange;
    return CupertinoColors.systemGreen;
  }

  String _getBudgetStatusText() {
    final percentage = _getBudgetUsagePercentage();
    final remaining = budget! - (actualCost ?? 0);

    if (percentage > 100) {
      return '超出预算 ¥${(-remaining).toStringAsFixed(0)}';
    } else if (percentage >= 80) {
      return '预算紧张，剩余 ¥${remaining.toStringAsFixed(0)}';
    } else {
      return '预算充足，剩余 ¥${remaining.toStringAsFixed(0)}';
    }
  }
}
