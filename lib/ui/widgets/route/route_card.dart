import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'route_info_chip.dart';

/// 路线卡片组件
class RouteCard extends StatelessWidget {
  /// 路线数据
  final Map<String, dynamic> route;
  
  /// 构造函数
  const RouteCard({
    super.key,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          context.go('/routes/${route['id']}');
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 路线图片
            _buildRouteImage(),
            
            // 路线信息
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 路线名称
                  Text(
                    route['name'] as String,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  
                  // 路线描述
                  Text(
                    route['description'] as String,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  
                  // 路线信息标签
                  Row(
                    children: [
                      RouteInfoChip(
                        icon: Icons.straighten,
                        label: '${route['distance']} km',
                      ),
                      const SizedBox(width: 8),
                      RouteInfoChip(
                        icon: Icons.timer,
                        label: route['duration'] as String,
                      ),
                      const SizedBox(width: 8),
                      RouteInfoChip(
                        icon: Icons.trending_up,
                        label: route['difficulty'] as String,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建路线图片
  Widget _buildRouteImage() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Center(
        child: Icon(
          Icons.landscape,
          size: 48,
          color: Colors.grey[600],
        ),
      ),
    );
  }
}