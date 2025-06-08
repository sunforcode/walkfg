import 'package:flutter/cupertino.dart';
import 'package:walk/model/guide/guide_model.dart';
import 'package:walk/theme/theme/app_colors.dart';

/// 相关攻略组件
class GuideRelatedWidget extends StatelessWidget {
  final GuideModel guide;

  const GuideRelatedWidget({
    super.key,
    required this.guide,
  });

  @override
  Widget build(BuildContext context) {
    final relatedGuides = guide.relatedGuides ?? [];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: CupertinoColors.separator,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: CupertinoColors.separator,
                  width: 0.5,
                ),
              ),
            ),
            child: const Text(
              '📚 相关攻略',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.label,
              ),
            ),
          ),

          // 相关攻略内容
          Container(
            padding: const EdgeInsets.all(16),
            child: relatedGuides.isNotEmpty
                ? SizedBox(
                    height: 180,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: relatedGuides.length,
                      itemBuilder: (context, index) {
                        final relatedGuide = relatedGuides[index];
                        return _buildRelatedGuideCard(relatedGuide);
                      },
                    ),
                  )
                : _buildEmptyState(),
          ),
        ],
      ),
    );
  }

  /// 构建相关攻略卡片
  Widget _buildRelatedGuideCard(GuideModel relatedGuide) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: CupertinoColors.separator,
          width: 0.5,
        ),
      ),
      child: GestureDetector(
        onTap: () => print('导航到攻略: ${relatedGuide.title}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 图片
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Container(
                height: 100,
                width: double.infinity,
                child: relatedGuide.coverUrl != null
                    ? Image.network(
                        relatedGuide.coverUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildFallbackImage(),
                      )
                    : _buildFallbackImage(),
              ),
            ),

            // 内容
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    relatedGuide.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    relatedGuide.location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: CupertinoColors.secondaryLabel,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        CupertinoIcons.eye,
                        size: 12,
                        color: CupertinoColors.secondaryLabel,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatNumber(relatedGuide.views),
                        style: const TextStyle(
                          fontSize: 12,
                          color: CupertinoColors.secondaryLabel,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        relatedGuide.getDifficultyName(),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建占位图片
  Widget _buildFallbackImage() {
    return Container(
      color: AppColors.primary.withOpacity(0.1),
      child: Icon(
        CupertinoIcons.photo,
        size: 32,
        color: AppColors.primary.withOpacity(0.5),
      ),
    );
  }

  /// 构建空状态
  Widget _buildEmptyState() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.doc_text,
              size: 32,
              color: CupertinoColors.secondaryLabel,
            ),
            SizedBox(height: 8),
            Text(
              '暂无相关攻略',
              style: TextStyle(
                color: CupertinoColors.secondaryLabel,
                fontSize: 14,
              ),
            ),
          ],
        ),
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