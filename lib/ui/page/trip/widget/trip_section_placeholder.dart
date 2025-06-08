import 'package:flutter/cupertino.dart';

/// 通用section占位符组件
class TripSectionPlaceholder extends StatelessWidget {
  /// 图标
  final IconData icon;
  
  /// 标题
  final String title;
  
  /// 副标题
  final String subtitle;
  
  /// 按钮文本
  final String buttonText;
  
  /// 点击回调
  final VoidCallback onPressed;

  const TripSectionPlaceholder({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: CupertinoColors.separator,
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 48,
            color: CupertinoColors.systemGrey,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.label,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14,
              color: CupertinoColors.secondaryLabel,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          CupertinoButton.filled(
            child: Text(buttonText),
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }
}