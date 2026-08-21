import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../theme/tokens/colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Loading
// ─────────────────────────────────────────────────────────────────────────────

class LoadingHome extends StatelessWidget {
  const LoadingHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 使用首页空态渐变背景保持视觉一致
        DecoratedBox(
          decoration: BoxDecoration(gradient: AppColors.gradientHome),
        ),
        const Center(child: CupertinoActivityIndicator(color: Colors.white)),
      ],
    );
  }
}
