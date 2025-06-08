import 'package:flutter/cupertino.dart';

/// 天气和安全提醒组件
class TripWeatherSafetyWidget extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;
  final Function() onManage;

  const TripWeatherSafetyWidget({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.onManage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 天气预报
          Row(
            children: [
              const Icon(
                CupertinoIcons.cloud_sun,
                size: 20,
                color: CupertinoColors.systemYellow,
              ),
              const SizedBox(width: 8),
              const Text(
                '天气预报',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.label,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._buildWeatherItems(),
          const SizedBox(height: 20),

          // 安全提醒
          Row(
            children: [
              const Icon(
                CupertinoIcons.shield_fill,
                size: 20,
                color: CupertinoColors.systemRed,
              ),
              const SizedBox(width: 8),
              const Text(
                '安全提醒',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.label,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._buildSafetyItems(),
        ],
      ),
    );
  }

  List<Widget> _buildWeatherItems() {
    // 模拟天气数据
    final weathers = [
      {
        'date': _formatDate(startDate),
        'day': '第1天',
        'weather': '多云',
        'temp': '5-12℃',
        'icon': '🌤️',
        'color': CupertinoColors.systemBlue,
        'tips': '适合徒步，注意保暖',
      },
      {
        'date': _formatDate(startDate.add(const Duration(days: 1))),
        'day': '第2天',
        'weather': '小雨',
        'temp': '3-8℃',
        'icon': '🌧️',
        'color': CupertinoColors.systemIndigo,
        'tips': '路面湿滑，注意安全',
      },
      {
        'date': _formatDate(startDate.add(const Duration(days: 2))),
        'day': '第3天',
        'weather': '晴天',
        'temp': '8-15℃',
        'icon': '☀️',
        'color': CupertinoColors.systemOrange,
        'tips': '天气晴好，适合拍照',
      },
    ];

    return weathers.map((weather) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: (weather['color'] as Color).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: (weather['color'] as Color).withOpacity(0.2),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Center(
                child: Text(
                  weather['icon'] as String,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        weather['day'] as String,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: weather['color'] as Color,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        weather['date'] as String,
                        style: const TextStyle(
                          fontSize: 13,
                          color: CupertinoColors.secondaryLabel,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        weather['weather'] as String,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: CupertinoColors.label,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        weather['temp'] as String,
                        style: const TextStyle(
                          fontSize: 14,
                          color: CupertinoColors.secondaryLabel,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    weather['tips'] as String,
                    style: const TextStyle(
                      fontSize: 12,
                      color: CupertinoColors.tertiaryLabel,
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

  List<Widget> _buildSafetyItems() {
    // 安全提醒数据
    final safetyItems = [
      {
        'title': '紧急联系',
        'content': '黄山救援: 400-559-9999',
        'icon': CupertinoIcons.phone_fill,
        'color': CupertinoColors.systemRed,
      },
      {
        'title': '装备检查',
        'content': '确保头灯、雨具、急救包齐全',
        'icon': CupertinoIcons.checkmark_shield_fill,
        'color': CupertinoColors.systemGreen,
      },
      {
        'title': '路线安全',
        'content': '雨天路滑，请使用登山杖',
        'icon': CupertinoIcons.exclamationmark_triangle_fill,
        'color': CupertinoColors.systemOrange,
      },
      {
        'title': '团队协作',
        'content': '保持队形，不要单独行动',
        'icon': CupertinoIcons.person_2_fill,
        'color': CupertinoColors.systemBlue,
      },
    ];

    return safetyItems.map((item) {
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: (item['color'] as Color).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              item['icon'] as IconData,
              size: 20,
              color: item['color'] as Color,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title'] as String,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: item['color'] as Color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item['content'] as String,
                    style: const TextStyle(
                      fontSize: 13,
                      color: CupertinoColors.secondaryLabel,
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

  String _formatDate(DateTime date) {
    return '${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
