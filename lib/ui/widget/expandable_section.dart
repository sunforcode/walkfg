import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../theme/tokens/tokens.dart';

/// 可展开/折叠的区块组件
///
/// 用于详情页的折叠内容，符合工具型应用的渐进式信息展示
///
/// 示例:
/// ```dart
/// ExpandableSection(
///   title: '详细信息',
///   initiallyExpanded: false,
///   child: Column(
///     children: [
///       Text('详细内容...'),
///     ],
///   ),
/// )
/// ```
class ExpandableSection extends StatefulWidget {
  /// 标题
  final String title;

  /// 初始展开状态
  final bool initiallyExpanded;

  /// 子内容
  final Widget child;

  /// 标题样式（可选）
  final TextStyle? titleStyle;

  /// 内边距（可选）
  final EdgeInsets? padding;

  /// 是否显示分割线
  final bool showDivider;

  /// 展开/折叠状态变化回调（可选）
  final ValueChanged<bool>? onExpansionChanged;

  const ExpandableSection({
    super.key,
    required this.title,
    this.initiallyExpanded = false,
    required this.child,
    this.titleStyle,
    this.padding,
    this.showDivider = true,
    this.onExpansionChanged,
  });

  @override
  State<ExpandableSection> createState() => _ExpandableSectionState();
}

class _ExpandableSectionState extends State<ExpandableSection>
    with SingleTickerProviderStateMixin {
  late bool _isExpanded;
  late AnimationController _controller;
  late Animation<double> _iconRotation;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _iconRotation = Tween<double>(
      begin: 0.0,
      end: 0.5,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
    if (_isExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 标题栏
        CupertinoButton(
          padding: widget.padding ??
              const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
          onPressed: _toggleExpanded,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.title,
                  style: widget.titleStyle ?? AppTypography.titleMedium,
                ),
              ),
              RotationTransition(
                turns: _iconRotation,
                child: const Icon(
                  CupertinoIcons.chevron_down,
                  size: 20,
                  color: AppColors.iconSecondary,
                ),
              ),
            ],
          ),
        ),

        // 内容区
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: _isExpanded
              ? Padding(
                  padding: widget.padding ??
                      const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                  child: widget.child,
                )
              : const SizedBox.shrink(),
        ),

        // 分割线
        if (widget.showDivider)
          const Divider(
            height: 1,
            thickness: 1,
            color: AppColors.divider,
          ),
      ],
    );
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
      widget.onExpansionChanged?.call(_isExpanded);
    });
  }
}
