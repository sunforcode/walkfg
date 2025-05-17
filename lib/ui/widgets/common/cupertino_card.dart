import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// 通用iOS风格卡片组件
class CupertinoCard extends StatelessWidget {
  /// 子组件
  final Widget child;
  
  /// 内边距
  final EdgeInsetsGeometry padding;
  
  /// 阴影高度
  final double elevation;
  
  /// 边框圆角
  final double borderRadius;
  
  /// 背景颜色
  final Color? backgroundColor;
  
  /// 渐变背景
  final Gradient? gradient;
  
  /// 构造函数
  const CupertinoCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.elevation = 2,
    this.borderRadius = 16,
    this.backgroundColor,
    this.gradient,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          color: backgroundColor,
          gradient: gradient,
        ),
        child: child,
      ),
    );
  }
}