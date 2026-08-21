import 'package:flutter/cupertino.dart';

/// 交通住宿组件
class TripTransportationAccommodationWidget extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;
  final String departureCity;
  final int participantCount;
  final Function() onManage;

  const TripTransportationAccommodationWidget({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.departureCity,
    required this.participantCount,
    required this.onManage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 交通安排
          Row(
            children: [
              const Icon(
                CupertinoIcons.car,
                size: 20,
                color: CupertinoColors.systemBlue,
              ),
              const SizedBox(width: 8),
              const Text(
                '交通安排',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.label,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._buildTransportationItems(),
          const SizedBox(height: 20),

          // 住宿安排
          Row(
            children: [
              const Icon(
                CupertinoIcons.bed_double,
                size: 20,
                color: CupertinoColors.systemPurple,
              ),
              const SizedBox(width: 8),
              const Text(
                '住宿安排',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.label,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._buildAccommodationItems(),
        ],
      ),
    );
  }

  List<Widget> _buildTransportationItems() {
    // 模拟交通数据
    final transportations = [
      {
        'type': '去程',
        'method': '高铁',
        'route': '$departureCity虹桥 → 黄山北',
        'time': '${_formatDate(startDate)} 08:30-12:05',
        'duration': '3.5小时',
        'price': '¥180/人',
        'icon': CupertinoIcons.train_style_one,
        'color': CupertinoColors.systemGreen,
      },
      {
        'type': '回程',
        'method': '高铁',
        'route': '黄山北 → $departureCity虹桥',
        'time': '${_formatDate(endDate)} 15:20-18:55',
        'duration': '3.5小时',
        'price': '¥180/人',
        'icon': CupertinoIcons.train_style_one,
        'color': CupertinoColors.systemOrange,
      },
    ];

    return transportations.map((transport) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: (transport['color'] as Color).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: transport['color'] as Color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                transport['icon'] as IconData,
                color: CupertinoColors.white,
                size: 20,
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
                        transport['type'] as String,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: transport['color'] as Color,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        transport['method'] as String,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: CupertinoColors.label,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    transport['route'] as String,
                    style: const TextStyle(
                      fontSize: 13,
                      color: CupertinoColors.secondaryLabel,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        transport['time'] as String,
                        style: const TextStyle(
                          fontSize: 12,
                          color: CupertinoColors.tertiaryLabel,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        transport['duration'] as String,
                        style: const TextStyle(
                          fontSize: 12,
                          color: CupertinoColors.tertiaryLabel,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Text(
              transport['price'] as String,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: transport['color'] as Color,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  List<Widget> _buildAccommodationItems() {
    // 模拟住宿数据
    final accommodations = [
      {
        'name': '半山寺客栈',
        'type': '山寨住宿',
        'date': _formatDate(startDate),
        'price': '¥120/间',
        'rating': '4.2',
        'features': ['热水', 'WiFi', '早餐'],
        'icon': CupertinoIcons.house_fill,
        'color': CupertinoColors.systemGreen,
      },
      {
        'name': '光明顶酒店',
        'type': '山顶酒店',
        'date': _formatDate(startDate.add(const Duration(days: 1))),
        'price': '¥280/间',
        'rating': '4.5',
        'features': ['观景', '餐厅', '暖气'],
        'icon': CupertinoIcons.building_2_fill,
        'color': CupertinoColors.systemPurple,
      },
    ];

    return accommodations.map((accommodation) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: (accommodation['color'] as Color).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: accommodation['color'] as Color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                accommodation['icon'] as IconData,
                color: CupertinoColors.white,
                size: 20,
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
                        accommodation['name'] as String,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: CupertinoColors.label,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        children: [
                          const Icon(
                            CupertinoIcons.star_fill,
                            size: 12,
                            color: CupertinoColors.systemYellow,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            accommodation['rating'] as String,
                            style: const TextStyle(
                              fontSize: 12,
                              color: CupertinoColors.secondaryLabel,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${accommodation['type']} · ${accommodation['date']}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: CupertinoColors.secondaryLabel,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    children: (accommodation['features'] as List<String>)
                        .map((feature) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: CupertinoColors.systemGrey6,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                feature,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: CupertinoColors.secondaryLabel,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
            Text(
              accommodation['price'] as String,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: accommodation['color'] as Color,
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
