import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:walk/service/route_service.dart';
import '../../../../model/model/route/route_model.dart';
import '../../../../theme/theme/app_colors.dart';
import '../../../widgets/common/network_image_with_fallback.dart';

/// 路线详情页头部组件
class RouteHeader extends StatelessWidget {
  /// 路线数据
  final RouteModel route;

  /// 评分数据
  final Map<String, dynamic> ratings;

  /// 标签列表
  final List<String> tags;

  /// 构造函数
  const RouteHeader({
    super.key,
    required this.route,
    required this.ratings,
    required this.tags,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: CupertinoColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 封面图片
          _buildCoverImage(),

          // 路线名称
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              route.name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // 评分和完成率
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                _buildRatingStars(ratings['overall'] ?? 0.0),
                const SizedBox(width: 8),
                Text(
                  '${ratings['overall']?.toStringAsFixed(1) ?? '0.0'}(${ratings['reviewCount'] ?? 0}评价)',
                  style: const TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                const Spacer(),
                Text(
                  '完成率:${(ratings['completionRate'] ?? 0.0).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.activeBlue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // 基本信息
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoChip('难度:${route.basicInfo.difficulty}',
                    route.getDifficultyColor()!),
                _buildInfoChip(
                  '距离:${route.basicInfo.distance}km',
                  CupertinoColors.systemBlue,
                ),
                _buildInfoChip(
                  '爬升:${route.basicInfo.elevationGain}m',
                  CupertinoColors.systemOrange,
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoChip(
                  '推荐天数:${route.basicInfo.duration}天',
                  CupertinoColors.systemIndigo,
                ),
                _buildInfoChip(
                  '最佳季节:${route.basicInfo.bestSeason}',
                  CupertinoColors.systemTeal,
                ),
              ],
            ),
          ),

          // 标签
          if (tags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: tags.map((tag) => _buildTag(tag)).toList(),
              ),
            ),

          const Divider(height: 1),
        ],
      ),
    );
  }

  /// 构建封面图片
  Widget _buildCoverImage() {
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
                "难",
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

  /// 构建评分星星
  Widget _buildRatingStars(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return const Icon(CupertinoIcons.star_fill,
              size: 16, color: CupertinoColors.systemYellow);
        } else if (index < rating.ceil() && rating.floor() != rating.ceil()) {
          return const Icon(CupertinoIcons.star_lefthalf_fill,
              size: 16, color: CupertinoColors.systemYellow);
        } else {
          return const Icon(CupertinoIcons.star,
              size: 16, color: CupertinoColors.systemYellow);
        }
      }),
    );
  }

  /// 构建信息芯片
  Widget _buildInfoChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// 构建标签
  Widget _buildTag(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey5,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '#$tag',
        style: const TextStyle(
          fontSize: 12,
          color: CupertinoColors.systemGrey,
        ),
      ),
    );
  }
}
