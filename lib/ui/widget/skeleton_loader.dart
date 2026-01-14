import 'package:flutter/material.dart';
import '../../theme/tokens/tokens.dart';

/// 骨架屏加载组件
///
/// 用于初次加载时的占位，符合现代化交互的加载状态规范
///
/// 示例:
/// ```dart
/// SkeletonLoader(
///   width: 200,
///   height: 20,
/// )
/// ```
class SkeletonLoader extends StatefulWidget {
  /// 宽度（可选，不指定则填充父容器）
  final double? width;

  /// 高度
  final double height;

  /// 圆角（可选，默认使用小圆角）
  final double? borderRadius;

  /// 是否启用动画
  final bool animate;

  const SkeletonLoader({
    super.key,
    this.width,
    required this.height,
    this.borderRadius,
    this.animate = true,
  });

  /// 创建文字行骨架屏
  factory SkeletonLoader.text({
    double? width,
    double height = 16,
  }) {
    return SkeletonLoader(
      width: width,
      height: height,
      borderRadius: AppRadius.xs,
    );
  }

  /// 创建圆形骨架屏
  factory SkeletonLoader.circle({
    required double size,
  }) {
    return SkeletonLoader(
      width: size,
      height: size,
      borderRadius: size / 2,
    );
  }

  /// 创建卡片骨架屏
  factory SkeletonLoader.card({
    double? width,
    required double height,
  }) {
    return SkeletonLoader(
      width: width,
      height: height,
      borderRadius: AppRadius.md,
    );
  }

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutSine,
      ),
    );
    if (widget.animate) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              widget.borderRadius ?? AppRadius.sm,
            ),
            gradient: widget.animate
                ? LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: const [
                      AppColors.divider,
                      AppColors.background,
                      AppColors.divider,
                    ],
                    stops: [
                      _animation.value - 0.3,
                      _animation.value,
                      _animation.value + 0.3,
                    ].map((v) => v.clamp(0.0, 1.0)).toList(),
                  )
                : null,
            color: widget.animate ? null : AppColors.divider,
          ),
        );
      },
    );
  }
}

/// 列表项骨架屏
class SkeletonListTile extends StatelessWidget {
  /// 是否显示头像
  final bool showAvatar;

  /// 是否显示副标题
  final bool showSubtitle;

  /// 是否显示尾部
  final bool showTrailing;

  const SkeletonListTile({
    super.key,
    this.showAvatar = true,
    this.showSubtitle = true,
    this.showTrailing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          // 头像
          if (showAvatar) ...[
            SkeletonLoader.circle(size: 40),
            const SizedBox(width: AppSpacing.md),
          ],

          // 文字区
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLoader.text(
                  width: 150,
                  height: 16,
                ),
                if (showSubtitle) ...[
                  const SizedBox(height: AppSpacing.xs),
                  SkeletonLoader.text(
                    width: 100,
                    height: 12,
                  ),
                ],
              ],
            ),
          ),

          // 尾部
          if (showTrailing) ...[
            const SizedBox(width: AppSpacing.md),
            SkeletonLoader.text(
              width: 40,
              height: 16,
            ),
          ],
        ],
      ),
    );
  }
}

/// 数据卡片骨架屏
class SkeletonDataCard extends StatelessWidget {
  /// 是否显示缩略图
  final bool showThumbnail;

  const SkeletonDataCard({
    super.key,
    this.showThumbnail = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.borderMd,
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 缩略图
          if (showThumbnail)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppRadius.md),
                  topRight: Radius.circular(AppRadius.md),
                ),
                child: const SkeletonLoader(
                  height: double.infinity,
                  borderRadius: 0,
                ),
              ),
            ),

          // 内容区
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLoader.text(
                  width: 200,
                  height: 18,
                ),
                const SizedBox(height: AppSpacing.xs),
                SkeletonLoader.text(
                  width: 150,
                  height: 14,
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    SkeletonLoader.text(
                      width: 60,
                      height: 14,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    SkeletonLoader.text(
                      width: 60,
                      height: 14,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
