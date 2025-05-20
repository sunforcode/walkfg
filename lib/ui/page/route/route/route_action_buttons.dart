import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 路线操作按钮组件
class RouteActionButtons extends StatelessWidget {
  /// 路线ID
  final String routeId;

  /// 构造函数
  const RouteActionButtons({
    super.key,
    required this.routeId,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                context.go('/routes/$routeId/map');
              },
              icon: const Icon(Icons.map),
              label: const Text('查看地图'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                context.go('/weather/$routeId');
              },
              icon: const Icon(Icons.wb_sunny),
              label: const Text('查看天气'),
            ),
          ),
        ],
      ),
    );
  }
}