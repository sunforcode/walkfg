import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// 通用iOS风格列表项组件
class CupertinoListTile extends StatelessWidget {
  /// 标题
  final String title;
  
  /// 副标题
  final String? subtitle;
  
  /// 前置图标
  final IconData? leading;
  
  /// 前置组件
  final Widget? leadingWidget;
  
  /// 后置图标
  final IconData? trailing;
  
  /// 后置组件
  final Widget? trailingWidget;
  
  /// 点击回调
  final VoidCallback? onTap;
  
  /// 长按回调
  final VoidCallback? onLongPress;
  
  /// 内边距
  final EdgeInsetsGeometry padding;
  
  /// 背景颜色
  final Color? backgroundColor;
  
  /// 前置图标颜色
  final Color? leadingColor;
  
  /// 后置图标颜色
  final Color? trailingColor;
  
  /// 构造函数
  const CupertinoListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.leadingWidget,
    this.trailing,
    this.trailingWidget,
    this.onTap,
    this.onLongPress,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.backgroundColor,
    this.leadingColor,
    this.trailingColor,
  }) : assert(leading == null || leadingWidget == null, '不能同时设置leading和leadingWidget'),
       assert(trailing == null || trailingWidget == null, '不能同时设置trailing和trailingWidget');
  
  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        padding: padding,
        color: backgroundColor ?? CupertinoColors.systemBackground,
        child: Row(
          children: [
            if (leading != null)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Icon(
                  leading,
                  color: leadingColor ?? CupertinoColors.systemBlue,
                  size: 24,
                ),
              ),
            if (leadingWidget != null)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: leadingWidget!,
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 14,
                        color: CupertinoColors.systemGrey.resolveFrom(context),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null)
              Icon(
                trailing,
                color: trailingColor ?? CupertinoColors.systemGrey,
                size: 20,
              ),
            if (trailingWidget != null)
              trailingWidget!,
          ],
        ),
      ),
    );
  }
}