import 'package:flutter/cupertino.dart';
import '../../theme/tokens/tokens.dart';

/// 底部操作栏组件
///
/// 用于详情页底部固定操作区，符合工具型应用的快速操作需求
///
/// 示例:
/// ```dart
/// ActionBar(
///   primary: ActionButton(
///     label: '开始导航',
///     onPressed: () => ...,
///   ),
///   secondary: [
///     ActionButton.icon(Icons.share, onPressed: ...),
///     ActionButton.icon(Icons.bookmark, onPressed: ...),
///   ],
/// )
/// ```
class ActionBar extends StatelessWidget {
  /// 主操作按钮
  final ActionButton primary;

  /// 次要操作按钮列表（可选）
  final List<ActionButton>? secondary;

  /// 背景颜色（可选）
  final Color? backgroundColor;

  /// 是否显示阴影
  final bool showShadow;

  const ActionBar({
    super.key,
    required this.primary,
    this.secondary,
    this.backgroundColor,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surface,
        boxShadow: showShadow ? AppShadows.topNav : null,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              // 主操作按钮
              Expanded(
                child: primary,
              ),

              // 次要操作按钮
              if (secondary != null && secondary!.isNotEmpty) ...[
                const SizedBox(width: AppSpacing.sm),
                ...secondary!.map((button) {
                  return Padding(
                    padding: const EdgeInsets.only(left: AppSpacing.sm),
                    child: button,
                  );
                }),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// 操作按钮
class ActionButton extends StatelessWidget {
  /// 按钮文字（主按钮必需）
  final String? label;

  /// 图标（图标按钮必需）
  final IconData? icon;

  /// 点击回调
  final VoidCallback? onPressed;

  /// 加载状态
  final bool isLoading;

  /// 禁用状态
  final bool isDisabled;

  /// 按钮类型
  final ActionButtonType type;

  /// 按钮大小
  final ActionButtonSize size;

  const ActionButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.type = ActionButtonType.primary,
    this.size = ActionButtonSize.medium,
  });

  /// 图标按钮构造
  const ActionButton.icon(
    this.icon, {
    super.key,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.type = ActionButtonType.secondary,
    this.size = ActionButtonSize.medium,
  }) : label = null;

  @override
  Widget build(BuildContext context) {
    final bool enabled = !isDisabled && !isLoading && onPressed != null;

    // 图标按钮
    if (label == null && icon != null) {
      return _buildIconButton(enabled);
    }

    // 文字按钮
    return _buildTextButton(enabled);
  }

  /// 构建图标按钮
  Widget _buildIconButton(bool enabled) {
    final double buttonSize = size == ActionButtonSize.large ? 48.0 : 44.0;

    return CupertinoButton(
      padding: EdgeInsets.zero,
      minSize: buttonSize,
      onPressed: enabled ? onPressed : null,
      child: Container(
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          color: _getBackgroundColor(enabled),
          borderRadius: AppRadius.borderMd,
          border: type == ActionButtonType.secondary
              ? Border.all(
                  color: enabled ? AppColors.border : AppColors.disabled,
                  width: 1,
                )
              : null,
        ),
        child: Center(
          child: isLoading
              ? CupertinoActivityIndicator(
                  color: _getContentColor(enabled),
                )
              : Icon(
                  icon,
                  color: _getContentColor(enabled),
                  size: 20,
                ),
        ),
      ),
    );
  }

  /// 构建文字按钮
  Widget _buildTextButton(bool enabled) {
    final double buttonHeight = size == ActionButtonSize.large ? 50.0 : 44.0;

    return CupertinoButton(
      padding: EdgeInsets.zero,
      minSize: buttonHeight,
      onPressed: enabled ? onPressed : null,
      child: Container(
        height: buttonHeight,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: _getBackgroundColor(enabled),
          borderRadius: AppRadius.borderMd,
          border: type == ActionButtonType.secondary
              ? Border.all(
                  color: enabled ? AppColors.primary : AppColors.disabled,
                  width: 1,
                )
              : null,
        ),
        child: Center(
          child: isLoading
              ? CupertinoActivityIndicator(
                  color: _getContentColor(enabled),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(
                        icon,
                        color: _getContentColor(enabled),
                        size: 18,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                    ],
                    Text(
                      label!,
                      style: AppTypography.button.copyWith(
                        color: _getContentColor(enabled),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  /// 获取背景颜色
  Color _getBackgroundColor(bool enabled) {
    if (!enabled) {
      return AppColors.disabled;
    }

    switch (type) {
      case ActionButtonType.primary:
        return AppColors.primary;
      case ActionButtonType.secondary:
        return AppColors.surface;
      case ActionButtonType.danger:
        return AppColors.error;
    }
  }

  /// 获取内容颜色
  Color _getContentColor(bool enabled) {
    if (!enabled) {
      return AppColors.textDisabled;
    }

    switch (type) {
      case ActionButtonType.primary:
        return AppColors.onPrimary;
      case ActionButtonType.secondary:
        return AppColors.primary;
      case ActionButtonType.danger:
        return AppColors.onPrimary;
    }
  }
}

/// 按钮类型
enum ActionButtonType {
  /// 主按钮
  primary,

  /// 次要按钮
  secondary,

  /// 危险操作按钮
  danger,
}

/// 按钮大小
enum ActionButtonSize {
  /// 中等
  medium,

  /// 大号
  large,
}
