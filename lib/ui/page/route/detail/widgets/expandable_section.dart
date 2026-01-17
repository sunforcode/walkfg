import 'package:flutter/cupertino.dart';
import 'package:walk/theme/tokens/tokens.dart';

/// 可展开/折叠的分类卡片组件
/// 
/// 用于将相关内容分类展示，支持展开/折叠交互。
/// 特点：
/// - 平滑的 300ms 动画
/// - 箭头旋转反馈
/// - 清晰的视觉层级
class ExpandableSection extends StatefulWidget {
  /// 分类标题
  final String title;

  /// 标题前的图标（可选）
  final IconData? icon;

  /// 分类内容
  final Widget child;

  /// 初始展开状态（默认折叠）
  final bool initiallyExpanded;

  /// 是否禁用展开/折叠功能
  final bool disabled;

  /// 展开/折叠时的回调
  final ValueChanged<bool>? onExpansionChanged;

  const ExpandableSection({
    super.key,
    required this.title,
    this.icon,
    required this.child,
    this.initiallyExpanded = false,
    this.disabled = false,
    this.onExpansionChanged,
  });

  @override
  State<ExpandableSection> createState() => _ExpandableSectionState();
}

class _ExpandableSectionState extends State<ExpandableSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _arrowRotation;
  late Animation<double> _contentOpacity;
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;

    // 动画控制器：300ms 展开/折叠
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // 箭头旋转动画：0° → 90°
    _arrowRotation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // 内容透明度动画
    _contentOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // 初始状态：如果展开则立即设置动画到末尾
    if (_isExpanded) {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// 处理标题点击
  void _handleTitleTap() {
    if (widget.disabled) return;

    setState(() {
      _isExpanded = !_isExpanded;
    });

    if (_isExpanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }

    widget.onExpansionChanged?.call(_isExpanded);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderMd,
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 标题行
          CupertinoButton(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            onPressed: widget.disabled ? null : _handleTitleTap,
            child: Row(
              children: [
                // 图标（如果提供）
                if (widget.icon != null) ...[
                  Icon(
                    widget.icon,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  AppSpacing.gapSm,
                ],

                // 标题文本
                Expanded(
                  child: Text(
                    widget.title,
                    style: AppTypography.headlineSmall.copyWith(
                      color: widget.disabled
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                    ),
                  ),
                ),

                // 箭头指示器（旋转动画）
                RotationTransition(
                  turns: _arrowRotation,
                  child: Icon(
                    CupertinoIcons.chevron_right,
                    color: widget.disabled
                        ? AppColors.textSecondary
                        : AppColors.iconPrimary,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),

          // 分隔线
          if (_isExpanded)
            Container(
              height: 0.5,
              color: AppColors.divider,
            ),

          // 展开内容（使用 SizeTransition 实现高度动画）
          ClipRect(
            child: SizeTransition(
              sizeFactor: _animationController,
              axisAlignment: -1.0,
              child: FadeTransition(
                opacity: _contentOpacity,
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: widget.child,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
