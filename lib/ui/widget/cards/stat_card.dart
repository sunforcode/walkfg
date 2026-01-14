import 'package:flutter/cupertino.dart';
import '../../../theme/tokens/tokens.dart';

/// 统计卡片组件
///
/// 用于首页概览展示关键数据，符合工具型应用的数据优先设计原则
///
/// 示例:
/// ```dart
/// StatCard(
///   icon: Icons.route,
///   label: '总里程',
///   value: '128.5',
///   unit: 'km',
///   trend: StatTrend.up,
/// )
/// ```
class StatCard extends StatelessWidget {
  /// 图标
  final IconData? icon;

  /// 标签文字
  final String label;

  /// 数值
  final String value;

  /// 单位（可选）
  final String? unit;

  /// 趋势（可选）
  final StatTrend? trend;

  /// 趋势值（可选）
  final String? trendValue;

  /// 背景颜色（可选）
  final Color? backgroundColor;

  /// 点击回调（可选）
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    this.icon,
    required this.label,
    required this.value,
    this.unit,
    this.trend,
    this.trendValue,
    this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.card,
          borderRadius: AppRadius.borderMd,
          border: Border.all(
            color: AppColors.border,
            width: 1,
          ),
          boxShadow: AppShadows.cardElevation1,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 图标 + 趋势指示器行
            if (icon != null || trend != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (icon != null)
                    Icon(
                      icon,
                      size: 20,
                      color: AppColors.iconSecondary,
                    ),
                  if (trend != null) _buildTrendIndicator(),
                ],
              ),
            if (icon != null || trend != null)
              const SizedBox(height: AppSpacing.sm),

            // 数值 + 单位行
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: AppTypography.statValue,
                ),
                if (unit != null) ...[
                  const SizedBox(width: AppSpacing.xs),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      unit!,
                      style: AppTypography.statUnit,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.xs),

            // 标签
            Text(
              label,
              style: AppTypography.statLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建趋势指示器
  Widget _buildTrendIndicator() {
    if (trend == null) return const SizedBox.shrink();

    final IconData trendIcon;
    final Color trendColor;

    switch (trend!) {
      case StatTrend.up:
        trendIcon = CupertinoIcons.arrow_up;
        trendColor = AppColors.success;
        break;
      case StatTrend.down:
        trendIcon = CupertinoIcons.arrow_down;
        trendColor = AppColors.error;
        break;
      case StatTrend.flat:
        trendIcon = CupertinoIcons.minus;
        trendColor = AppColors.textSecondary;
        break;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          trendIcon,
          size: 12,
          color: trendColor,
        ),
        if (trendValue != null) ...[
          const SizedBox(width: 2),
          Text(
            trendValue!,
            style: AppTypography.labelSmall.copyWith(
              color: trendColor,
            ),
          ),
        ],
      ],
    );
  }
}

/// 统计趋势枚举
enum StatTrend {
  /// 上升
  up,

  /// 下降
  down,

  /// 持平
  flat,
}
