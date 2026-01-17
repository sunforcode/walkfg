import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:walk/theme/tokens/tokens.dart';

/// 错误卡片
class ErrorCard extends StatelessWidget {
  final String error;
  final Future<void> Function()? onRetry;

  const ErrorCard({
    Key? key,
    required this.error,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEF5350), Color(0xFFC62828)],
        ),
        borderRadius: const BorderRadius.all(Radius.circular(16.0)),
        boxShadow: [
BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: AppColors.textOnDark,
              size: 48,
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              '加载失败: $error',
              style: const TextStyle(
                color: AppColors.textOnDark,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              SizedBox(height: AppSpacing.md),
              CupertinoButton(
                padding: EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: AppSpacing.xs,
                ),
                color: AppColors.textOnDark.withOpacity(0.3),
                child: const Text(
                  '重试',
                  style: TextStyle(
                    color: AppColors.textOnDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: onRetry,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
