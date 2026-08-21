import 'package:flutter/cupertino.dart';

/// 重要提醒组件
class TripImportantAlertsWidget extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;
  final Function() onTap;

  const TripImportantAlertsWidget({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final alerts = _getImportantAlerts();
    
    if (alerts.isEmpty) {
      return const SizedBox.shrink(); // 没有预警时不显示
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🚨 重要提醒',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.label,
            ),
          ),
          const SizedBox(height: 8),
          ...alerts.map((alert) => _buildAlertCard(alert)).toList(),
        ],
      ),
    );
  }

  Widget _buildAlertCard(Map<String, dynamic> alert) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: (alert['color'] as Color).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: (alert['color'] as Color).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              alert['icon'] as IconData,
              size: 20,
              color: alert['color'] as Color,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alert['title'] as String,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: alert['color'] as Color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    alert['message'] as String,
                    style: const TextStyle(
                      fontSize: 13,
                      color: CupertinoColors.secondaryLabel,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              CupertinoIcons.chevron_right,
              size: 16,
              color: CupertinoColors.tertiaryLabel,
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getImportantAlerts() {
    final alerts = <Map<String, dynamic>>[];
    final now = DateTime.now();

    // 天气预警
    if (_hasWeatherAlert()) {
      alerts.add({
        'title': '天气预警',
        'message': '明日有雨，注意携带雨具和防滑装备',
        'icon': CupertinoIcons.cloud_rain_fill,
        'color': CupertinoColors.systemOrange,
        'type': 'weather',
      });
    }

    // 安全提醒
    if (_hasSafetyAlert()) {
      alerts.add({
        'title': '安全提醒',
        'message': '路段湿滑，建议使用登山杖',
        'icon': CupertinoIcons.exclamationmark_triangle_fill,
        'color': CupertinoColors.systemRed,
        'type': 'safety',
      });
    }

    // 装备检查
    if (_hasEquipmentAlert()) {
      alerts.add({
        'title': '装备检查',
        'message': '还有重要装备未准备，请及时检查',
        'icon': CupertinoIcons.checkmark_shield,
        'color': CupertinoColors.systemPurple,
        'type': 'equipment',
      });
    }

    // 出发提醒
    if (_hasDepartureAlert()) {
      final daysUntil = startDate.difference(now).inDays;
      alerts.add({
        'title': '出发提醒',
        'message': '$daysUntil天后出发，请做好最后准备',
        'icon': CupertinoIcons.time,
        'color': CupertinoColors.systemBlue,
        'type': 'departure',
      });
    }

    return alerts;
  }

  // 检查是否有天气预警
  bool _hasWeatherAlert() {
    // 模拟天气预警逻辑
    // 实际应用中应该从天气API获取数据
    return DateTime.now().weekday == 2; // 假设周二有雨
  }

  // 检查是否有安全提醒
  bool _hasSafetyAlert() {
    // 模拟安全提醒逻辑
    return _hasWeatherAlert(); // 有天气预警时通常也有安全提醒
  }

  // 检查是否有装备提醒
  bool _hasEquipmentAlert() {
    // 模拟装备检查逻辑
    // 实际应用中应该检查装备准备情况
    return true; // 假设总是有装备需要检查
  }

  // 检查是否有出发提醒
  bool _hasDepartureAlert() {
    final now = DateTime.now();
    final daysUntil = startDate.difference(now).inDays;
    return daysUntil > 0 && daysUntil <= 3; // 3天内出发时提醒
  }
}