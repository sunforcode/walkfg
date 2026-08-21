import 'package:flutter/cupertino.dart';
import 'package:walk/theme/tokens/colors.dart';

/// 未登录视图组件
class NotLoggedInView extends StatelessWidget {
  /// 点击登录的回调
  final VoidCallback onLoginPressed;

  /// 点击注册的回调
  final VoidCallback onRegisterPressed;

  /// 构造函数
  const NotLoggedInView({
    super.key,
    required this.onLoginPressed,
    required this.onRegisterPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(
            CupertinoIcons.person_crop_circle_badge_checkmark,
            size: 80,
            color: AppColors.statusCompletedText,
          ),
          const SizedBox(height: 40),
          const Text(
            'Walk',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            '徒步旅行助手',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          CupertinoButton(
            color: AppColors.interactiveAccent,
            child: const Text('登录'),
            onPressed: onLoginPressed,
          ),
          const SizedBox(height: 16),
          CupertinoButton(
            color: AppColors.surfaceCard,
            child: const Text(
              '注册',
              style: TextStyle(color: AppColors.interactiveAccent),
            ),
            onPressed: onRegisterPressed,
          ),
          const SizedBox(height: 40),
          const Text(
            '登录后可以使用更多功能',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSubtitle,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
