import 'package:flutter/cupertino.dart';
import 'package:walk/model/guide/guide_model.dart';
import 'package:walk/theme/theme/app_colors.dart';

/// 攻略封面组件
class GuideCoverWidget extends StatelessWidget {
  final GuideModel guide;

  const GuideCoverWidget({
    super.key,
    required this.guide,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 背景图片
          _buildCoverImage(),

          // 渐变遮罩
          _buildGradientOverlay(),

          // 标签
          if (guide.tags.isNotEmpty) _buildTagBadge(),

          // 底部信息
          _buildBottomInfo(),
        ],
      ),
    );
  }

  /// 构建封面图片
  Widget _buildCoverImage() {
    return Hero(
      tag: 'guide_image_${guide.id}',
      child: guide.coverUrl != null
          ? Image.network(
              guide.coverUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _buildFallbackImage(),
            )
          : _buildFallbackImage(),
    );
  }

  /// 构建占位图片
  Widget _buildFallbackImage() {
    return Container(
      color: AppColors.primary.withOpacity(0.2),
      child: const Center(
        child: Icon(
          CupertinoIcons.photo,
          size: 64,
          color: AppColors.primary,
        ),
      ),
    );
  }

  /// 构建渐变遮罩
  Widget _buildGradientOverlay() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              CupertinoColors.black.withOpacity(0.0),
              CupertinoColors.black.withOpacity(0.7),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建标签徽章
  Widget _buildTagBadge() {
    return Positioned(
      top: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          guide.tags.first,
          style: const TextStyle(
            color: CupertinoColors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// 构建底部信息
  Widget _buildBottomInfo() {
    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: Row(
        children: [
          // 难度指示
          _buildInfoBadge(
            icon: CupertinoIcons.chart_bar_alt_fill,
            text: guide.getDifficultyName(),
          ),
          const SizedBox(width: 8),
          // 阅读时长
          _buildInfoBadge(
            icon: CupertinoIcons.time,
            text: guide.getReadingTimeText(),
          ),
          const Spacer(),
          // 阅读量
          _buildInfoBadge(
            icon: CupertinoIcons.eye,
            text: _formatNumber(guide.views),
          ),
        ],
      ),
    );
  }

  /// 构建信息徽章
  Widget _buildInfoBadge({
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: CupertinoColors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: CupertinoColors.white,
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: CupertinoColors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  /// 格式化数字
  String _formatNumber(int number) {
    if (number >= 1000) {
      final double result = number / 1000;
      return '${result.toStringAsFixed(1)}k';
    }
    return number.toString();
  }
}