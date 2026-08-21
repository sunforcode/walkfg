import 'dart:ui';

import 'package:flutter/cupertino.dart';

import '../../../../theme/tokens/colors.dart';
// ─────────────────────────────────────────────────────────────────────────────
// Error
// ─────────────────────────────────────────────────────────────────────────────

class ErrorHome extends StatelessWidget {
  final VoidCallback onRetry;
  final VoidCallback onChange;
  const ErrorHome({super.key, required this.onRetry, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 使用首页空态渐变背景保持视觉一致
        DecoratedBox(
          decoration: BoxDecoration(gradient: AppColors.gradientHome),
        ),
        SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(CupertinoIcons.exclamationmark_triangle,
                      color: AppColors.accentBlue, size: 42),
                  const SizedBox(height: 18),
                  const Text('当前路线加载失败',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Color(0xFFFFFFFF),
                          fontSize: 24,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  Text('可以重试，或者换一条路线。',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppColors.textBody,
                          fontSize: 15)),
                  const SizedBox(height: 26),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _GlassButton(
                        label: '重试',
                        onTap: onRetry,
                      ),
                      const SizedBox(width: 12),
                      _GlassButton(
                        label: '更换路线',
                        onTap: onChange,
                        accent: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// 毛玻璃按钮 — 复用 P1 CTA 视觉语言
class _GlassButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool accent;

  const _GlassButton({
    required this.label,
    required this.onTap,
    this.accent = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: accent
                  ? AppColors.interactiveCta
                  : const Color(0x0AFFFFFF),
              borderRadius: BorderRadius.circular(50),
              border: Border.all(
                color: accent
                    ? AppColors.interactiveCtaBorder
                    : AppColors.surfaceCardBorder,
                width: 1,
              ),
            ),
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFFFFFFFF),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
