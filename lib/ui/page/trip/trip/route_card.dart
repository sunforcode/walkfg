import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../model/model/route/route_model.dart';
import '../../../../theme/theme/app_colors.dart';

/// 路线卡片组件
class RouteCard extends StatelessWidget {
  /// 路线数据
  final RouteModel route;

  /// 点击回调
  final VoidCallback? onTap;

  /// 规划按钮点击回调
  final VoidCallback? onPlanningTap;

  /// 构造函数
  const RouteCard({
    super.key,
    required this.route,
    this.onTap,
    this.onPlanningTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 路线图片
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: SizedBox(
                height: 150,
                width: double.infinity,
                child: route.coverUrl == null
                    ? Image.network(
                        route.coverUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildPlaceholderImage(),
                      )
                    : _buildPlaceholderImage(),
              ),
            ),

            // 路线信息
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 路线名称
                  Text(
                    route.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // 路线信息
                  Row(
                    children: [
                      _buildInfoChip(
                        CupertinoIcons.clock,
                        '${route.basicInfo.duration}天',
                      ),
                      const SizedBox(width: 16),
                      _buildInfoChip(
                        CupertinoIcons.chart_bar,
                        route.getDifficultyName(),
                      ),
                      const SizedBox(width: 16),
                      _buildInfoChip(
                        CupertinoIcons.calendar,
                        route.basicInfo.bestSeason.join(','),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // 规划按钮
                  if (onPlanningTap != null)
                    SizedBox(
                      width: double.infinity,
                      child: CupertinoButton(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                        onPressed: onPlanningTap,
                        child: const Text('规划此行程'),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建信息标签
  Widget _buildInfoChip(IconData icon, String label) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.primary,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: CupertinoColors.systemGrey,
          ),
        ),
      ],
    );
  }

  /// 构建占位图片
  Widget _buildPlaceholderImage() {
    return Container(
      color: AppColors.primary.withOpacity(0.2),
      child: const Center(
        child: Icon(
          CupertinoIcons.photo,
          size: 40,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
