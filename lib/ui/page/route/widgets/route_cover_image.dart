import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../model/model/route/route_model.dart';
import '../../../../theme/theme/app_colors.dart';
import '../../../widgets/common/network_image_with_fallback.dart';

/// 封面图片组件
class RouteCoverImage extends StatelessWidget {
  final RouteModel route;

  const RouteCoverImage({
    super.key,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = route.coverUrl;

    return Container(
      height: 200,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 图片
          imageUrl != null
              ? NetworkImageWithFallback(
                  url: imageUrl,
                  fit: BoxFit.cover,
                  fallbackColor: AppColors.primary,
                  fallbackIcon: CupertinoIcons.map,
                )
              : Container(
                  color: AppColors.primary.withOpacity(0.2),
                  child: const Center(
                    child: Icon(
                      CupertinoIcons.map,
                      size: 64,
                      color: AppColors.primary,
                    ),
                  ),
                ),

          // 难度标签
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: route.getDifficultyColor(),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                route.getDifficultyName(),
                style: const TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // 季节标签
          Positioned(
            bottom: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: CupertinoColors.systemBlue.withOpacity(0.8),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                route.basicInfo.bestSeason.join(','),
                style: const TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}