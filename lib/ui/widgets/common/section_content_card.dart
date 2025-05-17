import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'section_header.dart';

/// 通用内容区块卡片组件
class SectionContentCard extends StatelessWidget {
  /// 标题
  final String title;
  
  /// 操作按钮文本
  final String? actionText;
  
  /// 操作按钮回调
  final VoidCallback? onAction;
  
  /// 内容
  final Widget content;
  
  /// 内边距
  final EdgeInsetsGeometry padding;
  
  /// 内容与标题的间距
  final double spacing;
  
  /// 构造函数
  const SectionContentCard({
    super.key,
    required this.title,
    this.actionText,
    this.onAction,
    required this.content,
    this.padding = const EdgeInsets.all(16),
    this.spacing = 16,
  });
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: title,
            actionText: actionText,
            onAction: onAction,
          ),
          SizedBox(height: spacing),
          content,
        ],
      ),
    );
  }
}