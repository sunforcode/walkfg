import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:walk/theme/theme/app_colors.dart';

/// 行程规划按钮组件
///
/// 在行程详情页面底部显示规划按钮，支持添加路线和开始规划
class TripPlanningButtonWidget extends StatelessWidget {
  /// 添加路线回调
  final VoidCallback onAddRoute;

  /// 开始规划回调
  final VoidCallback onStartPlanning;

  /// 是否已有路线
  final bool hasRoutes;

  /// 构造函数
  const TripPlanningButtonWidget({
    Key? key,
    required this.onAddRoute,
    required this.onStartPlanning,
    required this.hasRoutes,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 添加路线按钮
        if (!hasRoutes)
          CupertinoButton(
            padding: EdgeInsets.zero,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                CupertinoIcons.map,
                color: CupertinoColors.white,
                size: 28,
              ),
            ),
            onPressed: onAddRoute,
          ),

        // 开始规划按钮
        CupertinoButton(
          padding: EdgeInsets.zero,
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: hasRoutes ? AppColors.primary : CupertinoColors.systemGrey,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (hasRoutes
                          ? AppColors.primary
                          : CupertinoColors.systemGrey)
                      .withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              CupertinoIcons.calendar_badge_plus,
              color: CupertinoColors.white,
              size: 32,
            ),
          ),
          onPressed: hasRoutes ? onStartPlanning : onAddRoute,
        ),

        // 按钮标签
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: CupertinoColors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            hasRoutes ? '开始规划' : '添加路线',
            style: const TextStyle(
              color: CupertinoColors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
