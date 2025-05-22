import 'package:flutter/cupertino.dart';

/// 通用的标题组件
class SectionTitleWidget extends StatelessWidget {
  /// 标题文本
  final String title;
  
  /// 标题样式
  final TextStyle? style;
  
  /// 底部间距
  final double bottomSpacing;

  /// 构造函数
  const SectionTitleWidget({
    super.key,
    required this.title,
    this.style,
    this.bottomSpacing = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: style ?? const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: bottomSpacing),
      ],
    );
  }
}