import 'package:flutter/cupertino.dart';

/// 空视图组件
class EmptyView extends StatelessWidget {
  /// 图标
  final IconData icon;
  
  /// 标题
  final String title;
  
  /// 消息
  final String message;
  
  /// 按钮文本
  final String buttonText;
  
  /// 按钮点击回调
  final VoidCallback onButtonPressed;
  
  /// 构造函数
  const EmptyView({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.buttonText,
    required this.onButtonPressed,
  });
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 50,
            color: CupertinoColors.systemBlue,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: CupertinoColors.systemGrey,
              ),
            ),
          ),
          const SizedBox(height: 16),
          CupertinoButton.filled(
            child: Text(buttonText),
            onPressed: onButtonPressed,
          ),
        ],
      ),
    );
  }
}