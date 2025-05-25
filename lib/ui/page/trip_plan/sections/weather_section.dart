import 'package:flutter/cupertino.dart';
import 'package:walk/ui/page/trip_plan/components/section_title_widget.dart';
import 'package:walk/ui/widgets/common/cupertino_card.dart';
import 'package:walk/theme/theme/app_colors.dart';

/// 天气预报部分
class WeatherSection extends StatelessWidget {
  /// 出发日期
  final DateTime? startDate;

  /// 编辑回调
  final VoidCallback? onEdit;

  /// 构造函数
  const WeatherSection({
    Key? key,
    required this.startDate,
    this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SectionTitleWidget(
                title: '天气预报',
              ),
              if (onEdit != null)
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: const Text('查看详情'),
                  onPressed: onEdit,
                ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildWeatherItem(
                  '周一',
                  '晴',
                  '18°/8°',
                  CupertinoIcons.sun_max_fill,
                ),
                _buildWeatherItem(
                  '周二',
                  '多云',
                  '16°/7°',
                  CupertinoIcons.cloud_sun_fill,
                ),
                _buildWeatherItem(
                  '周三',
                  '小雨',
                  '14°/6°',
                  CupertinoIcons.cloud_rain_fill,
                ),
                _buildWeatherItem(
                  '周四',
                  '阴',
                  '15°/7°',
                  CupertinoIcons.cloud_fill,
                ),
                _buildWeatherItem(
                  '周五',
                  '晴',
                  '17°/8°',
                  CupertinoIcons.sun_max_fill,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // 警告提示
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: CupertinoColors.systemYellow.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: const [
                Icon(
                  CupertinoIcons.exclamationmark_triangle,
                  color: CupertinoColors.systemYellow,
                  size: 20,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '周三有雨，建议携带雨具和防水外套',
                    style: TextStyle(color: CupertinoColors.systemYellow),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建天气项
  Widget _buildWeatherItem(
    String day,
    String weather,
    String temperature,
    IconData icon,
  ) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Text(day, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: CupertinoColors.systemYellow.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: CupertinoColors.systemYellow, size: 24),
          ),
          const SizedBox(height: 8),
          Text(weather, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 4),
          Text(
            temperature,
            style: const TextStyle(
              fontSize: 14,
              color: CupertinoColors.systemGrey,
            ),
          ),
        ],
      ),
    );
  }
}
