import 'package:flutter/cupertino.dart';
import 'package:walk/model/trip/trip_model.dart';
import 'package:walk/model/route/route_model.dart';

/// 行程概览展示组件
class TripOverviewDisplayWidget extends StatelessWidget {
  final TripModel trip;
  final List<RouteModel> relatedRoutes;
  final bool isReadOnly;

  const TripOverviewDisplayWidget({
    super.key,
    required this.trip,
    required this.relatedRoutes,
    this.isReadOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题行
          Row(
            children: [
              const Icon(
                CupertinoIcons.chart_bar,
                size: 20,
                color: CupertinoColors.systemBlue,
              ),
              const SizedBox(width: 8),
              Text(
                _getOverviewTitle().replaceAll('📊 ', ''),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.label,
                ),
              ),
              const Spacer(),
              _buildStatusBadge(),
            ],
          ),
          const SizedBox(height: 16),

          // 基础信息卡片
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey6,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: CupertinoColors.separator,
                width: 0.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 基础信息
                ..._buildBasicInfo(),

                // 重要提醒（条件显示）
                ..._buildImportantAlertsInline(),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 计划现状概览或完成记录
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey6,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: CupertinoColors.separator,
                width: 0.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getSectionTitle(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.label,
                  ),
                ),
                const SizedBox(height: 12),

