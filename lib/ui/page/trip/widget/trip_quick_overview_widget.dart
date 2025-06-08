import 'package:flutter/cupertino.dart';
import 'package:walk/model/trip/trip_model.dart';

/// 快速概览卡片组件
class TripQuickOverviewWidget extends StatelessWidget {
  final TripModel trip;
  final int participantCount;
  final Function() onTap;

  const TripQuickOverviewWidget({
    super.key,
    required this.trip,
    required this.participantCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📊 快速概览',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.label,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // 行程进度
              Expanded(
                child: _buildOverviewCard(
                  icon: CupertinoIcons.calendar_today,
                  title: '行程进度',
                  value: '${_getCompletedDays()}/${_getTotalDays()}天',
                  subtitle: _getProgressStatus(),
                  color: CupertinoColors.systemBlue,
                ),
              ),
              const SizedBox(width: 12),
              // 参与者状态
              Expanded(
                child: _buildOverviewCard(
                  icon: CupertinoIcons.person_2_fill,
                  title: '参与者',
                  value: '$participantCount人',
                  subtitle: '${_getConfirmedCount()}人已确认',
                  color: CupertinoColors.systemOrange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // 装备准备
              Expanded(
                child: _buildOverviewCard(
                  icon: CupertinoIcons.bag_fill,
                  title: '装备准备',
                  value: '${_getEquipmentProgress()}%',
                  subtitle: _getEquipmentStatus(),
                  color: CupertinoColors.systemPurple,
                ),
              ),
              const SizedBox(width: 12),
              // 预算使用
              Expanded(
                child: _buildOverviewCard(
                  icon: CupertinoIcons.money_dollar_circle_fill,
                  title: '预算使用',
                  value: '${_getBudgetProgress()}%',
                  subtitle: _getBudgetStatus(),
                  color: CupertinoColors.systemGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: color,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: color,
                    ),
                  ),
                ),
              ],
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
                fontSize: 11,
                color: CupertinoColors.secondaryLabel,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 获取已完成天数
  int _getCompletedDays() {
    final now = DateTime.now();
    if (now.isBefore(trip.startDate)) return 0;
    if (now.isAfter(trip.endDate)) return _getTotalDays();
    return now.difference(trip.startDate).inDays + 1;
  }

  // 获取总天数
  int _getTotalDays() {
    return trip.endDate.difference(trip.startDate).inDays + 1;
  }

  // 获取进度状态
  String _getProgressStatus() {
    final now = DateTime.now();
    if (now.isBefore(trip.startDate)) {
      final daysUntil = trip.startDate.difference(now).inDays;
      return '$daysUntil天后开始';
    }
    if (now.isAfter(trip.endDate)) {
      return '已完成';
    }
    return '进行中';
  }

  // 获取确认人数
  int _getConfirmedCount() {
    return 1;
  }

  // 获取装备进度
  int _getEquipmentProgress() {
    if (trip.equipmentList == null || trip.equipmentList!.totalItems == 0) {
      return 0;
    }
    final prepared =
        trip.equipmentList!.equipments.where((e) => e.isOwned).length;
    return ((prepared / trip.equipmentList!.totalItems) * 100).round();
  }

  // 获取装备状态
  String _getEquipmentStatus() {
    final progress = _getEquipmentProgress();
    if (progress == 100) return '准备完成';
    if (progress >= 70) return '基本就绪';
    if (progress >= 30) return '准备中';
    return '待准备';
  }

  // 获取预算进度
  int _getBudgetProgress() {
    if (trip.budget == null || trip.budget! == 0) return 0;
    final actualCost = trip.actualCost ?? 0;
    return ((actualCost / trip.budget!) * 100).round();
  }

  // 获取预算状态
  String _getBudgetStatus() {
    final progress = _getBudgetProgress();
    if (progress == 0) return '未开始';
    if (progress <= 70) return '控制良好';
    if (progress <= 90) return '接近预算';
    if (progress <= 100) return '预算充足';
    return '超出预算';
  }
}
