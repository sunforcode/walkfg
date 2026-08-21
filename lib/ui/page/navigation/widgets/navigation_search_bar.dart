import 'package:flutter/cupertino.dart';

/// 导航页面搜索栏组件
class NavigationSearchBar extends StatelessWidget {
  /// 搜索控制器
  final TextEditingController controller;

  /// 提交搜索时的回调
  final ValueChanged<String> onSubmitted;

  /// 构造函数
  const NavigationSearchBar({
    super.key,
    required this.controller,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: CupertinoSearchTextField(
        controller: controller,
        placeholder: '搜索路线名称或地点...',
        onSubmitted: onSubmitted,
      ),
    );
  }
}