                // 根据状态显示不同内容
                if (trip.status == TripStatus.completed)
                  ..._buildCompletedSummary()
                else
                  ..._buildPlanningStatus(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 获取概览标题
  String _getOverviewTitle() {
    if (isReadOnly) {
      return '📊 行程详情';
    }

    switch (trip.status) {
      case TripStatus.planning:
        return '📊 规划总览';
      case TripStatus.confirmed:
        return '📊 行程总览';
      case TripStatus.inProgress:
        return '📊 进行状况';
      case TripStatus.completed:
        return '📊 行程记录';
      case TripStatus.cancelled:
        return '📊 已取消';
    }
  }

  /// 获取区域标题
  String _getSectionTitle() {
    switch (trip.status) {
      case TripStatus.planning:
        return '规划进度';
      case TripStatus.confirmed:
        return '准备状况';
      case TripStatus.inProgress:
        return '实时状态';
      case TripStatus.completed:
        return '完成总结';
      case TripStatus.cancelled:
        return '已取消';
    }
  }

  /// 构建状态标识
  Widget _buildStatusBadge() {
    Color badgeColor;
    String statusText;

    switch (trip.status) {
      case TripStatus.planning:
        badgeColor = CupertinoColors.systemOrange;
        statusText = '规划中';
        break;
      case TripStatus.confirmed:
        badgeColor = CupertinoColors.systemBlue;
        statusText = '已确认';
        break;
      case TripStatus.inProgress:
        badgeColor = CupertinoColors.systemGreen;
        statusText = '进行中';
        break;
      case TripStatus.completed:
        badgeColor = CupertinoColors.systemPurple;
        statusText = '已完成';
        break;
      case TripStatus.cancelled:
        badgeColor = CupertinoColors.systemRed;
        statusText = '已取消';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: badgeColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: badgeColor,
        ),
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
              color: CupertinoColors.systemBlue,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                relatedRoutes.first.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: CupertinoColors.label,
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
            color: CupertinoColors.systemGreen,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _formatDateRange(),
              style: const TextStyle(
                fontSize: 14,
                color: CupertinoColors.label,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),

      // 人数和其他信息
      Row(
        children: [
          const Icon(
            CupertinoIcons.person_2,
            size: 20,
            color: CupertinoColors.systemOrange,
          ),
          const SizedBox(width: 8),
          Text(
            '${trip.participantCount}人',
            style: const TextStyle(
              fontSize: 14,
              color: CupertinoColors.label,
            ),
          ),
          if (trip.status == TripStatus.completed) ...[
            const SizedBox(width: 16),
            const Icon(
              CupertinoIcons.checkmark_circle_fill,
              size: 20,
              color: CupertinoColors.systemGreen,
            ),
            const SizedBox(width: 8),
            const Text(
              '圆满完成',
              style: TextStyle(
                fontSize: 14,
                color: CupertinoColors.systemGreen,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    ];
  }

  List<Widget> _buildImportantAlerts() {
    // 只在规划中和已确认状态显示提醒
    if (trip.status != TripStatus.planning &&
        trip.status != TripStatus.confirmed) {
      return [];
    }

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
              color: CupertinoColors.separator,
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
                  color: CupertinoColors.systemOrange,
                ),
                SizedBox(width: 8),
                Text(
                  '重要提醒',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.systemOrange,
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
                        color: (alert['color'] as Color).withOpacity(0.1),
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

  /// 构建规划状态（规划中、已确认、进行中）
  List<Widget> _buildPlanningStatus() {
    return [
      // 4个关键指标
      Row(
        children: [
          // 行程进度
          Expanded(
            child: _buildStatusCard(
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
            child: _buildStatusCard(
              icon: CupertinoIcons.person_2_fill,
              title: '参与者',
              value: '${trip.participantCount}人',
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
            child: _buildStatusCard(
              icon: CupertinoIcons.bag_fill,
              title: '装备准备',
              value: _getEquipmentSummary(),
              subtitle: '总重量${_getTotalWeight()}kg',
              color: CupertinoColors.systemPurple,
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
              color: CupertinoColors.systemGreen,
            ),
          ),
        ],
      ),
    ];
  }

  /// 构建完成总结（已完成状态）
  List<Widget> _buildCompletedSummary() {
    return [
      // 完成统计
      Row(
        children: [
          Expanded(
            child: _buildStatusCard(
              icon: CupertinoIcons.checkmark_circle_fill,
              title: '完成天数',
              value: '${_getTotalDays()}天',
              subtitle: '全程完成',
              color: CupertinoColors.systemGreen,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatusCard(
              icon: CupertinoIcons.location_fill,
              title: '总里程',
              value: '${_getTotalDistance()}km',
              subtitle: '实际完成',
              color: CupertinoColors.systemBlue,
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: _buildStatusCard(
              icon: CupertinoIcons.photo_fill,
              title: '记录照片',
              value: '${_getPhotoCount()}张',
              subtitle: '美好回忆',
              color: CupertinoColors.systemPurple,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatusCard(
              icon: CupertinoIcons.star_fill,
              title: '行程评分',
              value: '${_getTripRating()}/5',
              subtitle: '满意度',
              color: CupertinoColors.systemOrange,
            ),
          ),
        ],
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
    return Container(
      padding: const EdgeInsets.all(12),
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
              color: CupertinoColors.secondaryLabel,
            ),
          ),
        ],
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
    if (trip.participants.isEmpty) return 1; // 至少组织者确认
    return trip.participants
        .where((p) => p.username.isNotEmpty // 简化的确认逻辑
            )
        .length;
  }

  // 获取装备概要
  String _getEquipmentSummary() {
    if (trip.equipmentList == null || trip.equipmentList!.totalItems == 0) {
      return '0/0';
    }
    final prepared =
        trip.equipmentList!.equipments.where((e) => e.isOwned).length;
    final total = trip.equipmentList!.totalItems;
    return '$prepared/$total';
  }

  // 获取总重量
  String _getTotalWeight() {
    if (trip.equipmentList == null) return '0';
    return trip.equipmentList!.totalWeight.toStringAsFixed(1);
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
        'color': CupertinoColors.systemOrange,
      });
    }

    // 装备检查
    if (_hasEquipmentAlert()) {
      alerts.add({
        'message': '还有重要装备未准备',
        'icon': CupertinoIcons.checkmark_shield,
        'color': CupertinoColors.systemPurple,
      });
    }

    // 出发提醒
    if (_hasDepartureAlert()) {
      final daysUntil = trip.startDate.difference(now).inDays;
      alerts.add({
        'message': '$daysUntil天后出发，请做好准备',
        'icon': CupertinoIcons.time,
        'color': CupertinoColors.systemBlue,
      });
    }

    return alerts;
  }

  // 检查是否有天气预警
  bool _hasWeatherAlert() {
    return DateTime.now().weekday == 2; // 假设周二有雨
  }

  // 检查是否有装备提醒
  bool _hasEquipmentAlert() {
    if (trip.equipmentList == null) return true;
    final prepared =
        trip.equipmentList!.equipments.where((e) => e.isOwned).length;
    final total = trip.equipmentList!.totalItems;
    return total > 0 && prepared < total;
  }

  // 检查是否有出发提醒
  bool _hasDepartureAlert() {
    final now = DateTime.now();
    final daysUntil = trip.startDate.difference(now).inDays;
    return daysUntil > 0 && daysUntil <= 3; // 3天内出发时提醒
  }

  // 格式化日期范围
  String _formatDateRange() {
    final days = _getTotalDays();
    return '${trip.startDate.year}-${trip.startDate.month.toString().padLeft(2, '0')}-${trip.startDate.day.toString().padLeft(2, '0')} ~ ${trip.endDate.year}-${trip.endDate.month.toString().padLeft(2, '0')}-${trip.endDate.day.toString().padLeft(2, '0')} ($days天)';
  }

  // 获取总里程（已完成状态）
  double _getTotalDistance() {
    return 45.8; // 模拟数据
  }

  // 获取照片数量（已完成状态）
  int _getPhotoCount() {
    return 127; // 模拟数据
  }

  // 获取行程评分（已完成状态）
  double _getTripRating() {
    return 4.8; // 模拟数据
  }

  List<Widget> _buildImportantAlertsInline() {
    // 只在规划中和已确认状态显示提醒
    if (trip.status != TripStatus.planning &&
        trip.status != TripStatus.confirmed) {
      return [];
    }

    final alerts = _getImportantAlerts();

    if (alerts.isEmpty) {
      return [];
    }

    return [
      const Row(
        children: [
          Icon(
            CupertinoIcons.exclamationmark_triangle_fill,
            size: 16,
            color: CupertinoColors.systemOrange,
          ),
          SizedBox(width: 8),
          Text(
            '重要提醒',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.systemOrange,
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      ...alerts
          .map((alert) => Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (alert['color'] as Color).withOpacity(0.1),
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
    ];
  }
}
