import 'package:flutter/material.dart';
import 'package:walk/theme/tokens/colors.dart';

/// 天气详情项组件
class WeatherDetailItem extends StatelessWidget {
  /// 图标
  final IconData icon;

  /// 标签
  final String label;

  /// 值
  final String value;

  const WeatherDetailItem({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.textOnDark.withValues(alpha: 0.9),
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textOnDark.withValues(alpha: 0.9),
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textOnDark,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
