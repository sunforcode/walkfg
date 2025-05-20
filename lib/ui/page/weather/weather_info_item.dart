import 'package:flutter/material.dart';

/// 天气信息项组件
class WeatherInfoItem extends StatelessWidget {
  /// 图标
  final IconData icon;
  
  /// 文本
  final String text;
  
  /// 构造函数
  const WeatherInfoItem({
    super.key,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 16),
        const SizedBox(width: 4),
        Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
              ),
        ),
      ],
    );
  }
}