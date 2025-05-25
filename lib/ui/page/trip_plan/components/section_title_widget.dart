import 'package:flutter/cupertino.dart';

/// 部分标题组件
class SectionTitleWidget extends StatelessWidget {
  /// 标题文本
  final String title;

  /// 构造函数
  const SectionTitleWidget({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}