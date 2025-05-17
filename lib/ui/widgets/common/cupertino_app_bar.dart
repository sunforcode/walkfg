import 'package:flutter/cupertino.dart';

/// 通用iOS风格导航栏组件
class CupertinoAppBar extends StatelessWidget {
  /// 标题
  final String title;
  
  /// 背景颜色
  final Color? backgroundColor;
  
  /// 右侧操作按钮
  final List<Widget>? actions;
  
  /// 左侧按钮
  final Widget? leading;
  
  /// 是否自动添加返回按钮
  final bool automaticallyImplyLeading;
  
  /// 构造函数
  const CupertinoAppBar({
    super.key,
    required this.title,
    this.backgroundColor,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
  });
  
  @override
  Widget build(BuildContext context) {
    return CupertinoNavigationBar(
      middle: Text(title),
      backgroundColor: backgroundColor,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      trailing: actions != null && actions!.isNotEmpty
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: actions!,
          )
        : null,
    );
  }
}