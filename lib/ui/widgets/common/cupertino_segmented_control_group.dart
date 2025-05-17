import 'package:flutter/cupertino.dart';

/// 通用iOS风格分段控制组件
class CupertinoSegmentedControlGroup<T> extends StatelessWidget {
  /// 选项映射
  final Map<T, String> children;
  
  /// 当前选中值
  final T groupValue;
  
  /// 值变更回调
  final ValueChanged<T> onValueChanged;
  
  /// 未选中背景色
  final Color? backgroundColor;
  
  /// 选中背景色
  final Color? selectedColor;
  
  /// 未选中文本颜色
  final Color? unselectedTextColor;
  
  /// 选中文本颜色
  final Color? selectedTextColor;
  
  /// 内边距
  final EdgeInsetsGeometry padding;
  
  /// 构造函数
  const CupertinoSegmentedControlGroup({
    super.key,
    required this.children,
    required this.groupValue,
    required this.onValueChanged,
    this.backgroundColor,
    this.selectedColor,
    this.unselectedTextColor,
    this.selectedTextColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: CupertinoSegmentedControl<T>(
        children: Map.fromEntries(
          children.entries.map(
            (entry) => MapEntry(
              entry.key,
              Text(
                entry.value,
                style: TextStyle(
                  color: entry.key == groupValue
                    ? selectedTextColor
                    : unselectedTextColor,
                ),
              ),
            ),
          ),
        ),
        groupValue: groupValue,
        onValueChanged: onValueChanged,
        selectedColor: selectedColor ?? CupertinoColors.systemBlue,
      ),
    );
  }
}