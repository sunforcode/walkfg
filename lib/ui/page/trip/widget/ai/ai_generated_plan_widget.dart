import 'package:flutter/cupertino.dart';
import 'package:walk/model/trip/trip_model.dart';

/// AI生成方案详细展示组件
class AIGeneratedPlanWidget extends StatelessWidget {
  final TripModel plan;
  final Function() onEdit;

  const AIGeneratedPlanWidget({
    super.key,
    required this.plan,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: CupertinoColors.separator,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: CupertinoColors.separator,
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  CupertinoIcons.checkmark_seal_fill,
                  color: CupertinoColors.systemGreen,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'AI生成的行程方案',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.label,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 方案概览
          _buildPlanOverview(),

          // 基础信息
          _buildBasicInfoSection(),

          // 预算信息
          _buildBudgetSection(),
        ],
      ),
    );
  }

  Widget _buildPlanOverview() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📋 方案概览',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.label,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildOverviewCard(
                  '总预算',
                  '¥${plan.budget?.toInt() ?? 0}/人',
                  CupertinoColors.systemBlue,
                  CupertinoIcons.money_dollar,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildOverviewCard(
                  '行程天数',
                  '${plan.endDate.difference(plan.startDate).inDays + 1}天',
                  CupertinoColors.systemOrange,
                  CupertinoIcons.calendar,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildOverviewCard(
                  '参与人数',
                  '${plan.participantCount}人',
                  CupertinoColors.systemGreen,
                  CupertinoIcons.person_2,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildOverviewCard(
                  '状态',
                  plan.getStatusName(),
                  CupertinoColors.systemPurple,
                  CupertinoIcons.checkmark_circle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCard(
      String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: color,
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.label,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return _buildSection(
      title: '📍 基础信息',
      child: Column(
        children: [
          _buildInfoRow('行程名称', plan.name),
          _buildInfoRow('开始日期', _formatDate(plan.startDate)),
          _buildInfoRow('结束日期', _formatDate(plan.endDate)),
          if (plan.description.isNotEmpty)
            _buildInfoRow('描述', plan.description),
        ],
      ),
    );
  }

  Widget _buildBudgetSection() {
    return _buildSection(
      title: '💰 预算信息',
      child: Column(
        children: [
          _buildInfoRow('预算总额', '¥${plan.budget?.toInt() ?? 0}'),
          if (plan.actualCost != null)
            _buildInfoRow('实际花费', '¥${plan.actualCost!.toInt()}'),
          _buildInfoRow(
              '人均预算', '¥${(plan.budget ?? 0) ~/ plan.participantCount}'),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.label,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: CupertinoColors.systemGrey,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: CupertinoColors.label,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }
}
