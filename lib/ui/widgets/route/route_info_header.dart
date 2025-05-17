import 'package:flutter/material.dart';

/// 路线信息头部组件
class RouteInfoHeader extends StatelessWidget {
  /// 路线数据
  final Map<String, dynamic> route;

  /// 构造函数
  const RouteInfoHeader({
    super.key,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: _buildInfoItem(
              context,
              Icons.straighten,
              '距离',
              '${route['distance']} km',
            ),
          ),
          Expanded(
            child: _buildInfoItem(
              context,
              Icons.timer,
              '时间',
              route['duration'] as String,
            ),
          ),
          Expanded(
            child: _buildInfoItem(
              context,
              Icons.trending_up,
              '难度',
              route['difficulty'] as String,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    IconData icon,
    String title,
    String value,
  ) {
    return Column(
      children: [
        Icon(icon, size: 24),
        const SizedBox(height: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}