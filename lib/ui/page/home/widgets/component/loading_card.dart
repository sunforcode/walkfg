import 'package:flutter/cupertino.dart';
import 'package:walk/theme/tokens/colors.dart';
import 'package:walk/theme/tokens/radius.dart';

/// 加载中的卡片
class LoadingCard extends StatelessWidget {
  const LoadingCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        gradient: AppColors.gradientCta,
        borderRadius: AppRadius.borderPanel,
        boxShadow: [
          BoxShadow(
            color: AppColors.surfaceOverlay,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Center(
        child: CupertinoActivityIndicator(
          color: AppColors.textPrimary,
          radius: 16,
        ),
      ),
    );
  }
}
