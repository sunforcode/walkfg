import 'package:flutter/cupertino.dart';
import 'package:walk/model/trip/trip_model.dart';
import 'package:walk/model/route/route_model.dart';
import 'package:walk/utils/date_time_utils.dart';
import 'package:walk/theme/tokens/colors.dart';

/// 综合总览组件
class TripComprehensiveOverviewWidget extends StatelessWidget {
  final TripModel trip;
  final List<RouteModel> relatedRoutes;
  final DateTime departureDate;
  final int days;
  final int participantCount;
  final String departureCity;
  final Function() onTap;

  const TripComprehensiveOverviewWidget({
    super.key,
    required this.trip,
    required this.relatedRoutes,
    required this.departureDate,
    required this.days,
    required this.participantCount,
    required this.departureCity,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16), // 移除上边距
      decoration: BoxDecoration(
        color: AppColors.bgBase,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.surfaceDivider,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题区域
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.surfaceDivider,
                  width: 0.5,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '📊 行程总览',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                // 基础信息
                ..._buildBasicInfo(),
              ],
            ),
          ),

          // 重要提醒（条件显示）
          ..._buildImportantAlerts(),

          // 计划现状概览
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '计划现状',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                // 4个关键指标
                Row(
                  children: [
                    // 行程进度
                    Expanded(
                      child: _buildStatusCard(
                        icon: CupertinoIcons.calendar_today,
                        title: '行程进度',
                        value: '${_getCompletedDays()}/${days}天',
                        subtitle: _getProgressStatus(),
                        color: AppColors.interactiveAccent,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // 参与者状态
                    Expanded(
                      child: _buildStatusCard(
                        icon: CupertinoIcons.person_2_fill,
                        title: '参与者',
                        value: '$participantCount人',
                        subtitle: '${_getConfirmedCount()}人已确认',
                        color: AppColors.statusPlanningText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    // 装备准备
                    Expanded(
                      child: _buildStatusCard(
                        icon: CupertinoIcons.bag_fill,
                        title: '装备准备',
                        value: _getEquipmentSummary(),
                        subtitle: '总重量${_getTotalWeight()}kg',
                        color: AppColors.statusCompletedText,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // 预算使用
                    Expanded(
                      child: _buildStatusCard(
                        icon: CupertinoIcons.money_dollar_circle_fill,
                        title: '预算使用',
                        value: '${_getBudgetProgress()}%',
                        subtitle: _getBudgetStatus(),
                        color: AppColors.statusCompletedText,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildBasicInfo() {
    return [
      // 路线信息
      if (relatedRoutes.isNotEmpty) ...[
        Row(
          children: [
            const Icon(
              CupertinoIcons.map,
              size: 20,
              color: AppColors.interactiveAccent,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                relatedRoutes.first.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
      ],

      // 时间信息
      Row(
        children: [
          const Icon(
            CupertinoIcons.calendar,
            size: 20,
            color: AppColors.statusCompletedText,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _formatDateRange(),
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),

      // 人数和出发地
      Row(
        children: [
          const Icon(
            CupertinoIcons.person_2,
            size: 20,
            color: AppColors.statusPlanningText,
          ),
          const SizedBox(width: 8),
          Text(
            '$participantCount人',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 16),
          const Icon(
            CupertinoIcons.location,
            size: 20,
            color: AppColors.statusCompletedText,
          ),
          const SizedBox(width: 8),
          Text(
            '$departureCity出发',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildImportantAlerts() {
    final alerts = _getImportantAlerts();

    if (alerts.isEmpty) {
      return [];
    }

    return [
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppColors.surfaceDivider,
              width: 0.5,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  CupertinoIcons.exclamationmark_triangle_fill,
                  size: 16,
                  color: AppColors.statusPlanningText,
                ),
                SizedBox(width: 8),
                Text(
                  '重要提醒',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.statusPlanningText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...alerts
                .map((alert) => Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: (alert['color'] as Color).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            alert['icon'] as IconData,
                            size: 12,
                            color: alert['color'] as Color,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              alert['message'] as String,
                              style: TextStyle(
                                fontSize: 12,
                                color: alert['color'] as Color,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ],
        ),
      ),
    ];
  }

  Widget _buildStatusCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
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
                  size: 16,
                  color: color,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 11,
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
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textWeak,
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
    if (now.isBefore(departureDate)) return 0;
    final endDate = departureDate.add(Duration(days: days - 1));
    if (now.isAfter(endDate)) return days;
    return now.difference(departureDate).inDays + 1;
  }

  // 获取进度状态
  String _getProgressStatus() {
    final now = DateTime.now();
    if (now.isBefore(departureDate)) {
      final daysUntil = departureDate.difference(now).inDays;
      return '$daysUntil天后开始';
    }
    final endDate = departureDate.add(Duration(days: days - 1));
    if (now.isAfter(endDate)) {
      return '已完成';
    }
    return '进行中';
  }

  // 获取确认人数
  int _getConfirmedCount() {
    if (trip.participants.isEmpty) return 1; // 至少组织者确认
    return trip.participants
        .where((p) => p.username.isNotEmpty // 简化的确认逻辑
            )
        .length;
  }

  // 获取装备概要（行程数据暂不内嵌装备清单）
  String _getEquipmentSummary() {
    return '0/0';
  }

  // 获取总重量
  String _getTotalWeight() {
    return '0';
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

  // 获取重要提醒
  List<Map<String, dynamic>> _getImportantAlerts() {
    final alerts = <Map<String, dynamic>>[];
    final now = DateTime.now();

    // 天气预警
    if (_hasWeatherAlert()) {
      alerts.add({
        'message': '明日有雨，注意携带雨具',
        'icon': CupertinoIcons.cloud_rain_fill,
        'color': AppColors.statusPlanningText,
      });
    }

    // 装备检查
    if (_hasEquipmentAlert()) {
      alerts.add({
        'message': '还有重要装备未准备',
        'icon': CupertinoIcons.checkmark_shield,
        'color': AppColors.statusCompletedText,
      });
    }

    // 出发提醒
    if (_hasDepartureAlert()) {
      final daysUntil = departureDate.difference(now).inDays;
      alerts.add({
        'message': '$daysUntil天后出发，请做好准备',
        'icon': CupertinoIcons.time,
        'color': AppColors.interactiveAccent,
      });
    }

    return alerts;
  }

  // 检查是否有天气预警
  bool _hasWeatherAlert() {
    return DateTime.now().weekday == 2; // 假设周二有雨
  }

  // 检查是否有装备提醒（行程数据暂不内嵌装备清单，暂不提示）
  bool _hasEquipmentAlert() {
    return false;
  }

  // 检查是否有出发提醒
  bool _hasDepartureAlert() {
    final now = DateTime.now();
    final daysUntil = departureDate.difference(now).inDays;
    return daysUntil > 0 && daysUntil <= 3; // 3天内出发时提醒
  }

  // 格式化日期范围
  String _formatDateRange() {
    final endDate = departureDate.add(Duration(days: days - 1));
    return DateTimeUtils.formatDateRange(departureDate, endDate, days);
  }
}
