import 'package:flutter/cupertino.dart';

/// 悬浮返回按钮组件
/// 可在任何需要返回功能的页面使用
class FloatingBackButton extends StatelessWidget {
  /// 点击回调，如果不提供则使用默认的Navigator.pop
  final VoidCallback? onPressed;

  /// 按钮图标，默认为返回图标
  final IconData icon;

  /// 按钮大小，默认为20
  final double iconSize;

  /// 按钮背景色，默认为半透明系统背景色
  final Color? backgroundColor;

  /// 图标颜色，默认为标签颜色
  final Color? iconColor;

  const FloatingBackButton({
    super.key,
    this.onPressed,
    this.icon = CupertinoIcons.back,
    this.iconSize = 20,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: const EdgeInsets.all(12),
      color: backgroundColor ??
          CupertinoColors.systemBackground.withValues(alpha: 0.9),
      borderRadius: BorderRadius.circular(25),
      minSize: 0,
      onPressed: onPressed ?? () => Navigator.of(context).pop(),
      child: Icon(
        icon,
        color: iconColor ?? CupertinoColors.label,
        size: iconSize,
      ),
    );
  }
}
