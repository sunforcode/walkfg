import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../theme/tokens/tokens.dart';

/// 数据卡片组件
///
/// 用于列表页展示内容卡片，符合工具型应用的渐进式信息展示
///
/// 示例:
/// ```dart
/// DataCard(
///   thumbnail: Image.network('...'),
///   title: '五台山大朝台',
///   subtitle: '山西忻州 · 中等难度',
///   metrics: [
///     DataMetric(icon: Icons.straighten, value: '68km'),
///     DataMetric(icon: Icons.terrain, value: '3058m'),
///   ],
///   onTap: () => ...,
/// )
/// ```
class DataCard extends StatefulWidget {
  /// 缩略图（可选）
  final Widget? thumbnail;

  /// 标题
  final String title;

  /// 副标题（可选）
  final String? subtitle;

  /// 指标列表
  final List<DataMetric> metrics;

  /// 迷你图表（可选）
  final Widget? miniChart;

  /// 右侧操作按钮（可选）
  final Widget? trailing;

  /// 点击回调
  final VoidCallback? onTap;

  /// 长按回调（可选）
  final VoidCallback? onLongPress;

  const DataCard({
    super.key,
    this.thumbnail,
    required this.title,
    this.subtitle,
    this.metrics = const [],
    this.miniChart,
    this.trailing,
    this.onTap,
    this.onLongPress,
  });

  @override
  State<DataCard> createState() => _DataCardState();
}

class _DataCardState extends State<DataCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap != null ? (_) => _setPressed(true) : null,
      onTapUp: widget.onTap != null ? (_) => _setPressed(false) : null,
      onTapCancel: widget.onTap != null ? () => _setPressed(false) : null,
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: AppRadius.borderMd,
            border: Border.all(
              color: AppColors.border,
              width: 1,
            ),
            boxShadow: AppShadows.cardElevation1,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 缩略图
              if (widget.thumbnail != null)
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppRadius.md),
                    topRight: Radius.circular(AppRadius.md),
                  ),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: widget.thumbnail!,
                  ),
                ),

              // 内容区
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 标题和右侧操作
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.title,
                            style: AppTypography.titleLarge,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (widget.trailing != null) ...[
                          const SizedBox(width: AppSpacing.sm),
                          widget.trailing!,
                        ],
                      ],
                    ),

                    // 副标题
                    if (widget.subtitle != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        widget.subtitle!,
                        style: AppTypography.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    // 指标区
                    if (widget.metrics.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.sm),
                      _buildMetrics(),
                    ],

                    // 迷你图表
                    if (widget.miniChart != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      widget.miniChart!,
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建指标区
  Widget _buildMetrics() {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.xs,
      children: widget.metrics.map((metric) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              metric.icon,
              size: 16,
              color: AppColors.iconSecondary,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              metric.value,
              style: AppTypography.metricValue,
            ),
            if (metric.label != null) ...[
              const SizedBox(width: 2),
              Text(
                metric.label!,
                style: AppTypography.metricLabel,
              ),
            ],
          ],
        );
      }).toList(),
    );
  }

  void _setPressed(bool pressed) {
    if (mounted) {
      setState(() {
        _isPressed = pressed;
      });
    }
  }
}

/// 数据指标
class DataMetric {
  /// 图标
  final IconData icon;

  /// 数值
  final String value;

  /// 标签（可选）
  final String? label;

  const DataMetric({
    required this.icon,
    required this.value,
    this.label,
  });
}
