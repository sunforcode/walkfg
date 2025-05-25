import 'package:flutter/material.dart';
import '../../../theme/theme/app_colors.dart';

/// 通用错误提示组件
class ErrorMessageWidget extends StatelessWidget {
  /// 错误信息
  final String errorMessage;
  
  /// 重试回调
  final VoidCallback onRetry;
  
  /// 颜色
  final Color? color;
  
  /// 构造函数
  const ErrorMessageWidget({
    super.key,
    required this.errorMessage,
    required this.onRetry,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final displayColor = color ?? AppColors.error;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: displayColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: displayColor.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            color: displayColor,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: TextStyle(color: displayColor.withOpacity(0.8)),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(
              foregroundColor: displayColor,
              backgroundColor: displayColor.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }
}